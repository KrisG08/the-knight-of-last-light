-- Actual RPC validation under a read-only transaction: no journeys can be written.
begin read only;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000001',true);
do $check$
declare
  item jsonb;
  observed text;
  errors text[] := '{}';
begin
  if current_setting('transaction_read_only') <> 'on' then
    raise exception 'This regression must run read only';
  end if;
  for item in select value from jsonb_array_elements('[
    {"version":1,"expected":"25006"},{"version":1.0,"expected":"25006"},
    {"version":8,"expected":"25006"},{"version":8.0,"expected":"25006"},
    {"version":0,"expected":"22023"},{"version":9,"expected":"22023"},
    {"version":8.5,"expected":"22023"},{"version":"8","expected":"22023"},
    {"version":null,"expected":"22023"},{"version":true,"expected":"22023"},
    {"version":{},"expected":"22023"},{"version":[],"expected":"22023"}
  ]'::jsonb) loop
    observed := 'unexpected success';
    begin
      perform public.commit_last_light_journey(
        '00000000-0000-4000-8000-000000000002',0,
        jsonb_build_object('schema_version',item->'version','slot_id',1,
          'character','{}'::jsonb,'campaign','{}'::jsonb,'recovery','{}'::jsonb),
        repeat('a',64));
    exception when others then
      get stacked diagnostics observed = returned_sqlstate;
    end;
    -- Valid versions reach INSERT, which the read-only guard rejects with 25006.
    -- Invalid versions must fail earlier in the actual RPC with 22023.
    if observed <> item->>'expected' then
      errors := array_append(errors,format('%s expected %s got %s',item->'version',item->>'expected',observed));
    end if;
  end loop;
  perform set_config('last_light.schema_wire_result',
    case when cardinality(errors)=0 then 'PASS: 12 actual RPC schema-number cases; zero writes'
    else 'FAIL: ' || array_to_string(errors,'; ') end,true);
end $check$;
select current_setting('last_light.schema_wire_result') as schema_wire_result;
rollback;

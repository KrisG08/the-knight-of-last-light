-- Preserve existing rows, RLS policies and RPC grants. Accept integral JSON numbers.
create or replace function public.commit_last_light_journey(
  p_id uuid, p_expected_revision bigint, p_snapshot jsonb, p_content_hash text
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  player uuid := auth.uid();
  next_revision bigint;
begin
  if player is null then raise exception 'Authentication required' using errcode='42501'; end if;
  if p_id is null or p_expected_revision is null or p_expected_revision < 0
     or p_content_hash is null or p_content_hash !~ '^[a-f0-9]{64}$'
     or p_snapshot is null or jsonb_typeof(p_snapshot) <> 'object'
     or octet_length(p_snapshot::text) > 2097152
     or not (p_snapshot ? 'schema_version')
     or not (case when jsonb_typeof(p_snapshot->'schema_version') = 'number'
       then (p_snapshot->>'schema_version')::numeric in (1,2,3,4,5,6,7,8)
       else false end)
     or not (p_snapshot ?& array['character','campaign','recovery','slot_id'])
  then raise exception 'Invalid journey snapshot' using errcode='22023'; end if;
  if p_expected_revision = 0 then
    insert into public.last_light_journeys(id,owner_id,revision,snapshot,content_hash)
      values(p_id,player,1,p_snapshot,p_content_hash)
      on conflict (id) do nothing returning revision into next_revision;
  else
    update public.last_light_journeys
      set snapshot=p_snapshot, content_hash=p_content_hash, revision=revision+1, updated_at=now()
      where id=p_id and owner_id=player and revision=p_expected_revision
      returning revision into next_revision;
  end if;
  if next_revision is null then raise exception 'Journey changed on another device' using errcode='40001'; end if;
  return jsonb_build_object('revision',next_revision);
end;
$$;

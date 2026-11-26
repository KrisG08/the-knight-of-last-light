import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
const source = await readFile(new URL('../backend/supabase/functions/account-confirmation/index.ts', import.meta.url), 'utf8');
const { handleRequest } = await import('data:text/javascript;base64,' + Buffer.from(source).toString('base64'));
const base = 'https://vtvvevevkhqwyemrpawy.supabase.co/functions/v1/account-confirmation';
const first = handleRequest(new Request(base + '?token=fixture-do-not-echo#access_token=fixture'));
assert.equal(first.status, 303);
assert.equal(first.headers.get('location'), base + '?view=return#last-light');
assert(!first.headers.get('location').includes('fixture'));
for (const [language, phrase] of Object.entries({ en:'RETURN TO THE GAME', bg:'ВЪРНЕТЕ СЕ В ИГРАТА', ru:'ВЕРНИТЕСЬ В ИГРУ', fr:'RETOURNEZ DANS LE JEU', ar:'عُد إلى اللعبة' })) {
  const response = handleRequest(new Request(base + '?view=return&email=fixture@example.invalid', { headers:{ 'accept-language':language + '-XX,en;q=0.5' } }));
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(response.headers.get('referrer-policy'), 'no-referrer');
  assert.match(response.headers.get('content-type'), /^text\/plain/);
  const text = await response.text();
  assert(text.includes(phrase));
  assert(!text.includes('fixture'));
}
assert.equal(handleRequest(new Request(base, {method:'POST',body:'fixture'})).status,405);
assert.equal(await handleRequest(new Request(base+'?view=return',{method:'HEAD'})).text(),'');
assert((await handleRequest(new Request(base+'?view=return',{headers:{'accept-language':'de'}})).text()).includes('RETURN TO THE GAME'));
console.log('Confirmation return page: fixed-origin fragment replacement, five languages, no echo, no cache, HEAD/POST checks PASS');

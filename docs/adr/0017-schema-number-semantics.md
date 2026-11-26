# Integral JSON schema versions across transports

Accepted 2026-11-08 after a live cloud upload failure.

Godot parses JSON numbers as floats. A loaded version-eight save is sent as
`schema_version: 8.0`, while a newly constructed snapshot can contain `8`.
The client validator accepts either integral number. PostgreSQL jsonb preserves
the decimal representation in text, so the original regex on `->>` rejected
valid loaded saves. It also incorrectly accepted the string `"8"`.

At the server boundary, require a JSON number whose numeric value is one of
the supported integral schema versions 1 through 8. Reject strings, fractions,
booleans, null, objects and arrays. Do not rewrite snapshots or hashes merely
to work around textual numeric formatting. Keep owner checks, revision CAS,
RLS and RPC grants unchanged. The corrective migration replaces only the RPC.

The live RPC regression runs inside a read-only transaction with a fixture
identity. Accepted versions reach an INSERT forbidden by that transaction;
invalid versions must fail earlier with the validation error. This exercises
the real routine while guaranteeing zero persistent test writes.

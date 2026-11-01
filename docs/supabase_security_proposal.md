# Supabase Security Proposal

This document separates what the Flutter client currently does from what must
be verified or implemented in Supabase. No SQL migrations or policies were
found in this repository, and this proposal must not be applied to production
without checking the live schema.

## Client-Observed Contract

The client reads these tables:

- `profiles`, keyed by the authenticated user id (`profiles.id`)
- `accounts`, filtered by `accounts.user_id`
- `transactions`, filtered by `transactions.user_id`, with `account_id` and
  an optional category relationship
- `categories`, read for transaction entry
- `bills`, filtered by `bills.user_id`

It also calls `create_wallet_transactions(p_account_id, p_transactions)` and
`pay_wallet_bill(p_bill_id, p_account_id)`. The RPC bodies and live schema were
not available for review.

## Required Verification

1. Confirm every table and column used by the client exists with the expected
   type and nullability.
2. Confirm account, transaction, bill, and profile foreign keys point to the
   intended user-owned records.
3. Confirm both RPCs use `SECURITY INVOKER` where appropriate or explicitly
   re-check `auth.uid()` and ownership when elevated privileges are required.
4. Confirm transaction creation and balance changes happen in one database
   transaction. Client-side sequential balance updates are not atomic.
5. Add an integration test that proves one user cannot select, mutate, or pay
   another user's records.

## Policy Shape

The intended policy shape is:

```sql
-- Adapt names and columns only after checking the live schema.
using (auth.uid() = user_id)
with check (auth.uid() = user_id)
```

For `profiles`, use the actual ownership column. For transactions, an insert
policy should additionally ensure the selected account belongs to
`auth.uid()`; do not rely on a client-supplied `user_id`. Categories may be
public read-only reference data, but that must be an explicit product choice.

## Balance Integrity

`create_wallet_transactions` is already the client entry point for batch
creation. The Flutter client now calls the proposed
`delete_wallet_transaction(uuid)` RPC instead of deleting a row and updating a
balance in separate requests. The migration is still only a proposal. Do not
disable RLS or trust amount, account, bill, or user values supplied by the
client.

Before deployment, inspect the live database for triggers on `transactions` and
`accounts`. If a trigger already adjusts balances on delete, the function must
be changed to use that trigger or the trigger must be removed through an
approved migration; running both would double-adjust the balance.

## Deployment Steps

From the repository root, after installing and authenticating the Supabase
CLI:

```sh
supabase link --project-ref kjxffcmjpiaapqihnesz
supabase db diff --linked
supabase functions deploy parse-expense --project-ref kjxffcmjpiaapqihnesz
supabase secrets set GEMINI_API_KEY='<value entered locally>' --project-ref kjxffcmjpiaapqihnesz
supabase db push --linked
```

Review the generated diff and the migration against the live schema before
`supabase db push`. Do not put the key in shell history if that is a concern;
set it through the Supabase dashboard under Edge Function secrets instead.
Verify the function requires a user JWT, the RPC is executable only by the
`authenticated` role, and cross-user deletion returns no data change.

## Gemini Proxy

The client now calls the prepared Edge Function. A production deployment must:

1. Requires a valid user access token.
2. Validates the request transcript and size.
3. Reads `GEMINI_API_KEY` from Supabase function secrets.
4. Calls Gemini server-side and returns a strict validated response.
5. Applies rate limits and maps upstream errors to safe client messages.

After deployment, verify the function URL, JWT validation, rate limits, and
safe error mapping from a test account. Deployment requires Supabase CLI login
or dashboard access, which was not available for this audit.
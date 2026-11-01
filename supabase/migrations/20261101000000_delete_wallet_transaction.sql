-- Review against the live schema and existing triggers before deployment.
-- This file is a deployment proposal; it has not been applied to Supabase.

create or replace function public.delete_wallet_transaction(p_transaction_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_transaction public.transactions%rowtype;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select *
    into selected_transaction
    from public.transactions
   where id = p_transaction_id
     and user_id = auth.uid()
   for update;

  if not found then
    raise exception 'transaction not found';
  end if;

  delete from public.transactions
   where id = selected_transaction.id
     and user_id = auth.uid();

  update public.accounts
     set balance = balance + case
       when selected_transaction.type = 'income' then -selected_transaction.amount
       else selected_transaction.amount
     end
   where id = selected_transaction.account_id
     and user_id = auth.uid();

  if not found then
    raise exception 'wallet account not found';
  end if;
end;
$$;

revoke all on function public.delete_wallet_transaction(uuid) from public;
grant execute on function public.delete_wallet_transaction(uuid) to authenticated;
# Implementation Notes

## Design
Three tables (customers, accounts, transactions) with primary keys,
foreign keys and CHECK constraints, so the database itself rejects bad
data. The transactions table is both an audit log and the place where
failures are recorded.

## Records and Collections
`apply_monthly_interest` defines a record type (account_id, balance) and
a nested table of that record. Rows are loaded into the collection in one
fetch, then processed from memory.

## Cursors
- **Implicit:** `SELECT INTO`, `UPDATE`, `INSERT` and `DELETE` statements.
  `SQL%FOUND`, `SQL%NOTFOUND` and `SQL%ROWCOUNT` report the outcome.
- **Explicit:** `c_savings_accounts` uses OPEN, FETCH and CLOSE to get
  the savings accounts that need interest.

## Bulk Processing and Performance
Row-by-row processing runs a loop where every iteration switches between
the PL/SQL engine and the SQL engine (a context switch). With thousands of
accounts, those switches dominate the run time.
`BULK COLLECT` fetches all rows in one switch, and `FORALL` sends all
updates to the SQL engine in one switch, so it is much faster at scale.
With `SAVE EXCEPTIONS`, one bad row does not stop the batch. Failures are
collected in `SQL%BULK_EXCEPTIONS` and reported afterwards.
The trade-off is memory: very large collections should be fetched in
chunks using `BULK COLLECT ... LIMIT`.

## Exception Handling
- Predefined: `NO_DATA_FOUND`, `TOO_MANY_ROWS`.
- User-defined: `e_insufficient_funds`, `e_invalid_type`.
- `RAISE_APPLICATION_ERROR` codes -20001 to -20006 give clear messages.
- Our own errors are re-raised, never hidden, and unexpected errors
  become -20099 with `SQLERRM`.
- On failure the transaction is rolled back, and insufficient-funds
  failures are logged in `bank_transactions` as FAILED.

## Concurrency
`SELECT ... FOR UPDATE` locks the account row so two withdrawals cannot
read the same balance at the same time.

## Limitations
No transfer between accounts yet (no destination account column).

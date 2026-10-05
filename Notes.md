# Notes

## Summary of changes
- **SQL (H2 repository, `db/queries`, Oracle package):** fixed AND/OR precedence in the search WHERE clause. Archived tasks were leaking in (e.g. #20, #21 for `q=api`) and the status filter was ignored for title matches. Added `id DESC` as a sort tiebreaker.
- **Backend:** removed an artificial `Thread.sleep`; invalid `status` now returns 400 instead of 500; `page` and `pageSize` are clamped (page >= 1, pageSize 1-100).
- **Frontend:** fixed a race condition with `AbortController`; loading is reset and the error cleared properly; page resets to 1 when filters change; added a 300 ms search debounce; removed `console.log`; replaced the magic number 10 with `PAGE_SIZE`.

Detailed explanations are in `handwritten/`.

## What I chose not to change
- In-memory pagination: fine for ~50 rows, and a DB-level rewrite would make the diff large.
- LIKE wildcard escaping (`%`, `_`), DB indexes, and tests.
- Hardcoded `@CrossOrigin`, `show-sql` and the H2 console (fine for an exercise, not for production).
- Oracle `ROWNUM` pagination (could use `OFFSET/FETCH` on 12c+).

## Biggest remaining risk
The backend loads every matching row and paginates in Java, with no indexes and no tests. It will slow down badly with a large table, and the next query edit could silently reintroduce a bug like the precedence one.

## Tools / AI used
I used Claude to scan the codebase, list candidate issues and draft the fixes. I ran the app myself, reproduced the bugs with curl (archived tasks appearing, 500 on `status=foo` and `page=0`), applied the patches and re-tested. The handwritten notes are my own.

## Assumptions
- Max page size is 100.
- An unknown status is a client error (400).
- Search debounce of 300 ms is acceptable.
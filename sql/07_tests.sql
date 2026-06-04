-- 07_tests.sql
-- Validation tests for procedures, functions and triggers.
-- The transaction is rolled back at the end so the tests can be run repeatedly.

BEGIN;

CREATE TEMP TABLE test_context (
    created_loan_id INTEGER,
    late_loan_id    INTEGER
) ON COMMIT DROP;

-- Test 1: check availability.
SELECT library.is_book_available(1) AS is_book_1_available;

-- Test 2: create a loan and store the exact loan id created by the procedure.
CALL library.create_loan(3, 2, 1, CURRENT_DATE + 14);

INSERT INTO test_context (created_loan_id)
SELECT loan_id
FROM library.loans
WHERE book_id = 3
  AND reader_id = 2
  AND employee_id = 1
  AND loan_date = CURRENT_DATE
  AND due_date = CURRENT_DATE + 14
  AND status = 'active'
ORDER BY loan_id DESC
LIMIT 1;

SELECT l.*
FROM library.loans l
JOIN test_context tc ON tc.created_loan_id = l.loan_id;

SELECT book_id, title, available_copies, total_copies FROM library.books WHERE book_id = 3;

-- Test 3: return exactly the loan created in Test 2.
DO $$
DECLARE
    v_created_loan_id INTEGER;
BEGIN
    SELECT created_loan_id INTO v_created_loan_id
    FROM test_context;

    CALL library.return_book(v_created_loan_id);
END;
$$;

SELECT l.*
FROM library.loans l
JOIN test_context tc ON tc.created_loan_id = l.loan_id;

SELECT book_id, title, available_copies, total_copies FROM library.books WHERE book_id = 3;

-- Test 4: count overdue loans for reader 1.
SELECT library.count_reader_overdue_loans(1) AS overdue_loans_for_reader_1;

-- Test 5: create and return a late loan to validate overdue status and penalty triggers.
UPDATE library.books
SET available_copies = available_copies - 1
WHERE book_id = 4;

WITH late_loan AS (
    INSERT INTO library.loans (book_id, reader_id, employee_id, loan_date, due_date, status)
    VALUES (4, 2, 1, CURRENT_DATE - 10, CURRENT_DATE - 5, 'active')
    RETURNING loan_id
)
UPDATE test_context
SET late_loan_id = (SELECT loan_id FROM late_loan);

SELECT l.loan_id, l.book_id, l.reader_id, l.loan_date, l.due_date, l.return_date, l.status AS status_after_insert
FROM library.loans l
JOIN test_context tc ON tc.late_loan_id = l.loan_id;

DO $$
DECLARE
    v_late_loan_id INTEGER;
BEGIN
    SELECT late_loan_id INTO v_late_loan_id
    FROM test_context;

    CALL library.return_book(v_late_loan_id);
END;
$$;

SELECT
    l.loan_id,
    l.status AS status_after_return,
    l.return_date,
    p.amount,
    p.reason,
    p.paid
FROM library.loans l
JOIN library.penalties p ON p.loan_id = l.loan_id
JOIN test_context tc ON tc.late_loan_id = l.loan_id;

ROLLBACK;

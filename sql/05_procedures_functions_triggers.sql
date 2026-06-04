-- 05_procedures_functions_triggers.sql
-- Procedures, functions and triggers for the library system.
-- Objects are created explicitly in the `library` schema.
-- Tables and functions are schema-qualified so the script works even when executed from the `public` schema in DataGrip.

CREATE SCHEMA IF NOT EXISTS library;

-- Function: checks if a book has at least one available copy.
CREATE OR REPLACE FUNCTION library.is_book_available(p_book_id INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_available_copies INTEGER;
BEGIN
    SELECT b.available_copies
    INTO v_available_copies
    FROM library.books b
    WHERE b.book_id = p_book_id;

    IF v_available_copies IS NULL THEN
        RAISE EXCEPTION 'Book with id % does not exist.', p_book_id;
    END IF;

    RETURN v_available_copies > 0;
END;
$$;

-- Procedure: creates a new loan and decreases available copies.
CREATE OR REPLACE PROCEDURE library.create_loan(
    p_book_id INTEGER,
    p_reader_id INTEGER,
    p_employee_id INTEGER,
    p_due_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT library.is_book_available(p_book_id) THEN
        RAISE EXCEPTION 'Book with id % is not available.', p_book_id;
    END IF;

    INSERT INTO library.loans (book_id, reader_id, employee_id, loan_date, due_date, status)
    VALUES (p_book_id, p_reader_id, p_employee_id, CURRENT_DATE, p_due_date, 'active');

    UPDATE library.books
    SET available_copies = available_copies - 1
    WHERE book_id = p_book_id;
END;
$$;

-- Procedure: returns a book and increases available copies.
CREATE OR REPLACE PROCEDURE library.return_book(
    p_loan_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_book_id INTEGER;
    v_status VARCHAR(20);
BEGIN
    SELECT l.book_id, l.status
    INTO v_book_id, v_status
    FROM library.loans l
    WHERE l.loan_id = p_loan_id;

    IF v_book_id IS NULL THEN
        RAISE EXCEPTION 'Loan with id % does not exist.', p_loan_id;
    END IF;

    IF v_status = 'returned' THEN
        RAISE EXCEPTION 'Loan with id % has already been returned.', p_loan_id;
    END IF;

    UPDATE library.loans
    SET return_date = CURRENT_DATE,
        status = 'returned'
    WHERE loan_id = p_loan_id;

    UPDATE library.books
    SET available_copies = available_copies + 1
    WHERE book_id = v_book_id;
END;
$$;

-- Function: counts overdue active loans for a selected reader.
CREATE OR REPLACE FUNCTION library.count_reader_overdue_loans(p_reader_id INTEGER)
RETURNS INTEGER
LANGUAGE sql
AS $$
    SELECT COUNT(*)::INTEGER
    FROM library.loans
    WHERE reader_id = p_reader_id
      AND return_date IS NULL
      AND due_date < CURRENT_DATE;
$$;

-- Trigger function: automatically marks active loans as overdue when the due date has passed.
CREATE OR REPLACE FUNCTION library.set_loan_status_before_write()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.return_date IS NOT NULL THEN
        NEW.status := 'returned';
    ELSIF NEW.due_date < CURRENT_DATE THEN
        NEW.status := 'overdue';
    ELSE
        NEW.status := 'active';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_loan_status_before_write ON library.loans;
CREATE TRIGGER trg_set_loan_status_before_write
BEFORE INSERT OR UPDATE ON library.loans
FOR EACH ROW
EXECUTE FUNCTION library.set_loan_status_before_write();

-- Trigger function: creates a penalty for an overdue returned loan if no penalty exists.
CREATE OR REPLACE FUNCTION library.create_penalty_after_late_return()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_days_late INTEGER;
BEGIN
    IF NEW.return_date IS NOT NULL AND NEW.return_date > NEW.due_date THEN
        v_days_late := NEW.return_date - NEW.due_date;

        INSERT INTO library.penalties (loan_id, amount, reason, paid)
        VALUES (NEW.loan_id, v_days_late * 2.50, 'Automatically calculated late return fee.', FALSE)
        ON CONFLICT (loan_id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_create_penalty_after_late_return ON library.loans;
CREATE TRIGGER trg_create_penalty_after_late_return
AFTER UPDATE OF return_date ON library.loans
FOR EACH ROW
EXECUTE FUNCTION library.create_penalty_after_late_return();

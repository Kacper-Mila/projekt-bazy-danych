-- 04_queries.sql
-- Example SELECT queries, subqueries and set operations.
-- All tables are schema-qualified with the `library` schema so each query can be executed separately in DataGrip.

-- 1. List of books written by a selected author.
SELECT
    b.book_id,
    b.title,
    b.isbn,
    b.publication_year,
    a.first_name || ' ' || a.last_name AS author
FROM library.books b
JOIN library.book_authors ba ON ba.book_id = b.book_id
JOIN library.authors a ON a.author_id = ba.author_id
WHERE a.last_name = 'Orwell'
ORDER BY b.title;

-- 2. Readers who borrowed books from a selected genre.
SELECT DISTINCT
    r.reader_id,
    r.first_name,
    r.last_name,
    r.email,
    g.name AS genre
FROM library.readers r
JOIN library.loans l ON l.reader_id = r.reader_id
JOIN library.books b ON b.book_id = l.book_id
JOIN library.book_genres bg ON bg.book_id = b.book_id
JOIN library.genres g ON g.genre_id = bg.genre_id
WHERE g.name = 'Science Fiction'
ORDER BY r.last_name;

-- 3. Number of books borrowed in the last month.
SELECT
    COUNT(*) AS loans_last_month
FROM library.loans
WHERE loan_date >= CURRENT_DATE - INTERVAL '1 month';

-- 4. Active overdue loans.
SELECT
    l.loan_id,
    b.title,
    r.first_name || ' ' || r.last_name AS reader,
    l.loan_date,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue
FROM library.loans l
JOIN library.books b ON b.book_id = l.book_id
JOIN library.readers r ON r.reader_id = l.reader_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- 5. Number of loans per reader with HAVING.
SELECT
    r.reader_id,
    r.first_name,
    r.last_name,
    COUNT(l.loan_id) AS loan_count
FROM library.readers r
LEFT JOIN library.loans l ON l.reader_id = r.reader_id
GROUP BY r.reader_id, r.first_name, r.last_name
HAVING COUNT(l.loan_id) >= 1
ORDER BY loan_count DESC, r.last_name;

-- 6. Nested subquery: books that have never been borrowed.
SELECT
    b.book_id,
    b.title,
    b.isbn
FROM library.books b
WHERE NOT EXISTS (
    SELECT 1
    FROM library.loans l
    WHERE l.book_id = b.book_id
)
ORDER BY b.title;

-- 7. Correlated subquery: readers with more than one active or overdue loan.
SELECT
    r.reader_id,
    r.first_name,
    r.last_name
FROM library.readers r
WHERE (
    SELECT COUNT(*)
    FROM library.loans l
    WHERE l.reader_id = r.reader_id
      AND l.status IN ('active', 'overdue')
) > 1;

-- 8. UNION: common list of system people.
SELECT first_name, last_name, email, 'reader' AS person_type
FROM library.readers
UNION
SELECT first_name, last_name, email, 'employee' AS person_type
FROM library.employees
ORDER BY last_name, first_name;

-- 9. EXCEPT: books that are not currently borrowed.
SELECT book_id, title
FROM library.books
EXCEPT
SELECT b.book_id, b.title
FROM library.books b
JOIN library.loans l ON l.book_id = b.book_id
WHERE l.status IN ('active', 'overdue')
ORDER BY title;

-- 10. INTERSECT: readers who borrowed both novels and history books.
SELECT r.reader_id, r.first_name, r.last_name
FROM library.readers r
JOIN library.loans l ON l.reader_id = r.reader_id
JOIN library.book_genres bg ON bg.book_id = l.book_id
JOIN library.genres g ON g.genre_id = bg.genre_id
WHERE g.name = 'Novel'
INTERSECT
SELECT r.reader_id, r.first_name, r.last_name
FROM library.readers r
JOIN library.loans l ON l.reader_id = r.reader_id
JOIN library.book_genres bg ON bg.book_id = l.book_id
JOIN library.genres g ON g.genre_id = bg.genre_id
WHERE g.name = 'History';

-- 11. List of books ever borrowed per reader (titles as comma-separated string)
SELECT
    r.reader_id,
    r.first_name,
    r.last_name,
    COUNT(l.loan_id) AS borrow_count,
    COALESCE(
      STRING_AGG(DISTINCT b.title, ', ' ORDER BY b.title),
      '') AS books_ever_borrowed
FROM library.readers r
LEFT JOIN library.loans l ON l.reader_id = r.reader_id
LEFT JOIN library.books b ON b.book_id = l.book_id
GROUP BY r.reader_id, r.first_name, r.last_name
ORDER BY r.last_name, r.first_name;

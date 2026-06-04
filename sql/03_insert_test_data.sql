-- 03_insert_test_data.sql
-- Inserts sample data for testing.

SET search_path TO library;

INSERT INTO publishers (name, city, country) VALUES
('Penguin Books', 'London', 'United Kingdom'),
('HarperCollins', 'New York', 'United States'),
('Wydawnictwo Literackie', 'Krakow', 'Poland'),
('Helion', 'Gliwice', 'Poland');

INSERT INTO genres (name, description) VALUES
('Novel', 'Fictional prose narrative.'),
('Science Fiction', 'Speculative fiction based on science and technology.'),
('Programming', 'Books related to software development and IT.'),
('History', 'Books about historical events and processes.'),
('Fantasy', 'Fiction with magical or supernatural elements.');

INSERT INTO authors (first_name, last_name, birth_date, country) VALUES
('George', 'Orwell', '1903-06-25', 'United Kingdom'),
('Frank', 'Herbert', '1920-10-08', 'United States'),
('Jacek', 'Dukaj', '1974-07-30', 'Poland'),
('Robert', 'Martin', '1952-12-05', 'United States'),
('Yuval Noah', 'Harari', '1976-02-24', 'Israel');

INSERT INTO books (title, isbn, publication_year, available_copies, total_copies, publisher_id) VALUES
('1984', '9780451524935', 1949, 3, 5, 1),
('Dune', '9780441172719', 1965, 2, 4, 2),
('Ice', '9788308041828', 2007, 1, 2, 3),
('Clean Code', '9780132350884', 2008, 4, 4, 4),
('Sapiens', '9780062316097', 2011, 0, 3, 2);

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1),
(2, 2),
(3, 2),
(3, 5),
(4, 3),
(5, 4);

INSERT INTO readers (first_name, last_name, email, phone, registration_date, is_active) VALUES
('Jan', 'Kowalski', 'jan.kowalski@example.com', '501111111', '2025-01-10', TRUE),
('Anna', 'Nowak', 'anna.nowak@example.com', '502222222', '2025-02-15', TRUE),
('Piotr', 'Wisniewski', 'piotr.wisniewski@example.com', '503333333', '2025-03-20', TRUE),
('Maria', 'Zielinska', 'maria.zielinska@example.com', '504444444', '2025-04-01', FALSE);

INSERT INTO employees (first_name, last_name, email, hire_date, position, is_active) VALUES
('Ewa', 'Library', 'ewa.library@example.com', '2023-09-01', 'Librarian', TRUE),
('Adam', 'Admin', 'adam.admin@example.com', '2022-05-15', 'Administrator', TRUE),
('Katarzyna', 'Assistant', 'katarzyna.assistant@example.com', '2024-01-12', 'Library Assistant', TRUE);

INSERT INTO loans (book_id, reader_id, employee_id, loan_date, due_date, return_date, status) VALUES
(1, 1, 1, CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE - INTERVAL '6 days', NULL, 'overdue'),
(2, 2, 1, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '4 days', NULL, 'active'),
(4, 3, 3, CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '16 days', CURRENT_DATE - INTERVAL '15 days', 'returned'),
(5, 1, 1, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '9 days', NULL, 'active');

INSERT INTO penalties (loan_id, amount, reason, paid) VALUES
(1, 12.50, 'Late return fee for overdue book.', FALSE);

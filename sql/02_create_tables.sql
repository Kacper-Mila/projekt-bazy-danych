-- 02_create_tables.sql
-- Creates tables, constraints, relations and indexes.
-- Run after connecting to library_system database.

CREATE SCHEMA IF NOT EXISTS library;
SET search_path TO library;

DROP TABLE IF EXISTS penalties CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS book_genres CASCADE;
DROP TABLE IF EXISTS book_authors CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS readers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;

CREATE TABLE publishers (
    publisher_id      SERIAL PRIMARY KEY,
    name              VARCHAR(200) NOT NULL UNIQUE,
    city              VARCHAR(100),
    country           VARCHAR(100),
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE genres (
    genre_id          SERIAL PRIMARY KEY,
    name              VARCHAR(100) NOT NULL UNIQUE,
    description       TEXT
);

CREATE TABLE authors (
    author_id         SERIAL PRIMARY KEY,
    first_name        VARCHAR(100) NOT NULL,
    last_name         VARCHAR(100) NOT NULL,
    birth_date        DATE,
    country           VARCHAR(100),
    CONSTRAINT uq_authors_full_name_birth UNIQUE (first_name, last_name, birth_date)
);

CREATE TABLE books (
    book_id           SERIAL PRIMARY KEY,
    title             VARCHAR(255) NOT NULL,
    isbn              VARCHAR(20) NOT NULL UNIQUE,
    publication_year  INTEGER CHECK (publication_year IS NULL OR publication_year > 0),
    available_copies  INTEGER NOT NULL DEFAULT 0 CHECK (available_copies >= 0),
    total_copies      INTEGER NOT NULL DEFAULT 1 CHECK (total_copies > 0),
    publisher_id      INTEGER REFERENCES publishers(publisher_id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_books_available_not_greater_than_total CHECK (available_copies <= total_copies)
);

CREATE TABLE book_authors (
    book_id           INTEGER NOT NULL REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
    author_id         INTEGER NOT NULL REFERENCES authors(author_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_genres (
    book_id           INTEGER NOT NULL REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
    genre_id          INTEGER NOT NULL REFERENCES genres(genre_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE readers (
    reader_id         SERIAL PRIMARY KEY,
    first_name        VARCHAR(100) NOT NULL,
    last_name         VARCHAR(100) NOT NULL,
    email             VARCHAR(255) NOT NULL UNIQUE,
    phone             VARCHAR(20),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_readers_email_format CHECK (email LIKE '%@%.%')
);

CREATE TABLE employees (
    employee_id       SERIAL PRIMARY KEY,
    first_name        VARCHAR(100) NOT NULL,
    last_name         VARCHAR(100) NOT NULL,
    email             VARCHAR(255) NOT NULL UNIQUE,
    hire_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    position          VARCHAR(100) NOT NULL,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_employees_email_format CHECK (email LIKE '%@%.%')
);

CREATE TABLE loans (
    loan_id           SERIAL PRIMARY KEY,
    book_id           INTEGER NOT NULL REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    reader_id         INTEGER NOT NULL REFERENCES readers(reader_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    employee_id       INTEGER NOT NULL REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    loan_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date          DATE NOT NULL,
    return_date       DATE,
    status            VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_loans_due_date CHECK (due_date >= loan_date),
    CONSTRAINT chk_loans_return_date CHECK (return_date IS NULL OR return_date >= loan_date),
    CONSTRAINT chk_loans_status CHECK (status IN ('active', 'returned', 'overdue', 'lost'))
);

CREATE TABLE penalties (
    penalty_id        SERIAL PRIMARY KEY,
    loan_id           INTEGER NOT NULL UNIQUE REFERENCES loans(loan_id) ON UPDATE CASCADE ON DELETE CASCADE,
    amount            NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    reason            TEXT NOT NULL,
    paid              BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_authors_last_name ON authors(last_name);
CREATE INDEX idx_readers_last_name ON readers(last_name);
CREATE INDEX idx_loans_reader_id ON loans(reader_id);
CREATE INDEX idx_loans_book_id ON loans(book_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_penalties_paid ON penalties(paid);

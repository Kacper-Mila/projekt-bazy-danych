-- 06_roles_permissions.sql
-- Creates roles and grants permissions.
-- Run as a PostgreSQL superuser or database owner.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_admin') THEN
        CREATE ROLE library_admin;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_librarian') THEN
        CREATE ROLE library_librarian;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_reader') THEN
        CREATE ROLE library_reader;
    END IF;
END
$$;

-- Optional login users for testing permissions.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_user') THEN
        CREATE USER admin_user WITH PASSWORD 'Admin123!';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'librarian_user') THEN
        CREATE USER librarian_user WITH PASSWORD 'Librarian123!';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'reader_user') THEN
        CREATE USER reader_user WITH PASSWORD 'Reader123!';
    END IF;
END
$$;

GRANT library_admin TO admin_user;
GRANT library_librarian TO librarian_user;
GRANT library_reader TO reader_user;

GRANT USAGE ON SCHEMA library TO library_admin, library_librarian, library_reader;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA library TO library_admin;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA library TO library_admin;

GRANT SELECT, INSERT, UPDATE ON library.books TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.authors TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.book_authors TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.genres TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.book_genres TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.readers TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.loans TO library_librarian;
GRANT SELECT, INSERT, UPDATE ON library.penalties TO library_librarian;
GRANT SELECT ON library.publishers TO library_librarian;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA library TO library_librarian;

GRANT SELECT ON library.books TO library_reader;
GRANT SELECT ON library.authors TO library_reader;
GRANT SELECT ON library.genres TO library_reader;
GRANT SELECT ON library.publishers TO library_reader;

ALTER DEFAULT PRIVILEGES IN SCHEMA library
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO library_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA library
GRANT SELECT ON TABLES TO library_reader;

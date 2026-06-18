# Library Database Project

A relational database project for a library management system, developed for the Database Systems Engineering course.

The project models books, authors, genres, publishers, readers, employees, loans, and penalties. It includes database schema creation scripts, sample data, SQL queries, stored procedures, functions, triggers, roles, permissions, tests, an ERD diagram, and full project documentation.

## Tech Stack

- SQL
- PostgreSQL 16
- Docker and Docker Compose

## Requirements

Before running the project, install:

- Docker Desktop
- Git
- Optional: DataGrip, pgAdmin, or another PostgreSQL client

## Project Structure

```text
projekt-bazy-danych/
├── docker-compose.yaml
├── README.md
├── docs/
│   ├── dokumentacja.md
│   ├── dokumentacja.pdf
│   └── library.png
└── sql/
    ├── 01_create_database.sql
    ├── 02_create_tables.sql
    ├── 03_insert_test_data.sql
    ├── 04_queries.sql
    ├── 05_procedures_functions_triggers.sql
    ├── 06_roles_permissions.sql
    └── 07_tests.sql
```

## Database Model

The database uses the `library` schema and contains the following main tables:

- `publishers`
- `genres`
- `authors`
- `books`
- `book_authors`
- `book_genres`
- `readers`
- `employees`
- `loans`
- `penalties`

The model includes one-to-many and many-to-many relationships, primary keys, foreign keys, uniqueness constraints, check constraints, and indexes for frequently queried columns.

The ERD diagram is available at [`docs/library.png`](docs/library.png).

## Getting Started

### 1. Clone the repository

```bash
git clone <REPOSITORY_URL>
cd projekt-bazy-danych
```

### 2. Create the `.env` file

Create a `.env` file in the project root:

```env
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=library_db
```

`POSTGRES_DB` creates the initial container database. The project database itself is created by `sql/01_create_database.sql` and is named `library_system`.

### 3. Start PostgreSQL

```bash
docker compose up -d
```

Verify that the container is running:

```bash
docker ps
```

The `library-postgres` container should be listed.

## Running the SQL Scripts

Run the scripts in the order shown below.

The first script creates the `library_system` database and should be executed against the default `postgres` database:

```bash
docker compose exec -T postgres psql -U admin -d postgres < sql/01_create_database.sql
```

Run the remaining scripts against `library_system`:

```bash
docker compose exec -T postgres psql -U admin -d library_system < sql/02_create_tables.sql
docker compose exec -T postgres psql -U admin -d library_system < sql/03_insert_test_data.sql
docker compose exec -T postgres psql -U admin -d library_system < sql/05_procedures_functions_triggers.sql
docker compose exec -T postgres psql -U admin -d library_system < sql/06_roles_permissions.sql
```

The example queries and tests can be run after the schema, data, and procedural objects are loaded:

```bash
docker compose exec -T postgres psql -U admin -d library_system < sql/04_queries.sql
docker compose exec -T postgres psql -U admin -d library_system < sql/07_tests.sql
```

The test script runs inside a transaction and ends with `ROLLBACK`, so it can be executed repeatedly without permanently changing the sample data.

## Database Connection

Use the following connection settings in DataGrip, pgAdmin, or another PostgreSQL client:

```text
Host: localhost
Port: 5432
Database: library_system
User: admin
Password: admin123
```

The database owner created by the setup script is:

```text
User: library_admin_user
Password: LibraryAdmin123!
```

## Included SQL Features

- Relational schema with primary and foreign keys
- One-to-many and many-to-many relationships
- Integrity constraints and indexes
- Sample `INSERT` data
- Simple and complex `SELECT` queries
- Aliases, filtering, grouping, `HAVING`, aggregation, and sorting
- Nested and correlated subqueries
- Set operations: `UNION`, `EXCEPT`, `INTERSECT`
- DML examples: `INSERT`, `UPDATE`, `DELETE`
- Stored procedures for creating loans and returning books
- Functions for checking availability and counting overdue loans
- Triggers for loan status updates and automatic penalty creation
- Database roles and permissions
- Validation tests

## Documentation

Full documentation (in Polish) is available in the `docs` directory:

- [`docs/dokumentacja.md`](docs/dokumentacja.md)

## Stop the Project

Stop the container:

```bash
docker compose down
```

Stop the container and remove the PostgreSQL volume:

```bash
docker compose down -v
```

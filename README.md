# Database Project
A relational database project developed for the Database Systems Engineering course.

## Tech Stack
- PostgreSQL 16
- Docker & Docker Compose
- SQL

## Requirements
Before running the project, make sure the following software is installed:
- Docker Desktop
- Git

## Getting Started

### 1. Clone the repository

```bash
git clone <REPOSITORY_URL>
cd database-project
```

### 2. Create the `.env` file
Create a `.env` file in the root directory of the project:

```env
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=library_db
```

### 3. Start the PostgreSQL container

```bash
docker compose up -d
```

### 4. Verify that the container is running

```bash
docker ps
```

The `biblioteka-postgres` container should be running.

## Database Connection
Use the following connection settings in [DataGrip](chatgpt://generic-entity?number=0) or another SQL client:

```text
Host: localhost
Port: 5432
Database: library_db
User: admin
Password: admin123
```

## Stop the Project

```bash
docker compose down
```

## Project Structure

```text
projekt-bazy-danych/
├── docker-compose.yml
├── README.md
├── docs/
│   ├── dokumentacja.md
│   └── diagram-erd.png
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_test_data.sql
│   ├── 04_queries.sql
│   ├── 05_procedures_functions_triggers.sql
│   └── 06_roles_permissions.sql
└── exports/
    └── przykładowe_wyniki/
```
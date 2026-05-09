-- 01_create_database.sql
-- Library Management System - PostgreSQL
-- Run this file from the default postgres database, for example:
-- psql -U postgres -f sql/01_create_database.sql

DROP DATABASE IF EXISTS library_system;
DROP ROLE IF EXISTS library_admin_user;

CREATE ROLE library_admin_user
    WITH LOGIN
    PASSWORD 'LibraryAdmin123!';

CREATE DATABASE library_system
    OWNER library_admin_user
    ENCODING 'UTF8';

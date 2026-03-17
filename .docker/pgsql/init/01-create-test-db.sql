-- Create a separate test database for running feature tests without
-- touching the main application database
SELECT 'CREATE DATABASE laravel_test'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'laravel_test')\gexec

GRANT ALL PRIVILEGES ON DATABASE laravel_test TO CURRENT_USER;

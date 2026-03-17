-- Create a separate test database for running feature tests without
-- touching the main application database
CREATE DATABASE IF NOT EXISTS `laravel_test`;
GRANT ALL PRIVILEGES ON `laravel_test`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;

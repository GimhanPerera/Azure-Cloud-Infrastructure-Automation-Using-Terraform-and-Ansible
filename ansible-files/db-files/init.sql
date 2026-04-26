CREATE USER admin WITH PASSWORD 'admin';

CREATE DATABASE fruitdb;

\c fruitdb;

GRANT ALL PRIVILEGES ON DATABASE fruitdb TO admin;

CREATE TABLE fruits (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC
);

INSERT INTO fruits (name, price) VALUES
('Apple', 2.5),
('Banana', 1.2);

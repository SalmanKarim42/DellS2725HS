-- Create a table for storing DELL_S2725HS license keys.

CREATE TABLE IF NOT EXISTS licenses(
    id INTEGER PRIMARY KEY,
    license_key TEXT NOT NULL
);

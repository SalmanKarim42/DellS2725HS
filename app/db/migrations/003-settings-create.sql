-- Create a table for storing DELL_S2725HS runtime settings.

CREATE TABLE IF NOT EXISTS settings(
    id INTEGER PRIMARY KEY,
    requires_https INTEGER NOT NULL
);

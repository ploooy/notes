CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


DROP DATABASE IF EXISTS notes;
CREATE DATABASE notes;


CREATE FUNCTION trigger_on_update_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    username VARCHAR(16) NOT NULL UNIQUE,
    first_name VARCHAR(16),
    last_name VARCHAR(16),
    secret VARCHAR(32) NOT NULL,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE note (
    id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    title VARCHAR(64) NOT NULL,
    body TEXT,
    create_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE session (
    id SERIAL PRIMARY KEY,
    token UUID NOT NULL DEFAULT uuid_generate_v4(),
    account_id INT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_time TIMESTAMPTZ
);

CREATE TABLE access (
    id SERIAL PRIMARY KEY,
    note_id INT NOT NULL,
    account_id INT NOT NULL,
    is_editor BOOLEAN NOT NULL
);




ALTER TABLE note
ADD CONSTRAINT note_account_id_fk FOREIGN KEY (account_id)
REFERENCES account(id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE session
ADD CONSTRAINT session_account_id_fk FOREIGN KEY (account_id)
REFERENCES account(id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE access
ADD CONSTRAINT access_note_id_fk FOREIGN KEY (note_id)
REFERENCES note(id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE access
ADD CONSTRAINT access_account_id_fk FOREIGN KEY (account_id)
REFERENCES account(id)
ON UPDATE CASCADE ON DELETE CASCADE;


CREATE TRIGGER on_update_set_timestamp
BEFORE UPDATE ON note
FOR EACH ROW
EXECUTE PROCEDURE trigger_on_update_set_timestamp();

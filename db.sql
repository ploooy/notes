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
    username VARCHAR(16),
    first_name VARCHAR(16),
    last_name VARCHAR(16),
    secret VARCHAR(32),
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE note (
    id SERIAL PRIMARY KEY,
    account_id INT,
    title VARCHAR(64),
    body TEXT,
    create_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE session (
    id SERIAL PRIMARY KEY,
    token TEXT,
    account_id INT,
    start_time TIME,
    end_time TIME
);

CREATE TABLE access (
    id SERIAL PRIMARY KEY,
    note_id INT,
    account_id INT,
    is_editor BOOLEAN
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

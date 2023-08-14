CREATE TABLE notes_db.notes ( id INTEGER PRIMARY KEY,
	item INTEGER NOT NULL,
	colname TEXT NOT NULL COLLATE NOCASE,
    doc TEXT NOT NULL DEFAULT '',
    searchable_text TEXT NOT NULL DEFAULT '',
    UNIQUE(item, colname)
);

CREATE TABLE notes_db.resources ( id INTEGER PRIMARY KEY,
    hash TEXT NOT NULL UNIQUE ON CONFLICT FAIL,
    name TEXT NOT NULL UNIQUE ON CONFLICT FAIL
);

CREATE TABLE notes_db.notes_resources_link ( id INTEGER PRIMARY KEY,
    note INTEGER NOT NULL, 
    resource INTEGER NOT NULL, 
    FOREIGN KEY(note) REFERENCES notes(id),
    FOREIGN KEY(resource) REFERENCES resources(id),
    UNIQUE(note, resource)
);

CREATE VIRTUAL TABLE notes_db.notes_fts USING fts5(searchable_text, content = 'notes', content_rowid = 'id', tokenize = 'calibre remove_diacritics 2');
CREATE VIRTUAL TABLE notes_db.notes_fts_stemmed USING fts5(searchable_text, content = 'notes', content_rowid = 'id', tokenize = 'porter calibre remove_diacritics 2');

CREATE TRIGGER notes_db.notes_fts_insert_trg AFTER INSERT ON notes_db.notes 
BEGIN
    INSERT INTO notes_fts(rowid, searchable_text) VALUES (NEW.id, NEW.searchable_text);
    INSERT INTO notes_fts_stemmed(rowid, searchable_text) VALUES (NEW.id, NEW.searchable_text);
END;

CREATE TRIGGER notes_db.notes_db_notes_delete_trg BEFORE DELETE ON notes_db.notes 
    BEGIN
        DELETE FROM notes_resources_link WHERE note=OLD.id;
        INSERT INTO notes_fts(notes_fts, rowid, searchable_text) VALUES('delete', OLD.id, OLD.searchable_text);
        INSERT INTO notes_fts_stemmed(notes_fts_stemmed, rowid, searchable_text) VALUES('delete', OLD.id, OLD.searchable_text);
    END;

CREATE TRIGGER notes_db.notes_fts_update_trg AFTER UPDATE ON notes_db.notes
BEGIN
    INSERT INTO notes_fts(notes_fts, rowid, searchable_text) VALUES('delete', OLD.id, OLD.searchable_text);
    INSERT INTO notes_fts(rowid, searchable_text) VALUES (NEW.id, NEW.searchable_text);
    INSERT INTO notes_fts_stemmed(notes_fts_stemmed, rowid, searchable_text) VALUES('delete', OLD.id, OLD.searchable_text);
    INSERT INTO notes_fts_stemmed(rowid, searchable_text) VALUES (NEW.id, NEW.searchable_text);
END;

CREATE TRIGGER notes_db.notes_db_resources_delete_trg BEFORE DELETE ON notes_db.resources 
BEGIN
    DELETE FROM notes_resources_link WHERE resource=OLD.id;
END;

PRAGMA notes_db.user_version=1;

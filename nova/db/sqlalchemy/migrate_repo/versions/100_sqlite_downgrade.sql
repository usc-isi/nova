BEGIN TRANSACTION;
    CREATE TEMPORARY TABLE instance_metadata_backup (
        created_at DATETIME,
        updated_at DATETIME,
        deleted_at DATETIME,
        deleted BOOLEAN,
        id INTEGER NOT NULL,
        instance_id INTEGER NOT NULL,
        instance_uuid VARCHAR(36),
        key VARCHAR(255) NOT NULL,
        value VARCHAR(255) NOT NULL,
        PRIMARY KEY (id)
    );

    INSERT INTO instance_metadata_backup
        SELECT created_at,
               updated_at,
               deleted_at,
               deleted,
               id,
               NULL,
               instance_uuid,
               key,
               value
        FROM instance_metadata;

    UPDATE instance_metadata_backup
        SET instance_id=
            (SELECT id
                 FROM instances
                 WHERE instance_metadata_backup.instance_uuid = instances.uuid
    );

    DROP TABLE instance_metadata;

    CREATE TABLE instance_metadata (
        created_at DATETIME,
        updated_at DATETIME,
        deleted_at DATETIME,
        deleted BOOLEAN,
        id INTEGER NOT NULL,
        instance_id INTEGER NOT NULL,
        key VARCHAR(255) NOT NULL,
        value VARCHAR(255) NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY(instance_id) REFERENCES instances (id)
    );

    CREATE INDEX instance_metadata_instance_id_idx ON instance_metadata(instance_id);

    INSERT INTO instance_metadata
        SELECT created_at,
               updated_at,
               deleted_at,
               deleted,
               id,
               instance_id,
               key,
               value
        FROM instance_metadata_backup;

    DROP TABLE instance_metadata_backup;

COMMIT;
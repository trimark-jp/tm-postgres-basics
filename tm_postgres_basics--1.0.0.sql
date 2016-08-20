\echo Use "CREATE EXTENSION tm_postgres_basics" to load this file. \quit

-- converts table name to oid.
CREATE OR REPLACE FUNCTION tm_name_to_oid(
    input_name NAME
) RETURNS OID AS $tm_name_to_oid$
DECLARE
    result_oid OID;
BEGIN

    SELECT oid INTO result_oid
    FROM pg_class
    WHERE relname = input_name;

    RETURN result_oid;
END;
$tm_name_to_oid$ LANGUAGE plpgsql;

-- CHECK INHERITANCE
CREATE OR REPLACE FUNCTION tm_is_inherit_from(
    input_target_oid OID,
    input_parent_oid OID
) RETURNS BOOLEAN AS $tm_is_inherit_from$
DECLARE
    parent_oid OID;
    has_parent BOOLEAN;
BEGIN
    SELECT 0 < COUNT(*) INTO has_parent
    FROM pg_inherits
    WHERE
        inhrelid = input_target_oid
        AND inhparent = input_parent_oid;

    IF has_parent THEN
        RETURN TRUE;
    END IF;

    FOR parent_oid IN
        SELECT inhparent
        FROM pg_inherits
        WHERE inhrelid = input_target_oid
    LOOP
        IF tm_is_inherit_from(parent_oid, input_parent_oid) THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;
END;
$tm_is_inherit_from$ LANGUAGE plpgsql;

-- Finds tables
CREATE OR REPLACE FUNCTION tm_find_tables_inherit_from(
    input_parent_table_name NAME,
    input_schema_name NAME DEFAULT 'public'
) RETURNS SETOF NAME AS $tm_find_tables_inherit_from$
DECLARE
    parent_oid OID;
    current_table_name NAME;
BEGIN
    parent_oid := tm_name_to_oid(input_parent_table_name);
    IF parent_oid IS NULL THEN
        RETURN;
    END IF;

    FOR current_table_name IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = input_schema_name
    LOOP
        IF tm_is_inherit_from(tm_name_to_oid(current_table_name), parent_oid) THEN
            RETURN NEXT current_table_name;
        END IF;
    END LOOP;
END;
$tm_find_tables_inherit_from$ LANGUAGE plpgsql;
# tm-postgres-basics
postgres basic functions

## Install

In shell:

```bash
git clone https://github.com/trimark-jp/tm-postgres-basics.git
cd tm-postgres-basics
make install
```

In psql:

```psql
CREATE EXTENSION tm_postgres_basics;
```

## tm_name_to_oid

Args

* table_name NAME

Converts table name to oid.

```sql
SELECT * FROM tm_name_to_oid('table_name')
```

```txt
 tm_name_to_oid
----------------
          77618
(1 row)
```

## tm_is_inherit_from

Args

* target_oid OID
* parent_oid OID

Returns TRUE if the target_oid inherits from parent_oid.

If following table exist:

```sql
CREATE TABLE parent();
CREATE TABLE child() INHERITS(parent);
CREATE TABLE grandchild() INHERITS(child);
```

Both returns true.
```sql
SELECT * FROM tm_is_inherit_from(tm_name_to_oid('child'), tm_name_to_oid('parent'));
SELECT * FROM tm_is_inherit_from(tm_name_to_oid('grandchild'), tm_name_to_oid('parent'));
```

```txt

 tm_is_inherit_from
--------------------
 t
(1 row)
```

## tm_find_tables_inherit_from

Args

* parent_table_name NAME
* schema_name NAME DEFAULT 'public'

```sql
SELECT * FROM tm_find_tables_inherit_from('parent');
```

```txt
 tm_find_tables_inherit_from
-----------------------------
 grandchild
 child
(2 rows)
```
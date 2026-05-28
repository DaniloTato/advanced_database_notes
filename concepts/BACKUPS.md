# SQL_BACKUPS

## My understanding

A database backup is the process of creating a copy of a database’s structure and/or data so it can be restored later if something goes wrong.

In Oracle, backups can include:
- Table definitions (DDL)
- Data
- Constraints
- Procedures, triggers, indexes, and other schema objects

Using tools like DBMS_METADATA.GET_DDL, we can extract the SQL definitions of database objects and recreate them in another database or schema.

Basically, backups protect the database from data loss and make migrations possible.

## Why it matters

Backups are important because databases can fail, become corrupted, or need to be migrated to another environment.

## Without backups:

- Data could be permanently lost
- Applications might stop working
- Recovery after mistakes would be very difficult

## Backups are also useful when:

- Moving a schema to another database
- Testing
- Cloning environments
- Recovering from accidental deletions

## Example

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', 'BRICKS')
FROM DUAL;
```

```sql
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(
    DBMS_METADATA.SESSION_TRANSFORM,
    'EMIT_SCHEMA',
    false
  );
END;
/
```

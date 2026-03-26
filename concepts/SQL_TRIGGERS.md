# SQL_TRIGGERS

## My understanding
A trigger in SQL is a special kind of stored procedure that runs automatically when a specific event happens in a database table. Instead of being called manually, it is “triggered” by actions like INSERT, UPDATE, or DELETE.

It acts like a rule attached to a table: whenever a certain change occurs, the database executes something in response.

## Why it matters
Triggers are important because they automate behavior within the db.
Could be used to mantain data log changes, update chenges across tables, etc.
They run on the db and reduce the need for extra logic in another logic layer.

## Example
```sql
CREATE TRIGGER log_transaction
AFTER UPDATE ON accounts
FOR EACH ROW --to update not on every query, but only when a row in accounts is changed.
BEGIN
    INSERT INTO transaction_log(account_id, old_balance, new_balance, changed_at)
    VALUES (OLD.id, OLD.balance, NEW.balance, NOW());
END;
```
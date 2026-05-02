# TRANSACTIONS

## My understanding
A trigger in SQL is a special type of stored procedure that executes automatically when a specific event occurs on a table, such as INSERT, UPDATE, or DELETE.

It is attached to a table and reacts to changes without being explicitly called. Triggers can access both the old and new values of a row during a modification.

## Why it matters
Triggers are important because they allow the database to enforce rules and automate data behaviour.
Since they run inside the database, they ensure consistency even if multiple applications interact with the same data.

## Example
```SQL
CREATE OR REPLACE TRIGGER log_transaction
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    INSERT INTO transaction_log(
        account_id,
        old_balance,
        new_balance,
        changed_at
    )
    VALUES (
        :OLD.account_id,
        :OLD.balance,
        :NEW.balance,
        SYSDATE
    );
END;
/
```
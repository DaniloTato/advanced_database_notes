# ORM

## My understanding

An ORM (Object-Relational Mapping) is a technique that allows us to interact with a database using classes and objects instead of writing SQL queries directly.

The ORM maps database tables to classes and table rows to objects.

It acts as a bridge between an application and a relational database.

## Why it matters

ORMs are useful because they reduce the amount of SQL code developers need to write and maintain. They also make applications easier to develop by allowing programmers to work with familiar programming concepts.

## Example

Instead of writing this:

```sql
SELECT * FROM users
WHERE id = 1;
```

We can do:

```sql
user = User.get(id=1)
print(user.name)
```
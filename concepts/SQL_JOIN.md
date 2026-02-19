# SQL_JOIN

## My understanding
A SQL JOIN is a way to connect two tables in a database using a shared column. Since databases usually split information into different tables, a JOIN helps us combine that information when we need it.

Basically, it matches related rows from different tables so we can see the full picture.

## Why it matters
JOINs are important because databases avoid repeating data. Instead of putting everything in one big table, data is separated to keep it organized.

Without JOINs, we wouldn’t be able to connect things like:
- Students and their courses
- Customers and their orders
- Employees and their departments

## Example

If we have a Students table and an Enrollments table, we can connect them like this:

```SQL

SELECT s.name, e.course
FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id;

```
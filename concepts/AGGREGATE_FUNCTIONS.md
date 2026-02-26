# SQL_AggregateFunctions

## My understanding
SQL Aggregate Functions are special functions that perform calculations on multiple rows of data and return a single result.

Instead of showing every individual row, they summarize the data into one meaningful value.

## Why it matters

Aggregate functions are important because they process data resulting from various rows. Its like a summary of the results.

Uses:
- Total sales of a store
- Average grade in a class
- Highest salary in a department

Without aggregate functions, we would have to calculate all of this manually outside SQL.

## Importance of GROUP BY

GROUP BY is used when we want aggregate results per category instead of one single result for the whole table.

```SQL
SELECT course_id, AVG(grade) AS average_grade
FROM Enrollments
GROUP BY course_id;
```

This groups all rows by course_id, and then calculates the average grade for each group.
So instead of one average for all students, we get one average per course.

## EXAMPLE

```SQL
SELECT AVG(grade) AS average_grade
FROM Students;
```

To get the average grade of the students registered
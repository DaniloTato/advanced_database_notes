# SQL_AnalyticFunctions

## My understanding
Unlike aggregate functions, analytic functions do not 'merge' multiple rows into a single row. Instead, they add additional info to each row.

## Why it matters

Without analytic functions, many operations would require multiple queries or unnecessarily complicated JOINS.

## OVER()

All analytic functions use the OVER() clause, which defines the window of rows used in the calculation.

### Relevant operations inside it:
PARTITION BY
ORDER BY
ROWS or RANGE windowing clauses

### Example:

```SQL
SELECT 
  employee_id,
  department_id,
  salary,
  AVG(salary) OVER (PARTITION BY department_id) AS avg_salary
FROM Employees;
```

## PARTITION BY

PARTITION BY divides the data into separate groups.
The analytic function is then applied independently in each group.

### Example:

```SQL
SELECT 
  employee_id,
  department_id,
  salary,
  RANK() OVER (
      PARTITION BY department_id
      ORDER BY salary DESC
  ) AS salary_rank
FROM Employees;
```

## ORDER BY in Analytic Functions

ORDER BY defines th order inside the logical limit/partition.

### Example:

```SQL
SELECT
  employee_id,
  salary,
  SUM(salary) OVER (
      ORDER BY employee_id
  ) AS running_total
FROM Employees;
```

## Windowing Clause

A windowing clause defines which rows around the current row are included in the calculation.

### Example:

```SQL
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```
- Start from the first row
- Include all rows up to the current row

```SQL
SELECT
  employee_id,
  salary,
  SUM(salary) OVER (
      ORDER BY employee_id
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM Employees;
```

## Sliding Window

A sliding window moves along the dataset and performs calculations on a limited set of nearby rows.

### Example:

```SQL
SELECT
  employee_id,
  salary,
  AVG(salary) OVER (
      ORDER BY employee_id
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS moving_average
FROM Employees;
```

## Filtering in Analytic Functions

Analytic functions are calculated after the WHERE clause, which means you cannot directly filter using them in WHERE.
We need to do a sub-query.

### Example:

```SQL
SELECT *
FROM (
    SELECT
      employee_id,
      salary,
      RANK() OVER (ORDER BY salary DESC) AS rank
    FROM Employees
) t
WHERE rank <= 3;
```

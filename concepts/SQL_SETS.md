# SQL_SETS

## My understanding
SQL set operators combine the results of multiple queries into a single result set.
Instead of connecting tables horizontally like a JOIN, they combine results vertically by stacking rows from different queries.
These operators are made to think about DB like if they were mathematical sets.

For the operators to work, the queries must return the same number of columns and compatible data types them.

## UNION

### My understanding

UNION combines rows from two queries into one result set and removes duplicates automatically.
It is useful when you want a unique list of values from multiple tables.

### Why it matters
Databases may store similar data in different tables. UNION lets us merge those results while keeping only distinct values.

### Example

```sql
SELECT colour, shape
FROM my_brick_collection

UNION

SELECT colour, shape
FROM your_brick_collection;
```

## UNION ALL

### My understanding

UNION ALL works like UNION, but keeps duplicates.
Instead of removing repeated rows, it simply appends all results.

### Why it matters

UNION ALL is usually faster and useful when duplicates are important.

### Example

```sql
SELECT shape
FROM my_brick_collection

UNION ALL

SELECT shape
FROM your_brick_collection;
```

## MINUS (Set Difference)

### My understanding

MINUS returns rows that exist in the first query but not in the second.

### Why it matters

This helps identify values present in one table but missing in another.

### Example

```sql
SELECT shape
FROM my_brick_collection

MINUS

SELECT shape
FROM your_brick_collection;
```

⸻

## INTERSECT

### My understanding

INTERSECT returns rows that exist in both queries.

### Why it matters

This is useful when we need to identify shared data between tables.

### Example

```sql
SELECT colour
FROM my_brick_collection

INTERSECT

SELECT colour
FROM your_brick_collection;
```
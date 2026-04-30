# INDEXES

## My understanding
A SQL index is a data structure that helps the database find rows faster without scanning the entire table.
Instead of checking every row one by one, the database uses the index to quickly locate the rows that match a condition.
Basically, it works like a lookup table that maps column values to the exact location of the data.

## Why it matters
Indexes are important because databases can store millions of rows, and scanning all of them is slow.

## Example
```SQL
CREATE INDEX idx_patient_id 
ON patient_visits(patient_id);

SELECT * 
FROM patient_visits 
WHERE patient_id = 5432;
```


-- ============================================================
-- Lesson 03 — Indexes: Class Exercises
-- Work through these before looking at the hints
-- ============================================================

-- ============================================================
-- Exercise 1 — Find the slow query
--
-- Run this query. Look at the execution plan.
-- Is Oracle using an index? Should it?
-- ============================================================

EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE site_id = 3;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) What scan type do you see? Why?
--
-- Full Table Scan, because there's no index on site_id, so the
-- DB decides that reading the full table is cheaper
--
-- b) site_id has values 1–5. Is this high or low cardinality?
--
-- Low cardinality
--
-- c) Would adding an index on site_id help? Why or why not?
--
-- No, becuase many rows share the same value, meaning low 
-- cardinality, this makes the index low selectively. This means
-- the Db will likely prefer a Full Table Scan.

-- ============================================================
-- Exercise 2 — Create an index and see if it helps
--
-- Create an index on visit_date.
-- Then run the range query below and check the plan.
-- ============================================================

-- Step 1: Create it
-- (write the CREATE INDEX statement here)


-- Step 2: Gather stats
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

-- Step 3: Run the range query and check the plan
EXPLAIN PLAN FOR
SELECT * FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) Does Oracle use the index for this range?
--
-- Yes, because 30 days is a small range compared to the total number of
-- registered days. Given that we have fewer rows, our index will efficiently
-- help us jump towards the desired rows.
--
-- b) Change the range to the last 7 days. Does the plan change?
--
-- It still ises the index, because theres higher selectivity.
--
-- c) Change to the last 700 days. What happens?
--
-- The DB will just read the whole table, because using indexes would cause
-- the system to jump around, wich is slower per access.
--
-- d) Why does the range size affect whether Oracle uses the index?
--
-- Because a full read is sequential and fast. In contrast, the index is
-- only faster if not many values are fetched. Each access is slower than in
-- a full read.
--

-- ============================================================
-- Exercise 3 — Composite index
--
-- You often query by both patient_id AND visit_date together:
--   WHERE patient_id = 1234 AND visit_date > SYSDATE - 90
--
-- Two options:
--   Option A: Two separate indexes (one per column)
--   Option B: One composite index (patient_id, visit_date)
--
-- Create the composite index and test the query.
-- ============================================================

CREATE INDEX idx_pv_patient_date ON patient_visits(patient_id, visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

EXPLAIN PLAN FOR
SELECT * FROM patient_visits
WHERE patient_id = 1234
  AND visit_date > SYSDATE - 90;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) Does the plan use the composite index?
--
-- Yes, because the query uses the leading column `patient_id` of our composite index. The DB can efficiently
-- use indexes to jump to the range of values whose `patient_id = 1234` and just then scan
-- the date range.
--
-- b) Now try querying ONLY on visit_date (no patient_id).
--    Does the composite index get used? Why not?
--
--  No. Because of the lack of `patient_id` specification, we would need to traverse
--  every `patient_id` group and for each one search for the date range. A full lookup would be faster.
--
-- c) What's the rule about column order in composite indexes?
-- 
-- Leftmost prefix rule: A composite index can only be used starting from the leftmost column.
-- “you must start from the first column, but you can stop early”

-- Bonus test — leading column only:
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE patient_id = 1234;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Trailing column only (index cannot be used from the middle):
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE visit_date > SYSDATE - 90;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================
-- Exercise 4 — Function that breaks an index
--
-- There IS an index on patient_id (from lesson 03).
-- Predict what happens when you wrap the column in a function.
-- ============================================================

-- This query CAN use the index:
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE patient_id = 5432;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- This one cannot — why?
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) What scan type did the second query use?
--
-- Full table scan.
--
-- b) Why does wrapping a column in a function break index use?
--
-- Because the index is built on the original column values, not on the result of the function.
--
-- c) How would you rewrite the second query to allow index use?

-- Works for deterministic functions

CREATE INDEX idx_pv_pid_char 
ON patient_visits(TO_CHAR(patient_id));

SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';

-- ============================================================
-- Exercise 5 — Discussion: real-world scenarios
--
-- For each scenario below, decide:
--   a) Would you add an index?
--   b) On which column(s)?
--   c) Any concerns?
-- ============================================================

-- Scenario A:
-- A reporting table gets loaded once per night (batch ETL).
-- During the day, analysts run SELECT queries by date range.
-- The table has 50 million rows.
-- → Index on date? Yes/No, why?

-- a) Yes
-- b) visit_date
-- c) no major concerns.

-- Scenario B:
-- An OLTP orders table gets 10,000 inserts per minute.
-- Support staff look up orders by customer_id or order_status.
-- order_status has 4 values: pending, processing, shipped, cancelled.
-- → What indexes would you add?

-- a) Yes, but only for the first row, and only if we are looking up data frequently.
-- If efficientcy for data rerieval is trivial, we should not use indexes becasue it compormises writes.
-- b) customer_id
-- c) Use of indexes slows down inserts, an the system has to be very efficient 
-- given the influx of data. Also, order_status has few possible values, meaning that
-- we'll still have to check up a huge number of values given the index.

-- Scenario C:
-- A patient table has an email column (unique per patient).
-- There are 5 million patients.
-- The app frequently does: WHERE email = 'user@example.com'
-- → What kind of index would be best here?

-- a) Yes
-- b) email
-- c) it has high cardinality.

-- Best index is an Unique Index
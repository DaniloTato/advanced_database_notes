-- ============================================
-- EXERCISE 1: Explore your schema
-- ============================================
-- List all the objects in your schema using user_objects
-- Group by object_type and count them
-- Which object types do you have?

    -- I explored my schema using USER_OBJECTS and grouped the results by OBJECT_TYPE.
    -- The schema currently contains different Oracle object types such as TABLE, INDEX,
    -- SEQUENCE, PROCEDURE, TRIGGER, and LOB objects.
    -- Current object count:
    --   - 6 INDEX objects
    --   - 1 LOB object
    --   - 1 PROCEDURE
    --   - 2 SEQUENCES
    --   - 8 TABLES
    --   - 1 TRIGGER
    -- This helped me understand the structure of my schema and identify all database
    -- objects that may need to be migrated or backed up.

-- ============================================
-- EXERCISE 2: Basic GET_DDL
-- ============================================
-- First, set transform params for clean output:

-- Identify the key parts in the output:
--   - Column definitions (NAME, TYPE, NULL/NOT NULL)
--   - Constraints (PRIMARY KEY, FK, CHECK)
--   - Storage parameters (if included)

    -- For this exercise, I selected the table BRICKS and generated its DDL using
    -- DBMS_METADATA.GET_DDL.

    -- The generated DDL recreates the complete structure of the BRICKS table.
    -- The output contains:
    --   - Column definitions
    --   - Data types
    --   - NULL / NOT NULL rules
    --   - Constraint information (if applicable)

    -- Example columns included in the table:
    --   - BRICK_ID NUMBER
    --   - COLOUR VARCHAR2
    --   - SHAPE VARCHAR2
    --   - WEIGHT NUMBER

    -- The generated script also included Oracle-specific storage settings and
    -- tablespace information before applying cleanup transformations.

-- ============================================
-- EXERCISE 3: Clean DDL for portability
-- ============================================
-- Remove schema names from DDL so it works in any schema
-- Compare the output with and without EMIT_SCHEMA:
-- With EMIT_SCHEMA (default):   CREATE TABLE "SALES"."ORDERS" ...
-- Without EMIT_SCHEMA:          CREATE TABLE "ORDERS" ...

    -- I attempted to use the EMIT_SCHEMA transformation parameter in
    -- DBMS_METADATA.SET_TRANSFORM_PARAM in order to remove schema-qualified names
    -- from the exported DDL.

    -- However, the FreeSQL environment restricts some DBMS_METADATA transformation
    -- options, so the parameter could not be fully applied.

    -- Even though the command could not be executed successfully, removing schema
    -- qualifiers is important because it makes the generated DDL portable across
    -- different Oracle schemas.

    -- Example:

    --   With schema:
    --     CREATE TABLE "OLD_SCHEMA"."BRICKS" ...

    --   Without schema:
    --     CREATE TABLE "BRICKS" ...

    -- The second version is preferable for migrations because it can be execute
    -- in any target schema without modifications.

-- ============================================
-- EXERCISE 4: Plan a migration
-- ============================================
-- You're moving to a new schema with a different name.
-- What changes would you need to make to your exported DDL?

    -- If I migrate my schema from SCHEMA_OLD to SCHEMA_NEW, I would need to review
    -- and adapt the exported DDL scripts before executing them in the new database.

    -- In my case, the BRICKS table could appear in the exported DDL as:
    --     SCHEMA_OLD.BRICKS

    -- To make the script portable, I would remove the schema qualifier so it becomes:
    --     BRICKS

    -- If the table contained foreign key relationships, I would also need to:
    --   - Verify that the referenced tables exist in SCHEMA_NEW
    --   - Update REFERENCES clauses if schema names changed
    --   - Recreate constraints after all related tables are created
    -- The BRICKS table currently does not contain foreign keys, so no FK changes
    -- are required for this migration.

    -- Order:
    --   1. Tables
    --   2. Primary keys and constraints
    --   3. Foreign keys
    --   4. Indexes
    --   5. Views, procedures, triggers, and other objects

    -- Migration checklist:
    --   Export BRICKS DDL without schema qualifiers
    --   Verify all column definitions
    --   Check primary key or constraint definitions
    --   Recreate the table in the target schema
    --   Recreate indexes and other dependent objects
    --   Validate the migrated data and structure

-- ============================================
-- EXERCISE 5: Dependency order
-- ============================================
-- Look at user_dependencies to understand object relationships

    -- I used the USER_DEPENDENCIES view to analyze relationships between objects
    -- in my schema.

    -- The results show that some schema objects depend on other database objects,
    -- especially procedures and triggers.

    -- Current dependency observations:
    --   - 1 PROCEDURE depends on schema objects
    --   - 1 TRIGGER also contains dependencies related to schema objects

    -- These dependencies are not directly related to the BRICKS table itself,
    -- but they demonstrate that some objects in the schema rely on other objects
    -- being created first.

    -- Dependency analysis is important during migration because objects must be
    -- recreated in the correct order to avoid compilation or reference errors.

-- ============================================
-- EXERCISE 6: Design your own backup strategy
-- ============================================
-- Given:
--   - No expdp access (no directory privileges)
--   - Need to move your schema to another database
--   - Only have SQL access
--
-- Design the steps you would take:

    -- Since I do not have access to expdp or Oracle directory privileges:

    -- STEP 1:
    -- Analyze the schema structure using USER_OBJECTS, USER_TABLES,
    -- USER_INDEXES, and USER_DEPENDENCIES.

    -- STEP 2:
    -- Extract all DDL definitions using DBMS_METADATA.GET_DDL for:
    --   - Tables
    --   - Sequences
    --   - Indexes
    --   - Views
    --   - Constraints
    --   - Procedures
    --   - Functions
    --   - Triggers

    -- STEP 3:
    -- Clean the generated DDL by:
    --   - Removing schema-qualified names
    --   - Removing storage parameters
    --   - Removing tablespace information
    -- This improves portability across Oracle environments.

    -- STEP 4:
    -- Execute the scripts in the target database using the proper dependency order:
    --   1. Tables
    --   2. Sequences
    --   3. Indexes
    --   4. Constraints and keys
    --   5. Views
    --   6. Procedures, functions, and packages
    --   7. Triggers

    -- STEP 5:
    -- Validate the migration by comparing:
    --   - Object counts
    --   - Table structures
    --   - Constraints
    --   - Indexes
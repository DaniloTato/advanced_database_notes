-- EXERCISE 1

-- Business Question:
-- How productive is each team relative to its size?
--
-- KPI Definition:
-- Velocity = completed tasks per team member.
-- Only tasks with status = 'completed' are considered.
--
-- Edge Cases:
-- Teams without members should not generate division errors.
--
-- Unit:
-- Completed tasks per user.
--
-- Limitation:
-- Task complexity is not considered.

WITH team_stats AS (
    SELECT
        t.id,
        t.name,
        COUNT(DISTINCT u.id) members,
        SUM(CASE WHEN ts.status = 'completed' THEN 1 ELSE 0 END) completed_count
    FROM teams t
    LEFT JOIN users u
        ON u.team_id = t.id
    LEFT JOIN tasks ts
        ON ts.assigned_to = u.id
    GROUP BY t.id, t.name
)
SELECT
    name AS team_name,
    members,
    completed_count,
    ROUND(completed_count / NULLIF(members,0),2) AS velocity,
    CASE
        WHEN ROUND(completed_count / NULLIF(members,0),2)
             < (
                SELECT AVG(completed_count / NULLIF(members,0))
                FROM team_stats
               )
        THEN 'Needs Improvement'
        ELSE 'Performing Well'
    END AS performance_flag
FROM team_stats
ORDER BY velocity DESC;



-- EXERCISE 2

-- Business Question:
-- How often are completed tasks delivered before their deadline?
--
-- KPI Definition:
-- A task is considered on time if completed_at <= due_date.
--
-- Edge Cases:
-- Tasks without due dates are ignored.
--
-- Unit:
-- Percentage by priority level.
--
-- Limitation:
-- Artificially extending deadlines improves the metric.

SELECT
    priority,
    COUNT(*) AS completed_tasks,
    SUM(
        CASE
            WHEN completed_at <= due_date THEN 1
            ELSE 0
        END
    ) AS delivered_on_time,
    ROUND(
        SUM(
            CASE
                WHEN completed_at <= due_date THEN 1
                ELSE 0
            END
        ) * 100 / COUNT(*),
        2
    ) AS on_time_percentage,
    ROUND(
        AVG(
            CASE
                WHEN completed_at > due_date
                THEN (completed_at - due_date) * 24
            END
        ),
        2
    ) AS avg_delay_hours
FROM tasks
WHERE status = 'completed'
  AND due_date IS NOT NULL
GROUP BY priority
ORDER BY DECODE(priority,'critical',1,'high',2,'medium',3,'low',4);



-- EXERCISE 3


-- Business Question:
-- What is the workload distribution across teams?
--
-- KPI Definition:
-- Total tasks, active tasks and completion percentage.
--
-- Edge Cases:
-- Teams without tasks still appear.
--
-- Unit:
-- Counts and percentages.
--
-- Limitation:
-- Does not reflect task difficulty.

SELECT
    t.name AS team_name,

    COUNT(ts.id) AS total_tasks,

    SUM(
        CASE
            WHEN ts.status IN ('open','in_progress','blocked')
            THEN 1
            ELSE 0
        END
    ) AS active_tasks,

    ROUND(
        SUM(
            CASE
                WHEN ts.status = 'completed'
                THEN 1
                ELSE 0
            END
        ) * 100
        /
        NULLIF(
            SUM(
                CASE
                    WHEN ts.status <> 'cancelled'
                    THEN 1
                    ELSE 0
                END
            ),
        0),
    2) AS completion_rate,

    CASE
        WHEN SUM(
                CASE
                    WHEN ts.status IN ('open','in_progress','blocked')
                    THEN 1
                    ELSE 0
                END
             ) > 10
            THEN 'Overloaded'

        WHEN SUM(
                CASE
                    WHEN ts.status IN ('open','in_progress','blocked')
                    THEN 1
                    ELSE 0
                END
             ) BETWEEN 5 AND 10
            THEN 'Healthy'

        ELSE 'Underutilized'
    END AS health_score

FROM teams t
LEFT JOIN users u
    ON u.team_id = t.id
LEFT JOIN tasks ts
    ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY active_tasks DESC;



-- EXERCISE 4


-- Business Question:
-- Are higher priority tasks resolved within expected SLA targets?
--
-- KPI Definition:
-- Resolution time measured from creation until completion.
--
-- Edge Cases:
-- Incomplete tasks excluded.
--
-- Unit:
-- Hours.
--
-- Limitation:
-- Small sample sizes reduce reliability.

WITH resolution_data AS (
    SELECT
        priority,
        (completed_at - created_at) * 24 AS resolution_hours
    FROM tasks
    WHERE status = 'completed'
      AND completed_at IS NOT NULL
)
SELECT
    priority,

    COUNT(*) AS completed_tasks,

    ROUND(AVG(resolution_hours),2) AS avg_hours,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY resolution_hours),
    2) AS median_hours,

    ROUND(MIN(resolution_hours),2) AS fastest_hours,

    ROUND(MAX(resolution_hours),2) AS slowest_hours,

    CASE
        WHEN priority='critical'
             AND AVG(resolution_hours) <= 24 THEN 'Met'
        WHEN priority='high'
             AND AVG(resolution_hours) <= 72 THEN 'Met'
        WHEN priority='medium'
             AND AVG(resolution_hours) <= 168 THEN 'Met'
        WHEN priority='low'
             AND AVG(resolution_hours) <= 336 THEN 'Met'
        ELSE 'Missed'
    END AS sla_result

FROM resolution_data
GROUP BY priority
ORDER BY DECODE(priority,'critical',1,'high',2,'medium',3,'low',4);



-- EXERCISE 5


-- Business Question:
-- Which overdue tasks represent the greatest operational risk?
--
-- KPI Definition:
-- Active tasks whose due date has already passed.
--
-- Edge Cases:
-- NULL due dates excluded.
--
-- Unit:
-- Days overdue.
--
-- Limitation:
-- Does not explain root causes.

SELECT
    ts.title,
    u.full_name AS assignee,
    tm.name AS team_name,
    ts.priority,
    ts.due_date,

    TRUNC(SYSDATE) - ts.due_date AS days_overdue,

    CASE
        WHEN ts.priority='critical'
            THEN 'CRITICAL'

        WHEN ts.priority='high'
             AND (TRUNC(SYSDATE)-ts.due_date) > 2
            THEN 'HIGH'

        WHEN ts.priority='medium'
             AND (TRUNC(SYSDATE)-ts.due_date) > 5
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS severity

FROM tasks ts
LEFT JOIN users u
    ON u.id = ts.assigned_to
LEFT JOIN teams tm
    ON tm.id = u.team_id
WHERE ts.status NOT IN ('completed','cancelled')
  AND ts.due_date IS NOT NULL
  AND ts.due_date < TRUNC(SYSDATE)
ORDER BY
    DECODE(severity,'CRITICAL',1,'HIGH',2,'MEDIUM',3,'LOW',4),
    days_overdue DESC;



-- EXERCISE 6

-- Problem:
-- Counting assigned tasks does not measure productivity.
-- It ignores completion, impact and priority.

SELECT
    u.full_name,

    SUM(
        CASE ts.priority
            WHEN 'critical' THEN 4
            WHEN 'high' THEN 3
            WHEN 'medium' THEN 2
            WHEN 'low' THEN 1
            ELSE 0
        END
    ) AS weighted_points,

    COUNT(*) AS completed_tasks,

    ROUND(
        SUM(
            CASE ts.priority
                WHEN 'critical' THEN 4
                WHEN 'high' THEN 3
                WHEN 'medium' THEN 2
                WHEN 'low' THEN 1
            END
        )
        /
        NULLIF(
            COUNT(DISTINCT TRUNC(ts.completed_at)),
        0),
    2) AS productivity_per_day

FROM users u
JOIN tasks ts
    ON ts.assigned_to = u.id
WHERE ts.status = 'completed'
GROUP BY u.id, u.full_name
ORDER BY productivity_per_day DESC;



-- EXERCISE 7

-- Problem:
-- Average task ID has no business meaning.

SELECT
    t.name AS team_name,

    COUNT(ts.id) AS total_tasks,

    SUM(
        CASE
            WHEN ts.status='completed'
            THEN 1
            ELSE 0
        END
    ) AS completed_tasks,

    ROUND(
        SUM(
            CASE
                WHEN ts.status='completed'
                THEN 1
                ELSE 0
            END
        ) * 100
        /
        NULLIF(COUNT(ts.id),0),
    2) AS completion_ratio

FROM teams t
LEFT JOIN users u
    ON u.team_id = t.id
LEFT JOIN tasks ts
    ON ts.assigned_to = u.id
GROUP BY t.id,t.name
ORDER BY completion_ratio DESC;



-- EXERCISE 8

-- Problem:
-- Priority is text and cannot be multiplied directly.
-- Due dates must be converted into a measurable value.

SELECT
    title,
    priority,
    due_date,

    (
        CASE priority
            WHEN 'critical' THEN 40
            WHEN 'high' THEN 30
            WHEN 'medium' THEN 20
            WHEN 'low' THEN 10
        END
    )
    +
    (
        CASE
            WHEN due_date < TRUNC(SYSDATE)
                THEN ABS(TRUNC(due_date - SYSDATE)) * 2
            ELSE
                GREATEST(0,10 - TRUNC(due_date - SYSDATE))
        END
    ) AS urgency_score

FROM tasks
WHERE status NOT IN ('completed','cancelled')
ORDER BY urgency_score DESC;


-- PART D - DASHBOARD QUERY

WITH task_base AS (

    SELECT
        ts.*,

        CASE
            WHEN status IN ('open','in_progress','blocked')
            THEN 1 ELSE 0
        END active_flag,

        CASE
            WHEN due_date < TRUNC(SYSDATE)
                 AND status NOT IN ('completed','cancelled')
            THEN 1 ELSE 0
        END overdue_flag

    FROM tasks ts
),

priority_summary AS (

    SELECT priority, COUNT(*) total_active
    FROM task_base
    WHERE active_flag = 1
    GROUP BY priority

),

team_summary AS (

    SELECT
        t.name team_name,
        COUNT(*) active_count
    FROM teams t
    JOIN users u
        ON u.team_id = t.id
    JOIN tasks ts
        ON ts.assigned_to = u.id
    WHERE ts.status IN ('open','in_progress','blocked')
    GROUP BY t.name

)

SELECT

    COUNT(*) AS total_tasks,

    SUM(
        CASE
            WHEN status='completed'
            THEN 1
            ELSE 0
        END
    ) AS completed_tasks,

    SUM(active_flag) AS active_tasks,

    SUM(overdue_flag) AS overdue_tasks,

    ROUND(
        SUM(
            CASE
                WHEN status='completed'
                THEN 1
                ELSE 0
            END
        ) * 100 / COUNT(*),
    2) AS completion_rate_pct,

    ROUND(
        AVG(
            CASE
                WHEN status='completed'
                THEN (completed_at-created_at)*24
            END
        ),
    2) AS avg_resolution_hours,

    ROUND(
        AVG(
            CASE
                WHEN overdue_flag=1
                THEN TRUNC(SYSDATE-due_date)
            END
        ),
    2) AS avg_days_overdue,

    (
        SELECT priority
        FROM priority_summary
        ORDER BY total_active DESC
        FETCH FIRST 1 ROW ONLY
    ) AS most_common_priority,

    (
        SELECT team_name
        FROM team_summary
        ORDER BY active_count DESC
        FETCH FIRST 1 ROW ONLY
    ) AS busiest_team

FROM task_base;
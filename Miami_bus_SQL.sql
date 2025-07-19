CREATE TABLE dev.public.bus_route_summary AS
WITH daily_vehicle_counts AS (
    SELECT
        wk,
        route_short_name,
        mode,
        AVG(trip_count) AS avg_daily_vehicles_per_route
    FROM (
        SELECT
            wk,
            actual_date,
            route_short_name,
            mode,
            COUNT(DISTINCT vehicle_id) AS trip_count
        FROM dev.public.mar3
        GROUP BY wk, actual_date, route_short_name, mode
    ) AS t
    GROUP BY wk, route_short_name, mode
),

peak_hour_vehicles AS (
    SELECT
        wk,
        route_short_name,
        AVG(trip_count) AS vehicles_peak_hr
    FROM (
        SELECT
            wk,
            actual_date,
            route_short_name,
            COUNT(DISTINCT vehicle_id) AS trip_count
        FROM dev.public.mar3
        WHERE hourOfTimestamp1 IN (6,7,8,9,16,17,18,19)
        GROUP BY wk, actual_date, route_short_name
    ) AS t
    GROUP BY wk, route_short_name
),

delay_distribution AS (
    SELECT
        wk,
        route_short_name,
        COUNT(*) AS total_arrivals,
        SUM(CASE WHEN sched_adherence_min < -2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS early_rate,
        SUM(CASE WHEN sched_adherence_min BETWEEN -2 AND 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS on_time_rate,
        SUM(CASE WHEN sched_adherence_min > 2 AND sched_adherence_min <= 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS late_2_5_rate,
        SUM(CASE WHEN sched_adherence_min > 5 AND sched_adherence_min <= 10 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS late_5_10_rate,
        SUM(CASE WHEN sched_adherence_min > 10 AND sched_adherence_min <= 30 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS late_10_30_rate,
        SUM(CASE WHEN sched_adherence_min > 30 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS late_30_plus_rate
    FROM dev.public.mar3
    GROUP BY wk, route_short_name
),

avg_delay AS (
    SELECT
        wk,
        route_short_name,
        AVG(sched_adherence_min) AS avg_delay_time
    FROM dev.public.mar3
    GROUP BY wk, route_short_name
),

trip_durations AS (
    WITH trip_bounds AS (
        SELECT
            wk,
            actual_date,
            route_short_name,
            trip_id,
            MIN(CAST(actual_time AS TIME)) AS min_time,
            MAX(CAST(actual_time AS TIME)) AS max_time
        FROM dev.public.mar3
        GROUP BY wk, actual_date, route_short_name, trip_id
    ),
    durations AS (
        SELECT
            wk,
            actual_date,
            route_short_name,
            trip_id,
            CASE 
                WHEN DATEDIFF(SECOND, min_time, max_time) / 60.0 >= 1000 
                THEN (1440 - (DATEDIFF(SECOND, min_time, max_time) / 60.0))
                ELSE DATEDIFF(SECOND, min_time, max_time) / 60.0
            END AS duration_min
        FROM trip_bounds
    ),
    daily_totals AS (
        SELECT
            wk,
            route_short_name,
            actual_date,
            SUM(duration_min) AS total_duration_min
        FROM durations
        GROUP BY wk, route_short_name, actual_date
    )
    SELECT
        wk,
        route_short_name,
        AVG(total_duration_min) / 60.0 AS avg_duration_hr
    FROM daily_totals
    GROUP BY wk, route_short_name
)

SELECT
    v.wk,
    v.route_short_name,
    v.mode,
    v.avg_daily_vehicles_per_route,
    p.vehicles_peak_hr,
    d.early_rate,
    d.late_30_plus_rate,
    a.avg_delay_time,
    td.avg_duration_hr
FROM daily_vehicle_counts v
LEFT JOIN peak_hour_vehicles p ON v.wk = p.wk AND v.route_short_name = p.route_short_name
LEFT JOIN delay_distribution d ON v.wk = d.wk AND v.route_short_name = d.route_short_name
LEFT JOIN avg_delay a ON v.wk = a.wk AND v.route_short_name = a.route_short_name
LEFT JOIN trip_durations td ON v.wk = td.wk AND v.route_short_name = td.route_short_name
ORDER BY v.wk, v.route_short_name;

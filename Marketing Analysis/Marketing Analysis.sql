-- Build user sessions based on a 60-minute inactivity threshold
WITH sessionized_events AS (
    SELECT
        user_pseudo_id,
        event_name,
        TIMESTAMP_MICROS(event_timestamp) AS event_time,
        campaign,
        country,
        purchase_revenue_in_usd,

        LAG(TIMESTAMP_MICROS(event_timestamp))
            OVER (
                PARTITION BY user_pseudo_id
                ORDER BY event_timestamp
            ) AS previous_event_time
    FROM `turing_data_analytics.raw_events`
),

-- Flag the start of a new session
session_flags AS (
    SELECT
        *,
        CASE
            WHEN previous_event_time IS NULL
              OR event_time - previous_event_time >= INTERVAL 60 MINUTE
            THEN 1
            ELSE 0
        END AS is_new_session
    FROM sessionized_events
),

-- Generate session identifiers
sessions AS (
    SELECT
        *,
        SUM(is_new_session)
            OVER (
                ORDER BY user_pseudo_id, event_time
            ) AS global_session_id,

        SUM(is_new_session)
            OVER (
                PARTITION BY user_pseudo_id
                ORDER BY event_time
            ) AS user_session_id
    FROM session_flags
),

-- Lookup valid marketing campaigns
campaign_lookup AS (
    SELECT DISTINCT
        Campaign AS campaign_name
    FROM `turing_data_analytics.adsense_monthly`
),

-- Calculate total revenue generated within each session
session_revenue AS (
    SELECT
        user_pseudo_id,
        global_session_id,
        SUM(purchase_revenue_in_usd) AS revenue
    FROM sessions
    GROUP BY
        user_pseudo_id,
        global_session_id
),

-- Calculate session duration and session-level attributes
session_summary AS (
    SELECT
        user_pseudo_id,
        global_session_id,
        user_session_id,
        MIN(event_time) AS first_event_time,
        MAX(event_time) AS last_event_time,
        country,

        TIMESTAMP_DIFF(
            MAX(event_time),
            MIN(event_time),
            SECOND
        ) AS session_duration_seconds
    FROM sessions
    GROUP BY
        user_pseudo_id,
        global_session_id,
        user_session_id,
        country
)

-- Final session-level dataset for campaign analysis
SELECT
    ss.user_pseudo_id,
    ss.global_session_id,
    ss.user_session_id,
    ss.first_event_time,
    ss.last_event_time,
    ss.country,
    cl.campaign_name,
    ss.session_duration_seconds,

    CASE
        WHEN EXTRACT(HOUR FROM ss.first_event_time) BETWEEN 0 AND 5 THEN 'Night'
        WHEN EXTRACT(HOUR FROM ss.first_event_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM ss.first_event_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS session_time_of_day,

    CASE
        WHEN ss.session_duration_seconds = 0 THEN 1
        ELSE 0
    END AS bounce_status,

    sr.revenue

FROM session_summary ss

JOIN session_revenue sr
    ON ss.user_pseudo_id = sr.user_pseudo_id
   AND ss.global_session_id = sr.global_session_id

JOIN (
    SELECT DISTINCT
        user_pseudo_id,
        global_session_id,
        campaign
    FROM sessions
) s
    ON ss.user_pseudo_id = s.user_pseudo_id
   AND ss.global_session_id = s.global_session_id

JOIN campaign_lookup cl
    ON s.campaign = cl.campaign_name;

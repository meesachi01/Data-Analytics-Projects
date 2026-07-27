-- =========================================================
-- Customer Purchase Journey Analysis
-- =========================================================
-- Description:
-- This query analyzes customer purchase behavior by:
-- 1. Extracting purchase events
-- 2. Extracting page view events
-- 3. Identifying the first page view before purchase
-- 4. Categorizing purchases by time of day
-- =========================================================

-- Purchase Events
WITH purchases AS (
    SELECT
        user_pseudo_id,
        country,
        category,
        mobile_brand_name,
        purchase_revenue_in_usd,
        -- Convert event timestamp into readable timestamp
        TIMESTAMP_MICROS(event_timestamp) AS purchase_date
    FROM `turing_data_analytics.raw_events`
    WHERE event_name = 'purchase'
),


-- Page View Events
page_views AS (
    SELECT
        user_pseudo_id,
        TIMESTAMP_MICROS(event_timestamp) AS page_view_date
    FROM `turing_data_analytics.raw_events`
    WHERE event_name = 'page_view'
),

-- Join Purchase and Page View Data
joined_data AS (
    SELECT
        p.user_pseudo_id,
        p.country,
        p.category,
        p.purchase_revenue_in_usd,
        p.purchase_date,

        -- Categorize purchase time
        CASE
            WHEN EXTRACT(HOUR FROM p.purchase_date) BETWEEN 0 AND 5 THEN 'Night'
            WHEN EXTRACT(HOUR FROM p.purchase_date) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM p.purchase_date) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM p.purchase_date) BETWEEN 18 AND 23 THEN 'Evening'
        END AS purchase_time_of_day,

        -- Find first page view before purchase
        MIN(pv.page_view_date) AS first_page_view_date

    FROM purchases AS p
    JOIN page_views AS pv
        ON p.user_pseudo_id = pv.user_pseudo_id
       AND DATE(p.purchase_date) = DATE(pv.page_view_date)

    GROUP BY
        p.user_pseudo_id,
        p.country,
        p.category,
        p.purchase_revenue_in_usd,
        p.purchase_date,
        purchase_time_of_day
)

-- Final Output
SELECT
    *
FROM joined_data;

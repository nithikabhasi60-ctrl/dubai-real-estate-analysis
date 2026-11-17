select count(*) from secondary_sales;
SELECT COUNT(*) AS total_rows, COUNT(floor) AS rows_with_floor FROM secondary_sales;

USE dubai_real_estate;
SELECT COUNT(*) AS total_rows,
       COUNT(floor) AS rows_with_floor,
       COUNT(DISTINCT id) AS unique_ids
FROM secondary_sales;
-- expect 50000 and 32180

TRUNCATE TABLE secondary_sales;
SELECT COUNT(*) FROM secondary_sales; 


USE dubai_real_estate;

SELECT 'secondary_sales' AS tbl, COUNT(*) AS total_rows, COUNT(DISTINCT id) AS unique_rows FROM secondary_sales
UNION ALL SELECT 'off_plan', COUNT(*), COUNT(DISTINCT id) FROM off_plan
UNION ALL SELECT 'rentals', COUNT(*), COUNT(DISTINCT id) FROM rentals
UNION ALL SELECT 'area_prices_monthly', COUNT(*), COUNT(DISTINCT `year_month`, community) FROM area_prices_monthly
UNION ALL SELECT 'metro_stations', COUNT(*), COUNT(DISTINCT station_name, `line`) FROM metro_stations;

SELECT COUNT(*) AS total_rows, COUNT(floor) AS rows_with_floor FROM secondary_sales;
-- expect 50000 and 32180

SELECT COUNT(*) AS total_rows, COUNT(offplan_price_per_sqft_usd) AS rows_with_offplan_price FROM area_prices_monthly;
-- expect 6384 and 5624

-- Average price per sq ft by community (top 10 most expensive)--
SELECT community,
       COUNT(*) AS listings,
       ROUND(SUM(price_usd) / SUM(area_sqft)) AS avg_price_per_sqft_usd
FROM secondary_sales
GROUP BY community
HAVING COUNT(*) >= 50
ORDER BY avg_price_per_sqft_usd DESC
LIMIT 10;

-- Secondary vs off-plan price per sq ft by community--
SELECT s.community,
       ROUND(SUM(s.price_usd) / SUM(s.area_sqft)) AS secondary_per_sqft,
       o.offplan_per_sqft,
       ROUND((o.offplan_per_sqft / (SUM(s.price_usd) / SUM(s.area_sqft)) - 1) * 100, 1) AS offplan_premium_pct
FROM secondary_sales s
JOIN (
    SELECT community, ROUND(SUM(price_usd) / SUM(area_sqft)) AS offplan_per_sqft
    FROM off_plan
    GROUP BY community
) o ON o.community = s.community
GROUP BY s.community, o.offplan_per_sqft
ORDER BY offplan_premium_pct DESC
LIMIT 15;

-- Rental yield by community (annual rent as a % of price)--
SELECT s.community,
       ROUND(SUM(r.annual_rent_usd) / SUM(r.area_sqft), 2) AS rent_per_sqft,
       ROUND(SUM(s.price_usd) / SUM(s.area_sqft), 2) AS price_per_sqft,
       ROUND(100 * (SUM(r.annual_rent_usd) / SUM(r.area_sqft)) /
                   (SUM(s.price_usd) / SUM(s.area_sqft)), 2) AS gross_yield_pct
FROM (SELECT community, SUM(price_usd) AS price_usd, SUM(area_sqft) AS area_sqft
      FROM secondary_sales GROUP BY community) s
JOIN (SELECT community, SUM(annual_rent_usd) AS annual_rent_usd, SUM(area_sqft) AS area_sqft
      FROM rentals GROUP BY community) r
  ON r.community = s.community
GROUP BY s.community, r.annual_rent_usd, r.area_sqft, s.price_usd, s.area_sqft
ORDER BY gross_yield_pct DESC
LIMIT 15;

-- check the range--
  SELECT MIN(metro_distance_min) AS min_min,
       MAX(metro_distance_min) AS max_min,
       ROUND(AVG(metro_distance_min), 1) AS avg_min
FROM secondary_sales;
SELECT metro_distance_type, COUNT(*) AS listings
FROM secondary_sales
GROUP BY metro_distance_type;

-- price per sq ft by metro distance bucket --
SELECT CASE
         WHEN metro_distance_min <= 5  THEN '1. 0-5 min'
         WHEN metro_distance_min <= 10 THEN '2. 6-10 min'
         WHEN metro_distance_min <= 20 THEN '3. 11-20 min'
         ELSE '4. 20+ min'
       END AS metro_distance_bucket,
       COUNT(*) AS listings,
       ROUND(SUM(price_usd) / SUM(area_sqft)) AS avg_price_per_sqft_usd
FROM secondary_sales
GROUP BY metro_distance_bucket
ORDER BY metro_distance_bucket;

SELECT property_category,
       CASE
         WHEN metro_distance_min <= 10 THEN 'Near (0-10 min)'
         ELSE 'Far (10+ min)'
       END AS metro_group,
       COUNT(*) AS listings,
       ROUND(SUM(price_usd) / SUM(area_sqft)) AS avg_price_per_sqft_usd
FROM secondary_sales
GROUP BY property_category, metro_group
ORDER BY property_category, metro_group;

-- Walking vs driving, by property type --
SELECT metro_distance_type, property_category,
       COUNT(*) AS listings,
       ROUND(SUM(price_usd) / SUM(area_sqft)) AS avg_price_per_sqft_usd
FROM secondary_sales
GROUP BY metro_distance_type, property_category
ORDER BY property_category, metro_distance_type;

-- Walking listings only, by distance:--
SELECT CASE
         WHEN metro_distance_min <= 5  THEN '1. 0-5 min walk'
         WHEN metro_distance_min <= 10 THEN '2. 6-10 min walk'
         ELSE '3. 10+ min walk'
       END AS walk_bucket,
       COUNT(*) AS listings,
       ROUND(SUM(price_usd) / SUM(area_sqft)) AS avg_price_per_sqft_usd
FROM secondary_sales
WHERE metro_distance_type = 'walk'
GROUP BY walk_bucket
ORDER BY walk_bucket;

-- Fastest-growing communities, from the first month to the latest: --
WITH first_m AS (
    SELECT community, secondary_price_per_sqft_usd AS start_price
    FROM area_prices_monthly
    WHERE `year_month` = (SELECT MIN(`year_month`) FROM area_prices_monthly)
),
last_m AS (
    SELECT community, secondary_price_per_sqft_usd AS end_price
    FROM area_prices_monthly
    WHERE `year_month` = (SELECT MAX(`year_month`) FROM area_prices_monthly)
)
SELECT f.community, f.start_price, l.end_price,
       ROUND(100 * (l.end_price / f.start_price - 1), 1) AS growth_pct
FROM first_m f
JOIN last_m l ON l.community = f.community
ORDER BY growth_pct DESC
LIMIT 10;

-- Yearly trend, with interest rates alongside: --
SELECT LEFT(`year_month`, 4) AS yr,
       ROUND(AVG(secondary_price_per_sqft_usd)) AS avg_secondary_per_sqft,
       ROUND(AVG(offplan_price_per_sqft_usd))   AS avg_offplan_per_sqft,
       ROUND(AVG(rental_price_per_sqft_annual_usd), 1) AS avg_rent_per_sqft,
       ROUND(AVG(avg_mortgage_rate_pct), 2)     AS avg_mortgage_rate
FROM area_prices_monthly
GROUP BY yr
ORDER BY yr;

SELECT MIN(`year_month`), MAX(`year_month`) FROM area_prices_monthly;

SELECT LEFT(`year_month`, 4) AS yr,
       COUNT(DISTINCT `year_month`) AS months_in_data,
       ROUND(AVG(secondary_price_per_sqft_usd)) AS avg_secondary_per_sqft,
       ROUND(AVG(avg_mortgage_rate_pct), 2) AS avg_mortgage_rate
FROM area_prices_monthly
WHERE RIGHT(`year_month`, 2) IN ('01', '02', '03', '04')
GROUP BY yr
ORDER BY yr;

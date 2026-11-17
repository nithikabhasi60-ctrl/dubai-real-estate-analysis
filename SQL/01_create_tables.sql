create database dubai_real_estate;
USE dubai_real_estate;
-- Creating Table --
CREATE TABLE secondary_sales (
  id VARCHAR(50), date_listed VARCHAR(20), community VARCHAR(100), zone VARCHAR(100),
  is_freehold VARCHAR(5), lat DECIMAL(9,6), lon DECIMAL(9,6),
  property_category VARCHAR(50), property_type VARCHAR(50), bedrooms INT,
  area_sqft INT, area_m2 DECIMAL(10,2), floor INT NULL, total_floors INT NULL,
  year_built INT, `view` VARCHAR(50), furnishing VARCHAR(50), `condition` VARCHAR(50),
  parking_spaces INT, chiller_included VARCHAR(5), metro_station VARCHAR(100),
  metro_line VARCHAR(50), metro_distance_min INT, metro_distance_type VARCHAR(50),
  to_burj_khalifa_km DECIMAL(8,2), price_usd BIGINT, price_per_sqft_usd INT,
  price_per_m2_usd INT, mortgage_rate_at_listing DECIMAL(6,3)
);

CREATE TABLE off_plan (
  id VARCHAR(50), date_listed VARCHAR(20), project_id VARCHAR(50), project_name VARCHAR(150),
  developer VARCHAR(100), developer_tier VARCHAR(50), community VARCHAR(100), zone VARCHAR(100),
  lat DECIMAL(9,6), lon DECIMAL(9,6), property_category VARCHAR(50), property_type VARCHAR(50),
  bedrooms INT, area_sqft INT, area_m2 DECIMAL(10,2), `view` VARCHAR(50),
  launch_year INT, handover_year INT, total_project_units INT, payment_plan VARCHAR(50),
  metro_station VARCHAR(100), metro_line VARCHAR(50), metro_distance_min INT,
  to_burj_khalifa_km DECIMAL(8,2), price_usd BIGINT, price_per_sqft_usd INT,
  price_per_m2_usd INT, mortgage_rate_at_listing DECIMAL(6,3)
);

CREATE TABLE rentals (
  id VARCHAR(50), date_listed VARCHAR(20), community VARCHAR(100), zone VARCHAR(100),
  lat DECIMAL(9,6), lon DECIMAL(9,6), property_category VARCHAR(50), property_type VARCHAR(50),
  bedrooms INT, area_sqft INT, area_m2 DECIMAL(10,2), `view` VARCHAR(50), furnishing VARCHAR(50),
  chiller_included VARCHAR(5), parking_spaces INT, metro_station VARCHAR(100),
  metro_line VARCHAR(50), metro_distance_min INT, to_burj_khalifa_km DECIMAL(8,2),
  contract_type VARCHAR(50), n_cheques INT, annual_rent_usd INT,
  rent_per_sqft_usd INT, rent_per_m2_usd INT
);

CREATE TABLE area_prices_monthly (
  `year_month` VARCHAR(10), community VARCHAR(100), zone VARCHAR(100), is_freehold VARCHAR(5),
  secondary_price_per_sqft_usd INT, secondary_price_per_m2_usd INT,
  offplan_price_per_sqft_usd DECIMAL(10,2) NULL, rental_price_per_sqft_annual_usd INT,
  n_listings_secondary INT, n_listings_offplan INT, n_listings_rental INT,
  cbuae_base_rate_pct DECIMAL(6,3), avg_mortgage_rate_pct DECIMAL(6,3)
);

CREATE TABLE metro_stations (
  station_name VARCHAR(100), `line` VARCHAR(50), lat DECIMAL(9,6), lon DECIMAL(9,6),
  year_opened INT, to_burj_khalifa_km DECIMAL(8,2)
);

-- Modifying the table, truncating--

select count(*) from area_prices_monthly;
TRUNCATE TABLE area_prices_monthly;
ALTER TABLE area_prices_monthly MODIFY offplan_price_per_sqft_usd VARCHAR(20);
DESCRIBE area_prices_monthly;

SET SQL_SAFE_UPDATES = 0;

UPDATE area_prices_monthly
SET offplan_price_per_sqft_usd = NULL
WHERE TRIM(offplan_price_per_sqft_usd) = '';

ALTER TABLE area_prices_monthly
MODIFY offplan_price_per_sqft_usd DECIMAL(10,2) NULL;

SELECT COUNT(*) AS total_rows,
       COUNT(offplan_price_per_sqft_usd) AS rows_with_offplan_price
FROM area_prices_monthly;

ALTER TABLE secondary_sales MODIFY floor VARCHAR(10);
ALTER TABLE secondary_sales MODIFY total_floors VARCHAR(10);



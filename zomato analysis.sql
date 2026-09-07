CREATE DATABASE zomato;

CREATE TABLE zomato (
  Restaurant_ID INT,
  Restaurant_Name TEXT,
  Country_Code INTEGER,
  City TEXT,
  Address TEXT,
  Cuisines TEXT,
  Average_Cost_for_two INTEGER,
  Currency TEXT,
  Has_Table_booking TEXT,
  Has_Online_delivery TEXT,
  Aggregate_rating REAL,
  Rating_text TEXT,
  Votes INTEGER
);

-- Focus on India only (Country_Code = 1)
-- Check rating distribution
SELECT Rating_text, COUNT(*) AS count
FROM zomato
WHERE Country_Code = 1
GROUP BY Rating_text
ORDER BY count DESC;


-- Level 1 — Market & Restaurant Landscape.
-- Goal: Understand where Zomato's restaurant ecosystem is concentrated and what the market looks like.


-- 1. Which cities have the most restaurants?
SELECT 
	City,
	COUNT(*) AS Resturant_count
FROM zomato
WHERE Country_Code = 1
GROUP BY city
ORDER BY Resturant_count DESC;

-- 2. What are the most popular cuisines in India?
SELECT
	Cuisines,
	ROUND(AVG(Aggregate_rating)::NUMERIC, 2) AS Average_rating
FROM zomato
WHERE Country_code = 1
GROUP BY Cuisines
ORDER BY Average_rating DESC;

-- 3. Which cities have the strongest restaurant diversity?
SELECT
    City,
    COUNT(*) AS restaurant_count,
    COUNT(DISTINCT Cuisines) AS cuisine_variety
FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY cuisine_variety DESC;

-- 4. Which cities combine restaurant scale with high average ratings?
SELECT
    City,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(Aggregate_rating)::NUMERIC, 2) AS avg_rating,
    ROUND(AVG(Votes):: NUMERIC, 0) AS avg_votes
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating > 0
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY avg_rating DESC;

--===============================================================================
-- Level 2 — Customer Trust & Restaurant Performance
--===============================================================================
-- Goal:Where is customer trust weakest?
----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- 5.Does higher customer engagement correspond to better ratings?
SELECT 
  CASE 
    WHEN Votes < 100 THEN 'Low votes (under 100)'
    WHEN Votes BETWEEN 100 AND 500 THEN 'Medium (100-500)'
    WHEN Votes BETWEEN 500 AND 2000 THEN 'High (500-2000)'
    ELSE 'Very High (2000+)'
  END AS vote_category,
  COUNT(*) AS restaurants,
  ROUND(AVG(Aggregate_rating):: NUMERIC, 2) AS avg_rating
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating > 0
GROUP BY vote_category
ORDER BY avg_rating DESC;


-- Q6. Which restaurants have high engagement but poor ratings?
SELECT
    Restaurant_Name,
    City,
    Cuisines,
    Votes,
    Aggregate_rating,
    Rating_text
FROM zomato
WHERE Country_Code = 1
  AND Votes >= 500
  AND Aggregate_rating BETWEEN 2.5 AND 3.5
ORDER BY Votes DESC;

-- 7. Where is customer trust weakest by city?
SELECT
    City,
    COUNT(*) AS restaurants,
    SUM(
        CASE
            WHEN Aggregate_rating > 0
             AND Aggregate_rating < 3.0
            THEN 1 ELSE 0
        END
    ) AS low_rated_restaurants,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Aggregate_rating > 0
                 AND Aggregate_rating < 3.0
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS low_rating_pct
FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY low_rating_pct DESC;


-- 8. Which restaurants have strong engagement but below-average ratings?
SELECT
    Restaurant_Name,
    City,
    Votes,
    Aggregate_rating
FROM zomato
WHERE Country_Code = 1
  AND Votes >= (
      SELECT AVG(Votes)
      FROM zomato
      WHERE Country_Code = 1
  )
  AND Aggregate_rating < (
      SELECT AVG(Aggregate_rating)
      FROM zomato
      WHERE Country_Code = 1
        AND Aggregate_rating > 0
  )
ORDER BY Votes DESC;

-- =====================================================================================
-- Level 3 — Service Adoption & Revenue Opportunity
-- =====================================================================================
-- Where are high-value services such as online delivery and table booking under-adopted?
-- -------------------------------------------------------------------------------------------

-- 9. Which cities have the highest online-delivery adoption?
SELECT
	City,
	COUNT(
		CASE WHEN Has_Online_delivery = 'Yes' THEN 1 
	END
	) AS Online_delivery_count
FROM zomato
WHERE Country_code = 1
GROUP BY City
ORDER BY Online_delivery_count DESC;


-- 10. Which cities have high restaurant presence but low delivery adoption?
SELECT
    City,
    COUNT(*) AS total_restaurants,
    SUM(
        CASE
            WHEN Has_Online_delivery = 'Yes'
            THEN 1 ELSE 0
        END
    ) AS delivery_restaurants,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Has_Online_delivery = 'Yes'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS delivery_pct
FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY delivery_pct ASC, total_restaurants DESC;

-- 11. Does table booking influence restaurant performance?
SELECT
    Has_Table_booking,
    COUNT(*) AS restaurants,
    ROUND(AVG(Aggregate_rating):: NUMERIC, 2) AS avg_rating,
    ROUND(AVG(Votes):: NUMERIC, 0) AS avg_votes
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating > 0
GROUP BY Has_Table_booking;

-- 12. Which cities have low table-booking adoption?
SELECT
    City,
    COUNT(*) AS total_restaurants,
    SUM(
        CASE
            WHEN Has_Table_booking = 'Yes'
            THEN 1 ELSE 0
        END
    ) AS booking_restaurants,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Has_Table_booking = 'Yes'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS booking_pct
FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY booking_pct ASC;

-- ============================================================================
-- Level 4 — Strategic City Prioritization
-- ============================================================================
-- Which cities should receive partner-quality support versus growth investment?
-- ------------------------------------------------------------------------------------

--13. Which cities need partner-quality support?
SELECT
    City,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(Aggregate_rating):: NUMERIC, 2) AS avg_rating,
    ROUND(AVG(Votes) :: NUMERIC, 0) AS avg_votes,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Aggregate_rating > 0
                 AND Aggregate_rating < 3
                THEN 1 ELSE 0
            END
        ) / COUNT(*):: NUMERIC,
        1
    ) AS low_rating_pct

FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY low_rating_pct DESC;


-- 14. Which cities represent the strongest growth opportunity?
SELECT
    City,
    COUNT(*) AS restaurant_count,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN Has_Online_delivery = 'Yes'
                THEN 1 ELSE 0
            END
        ) / COUNT(*):: NUMERIC,
        1
    ) AS delivery_pct,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN Has_Table_booking = 'Yes'
                THEN 1 ELSE 0
            END
        ) / COUNT(*):: NUMERIC,
        1
    ) AS booking_pct

FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) >= 50
ORDER BY restaurant_count DESC;

-- Q15. Final City Opportunity Matrix.
WITH city_metrics AS (
    SELECT
        City,
        COUNT(*) AS restaurant_count,

        ROUND(AVG(
            CASE
                WHEN Aggregate_rating > 0
                THEN Aggregate_rating
            END
        ):: NUMERIC, 2) AS avg_rating,

        ROUND(
            100.0 * SUM(
                CASE
                    WHEN Aggregate_rating > 0
                     AND Aggregate_rating < 3
                    THEN 1 ELSE 0
                END
            ) / COUNT(*):: NUMERIC,
            1
        ) AS low_rating_pct,

        ROUND(
            100.0 * SUM(
                CASE
                    WHEN Has_Online_delivery = 'Yes'
                    THEN 1 ELSE 0
                END
            ) / COUNT(*):: NUMERIC,
            1
        ) AS delivery_pct,

        ROUND(
            100.0 * SUM(
                CASE
                    WHEN Has_Table_booking = 'Yes'
                    THEN 1 ELSE 0
                END
            ) / COUNT(*)::NUMERIC,
            1
        ) AS booking_pct

    FROM zomato
    WHERE Country_Code = 1
    GROUP BY City
    HAVING COUNT(*) >= 50
)

SELECT
    City,
    restaurant_count,
    avg_rating,
    low_rating_pct,
    delivery_pct,
    booking_pct,

    CASE
        WHEN low_rating_pct >= 20
             AND avg_rating < 3.5
            THEN 'Partner Quality Support'

        WHEN restaurant_count >= 100
             AND delivery_pct < 40
             AND booking_pct < 20
            THEN 'Growth Investment'

        WHEN avg_rating >= 4.0
             AND delivery_pct >= 50
            THEN 'Strong Market'

        ELSE 'Monitor'
    END AS city_priority

FROM city_metrics
ORDER BY
    CASE
        WHEN low_rating_pct >= 20
             AND avg_rating < 3.5
            THEN 1

        WHEN restaurant_count >= 100
             AND delivery_pct < 40
             AND booking_pct < 20
            THEN 2

        WHEN avg_rating >= 4.0
             AND delivery_pct >= 50
            THEN 3

        ELSE 4
    END,
    restaurant_count DESC;

-- Q16.Which restaurants charge significantly more than their city's average but fail to deliver competitive ratings?
WITH LocalMarketPricing AS (
    SELECT 
        Restaurant_Name,
        City,
        Average_Cost_for_two,
        Aggregate_rating,
        ROUND(AVG(Average_Cost_for_two) OVER (PARTITION BY City):: NUMERIC, 2) AS city_avg_cost
    FROM zomato
    WHERE Country_Code = 1
)
SELECT 
    Restaurant_Name,
    City,
    Average_Cost_for_two,
    city_avg_cost,
    ROUND((Average_Cost_for_two - city_avg_cost) / city_avg_cost * 100.00:: NUMERIC, 2) AS price_premium_pct,
    Aggregate_rating
FROM LocalMarketPricing
WHERE Average_Cost_for_two > city_avg_cost
  AND Aggregate_rating < 3.5
ORDER BY price_premium_pct DESC;


-- Q17.Who are the top 3 most engaged restaurants for every major cuisine category?
WITH RankedRestaurants AS (
    SELECT 
        Restaurant_Name,
        City,
        Cuisines,
        Votes,
        Aggregate_rating,
        DENSE_RANK() OVER (PARTITION BY Cuisines ORDER BY Votes DESC, Aggregate_rating DESC) as market_rank
    FROM zomato
    WHERE Country_Code = 1
      AND Aggregate_rating > 0
)
SELECT 
    Cuisines,
    market_rank,
    Restaurant_Name,
    City,
    Votes,
    Aggregate_rating
FROM RankedRestaurants
WHERE market_rank <= 3
ORDER BY Cuisines, market_rank;

-- Q19.How do we automatically segment restaurants into performance tiers relative to their local competition?
WITH CityPerformanceTiers AS (
    SELECT 
        Restaurant_Name,
        City,
        Aggregate_rating,
        Votes,
        NTILE(4) OVER (PARTITION BY City ORDER BY Aggregate_rating DESC, Votes DESC) as city_tier
    FROM zomato
    WHERE Country_Code = 1
      AND Aggregate_rating > 0
)
SELECT 
    City,
    Restaurant_Name,
    Aggregate_rating,
    Votes,
    CASE 
        WHEN city_tier = 1 THEN 'Premium Partner (Top 25%)'
        WHEN city_tier = 2 THEN 'Growth Target (26-50%)'
        ELSE 'Standard / Monitor'
    END AS partner_status
FROM CityPerformanceTiers
WHERE city_tier <= 2
ORDER BY City, city_tier, Aggregate_rating DESC;
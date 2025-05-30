/*
=========================================================================================================
Quality checks
=========================================================================================================
Script Purpose:
          This script performs quality checks to validate the integrity, consistency, and accuracy of the
          gold layer. These checks ensure:
        - uniqueness of surrogate keys in dimension tables.
        - referential integrity betweem fact and dimension tables.
        - validation of relationships in the data model for analytical purposes.

Usage Notes:
        - Run these checks after data loading silver layer.
        - Investigate and resolve any discrepancies found during the checks.
===========================================================================================================
*/

-- ========================================================================================================
-- checking gold.dim_customers
-- ========================================================================================================
-- check for uniquesness of customer key in gold.dim_customers
-- Expectation: No result
SELECT
      customer_key,
      COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ========================================================================================================
-- checking gold.product_dim
-- ========================================================================================================
-- check for uniquesness of product key in gold.product_dim
-- Expectation: No result

SELECT
      product_key,
      COUNT(*) AS duplicate_count
FROM gold.product_dim
GROUP BY product_key
HAVING COUNT(*) > 1;


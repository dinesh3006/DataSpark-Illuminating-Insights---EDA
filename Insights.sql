-- 1. Top Country by Customer Count
-- Question: Which country has the highest customer count, and how much higher is it than the lowest country?

SELECT
  `country`,
  COUNT(`customerkey`) AS `CustomerCount`
FROM
  `Customers`
GROUP BY
  `country`
ORDER BY
  `CustomerCount` DESC  -- (ASC)
LIMIT
  1;

-- 2. Customer Count Percentage by Country
-- Question: What percentage of total customers is represented by each country?

SELECT
  `country`,
  COUNT(`customerkey`) AS `CustomerCount`,
  ROUND(
    COUNT(`customerkey`) * 100.0 / SUM(COUNT(`customerkey`)) OVER (),
    2
  ) AS `CustomerPercentage`
FROM
  `Customers`
GROUP BY
  `country`
ORDER BY
  `CustomerPercentage` DESC;

-- 3. Correlation Check between Purchase Frequency and Order Value
-- Question: Is there a negative correlation between purchase frequency and order value?


SELECT
  `sales`.`customerkey`,
  `sales`.`order_number` AS PurchaseFrequency,
  `sales`.`quantity` AS OrderValue,
  CASE
    WHEN `sales`.`quantity` > `sales`.`order_number` THEN 'Diverged'
    ELSE 'Converged'
  END AS Divergence
FROM
  `sales`
WHERE
  `sales`.`customerkey` = 1702221;

-- 4. Range of Purchase Frequency and Order Value
-- Question: What is the range of purchase frequency and order value across all customers?

SELECT
  MIN(`sales`.`quantity`) AS MinPurchaseFrequency,
  MAX(`sales`.`quantity`) AS MaxPurchaseFrequency,
  MIN(`sales`.`order_number`) AS MinOrderValue,
  MAX(`sales`.`order_number`) AS MaxOrderValue
FROM
  `sales`;

-- 5. Average Total Spent by Gender
-- Question: What is the average total amount spent by each gender? 


SELECT
  `c`.`gender`,
  ROUND(SUM(`p`.`unit_price_usd` * `s`.`quantity`), 2) AS `AvgTotalSpent`
FROM
  `customers` AS `c`
  JOIN `sales` AS `s` ON `c`.`customerkey` = `s`.`customerkey`
  JOIN `products` AS `p` ON `s`.`productkey` = `p`.`productkey`
GROUP BY
  `c`.`gender`
ORDER BY
  `AvgTotalSpent` DESC;  -- ASC

-- 6. Total Spent by Age Group and Gender
-- Question: In which age group did total spent diverge the most between males and females?

SELECT
  ROUND(SUM(`s`.`quantity` * `p`.`unit_price_usd`), 2) AS `TotalSpent`,
  `c`.`gender`
FROM
  `customers` AS `c`
  JOIN `sales` AS `s` ON `c`.`customerkey` = `s`.`customerkey`
  JOIN `products` AS `p` ON `s`.`productkey` = `p`.`productkey`
GROUP BY
  `c`.`gender`
ORDER BY
  `TotalSpent` DESC;

-- 7. Store with the Highest and Lowest Total Sales
-- Question: Which store had the highest and lowest total sales?

SELECT
  `stores`.`storekey`,
  ROUND(
    SUM(`sales`.`quantity` * `products`.`unit_price_usd`),
    2
  ) AS TotalSalesByStore
FROM
  `stores`
  JOIN `sales` ON `stores`.`storekey` = `sales`.`storekey`
  JOIN `products` ON `sales`.`productkey` = `products`.`productkey`
GROUP BY
  `stores`.`storekey`
ORDER BY
  TotalSalesByStore DESC;

-- 8. Top Product by Sales
-- Question: Which product generated the highest total sales, and how much higher is it than the lowest-selling product?

SELECT
  `p`.`brand`,
  ROUND(SUM(`s`.`quantity` * `p`.`unit_price_usd`), 2) AS `TotalSales`
FROM
  `products` AS `p`
  JOIN `sales` AS `s` ON `p`.`productkey` = `s`.`productkey`
GROUP BY
  `p`.`brand`
ORDER BY
  `TotalSales` DESC
LIMIT
  1;

-- 9. Sales Per Square Meter by State
-- Question: What is the range of sales per square meter across different states?

SELECT
  `stores`.`state`,
  ROUND(
    SUM(`sales`.`quantity` * `products`.`unit_price_usd`) / SUM(`stores`.`square_meters`),
    2
  ) AS SalesPerSquareMeter
FROM
  `stores`
  JOIN `sales` ON `stores`.`storekey` = `sales`.`storekey`
  JOIN `products` ON `sales`.`productkey` = `products`.`productkey`
GROUP BY
  `stores`.`state`
ORDER BY
  SalesPerSquareMeter DESC;

-- 10. Top City by Customer Count
-- Question: Which city has the highest customer count within each country?


SELECT
  `customers`.`country`,
  `customers`.`city`,
  COUNT(`customers`.`customerkey`) AS `CustomerCount`
FROM
  `customers`
GROUP BY
  `customers`.`country`,
  `customers`.`city`
ORDER BY
  `CustomerCount` DESC;

-- 11. Average Order Value by Country and Age Group
-- Question: What is the average order value for each country segmented by age group?

SELECT
  `stores`.`country`,
  CASE
    WHEN `customers`.`birthday` IS NOT NULL THEN YEAR(CURDATE()) - YEAR(STR_TO_DATE(`customers`.`birthday`, '%m/%d/%Y'))
  END AS `AgeGroup`,
  ROUND(
    AVG(`sales`.`quantity` * `products`.`unit_price_usd`),
    2
  ) AS `AvgOrderValue`
FROM
  `sales`
  JOIN `customers` ON `sales`.`customerkey` = `customers`.`customerkey`
  JOIN `products` ON `sales`.`productkey` = `products`.`productkey`
  JOIN `stores` ON `sales`.`storekey` = `stores`.`storekey`
GROUP BY
  `stores`.`country`,
  `AgeGroup`
ORDER BY
  `AvgOrderValue` DESC;

-- 12. Average Sales and Order Value by Store Type
-- Question: What are the average sales and average order value by each store type (e.g., online vs. physical)?

 SELECT
  `stores`.`state`,
  ROUND(AVG(`sales`.`quantity`), 2) AS AvgSales,
  ROUND(
    AVG(`sales`.`quantity` * `products`.`unit_price_usd`),
    2
  ) AS AvgOrderValue
FROM
  `stores`
  JOIN `sales` ON `stores`.`storekey` = `sales`.`storekey`
  JOIN `products` ON `sales`.`productkey` = `products`.`productkey`
GROUP BY
  `stores`.`state`
ORDER BY
  AvgSales DESC;


-- 13. Total Sales by Brand and Category
-- Question: What are the total sales by each brand and category?

SELECT
  `products`.`brand`,
  `products`.`category`,
  ROUND(
    SUM(`sales`.`quantity` * `products`.`unit_price_usd`),
    2
  ) AS TotalSales
FROM
  `products`
  JOIN `sales` ON `products`.`productkey` = `sales`.`productkey`
GROUP BY
  `products`.`brand`,
  `products`.`category`
ORDER BY
  TotalSales DESC;

-- 14. Average Order Value by Age and Gender
-- Question: What is the average order value by age group and gender?

SELECT
  YEAR(CURDATE()) - YEAR(STR_TO_DATE(`C`.`birthday`, '%m/%d/%Y')) AS `AgeGroup`,
  `C`.`gender` AS `Gender`,
  ROUND(AVG(`O`.`quantity` * `P`.`unit_price_usd`), 2) AS `AvgOrderValue`
FROM
  `customers` AS `C`
  JOIN `sales` AS `O` ON `C`.`customerkey` = `O`.`customerkey`
  JOIN `products` AS `P` ON `O`.`productkey` = `P`.`productkey`
GROUP BY
  `AgeGroup`,
  `Gender`
ORDER BY
  `AgeGroup`,
  `AvgOrderValue` DESC;

-- 15. Customer Distribution by State and Age Group
-- Question: How are customers distributed by state and age group?

SELECT
  `state`,
  COUNT(`customerkey`) AS `CustomerCount`
FROM
  `customers`
GROUP BY
  `state`
ORDER BY
  `state`,
  `CustomerCount` DESC;

-- 16. Highest and Lowest TotalSpent by Age Group
-- Question: What is the range of TotalSpent for each age group?

SELECT
  `gender` AS `AgeGroup`,
  MIN(`quantity`) AS `MinTotalSpent`,
  MAX(`quantity`) AS `MaxTotalSpent`
FROM
  `customers`
  JOIN `sales` ON `customers`.`customerkey` = `sales`.`customerkey`
GROUP BY
  `gender`
ORDER BY
  `gender`;

-- 17. Total Sales by Continent
-- Question: How does total sales vary across continents?

SELECT
  `C`.`continent`,
  ROUND(SUM(`O`.`quantity` * `P`.`unit_price_usd`), 2) AS TotalSales
FROM
  `customers` AS `C`
  JOIN `sales` AS `O` ON `C`.`customerkey` = `O`.`customerkey`
  JOIN `products` AS `P` ON `O`.`productkey` = `P`.`productkey`
GROUP BY
  `C`.`continent`
ORDER BY
  TotalSales DESC;

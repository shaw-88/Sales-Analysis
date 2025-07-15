USE AmazonSalesDB

-------------------------------------* Cancellation Analysis *---------------------------------------
-- 1. Cancellation rate per Category
SELECT Category, 
       COUNT(*) AS Total_Orders,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders,
       ROUND(100 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
JOIN Products ON Orders.SKU = Products.SKU
GROUP BY Category;

-- 2. Top states with highest cancellation rate
SELECT ship_state, 
       COUNT(*) AS Total_Orders,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Shipping
JOIN Orders ON Shipping.Order_ID = Orders.Order_ID
GROUP BY ship_state
ORDER BY Cancellation_Rate DESC;

-- 3. Size-wise cancellation pattern
SELECT Size,
       COUNT(*) AS Total,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
JOIN Products ON Orders.SKU = Products.SKU
GROUP BY Size;

-- 4. Does Coupon Usage influence cancellation?
SELECT Coupon_Applied,
       COUNT(*) AS Total_Orders,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
GROUP BY Coupon_Applied;

-- 5. Fulfillment type vs cancellation
SELECT Fulfilment,
       COUNT(*) AS Total,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
GROUP BY Fulfilment;

-- 6. Date-wise cancellation trend
SELECT MONTH(Date) AS Month,
       COUNT(*) AS Total,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
GROUP BY MONTH(Date)
ORDER BY Month

-- 7. Channel-wise cancellation
SELECT Sales_Channel ,
       COUNT(*) AS Total,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
GROUP BY Sales_Channel;

-- 8. Courier status and cancellation relation
SELECT Courier_Status,
       COUNT(*) AS Total,
       SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders
GROUP BY Courier_Status;

-------------------------------------------* SALES AND REVENUE *-----------------------------------------

-- 9. Top performing categories by revenue
SELECT Category,
       SUM(Amount)/1000 AS Total_Revenue
FROM Orders
JOIN Products ON Orders.SKU = Products.SKU
GROUP BY Category
ORDER BY Total_Revenue DESC;

-- 10. Revenue by shipping state
SELECT ship_state,
       SUM(Amount)/1000 AS Revenue
FROM Shipping
JOIN Orders ON Shipping.Order_ID = Orders.Order_ID
GROUP BY ship_state
ORDER BY Revenue DESC;

-- 11. Category-size combinations with highest revenue
SELECT Category, Size,
       SUM(Amount) AS Revenue
FROM Orders
JOIN Products ON Orders.SKU = Products.SKU
GROUP BY Category, Size
ORDER BY Revenue DESC;

-- 12. Coupon-wise sales comparison
SELECT Coupon_Applied,
       COUNT(*) AS Orders,
       SUM(Amount) AS Revenue
FROM Orders
GROUP BY Coupon_Applied;

-- 13. Monthly sales trend
SELECT FORMAT(Date, 'yyyy-MM') AS Month,
       COUNT(*) AS Orders,
       SUM(Amount) AS Revenue
FROM Orders
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY Month;

-- 14. Size-wise revenue performance
SELECT Size,
       SUM(Amount) AS Revenue
FROM Orders
JOIN Products ON Orders.SKU = Products.SKU
GROUP BY Size
ORDER BY Revenue DESC;

-- 15. Channel-wise revenue
SELECT Sales_Channel ,
       SUM(Amount) AS Revenue
FROM Orders
GROUP BY Sales_Channel 
ORDER BY Revenue DESC;

--------------------------Advanced & Strategy Queries--------------------

-- 16. Average delivery amount per courier status
SELECT Courier_Status, 
       AVG(Amount) AS Avg_Delivery_Amount
FROM Orders
GROUP BY Courier_Status;

-- 17. Cancellation Rate by State and Category
SELECT s.ship_state, p.Category,
       COUNT(*) AS Total,
       SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100 * SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders o
JOIN Shipping s ON o.Order_ID = s.Order_ID
JOIN Products p ON o.SKU = p.SKU
GROUP BY s.ship_state, p.Category
ORDER BY Cancellation_Rate DESC;

-- 18. Top 5 worst performing Category-Size pairs by cancellation
SELECT TOP 5 p.Category, p.Size,
       COUNT(*) AS Total,
       SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(100.0 * SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancellation_Rate
FROM Orders o
JOIN Products p ON o.SKU = p.SKU
GROUP BY p.Category, p.Size
ORDER BY Cancellation_Rate DESC;

-- 19. Repeat orders (same city, same product)
SELECT o.SKU, s.ship_city, COUNT(*) AS Repeat_Count
FROM Orders o
JOIN Shipping s ON o.Order_ID = s.Order_ID
GROUP BY o.SKU, s.ship_city
HAVING COUNT(*) > 1
ORDER BY Repeat_Count DESC;

-- 20. State-wise fulfillment performance
SELECT ship_state, Fulfilment,
       COUNT(*) AS Orders,
       SUM(Amount) AS Revenue
FROM Orders
JOIN Shipping ON Orders.Order_ID = Shipping.Order_ID
GROUP BY ship_state, Fulfilment
ORDER BY Orders DESC;

--------------------------------------Advanced SQL Queries for Insight Extraction-------------------

--21. Running Total of Revenue
SELECT 
    o.Date,
    SUM(o.Amount) AS Daily_Revenue,
    SUM(SUM(o.Amount)) OVER (ORDER BY o.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Running_Total_Revenue
FROM Orders o
GROUP BY o.Date
ORDER BY o.Date;

--22. Rank Products by Sales Within Category
WITH Ranked_Products AS (
    SELECT 
        p.Category,
        p.SKU,
        SUM(o.Amount) AS Total_Sales,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(o.Amount) DESC) AS Sales_Rank
    FROM Orders o
    JOIN Products p ON o.SKU = p.SKU
    GROUP BY p.Category, p.SKU
)
SELECT *
FROM Ranked_Products
WHERE Sales_Rank <= 3
ORDER BY Category, Sales_Rank;

--23. Dense Rank of States by Cancellation (DENSE_RANK)
SELECT 
    s.ship_state,
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
    DENSE_RANK() OVER (ORDER BY SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) DESC) AS Cancellation_Rank
FROM Shipping s
JOIN Orders o ON s.Order_ID = o.Order_ID
GROUP BY s.ship_state;

--24. % Change in Sales Month-over-Month (LAG)
SELECT 
    FORMAT(o.Date, 'yyyy-MM') AS Sales_Month,
    SUM(o.Amount) AS Total_Sales,
    LAG(SUM(o.Amount)) OVER (ORDER BY FORMAT(o.Date, 'yyyy-MM')) AS Prev_Month_Sales,
    ROUND(
        100.0 * (SUM(o.Amount) - LAG(SUM(o.Amount)) OVER (ORDER BY FORMAT(o.Date, 'yyyy-MM'))) /
        NULLIF(LAG(SUM(o.Amount)) OVER (ORDER BY FORMAT(o.Date, 'yyyy-MM')), 0), 2
    ) AS MoM_Change
FROM Orders o
GROUP BY FORMAT(o.Date, 'yyyy-MM')
ORDER BY Sales_Month;
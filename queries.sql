--#1 Display each store's total orders, total revenue, average order value, and total profit. Sort the result by highest revenue.
select s.Store_id, s.Store_Name, s.Store_City,
count(distinct o.order_id) as Total_Orders,
round(sum(od.Final_amount),2) as Total_Revenue,
round(avg(o.Total_Amount), 2) as Average_Order_Value,
round(sum(od.profit), 2) as Total_Profit
from stores s inner join orders o on
s.store_id = o.store_id 
inner join order_details od on o.order_id = od.order_id
where delivery_status = 'Delivered'
group by s.Store_id, s.Store_Name, s.Store_City
order by Total_Revenue desc;

-- #2 Classify customers based on total spending.
-- #•	Platinum → Above ₹1,50,000 
-- #•	Gold → ₹80,000–₹1,50,000 
-- #•	Silver → ₹30,000–₹79,999 
-- #•	Bronze → Below ₹30,000 
-- #Show only customers having more than 2 orders.

select c.Customer_ID, c.Customer_Name,
count(distinct o.Order_id) As Total_Orders,
ROund(sum(o.Total_Amount),2) as Total_Spending, 
case 
when sum(o.Total_Amount) > 150000 then 'Platinum'
when sum(o.Total_Amount) between 80000 and 150000 then 'Gold'
when sum(o.Total_Amount) between 30000 and 79000 then 'Silver'
else 'Bronze'
end as 'Customer_Segment'
from Customers c inner join orders o on c.customer_id = o.customer_id 
where delivery_Status = 'delivered'
group by c.Customer_ID, c.Customer_Name
order by Total_Spending desc limit 10;

-- #3 Find the highest revenue-generating product in each product category.
-- #If two products have the same revenue, show both.
 with Product_Sales as 
 (select p.Product_ID,p.Product_Name, 
 p.category as Product_Category,
 sum(od.Quantity) as Total_Quantity_Sold,
 round(sum(od.Final_Amount),2) as Total_Revenue
 from Products p inner join Order_Details od 
 on p.product_id = od.product_id 
 inner join Orders o on od.order_id = o.order_id
 where o.delivery_status = 'Delivered'
 group by p.Product_id, p.Product_Name, p.Category
 ),
 Product_Rank as (
 select *, dense_rank() 
 over(partition by Product_Category order by Total_Revenue desc) 
 as Product_Rank from Product_Sales)
 select Product_ID, Product_Name, 
 Product_Category, Total_Quantity_Sold, Total_Revenue, Product_Rank
 from Product_Rank where Product_Rank = 1 order by Product_Category;
 
 -- #4 Find top 10 customers whose total purchase amount is greater than the 
 -- #average spending of all customers.
 select c.Customer_ID, c.Customer_Name, 
 count(distinct o.order_id) as Total_Orders, 
 Round(sum(o.Total_Amount), 2) as Customer_Spending from customers c
 inner join orders o on c.customer_id= o.customer_id
 where o.delivery_status = 'delivered' 
 group by c.Customer_ID, c.Customer_Name
 having sum(o.Total_Amount) > (select avg(Customer_Spending)  
 from (select Customer_ID, sum(Total_Amount) as Customer_Spending
 from orders where delivery_status = 'delivered'
 group by Customer_ID) as Avg_Spending)
 order by Customer_Spending desc limit 10;
 
-- #5 Display monthly revenue. Also show Previous month's revenue, Revenue Difference ,Growth % 
WITH Monthly_Sales AS
(
SELECT YEAR(Order_Date) AS Year, MONTH(Order_Date) AS Month,
ROUND(SUM(Total_Amount),2) AS Total_Revenue FROM Orders 
WHERE Delivery_Status = 'Delivered'
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT Year, Month, Total_Revenue, LAG(Total_Revenue) 
OVER( ORDER BY Year, Month) AS Previous_Month_Revenue,
ROUND( Total_Revenue - LAG(Total_Revenue) 
OVER( ORDER BY Year, Month),2) AS Revenue_Difference,
ROUND(((Total_Revenue - LAG(Total_Revenue) 
OVER(ORDER BY Year, Month)) / LAG(Total_Revenue) 
OVER( ORDER BY Year, Month)
 ) * 100,2 ) AS Growth_Percentage
FROM Monthly_Sales ORDER BY Year, Month;

select year(order_Date) as year, month(order_Date) as month, round(sum(total_amount),2) as total_revenue, 
round(lag(sum(total_amount)) over(order by year(order_Date) ,month(order_Date)),2) as previous_month_revenue,  
round(sum(total_amount) - lag(sum(total_amount)) over(order by year(order_Date) ,month(order_Date)),2) as Revenue_Difference,
round(round(sum(total_amount) - lag(sum(total_amount)) over(order by year(order_Date) ,month(order_Date)),2) * 100 / 
round(lag(sum(total_amount)) over(order by year(order_Date) ,month(order_Date)),2) ,2)as growth_Percentage
from orders where delivery_Status='delivered' group by YEAR(Order_Date), month(order_date);
 
-- #6 Rank all products based on total revenue.
#Display
#	Rank 
#	Dense Rank 
#	Row Number 
#Also display revenue.
 
select p.product_id,p.Product_Name, p.Category, sum(od.Quantity) as Total_Quantity_Sold, 
round(sum(od.Final_Amount),2) as Total_Revenue, 
row_number() over(order by sum(od.final_amount) desc) as Row_Num,
rank() over(order by sum(od.final_amount) desc) as Product_Rank,
dense_rank() over(order by sum(od.final_amount) desc) as Dense_Product_Rank
from products p inner join order_details od on p.product_id = od.product_id
inner join orders o on od.order_id = o.order_id
where delivery_Status='delivered' group by p.product_id,p.Product_Name, p.Category
order by Total_Revenue limit 10;

-- #7For every supplier display
#•	Total Products 
#•	Average Product Rating 
#•	Total Orders 
#•	Total Revenue Generated 
#Sort by Revenue.

select s.Supplier_ID, s.supplier_name,
count(distinct p.Product_ID) as Total_Products, 
round( avg(p.Product_Rating ),2) as average_rating, 
count(distinct od.order_ID) as total_orders, 
round(sum(od.Final_Amount),2) as Total_Revenue 
from  products p inner join Suppliers s on p.supplier_id = s.supplier_id 
left join  order_details od on p.product_id = od.product_id 
left join orders o on o.order_id=od.order_id
where o.delivery_status = 'Delivered' 
group by s.Supplier_ID, s.supplier_name order by Total_Revenue desc limit 10; 

SELECT
    s.Supplier_ID,
    s.Supplier_Name,

    COUNT(DISTINCT p.Product_ID) AS Total_Products,

    ROUND(AVG(p.Product_Rating),2) AS Average_Rating,

    COUNT(DISTINCT od.Order_ID) AS Total_Orders,

    ROUND(SUM(od.Final_Amount),2) AS Total_Revenue

FROM Suppliers s

INNER JOIN Products p
ON s.Supplier_ID = p.Supplier_ID

LEFT JOIN Order_Details od
ON p.Product_ID = od.Product_ID

LEFT JOIN Orders o
ON od.Order_ID = o.Order_ID

WHERE o.Delivery_Status = 'Delivered'

GROUP BY
    s.Supplier_ID,
    s.Supplier_Name

ORDER BY Total_Revenue DESC;

-- #8 Find products that were never sold.Display •	Product Name  •	Category  •	Supplier Name.  Also create a Status column. sold unsold
SELECT p.Product_ID, p.Product_Name, p.Category, s.Supplier_Name,
CASE
	WHEN od.Product_ID IS NULL THEN 'Not Sold'
	ELSE 'Sold'
    END AS Status
FROM Products p INNER JOIN Suppliers s ON p.Supplier_ID = s.Supplier_ID
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category, s.Supplier_Name
ORDER BY p.Category, status desc, p.Product_Name limit 10;

/*Calculate
•	Store Revenue 
•	Percentage contribution to Total Revenue 
Example 
Bangalore 18.5%

Mumbai 15.2%
Sort highest contribution first.*/
with Highest_Contribution as 
(
select  s.Store_ID, s.Store_Name , s.Store_City, 
round(sum(od.Final_Amount),2) as Total_Revenue from Stores s
inner join orders o on s.store_id = o.store_id
inner join order_Details od on o.Order_id = od.order_id
where o.delivery_status = 'delivered'
group by s.Store_ID, s.Store_Name , s.Store_City
) 
select Store_ID, Store_Name, Store_City, Total_Revenue, 
round((Total_Revenue/ sum(Total_Revenue) over()) * 100,2) as Revenue_Contribution_Percentage
from Highest_Contribution 
order by Total_Revenue desc;

-- Generate a business report showing •	Customer Name 
-- •	Store Name 
-- •	Product Category 
-- •	Total Orders 
-- •	Revenue 
-- •	Profit 
-- •	Customer Segment 
-- •	Product Rank within Category 
-- Only include
-- •	Delivered Orders 
-- •	Revenue > ₹20,000 

with Customer_Report as (
select c.Customer_ID, c.Customer_Name, s.Store_Name, p.Category,
count(distinct o.order_id) as Total_Orders, 
round(sum(od.Final_Amount),2) as Total_Revenue,
Round(sum(od.profit),2) as Total_Profit,
case when sum(od.Final_Amount) > 150000 then 'Platinum'
when sum(od.Final_Amount) between 80000 and 150000 then 'Gold'
when sum(od.Final_Amount) between 30000 and 79999 then 'Silver'
else 'Bronze'
end as Customer_Segment
from customers c inner join orders o on c.customer_id = o.Customer_id
inner join Stores s on o.store_id = s.store_id
inner join Order_Details od on o.Order_ID = od.Order_ID
inner join Products p on od.Product_ID = p.Product_ID
where o.delivery_status = 'delivered'
group by c.Customer_ID, c.Customer_Name, s.Store_Name, p.Category
having sum(od.Final_Amount) > 20000)
select Customer_Name, Store_Name, Category, Total_Orders,
Total_Revenue, Total_Profit, Customer_Segment,
dense_rank() over(partition by Category 
order by Total_Revenue desc) as Product_Category_Rank
from Customer_Report 
order by Total_Revenue desc;

-- #Highest Product_Rating from each Product Category
SELECT product_name, category, sub_category, product_rating
FROM (SELECT product_name, category, sub_category, product_rating,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY product_rating DESC) AS rn
FROM products) as p
WHERE rn = 1 order by product_rating desc;

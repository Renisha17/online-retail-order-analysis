-- 1.Write a query to Display the product details (product_class_code, product_id, product_desc, product_price,)as per the following criteria and sort them in descending order of category: 
#a. If the category is 2050, increase the price by 2000 
#b. If the category is 2051, increase the price by 500 
#c. If the category is 2052, increase the price by 600.
##SOLUTION:-

select product_class_code, product_id, product_desc, product_price,
case product_class_code
when 2050 then product_price +2000
when 2051 then product_price +500
when 2052 then product_price +600
Else product_price end as 'Calculated Price'
From product
order by product_class_code desc;

-- 2.Write a query to display (product_class_desc, product_id, product_desc, product_quantity_avail ) and Show inventory status of products as below as per their available quantity: 
# a. For Electronics and Computer categories, if available quantity is <= 10, show 'Low stock', 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock' 
# b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 21 <= qty <= 80, show 'In stock', >= 81, show 'Enough stock' 
# c. Rest of the categories, if qty <= 15 – 'Low Stock', 16 <= qty <= 50 – 'In Stock', >= 51 – 'Enough stock' For all categories, if available quantity is 0, show 'Out of stock'. 

SELECT PRODUCT_CLASS_CODE,
 PRODUCT_ID,
 PRODUCT_DESC ,
 PRODUCT_QUANTITY_AVAIL,
Case 
when (PRODUCT_CLASS_DESC='Electronics' or 'Computer categories') and PRODUCT_QUANTITY_AVAIL<= 10 then 'Low Stock'
when (PRODUCT_CLASS_DESC='Electronics' or 'Computer categories') and (PRODUCT_QUANTITY_AVAIL <=11 and PRODUCT_QUANTITY_AVAIL <=30) then'In Stock'
when (PRODUCT_CLASS_DESC='Electronics' or 'Computer categories') and PRODUCT_QUANTITY_AVAIL >=31 then 'Enough Stock'

when (PRODUCT_CLASS_DESC='Stationery' or 'Clothes') and PRODUCT_QUANTITY_AVAIL<= 20 then 'Low Stock'
when (PRODUCT_CLASS_DESC='Stationery' or 'Clothes') and (PRODUCT_QUANTITY_AVAIL <=21 and PRODUCT_QUANTITY_AVAIL <=80) then'In Stock'
when (PRODUCT_CLASS_DESC='Stationery' or 'Clothes') and PRODUCT_QUANTITY_AVAIL >=81 then 'Enough Stock'

WHEN (PRODUCT_CLASS_DESC != 'Stationery' or PRODUCT_CLASS_DESC != 'Clothes' or PRODUCT_CLASS_DESC != 'Electronics' or PRODUCT_CLASS_DESC != 'Computer') and PRODUCT_QUANTITY_AVAIL <= 15 then 'Low stock'
WHEN (PRODUCT_CLASS_DESC != 'Stationery' or PRODUCT_CLASS_DESC != 'Clothes' or PRODUCT_CLASS_DESC != 'Electronics' or PRODUCT_CLASS_DESC != 'Computer') and (PRODUCT_QUANTITY_AVAIL <= 16 OR PRODUCT_QUANTITY_AVAIL <= 50) then 'In Stock'
WHEN (PRODUCT_CLASS_DESC != 'Stationery' or PRODUCT_CLASS_DESC != 'Clothes' or PRODUCT_CLASS_DESC != 'Electronics' or PRODUCT_CLASS_DESC != 'Computer') and PRODUCT_QUANTITY_AVAIL >= 51 then 'Enough Stock'
WHEN PRODUCT_QUANTITY_AVAIL=0 then 'Out of Stock'

END AS InventoryStatus
FROM PRODUCT INNER JOIN PRODUCT_CLASS USING (PRODUCT_CLASS_CODE);

-- 3.Write a query to show the number of cities in all countries other than USA & MALAYSIA, with more than 1 city, in the descending order of CITIES. (2 rows)

SELECT COUNTRY, COUNT(CITY) As 'City Count'
FROM ADDRESS
Where country!='USA' and country != 'Malaysia'
Group by Country
having count(city)>1
order by count(city) desc;

-- 4.Write a query to display the customer_id,customer full name ,city,pincode,and order details 
-- (order id, product class desc, product desc, subtotal(product_quantity * product_price)) 
-- for orders shipped to cities whose pin codes do not have any 0s in them. Sort the output on customer name and subtotal.(52 ROWS) 


SELECT oc.customer_id, concat(ifnull(oc.customer_fname,''), '' ,ifnull(oc.customer_lname,'')) AS Fullname, a.city, a.pincode, oh.order_id, oh.order_date, pc.product_class_desc, p.product_desc,
oi.product_quantity * p.product_price AS Subtotal 
FROM online_customer oc 
INNER JOIN address a
 ON oc.address_id= a.address_id 
INNER JOIN order_header oh
 ON oc.customer_id= oh.customer_id 
AND oh.order_status = 'Shipped'
INNER JOIN order_items oi
 ON oh.order_id= oi.order_id 
INNER JOIN product p
 ON oi.product_id = p.product_id 
INNER JOIN product_class pc
 ON pc.product_class_code=p.product_class_code
where a.PINCODE not like "%0%"
ORDER BY fullname, oh.order_date,subtotal;

-- 5. Write a Query to display product id,product description,totalquantity(sum(product quantity) 
--- for a given item whose product id is 201 and which item has been bought along with it maximum no. of times. 
--- Display only one record which has the maximum value for total quantity in this scenario.



SELECT P.PRODUCT_ID, PRODUCT_DESC, SUM(PRODUCT_QUANTITY) AS TOTAL_QUANTITY 
 FROM ORDER_ITEMS OI, PRODUCT P 
 WHERE ORDER_ID IN 
 (SELECT ORDER_ID FROM ORDER_ITEMS  
 WHERE PRODUCT_ID = 201) 
 AND P.PRODUCT_ID != 201 
 AND OI.PRODUCT_ID = P.PRODUCT_ID 
 GROUP BY P.PRODUCT_ID, PRODUCT_DESC 
 ORDER BY TOTAL_QUANTITY DESC LIMIT 1; 
 
 -- 6. Write a query to display the customer_id,customer name, email and order details 
--- (order id, product desc,product qty, subtotal(product_quantity * product_price)) 
--- for all customers even if they have not ordered any item
 
 SELECT OC.CUSTOMER_ID ,OC.CUSTOMER_FNAME,OC.CUSTOMER_LNAME,OC.CUSTOMER_EMAIL,OH.ORDER_ID,PR.PRODUCT_DESC,OI.PRODUCT_QUANTITY,
OI.PRODUCT_QUANTITY * PR.PRODUCT_PRICE as SUBTOTAL
FROM ONLINE_CUSTOMER OC 
LEFT JOIN ORDER_HEADER OH 
ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
LEFT JOIN ORDER_ITEMS OI 
ON OH.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCT PR 
ON OI.PRODUCT_ID = PR.PRODUCT_ID;

-- 7. Write a query to display carton id, (len*width*height) as carton_vol and identify the optimum carton 
-- (carton with the least volume whose volume is greater than the total volume of all items 
-- (len * width * height * product_quantity)) for a given order whose order id is 10006, 
-- Assume all items of an order are packed into one single carton (box).
 


 Select Carton_id, (len*width*height) as Carton_vol from carton c
 where (len*width*height)>=
 (
 select sum(len * width * height * product_quantity)
 from order_items oi inner join product p
 ON oi.product_id=p.product_id
 where order_id=10006
 )
 order by Carton_vol limit 1;
 
  -- 8. Write a query to display details (customer id,customer fullname,order id,product quantity) of customers 
 -- who bought more than ten (i.e. total order qty) products with credit card or Net banking 
 -- as the mode of payment per shipped order.
 
 
 Select oc.Customer_id, concat(ifnull(oc.customer_fname,'' ), ' ' ,ifnull(oc.customer_lname,'')) AS Fullname, 
oh.Order_id, sum(oi.product_quantity) as Total_Quantity 
FROM online_customer oc 
inner join order_header oh
on oc.customer_id=oh.customer_id
and oh.order_status='Shipped' 
inner join order_items oi
on oh.order_id=oi.order_id
and payment_mode in ('Net Banking','Credit Card')
group by oc.customer_id, fullname, oh.order_id
having Total_Quantity >10;

-- 9. Write a query to display the order_id, customer id and cutomer full name of customers 
-- starting with the alphabet "A" along with (product_quantity) as total quantity of products shipped 
-- for order ids > 10030. (5 ROWS) [NOTE: TABLES TO BE USED - online_customer, order_header, order_items]


select oh.Order_id, oc.Customer_ID, concat(ifnull(oc.customer_fname,'' ), ' ' ,ifnull(oc.customer_lname,'')) AS Fullname, 
sum(oi.product_quantity) as Total_Quantity 
FROM online_customer oc 
inner join order_header oh
on oc.Customer_ID=oh.Customer_ID
inner join order_items oi
on oh.order_id=oi.order_id
where oh.order_status='Shipped'
group by oh.order_id
having (Fullname like 'A%') and (oh.order_id>10030);

-- 10. Write a query to display product class description ,total quantity (sum(product_quantity),
-- Total value (product_quantity * product price) and 
-- show which class of products have been shipped highest(Quantity) to countries outside India other than USA? 
-- Also show the total value of those items. (1 ROWS)[NOTE:PRODUCT TABLE,ADDRESS TABLE,ONLINE_CUSTOMER TABLE,ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE]



SELECT product_class_desc, SUM(oi.product_quantity) AS Total_Quantity,  SUM(oi.product_quantity * p.product_price) AS Total_Value 
FROM Address a 

inner join Online_Customer oc 
on oc.address_id=a.address_id 
inner join Order_Header oh 
on oc.customer_id = oh.customer_id  
inner join Order_Items oi 
on oh.order_id = oi.order_id 
inner join Product p 
on oi.product_id = p.product_id 
inner join Product_class pc  
on p.product_class_code = pc.product_class_code 

WHERE a.country != 'India' AND a.country != 'USA' AND order_status = "shipped" 
GROUP BY product_class_desc 
ORDER BY Total_Quantity DESC limit 1

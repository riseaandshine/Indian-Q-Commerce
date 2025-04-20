create table quick_commerce (
Agent_name varchar,
Rating varchar,
Review_text varchar,
Delivery_time int,
Location text,
Order_type varchar,
Customer_feedback varchar,
Price_range text,
Discount text,
Product_availability text,
Custome_rating float,
Order_accuracy text
) 

ALTER TABLE quick_commerce 
ALTER COLUMN Rating TYPE float USING rating::decimal;

ALTER TABLE quick_commerce 
ALTER COLUMN Rating TYPE float USING rating::numeric;

select * from quick_commerce

--What is the average rating given to each delivery service (Agent Name)?

select Agent_name, round(avg(Rating)::numeric,2) as agent_rating 
from quick_commerce
group by Agent_name
order by agent_rating desc

--How does delivery time impact customer ratings?
select case when Delivery_time <= 10 then '0-10 mins'
            when Delivery_time <= 20 then '10-20 mins'
			when Delivery_time <= 30 then '20-30 mins'
			when Delivery_time <= 40 then '30-40 mins'
			else '40+min'
			end as time_range,
			round(avg(Rating)::decimal,2) as ratings,
			count(1) as order_count
			from quick_commerce
			group by Delivery_time

            
create table quick_commerce1 (
Agent_name varchar,
Rating int,
Review_text varchar,
Delivery_time int,
Location text,
Order_type varchar,
Customer_feedback varchar,
Price_range text,
Discount text,
Product_availability text,
Custome_rating float,
Order_accuracy text
) 

select * from quick_commerce1

--How does delivery time impact customer ratings?

select Rating, 
count(case when Delivery_time <= 10 then 1
	  end ) as "<10 mins",
count(case when Delivery_time > 10 and Delivery_time <= 20 then 1
	  end ) as "10-20 mins",	
count(case when Delivery_time > 20 and Delivery_time <= 30 then 1
	  end ) as "20-30 mins",
count(case when Delivery_time > 30 and Delivery_time <= 40 then 1
	  end ) as "30-40 mins",
count(case when Delivery_time > 40 then 1
	  end ) as "40-50 mins"
	  from quick_commerce1
	  group by Rating
	  order by Rating desc
	  
--How does delivery time & location impact customer ratings?

select Rating,Location,
count(case when Delivery_time <= 10 then 1
	  end ) as "<10 mins",
count(case when Delivery_time > 10 and Delivery_time <= 20 then 1
	  end ) as "10-20 mins",	
count(case when Delivery_time > 20 and Delivery_time <= 30 then 1
	  end ) as "20-30 mins",
count(case when Delivery_time > 30 and Delivery_time <= 40 then 1
	  end ) as "30-40 mins",
count(case when Delivery_time > 40 then 1
	  end ) as "40-50 mins"
	  from quick_commerce1
	  group by Rating,Location
	  order by Rating desc, Location
	  
-- What are the most common themes in negative and positive customer reviews?

select order_type, count(1) as common_themes
from quick_commerce1
where customer_feedback = 'Negative'
group by order_type
order by common_themes desc

select order_type, count(1) as common_themes
from quick_commerce1
where customer_feedback = 'Positive'
group by order_type
order by common_themes desc

-- Is there a significant difference in ratings between different order types (Grocery, Food, Essentials)?

select order_type, round(avg(Rating),2) as average_rating
from quick_commerce1
group by order_type
order by average_rating desc

with t1 as(select order_type, round(avg(Rating),2) as average_rating
			from quick_commerce1
			group by order_type
			order by average_rating desc),
			t2 as(select *, average_rating - lead(average_rating) over(order by average_rating desc) from t1)
			select * from t2

-- Which delivery service has the fastest delivery time on average?

select Agent_name, round(avg(Delivery_time),2) as fastest_del_time
from quick_commerce1
group by Agent_name
order by fastest_del_time desc

-- Which delivery service has the fastest delivery time on average based on location?

select Agent_name,Location, round(avg(Delivery_time),2) as fastest_del_time
from quick_commerce1
group by Agent_name, Location
order by Agent_name,Location

-- How often do incorrect orders occur, and which agent has the highest order accuracy?

select Agent_name, count(1) as no_of_incorrect_orders
from quick_commerce1
where Order_accuracy = 'Incorrect'
group by Agent_name
order by no_of_incorrect_orders desc 


select Agent_name, count(1) as no_of_correct_orders
from quick_commerce1
where Order_accuracy = 'Correct'
group by Agent_name
order by no_of_correct_orders desc 

-- Does product availability impact customer feedback sentiment?

select Product_availability, round(avg(Custome_rating::numeric),2) as avg_customer_rating
from quick_commerce1
group by Product_availability
order by avg_customer_rating desc

select Agent_name,Product_availability, round(avg(Custome_rating::numeric),2) as avg_customer_rating
from quick_commerce1
group by Agent_name, Product_availability
order by Agent_name, avg_customer_rating desc

-- Are deliveries in certain locations consistently delayed compared to others?

select Location, round(avg(Delivery_time),2) as avg_delivery_time
from quick_commerce1
group by  Location
order by avg_delivery_time 

-- Do customers who receive discounts give higher ratings?

select Discount, round(avg(Custome_rating::numeric),2) as avg_cust_rating
from quick_commerce1
group by Discount

-- Is there a correlation between price range and customer feedback sentiment?

select Custome_rating, 
count(case when Price_range = 'High' then 1 end) as high,
count(case when Price_range = 'Medium' then 1 end) as medium,
count(case when Price_range = 'Low' then 1 end) as low
from quick_commerce1
group by Custome_rating
order by Custome_rAre higher-priced orders more likely to receive negative feedback?ating desc

-- Are higher-priced orders more likely to receive negative feedback?

select price_range, count(case when Customer_feedback = 'Negative' then 1 end) as Negative_feedback,
count(case when Customer_feedback = 'Positive' then 1 end) as Positive_feedback,
count(case when Customer_feedback = 'Neutral' then 1 end) as Neutral_feedback
from quick_commerce1
group by price_range

-- How does order accuracy affect customer satisfaction and reviews?

select Order_accuracy, 	
count(case when Customer_feedback = 'Negative' then 1 end) as Negative_feedback,
count(case when Customer_feedback = 'Positive' then 1 end) as Positive_feedback,
count(case when Customer_feedback = 'Neutral' then 1 end) as Neutral_feedback
from quick_commerce1
group by Order_accuracy


-- Which factors contribute the most to negative customer sentiment?

select round(avg(Delivery_time::numeric),2) as avg_del_time, Customer_feedback
from quick_commerce1
group by Customer_feedback
order by avg_del_time desc

-- How do different delivery agents compare in terms of rating, delivery time, and accuracy?

select 	Agent_name, round(avg(Delivery_time),2) as avg_del_time, round(avg(Rating),2) as avg_ratings,
count(case when Order_accuracy = 'Incorrect' then 1 end) as Incorrect_orders,
count(case when Order_accuracy = 'Correct' then 1 end) as Correct_orders
from quick_commerce1
group by Agent_name
order by Agent_name

-- Is there a difference in customer satisfaction across various locations?

select Location,Customer_feedback, round(avg(Custome_rating::numeric),2) as avg_cust_rating
from quick_commerce1
group by Location,Customer_feedback
order by Location

-- Does customer service rating vary by order type?

select order_type, round(avg(Custome_rating::numeric),2) as customer_rating_by_order_type
from quick_commerce1
group by order_type
order by order_type











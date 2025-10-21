use assignmenttwo;

-- salesInfo Abstraction

create view salesInfo as
select r.name as rest_name, price, 
	f.name as food_name, f.type as food_type, f.foodID, r.restID 
from serves s
join foods f using (foodID)
join restaurants  r using (restID);

-- This section joins tables foods, serves, and restaurants as a view
-- for use in following queries

-- Question #1 --

select avg(price) as avg_price, rest_name
from salesInfo
group by rest_name
order by avg_price desc;

-- This query generates a table of average food prices per restaurant grouped 
-- by their name in a descending order using the view salesInfo

-- Question #2 --

select max(price) as max_price, rest_name
from salesInfo
group by rest_name
order by max_price desc;

-- This query generates a table of the highest pricing of food prices per restaurant grouped 
-- by restaurant name in a descending order using the view salesInfo

-- Question #3 --

select  count(distinct food_type) as food_types, rest_name
from salesInfo
group by rest_name;

-- This query generates the total number of different food types per restraurant grouped by their name,
-- using the distinct keyword to not count any repeats, from the salesInfo view

-- Question #4 --

select avg(price) as avg_price, name
from salesInfo 
join works using (restID)
join chefs using (chefID)
group by name
order by avg_price desc;

-- This query generates the average price of food sold per chef grouped by their name
-- by joining salesInfo with works and chefs and ordered descending

-- Question #5 --

select avg(price) as avg_price, rest_name
from salesInfo
group by rest_name
having avg_price >= all
	(select avg (price) from salesInfo group by rest_name);
    
    -- This query generates the highest average price of food per restaurant,
    -- grouped their name and prints multiple if they're tied for the highest,
    -- using a subquery

-- Question #6 --

select avg(price) as avg_price, name, rest_name
from salesInfo 
join works using (restID)
join chefs using (chefID)
group by name, rest_name
order by avg_price desc;

-- This query generates the average price of the food each chef serves for each restaurant , 
-- joining works and chefs, grouped by the chefs and restaurants name and order in a descending order

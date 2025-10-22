-- Adding primary and composite keys for imported data
alter table merchants add primary key (mid);
alter table products add primary key (pid);
alter table sell add primary key (mid, pid);
alter table orders add primary key (oid);
alter table contain add primary key (oid, pid);
alter table customers add primary key (cid);
alter table place add primary key (cid, oid);

-- Adding foreign keys
alter table sell add foreign key (mid) references merchants (mid),
	add foreign key (pid) references products (pid);
alter table contain add foreign key (oid) references orders (oid),
	add foreign key (pid) references products (pid);
alter table place add foreign key (cid) references customers (cid),
	add foreign key (oid) references orders (oid);
	

-- Valid product name constraint
alter table products
	add constraint valid_name 
    check (name in ('Printer','Ethernet Adapter','Desktop','Hard Drive','Laptop','Router','Network Card','Super Drive','Monitor'));

-- Valid product category constraint    
alter table products
	add constraint valid_product_category 
    check (category in ('Peripheral', 'Networking', 'Computer'));

-- Valid sale price constraint
alter table sell 
	add constraint valid_price
    check (price between 0 and 100000);
    
-- Valid quantity of available product constraint
alter table sell 
	add constraint valid_quantity_available
    check (quantity_available between 0 and 1000);
    
-- Valid shipping method constraint
alter table orders
	add constraint valid_shipping_method
    check (shipping_method in ('UPS', 'FedEx', 'USPS'));
    
-- Valid shipping cost constraint
alter table orders
	add constraint valid_shipping_cost
    check (shipping_cost between 0 and 500);
    
-- Valid date constraint
alter table place
    modify column order_date date;
    
    
--  #1 Prints table of the sellers names and their products that have a zero products available by 
-- joining sell, merchant, and product
select merchants.name as merchant_name, products.name as unavailable_product_name
from sell s
join merchants using (mid)
join products using (pid)
where s.quantity_available = 0;


--  #2 Prints a table of products' name and description that aren't being sold
select p.name, description
from products p left join
sell s using (pid)
where s.pid is null;

--  #3 Prints the count of customers that have purchased sata drives but not routers
select count(*) as customers_amount
from ( 
	select p.cid
    from place p
    join contain using (oid)
	join products pr using (pid)
	group by p.cid
    having sum(pr.description = '%Router%') = 0 and sum(pr.description like '%Sata%') > 0)  t;
    
-- #4 Prints table of the names and prices of all products on sale at HP
select round(s.price * 0.8, 2) as sale_price, p.name as product_name, m.name as merchant_name
from sell s 
join products p using (pid)
join merchants m using (mid)
where m.name = 'HP' and p.category = 'Networking';

-- #5 Shows a full history of what customer Uriel Whitney has order in descending order
select c.fullname as customer,  s.price, p.name as product, place.order_date
from customers c 
join place using (cid)
join contain using (oid)
join products p using (pid)
join sell s using (pid)
where c.fullname = 'Uriel Whitney'
order by order_date desc;

-- #6 This table prints the total sales for every company for each recorded year ordered by company then year
select year(place.order_date) as year, m.name as company, round(sum(s.price), 2) as total_sales
from merchants m
join sell s using (mid)
join products using (pid)
join contain using (pid)
join place using (oid)
group by m.name, year(place.order_date)
order by m.name, year(place.order_date);

-- #7 Prints the one highest annual revenue for any company any year, company name, and the year 
select year(place.order_date) as year, m.name as company, round(sum(s.price), 2) as total_sales
from merchants m
join sell s using (mid)
join products using (pid)
join contain using (pid)
join place using (oid)
group by year(place.order_date), m.name
order by total_sales limit 1;

-- #8 Prints a table of the lowest average shipping method and its average price 
select shipping_method, round(avg(shipping_cost), 2) as avg_cost
from orders
group by shipping_method
order by round(avg(shipping_cost), 2) asc
limit 1;

-- #9 Prints a table of each company and their category of product that has made the most money along with the total sales
select x.company, x.category, round(total_sales, 2) as total_sales
from (
	select m.name as company, p.category, sum(s.price) as total_sales
    from merchants m
    join sell s using (mid)
    join products p using (pid)
	join contain using (pid)
    join place using (oid)
    group by m.name, p.category) as x
where round(x.total_sales, 2) = (
	select round(max(category_total), 2)
    from (
		select sum(s2.price) as category_total
		from merchants m2
		join sell s2 using (mid)
		join products p2 using (pid)
		join contain using (pid)
		join place using (oid)
		where m2.name = x.company
		group by p2.category
        ) as totals
)
order by x.company;

-- #10 Finds the highest and lowest paying customers for each company and how much they have spent
create view customer_spending as
	select m.name as company, c.fullname as customer, sum(s.price) as total_spent
	from merchants m
	join sell s using (mid)
	join products p using (pid)
	join contain using (pid)
	join place using (oid)
	join customers c using (cid)
	group by m.name, c.fullname;

-- Highest paying customers
select company, customer, round(total_spent, 2) AS total_spent
from customer_spending cs1
where total_spent = (
	select max(total_spent)
    from customer_spending cs2
    where cs1.company = cs2.company)
order by company, total_spent desc;

-- Lowest paying customers
select company, customer, round(total_spent, 2) AS total_spent
from customer_spending cs1
where total_spent = (
	select min(total_spent)
    from customer_spending cs2
    where cs1.company = cs2.company)
order by company, total_spent desc;

    

-- Setting Primary Keys for Imported Tables
alter table actor add primary key (actor_id);
alter table address add primary key (address_id);
alter table category add primary key (category_id);
alter table city add primary key (city_id);
alter table country add primary key (country_id);
alter table customer add primary key (customer_id);
alter table film add primary key (film_id);
alter table film_actor add primary key (film_id, actor_id);
alter table rental add primary key (rental_id);
alter table staff add primary key (staff_id);
alter table store add primary key (store_id);
alter table film_category add primary key (film_id, category_id);
alter table inventory add primary key (inventory_id);
alter table language add primary key (language_id);
alter table payment add primary key (payment_id);

-- Setting Foreign Keys for Imported Tables
alter table address add foreign key (city_id) references city (city_id);
alter table city add foreign key (country_id) references country (country_id);
alter table customer add foreign key (store_id) references store (store_id), 
	add foreign key (address_id) references address (address_id);
alter table film add foreign key (language_id) references language (language_id);
alter table film_actor add foreign key (film_id) references film (film_id), 
	add foreign key (actor_id) references actor (actor_id);
alter table rental add foreign key (customer_id) references customer (customer_id),
	add foreign key (inventory_id) references inventory (inventory_id);
alter table staff add foreign key (address_id) references address (address_id),
	add foreign key (store_id) references store (store_id);
alter table store add foreign key (address_id) references address (address_id);
alter table film_category add foreign key (film_id) references film (film_id),
	add foreign key (category_id) references category (category_id);
alter table inventory add foreign key (film_id) references film (film_id),
	add foreign key (store_id) references store (store_id);
alter table payment add foreign key (customer_id) references customer (customer_id),
	add foreign key (staff_id) references staff (staff_id),
    add foreign key (rental_id) references rental (rental_id);

-- Valid Category Name Constaint
alter table category
	add constraint name_check check (category.name in ("Animation", "Comedy", "Family", "Foreign", "Sci-Fi", "Travel", "Children", 
		"Drama", "Horror", "Action", "Classics", "Games", "New", "Documentary", "Sports", "Music"));

-- Valid Special Feature Constraint
alter table film
	add constraint feature_check check (special_features in ("Behind the Scenes", "Commentaries", "Deleted Scenes", "Trailers"));
    
-- Valid Date Constraints
alter table film add constraint release_year_check check (release_year between 1850 and 2025);
alter table rental
	modify column rental_date datetime,
    modify column return_date datetime,
	add constraint rent_return_check check (return_date >= rental_date);
alter table payment modify column payment_date datetime;

-- Valid Activity State Constraints
alter table staff add constraint staff_activity_check check (active in (0, 1));
alter table customer add constraint customer_activity_check check (active in (0, 1));

-- Valid Rental Durations Constraint
alter table film add constraint duration_check check (rental_duration between 2 and 8);

-- Valid Daily Rental Rate Constraint
alter table film add constraint rate_check check (rental_rate between 0.99 and 6.99);

-- Valid Movie Length Constraint
alter table film add constraint length_check check (length between 30 and 200);

-- Valid Movie Rating Constraint
alter table film add constraint rating_check check (rating in ("PG", "G", "NC-17", "PG-13", "R"));

-- Valid Movie Replacement Cost Constraint
alter table film add constraint replacement_check check (replacement_cost between 5.00 and 100.00);

-- Valid Movie Payment Amount Constraint
alter table payment add constraint payment_check check (amount >= 0);

--  #1 Displays length of movies for each category rounded to the nearest whole number
select round(avg(length), 0) as avg_length, category.name
from film join film_category using (film_id)
join category using (category_id)
group by category.name;

--  #2a Displays the longest average category of movies
 select round(avg(length), 0) as avg_length, category.name
from film join film_category using (film_id)
join category using (category_id)
group by category.name
order by avg_length desc
limit 1;

--  #2b Displays the shortest average category of movies
 select round(avg(length), 0) as avg_length, category.name
from film join film_category using (film_id)
join category using (category_id)
group by category.name
order by avg_length asc
limit 1;

--  #3 Displays all customers who have rented an action movie but not comedy or classic, using a view and subquery
create view customer_categories as
	select distinct customer_id, customer.first_name, customer.last_name, category.name as category_name
    from customer join rental using (customer_id)
    join inventory using (inventory_id)
    join film_category using (film_id)
    join category using (category_id);
            
select customer_id, first_name, last_name, category_name
from customer_categories c1
where category_name = "Action" and customer_id not  in (
	select customer_id
    from customer_categories c2
    where c2.category_name in ("Comedy", "Classics"));

-- #4 Displays the actor found in the most amount of english spoken movies
select count(film_id) as total_english_films, actor.first_name, actor.last_name
from actor join film_actor using(actor_id)
join film using (film_id)
join language using (language_id)
group by language.name, actor_id
having language.name = "English"
order by total_english_films desc
limit 1;

-- #5 Displays the number of distanct movies rented for 10 days from the store that Mike works at    
select count(distinct(film_id)) as movies_rented_for_10_days
from film f join inventory using (film_id)
join rental r using (inventory_id)
join staff sta using (staff_id)
join store sto on sta.store_id = sto.store_id
where datediff(return_date, rental_date) = 10 and sto.store_id = (
	select sto2.store_id
    from store sto2 join staff sta2 on sto2.store_id = sta2.store_id
    where sta2.first_name = "Mike");

-- #6 Displays the names of cast members that starred in the movie with the largest cast in an alphabetical order
select a.last_name, a.first_name, film.title
from film join film_actor using (film_id)
join actor a using (actor_id)
where film_id = (
	select film_id
	from film join film_actor using (film_id)
	group by film_id
	order by count(actor_id) desc
	limit 1)
order by a.last_name, a.first_name;











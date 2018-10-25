-- HOMEWORK ASSIGNMENT

USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`
SELECT UCASE(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor,
-- of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT * 
FROM actor
WHERE last_name LIKE '%GEN%';

-- Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries:
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan','Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. 
-- Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type
ALTER TABLE actor
ADD  COLUMN middle_name VARCHAR(20) AFTER first_name;

SELECT * FROM actor;

-- **** You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs` *****
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the `middle_name` column
ALTER TABLE actor
DROP COLUMN middle_name;

SELECT * FROM actor;


-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors 
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name)>= 2
ORDER BY COUNT(last_name) DESC;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record
UPDATE actor
SET first_name = 'HARPO'
where first_name = 'GROUCHO';

-- 4d.In a single query, if the first name of the actor is currently `HARPO`,
-- change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`,
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER!
-- (Hint: update the record using a unique identifier.)

-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, 
-- as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

-- ***6b. Use `JOIN` to display 
-- the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`***
SELECT first_name, last_name
FROM staff;

SELECT s.first_name, s.last_name, SUM(p.amount) AS 'Total Amount Rung'
FROM payment p
INNER JOIN staff s
ON s.staff_id = p.staff_id
GROUP BY s.first_name;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(inventory_id) AS 'Number of Copies'
FROM film f
INNER JOIN  inventory i
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

--  6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total paid'
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.first_name
ORDER BY c.first_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM language;

SELECT title 
FROM film
WHERE title LIKE 'K%' 
OR title LIKE'Q%'
AND language_id IN
(
SELECT language_id
FROM language
WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
 SELECT actor_id
 FROM film_actor
 WHERE film_id IN
 (
  SELECT film_id
  FROM film
  where title = 'Alone Trip'
  )
 );
 
-- 7c. You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
SELECT * FROM country;

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
(
 SELECT address_id
 FROM address
 WHERE city_id IN
 (
  SELECT city_id
  FROM city
  WHERE country_id IN
  (
   SELECT country_id
   FROM country
   WHERE country = 'Canada'
  )
 )
);  

-- another solution using joins
SELECT c.first_name, c.last_name, c.email, ct.city, coun.country
FROM customer c
INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country coun
ON ct.country_id = coun.country_id
WHERE coun.country = 'Canada';

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion.
-- Identify all movies categorized as famiy films.
SELECT * FROM category;

SELECT f.title AS Movie_title, c.name AS Category
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
On fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title AS 'Movie Title', COUNT(r.rental_id) AS 'Rental Frequency'
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;

--  7f. Write a query to display how much business, in dollars, each store brought in
SELECT s.store_id, SUM(p.amount)
FROM payment p
INNER JOIN rental r
ON p.rental_id = r.rental_id
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN store s
ON i.store_id = s.store_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS store_id, ct.city AS city, c.country AS country
FROM store s
INNER JOIN address a
ON s.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country  c
ON ct.country_id = c.country_id
GROUP BY s.store_id;

SELECT * FROM store;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)
SELECT c.name AS 'Film Genre', SUM(p.amount) AS 'Gross Revenue'
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
order by SUM(p.amount) desc 
;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW GrossRevenue AS
SELECT c.name AS 'Film Genre', SUM(p.amount) AS 'Gross Revenue'
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
order by SUM(p.amount) desc 
;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM grossrevenue;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW grossrevenue;
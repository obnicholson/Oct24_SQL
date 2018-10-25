USE sakila;

-- 1a - Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor;

-- 1b - Display the first and last name of each actor in a single column in upper case letters.  Name the column Actor Name
SELECT CONCAT(first_name,' ',last_name) AS 'Actor Name'
FROM actor;

-- 2a - You need to find the ID number, first name, and last name of an actor, of whom you only know the first name, "Joe".
-- What is one query you would use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b - Find all actors whose last name contian the letters GEN
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c - Find all actors whose last names contain the letters LI.  Order the rows by last name and first name.
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name ASC, first_name ASC;

-- 2d - Using IN, display the country_id and country columns of the following countries:
-- Afghanistan, Bangladesh, and China.
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a - You want to keep a description of each actor.  You don't think you will be performing queries on a description,
-- so create a column named description and use the data type BLOB
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b - Very quickly you realize that entering descriptions for each actor is too much effort.  Delete the description column
ALTER TABLE actor
DROP COLUMN description;

-- 4a - List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(*) AS 'Actor Count'
FROM actor
GROUP BY last_name;

-- 4b - List the last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Actor Count'
FROM actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

-- 4c - The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix that record
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 5a - You cannot locate the schema of the address table.  Which query would you use to re-create it?
DESCRIBE address;

-- 6a - Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
SELECT first_name, last_name, SUM(amount) AS 'Total Amount'
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY first_name, last_name;

-- 6b - Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
SELECT first_name, last_name, SUM(amount) AS 'Total Amount'
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY first_name, last_name;

-- 6c - List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join
SELECT title AS 'Film Title', COUNT(actor_id) AS 'Number of Actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

-- 6d - How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) AS 'Number of Copies'
FROM inventory
INNER JOIN FILM ON inventory.film_id = film.film_id
WHERE title = 'Hunchback Impossible';

-- 6e - Using the tables payment and customer and the JOIN command, list the total paid by each customer
-- List the customers alphabetically by last name
SELECT first_name, last_name, SUM(amount) AS 'Total Payment'
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY first_name, last_name
ORDER BY last_name ASC;

-- 7a - Use subqueries to display the titles of movies starting with the letters K and Q whose language is English
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language_id IN (
	SELECT language_id 
    FROM language
    WHERE name = 'English'
    GROUP BY language_id);

-- 7b - Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'));

-- 7c - You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information
SELECT first_name, last_name, email
FROM customer
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country = 'Canada';

-- 7d - Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films
SELECT title
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- 7e - Display the most frequently rented movies in descending order.
SELECT title, COUNT(rental.rental_id) AS 'Rental Frequency'
FROM film
INNER JOIN inventory ON film.film_id = inventory.inventory_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY COUNT(rental.rental_id) DESC;

-- 7f - Write a query to display how much business, in dollars, each store brought in
SELECT store.store_id, SUM(payment.amount) AS 'Total Amount'
FROM store
INNER JOIN inventory ON store.store_id = inventory.store_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment on rental.rental_id = payment.rental_id
GROUP BY store_id;

-- 7g - Write a query to display for each store its store ID, city, and country
SELECT store.store_id, city, country
FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city on address.city_id = city.city_id
INNER JOIN country on city.country_id = country.country_id;

-- 7h - List the top five genres in gross revenue in descending order
SELECT name AS 'Genre', SUM(amount) as 'Revenue'
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment on rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- 8a - In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres
AS SELECT name AS 'Genre', SUM(amount) as 'Revenue'
		FROM category
		INNER JOIN film_category ON category.category_id = film_category.category_id
		INNER JOIN inventory ON film_category.film_id = inventory.film_id
		INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
		INNER JOIN payment on rental.rental_id = payment.rental_id
		GROUP BY name
		ORDER BY SUM(amount) DESC
		LIMIT 5;

-- 8b - How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- 8c - You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
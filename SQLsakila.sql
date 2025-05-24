#CHIFFRE D'AFFAIRES TOTAL PAR CLIENT
SELECT p.customer_id, first_name, last_name, SUM(amount), AVG(amount), COUNT(payment_id)
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY customer_id
ORDER BY SUM(amount) DESC;

#REVENU MENSUEL TOTAL
SELECT EXTRACT(month FROM payment_date), SUM(amount) FROM payment
GROUP BY EXTRACT(month FROM payment_date) 
ORDER BY SUM(amount) DESC;

#TOP DES FILMS LES PLUS LOUES 
SELECT f.title, COUNT(rental_id) 
FROM film f 
JOIN inventory i ON f.film_id = i.film_id    
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.film_id
ORDER BY COUNT(rental_id) DESC;

#TOP MAGASINS PAR CHIFFRE D'AFFAIRES
SELECT s.store_id, SUM(amount)
FROM store s 
JOIN staff st ON st.staff_id = s.manager_staff_id
JOIN customer c ON c.store_id = s.store_id 
JOIN payment p ON p.customer_id = c.customer_id 
GROUP BY s.store_id
ORDER BY SUM(amount) DESC;

#REPARTITON DES VENTES PAR CATEGORIE DE FILM
SELECT category.name, SUM(amount)
FROM payment
JOIN rental ON rental.rental_id = payment.rental_id
JOIN inventory ON inventory.inventory_id = rental.inventory_id
JOIN film_category ON film_category.film_id = inventory.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY category.category_id
ORDER BY SUM(amount) DESC;

#VUE REVENU PAR CLIENT
CREATE OR REPLACE VIEW revenu_par_client AS
SELECT c.customer_id, first_name, last_name, SUM(amount), AVG(amount)
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

#VUE REVENU PAR CLIENT
CREATE OR REPLACE VIEW revenu_par_mois AS
SELECT EXTRACT(month FROM payment_date), SUM(amount) FROM payment
GROUP BY EXTRACT(month FROM payment_date);

#VUE FILMS LES PLUS LOUES
CREATE OR REPLACE VIEW film_les_plus_loues AS
SELECT f.film_id, f.title, COUNT(rental_id) 
FROM film f 
JOIN inventory i ON f.film_id = i.film_id    
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.film_id;

#VUE REVENU PAR MAGASIN
CREATE OR REPLACE VIEW revenu_par_magasin AS 
SELECT s.store_id, SUM(amount)
FROM store s 
JOIN staff st ON st.staff_id = s.manager_staff_id
JOIN customer c ON c.store_id = s.store_id 
JOIN payment p ON p.customer_id = c.customer_id 
GROUP BY s.store_id;

#VUE REVENU PAR CATEGORY DE FILM 
CREATE OR REPLACE VIEW revenu_par_category_de_film AS
SELECT category.name, SUM(amount)
FROM payment
JOIN rental ON rental.rental_id = payment.rental_id
JOIN inventory ON inventory.inventory_id = rental.inventory_id
JOIN film_category ON film_category.film_id = inventory.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY category.category_id;

#Pour R Sutdio
SELECT * 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM payment;

SELECT * 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM customer;

SELECT * 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rental.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM rental;
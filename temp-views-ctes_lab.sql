USE sakila;

-- Challenge 

-- Paso 1. Crear view que resuma info de alquiles por cliente. Incluir custumer ID, name, email, total alquileres
DROP VIEW IF EXISTS rental_summary;

CREATE VIEW rental_summary AS
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

SELECT * FROM rental_summary;

-- Paso 2. Crear Temporary table  que calcule total pagado por cada cliente.
-- Usar rental summary view del Step 1 para unirla con la tabla de pagos
DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT rs.customer_id,
       SUM(p.amount) AS total_paid        
FROM rental_summary rs
JOIN rental r ON rs.customer_id = r.customer_id    
JOIN payment p ON r.rental_id = p.rental_id        
GROUP BY rs.customer_id;

SELECT * FROM customer_payment_summary;  

-- Paso 3. Create a CTE that joins the rental summary View with the customer payment summary Temporary Table. 
-- Then generate the final report with customer name, email, rental_count, total_paid and average_payment_per_rental.
WITH customer_summary AS (
    SELECT rs.customer_name,        
           rs.email,
           rs.rental_count,
           cps.total_paid
    FROM rental_summary rs
    JOIN customer_payment_summary cps
      ON rs.customer_id = cps.customer_id
)
SELECT customer_name,
       email,
       rental_count,
       total_paid,
       ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC;
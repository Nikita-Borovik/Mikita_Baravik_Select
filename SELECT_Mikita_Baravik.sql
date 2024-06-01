
SELECT 
    s.store_id,
    st.staff_id,
    st.first_name,
    st.last_name,
    SUM(p.amount) as total_revenue
FROM 
    store s
JOIN 
    staff st ON s.store_id = st.store_id
JOIN 
    payment p ON st.staff_id = p.staff_id
WHERE 
    EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY 
    s.store_id, st.staff_id, st.first_name, st.last_name
HAVING 
    SUM(p.amount) = (
        SELECT MAX(total_revenue)
        FROM (
            SELECT SUM(p.amount) as total_revenue
            FROM staff st2
            JOIN payment p ON st2.staff_id = p.staff_id
            WHERE st2.store_id = s.store_id AND EXTRACT(YEAR FROM p.payment_date) = 2017
            GROUP BY st2.staff_id
        ) subquery
    )
ORDER BY 
    s.store_id, total_revenue DESC;


WITH rental_counts AS (
    SELECT 
        f.film_id,
        f.title,
        COUNT(r.rental_id) as rental_count
    FROM 
        film f
    JOIN 
        inventory i ON f.film_id = i.film_id
    JOIN 
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY 
        f.film_id, f.title
    ORDER BY 
        rental_count DESC
    LIMIT 5
),
customer_ages AS (
    SELECT 
        rc.film_id,
        rc.title,
        c.customer_id,
        EXTRACT(YEAR FROM AGE(c.create_date)) AS age
    FROM 
        rental_counts rc
    JOIN 
        inventory i ON rc.film_id = i.film_id
    JOIN 
        rental r ON i.inventory_id = r.inventory_id
    JOIN 
        customer c ON r.customer_id = c.customer_id
)
SELECT 
    ca.film_id,
    ca.title,
    AVG(ca.age) AS average_age
FROM 
    customer_ages ca
GROUP BY 
    ca.film_id, ca.title
ORDER BY 
    average_age;



WITH actor_activity AS (
    SELECT 
        a.actor_id,
        a.first_name,
        a.last_name,
        MIN(f.release_year) as first_film_year,
        MAX(f.release_year) as last_film_year,
        (MAX(f.release_year) - MIN(f.release_year)) as active_years
    FROM 
        actor a
    JOIN 
        film_actor fa ON a.actor_id = fa.actor_id
    JOIN 
        film f ON fa.film_id = f.film_id
    GROUP BY 
        a.actor_id, a.first_name, a.last_name
),
inactivity_period AS (
    SELECT 
        actor_id,
        first_name,
        last_name,
        active_years,
        EXTRACT(YEAR FROM AGE(MAKE_DATE(last_film_year, 1, 1))) as inactivity_years
    FROM 
        actor_activity
)
SELECT 
    actor_id,
    first_name,
    last_name,
    inactivity_years
FROM 
    inactivity_period
ORDER BY 
    inactivity_years DESC;

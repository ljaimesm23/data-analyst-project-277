-- consulta SQL en DBeaver que cuenta el número total de clientes en la tabla customers. 
SELECT COUNT(*) AS customers_count
FROM customers;

--Reporte 1: clientes por grupo de edad
SELECT
    age_category,
    COUNT(*) AS age_count
FROM (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16–25'
            WHEN age BETWEEN 26 AND 40 THEN '26–40'
            WHEN age > 40 THEN '40+'
        END AS age_category -- Primero crea la columna age_category
    FROM customers
) AS grupos_edad
GROUP BY age_category
ORDER BY
    CASE age_category
        WHEN '16–25' THEN 1
        WHEN '26–40' THEN 2
        WHEN '40+' THEN 3
    END;

-- Reporte 2: clientes e ingresos por mes
SELECT
    TO_CHAR(sales.sale_date, 'YYYY-MM') AS selling_month,--Crear el mes de venta
    COUNT(DISTINCT sales.customer_id) AS total_customers,--Contar clientes únicos
    FLOOR(SUM(sales.quantity * products.price)) AS income -- Calcular ingresos--Redondear hacia abajo
FROM sales
INNER JOIN products
    ON sales.product_id = products.product_id
GROUP BY selling_month
ORDER BY selling_month;

-- Reporte 3: clientes cuya primera compra fue durante una promoción
WITH primeras_compras AS (
    SELECT
        sales_id,
        customer_id,
        product_id,
        sales_person_id,
        sale_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date
        ) AS orden_compra
    FROM sales
)
SELECT
    customers.first_name || ' ' || customers.last_name AS customer,
    primeras_compras.sale_date,
    employees.first_name || ' ' || employees.last_name AS seller
FROM primeras_compras
INNER JOIN customers
    ON primeras_compras.customer_id = customers.customer_id
INNER JOIN products
    ON primeras_compras.product_id = products.product_id
INNER JOIN employees
    ON primeras_compras.sales_person_id = employees.employee_id
WHERE primeras_compras.orden_compra = 1
AND products.price = 0
ORDER BY customers.customer_id;

-- Reporte 1: los 10 vendedores con más ingresos
SELECT
    employees.first_name || ' ' || employees.last_name AS seller,
    COUNT(sales.sales_id) AS operations,
    ROUND(SUM(sales.quantity * products.price), 2) AS income
FROM employees
INNER JOIN sales
    ON employees.employee_id = sales.sales_person_id
INNER JOIN products
    ON sales.product_id = products.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-- Reporte 2: vendedores con ingresos por debajo del promedio
SELECT
    employees.first_name || ' ' || employees.last_name AS seller,
    FLOOR(AVG(sales.quantity * products.price)) AS average_income
FROM employees
INNER JOIN sales
    ON employees.employee_id = sales.sales_person_id
INNER JOIN products
    ON sales.product_id = products.product_id
GROUP BY seller
HAVING AVG(sales.quantity * products.price) < (
    SELECT AVG(vendedor_income)
    FROM (
        SELECT
            sales.sales_person_id,
            AVG(sales.quantity * products.price) AS vendedor_income
        FROM sales
        INNER JOIN products
            ON sales.product_id = products.product_id
        GROUP BY sales.sales_person_id
    ) AS promedio_vendedores
)
ORDER BY average_income ASC;

--Reporte 3: ingresos por día de la semana
SELECT
    seller,
    day_of_week,
    income
FROM (
    SELECT
        employees.first_name || ' ' || employees.last_name AS seller,
        LOWER(TRIM(TO_CHAR(sales.sale_date, 'Day'))) AS day_of_week,
        FLOOR(SUM(sales.quantity * products.price)) AS income
    FROM employees
    INNER JOIN sales
        ON employees.employee_id = sales.sales_person_id
    INNER JOIN products
        ON sales.product_id = products.product_id
    GROUP BY
        seller,
        day_of_week
) AS ventas_dia
ORDER BY
    CASE day_of_week
        WHEN 'monday' THEN 1
        WHEN 'tuesday' THEN 2
        WHEN 'wednesday' THEN 3
        WHEN 'thursday' THEN 4
        WHEN 'friday' THEN 5
        WHEN 'saturday' THEN 6
        WHEN 'sunday' THEN 7
    END,
    seller;

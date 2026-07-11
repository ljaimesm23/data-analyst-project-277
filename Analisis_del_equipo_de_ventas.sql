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
-- ============================================================
-- 문제 1. [집계 함수 + HAVING]
-- 제품 라인(productLine)별 제품 수를 구하고,
-- 제품이 10개 이상인 라인만 제품 수 내림차순으로 보여주세요.
-- 조회할 필드명: productLine, 제품수
-- 테이블: products
-- ============================================================

SELECT productLine, COUNT(*) AS product_cnt
FROM products
GROUP BY productLine
HAVING product_cnt >= 10
ORDER BY product_cnt DESC;


SELECT c.country
    , SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 10;


SELECT c.customerNumber
    , c.customerName
FROM customers c
JOIN orders o
    ON o.customerNumber = c.customerNumber
WHERE strftime('%Y', o.orderDate) IN ('2003', '2004');   -- 년도만 뽑아내겠다 orders테이블에 있는 orderDate 필드에서

--- 서브 쿼리로 푼다면?
SELECT c.customerNumber
    , c.customerName
FROM customers c
WHERE customerNumber IN (
    SELECT o.customerNumber
    FROM order o
    WHERE strftime('%Y', o.orderDate) IN ('2003', '2004')
);
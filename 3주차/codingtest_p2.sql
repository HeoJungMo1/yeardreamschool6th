/* =====================================================================
   Day 07 마케팅 분석 SQL 퀴즈 20문제 (정답 작성용)
   - 사용 DB : classicmodels.db  (datasets/classicmodels.db)
   - 테마    : 마케팅·매출·고객·제품 라인 분석
   ===================================================================== */

/* ================================================================
   PART A. 쉬운 문제 (4)
   ================================================================ */

SELECT sqlite_version();


/* ----------------------------------------------------------------
   Q01. [집계] productLine별 등록 제품 수
   -- 마케팅팀: 카탈로그에 제품 라인별 SKU(품목) 수가 필요합니다.
   -- 출력: productLine, product_count (내림차순)
   -- 테이블명: products
   ---------------------------------------------------------------- */
SELECT productLine, COUNT(*) AS product_count
FROM products
GROUP BY productLine
ORDER BY product_count DESC;



/* ----------------------------------------------------------------
   Q02. [GROUP BY] country별 잠재 고객(고객) 수
   -- 글로벌 마케팅: 국가별 고객 규모를 파악합니다.
   -- 출력: country, customer_count (고객 수 내림차순)
   -- 테이블명: customers
   ---------------------------------------------------------------- */
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY csutomer_count DESC;


/* ----------------------------------------------------------------
   Q03. [집계] productLine별 평균 권장소비자가(MSRP)
   -- 가격 정책 검토: 라인별 평균 MSRP를 소수 둘째 자리까지 구하세요.
   -- 출력: productLine, avg_msrp (내림차순)
   -- 테이블명: products
   ---------------------------------------------------------------- */
SELECT productLine, AVG(MSRP) AS avg_msrp
FROM products
GROUP BY productLine
ORDER BY avg_msrp DESC;

/* ----------------------------------------------------------------
   Q04. [WHERE + COUNT] 2004년 주문 건수
   -- 연도별 마케팅 캠페인 성과: 2004년 주문이 몇 건인지 구하세요.
   -- 힌트: strftime('%Y', orderDate)
   -- 출력: orders_in_2004
   -- 테이블명: orders
   ---------------------------------------------------------------- */
SELECT COUNT(*) AS orders_in_2004
FROM orders
WHERE strftime("%Y", orderDate) = '2004'
;


/* ================================================================
   PART B. JOIN 문제 (5)
   ================================================================ */


/* ----------------------------------------------------------------
   Q05. [INNER JOIN] country별 총 주문 금액
   -- 지역 마케팅 예산: 국가별 매출(quantity × priceEach 합) TOP 10
   -- 출력: country, total_revenue (내림차순, LIMIT 10)
   -- 테이블명: customers, orders, orderdetails
   ---------------------------------------------------------------- */
SELECT country
   , ROUND(SUM(quantityOrdered * priceEach), 2) AS total_revenue
FROM customers c
JOIN orders o
   ON c.customerNumber = o.customerNumber
JOIN orderdetails od
   ON o.orderNumber = od.orderNumber
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 10;


/* ----------------------------------------------------------------
   Q06. [JOIN + GROUP BY] productLine별 매출 및 판매 수량
   -- 제품 라인 마케팅: 라인별 매출·판매량 비교
   -- 출력: productLine, total_revenue, total_qty (매출 내림차순)
   -- 테이블명: products, orderdetails
   ---------------------------------------------------------------- */
SELECT p.productLine
   , ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS total_revenue
   , SUM(od.quantityOrdered) AS total_qty
FROM products p
JOIN orderdetails od
   ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY total_revenue DESC;


/* ----------------------------------------------------------------
   Q07. [JOIN] salesRep(영업 담당)별 담당 고객 수·평균 신용한도
   -- 세일즈 마케팅: 담당자별 포트폴리오 규모
   -- 출력: employeeNumber, rep_name, customer_count, avg_creditLimit
   -- 정렬: customer_count 내림차순
   -- 테이블명: employees, customers
   ---------------------------------------------------------------- */
SELECT e.employeeNumber
   , e.firstName || ' ' || e.lastName AS rep_name
   , COUNT(c.customerNumber) AS customer_count
   , AVG(c.creditLimit) AS avg_creditLimit
FROM employees e
JOIN customers c
   ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY e.employeeNumber, rep_name
ORDER BY customer_count DESC;

/* ----------------------------------------------------------------
   Q08. [JOIN] territory(지역)별 고객·주문·매출 요약
   -- 지역 마케팅 KPI: offices.territory 기준
   -- 출력: territory, customer_count, order_count, total_revenue
   -- 테이블명: offices, employees, customers, orders, orderdetails
   ---------------------------------------------------------------- */
SELECT territory
   , COUNT(DISTINCT c.customerNumber) AS customer_count
   , COUNT(DISTINCT o.orderNumber) AS order_count
   , SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM offices o
JOIN employees e
   ON o.officeCode = e.officeCode
JOIN customers c
   ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o
   ON c.customerNumber = o.customerNumber
JOIN orderdetails od
   ON o.orderNumber = od.orderNumber
GROUP BY territory;


/* ----------------------------------------------------------------
   Q09. [JOIN + HAVING] 'Classic Cars' 라인 제품을 3회 이상 구매한 고객
   -- 타깃 마케팅: 충성 고객 후보군 추출
   -- 출력: customerNumber, customerName, purchase_count
   -- 조건: HAVING purchase_count >= 3
   -- 테이블명: customers, orders, orderdetails, products
   ---------------------------------------------------------------- */
SELECT c.customerNumber
   , c.customerName
   , COUNT(*) AS purchase_count
FROM customers c
JOIN orders o
   ON c.customerNumber = o.customerNumber
JOIN orderdetails od
   ON o.orderNumber = od.orderNumber
JOIN products p
   ON od.productCode = p.productCode
WHERE p.productLine = 'Classic Cars'
GROUP BY c.customerNumber, c.customerName
HAVING purchase_count >= 3;


/* ================================================================
   PART C. 서브쿼리 문제 (5)
   ================================================================ */


/* ----------------------------------------------------------------
   Q10. [WHERE 서브쿼리] 전체 고객 평균 creditLimit 초과 고객
   -- VIP 마케팅 후보: 평균 신용한도보다 높은 고객
   -- 출력: customerNumber, customerName, creditLimit (내림차순)
   -- 테이블명: customers
   ---------------------------------------------------------------- */
SELECT c1.customerNumber
   , c1.customerName
   , c1.creditLimit
FROM customers c1
WHERE c1.creditLimit > (
   SELECT AVG(c2.creditLimit)
   FROM customers c2
   )
ORDER BY c1.creditLimit DESC;

/* ----------------------------------------------------------------
   Q11. [IN 서브쿼리] 2003년과 2004년 모두 주문한 고객
   -- 리텐션 마케팅: 연속 구매 고객 식별 (IN 2회 또는 조건 조합)
   -- 출력: customerNumber, customerName
   -- 테이블명: customers, orders
   ---------------------------------------------------------------- */
SELECT c.customerNumber
   , c.customerName
FROM customers c
WHERE c.customerNumber IN (
   SELECT o.customerNumber
   FROM orders o
   WHERE strftime("%Y", o.orderDate) = '2003'
) AND c.customerNumber IN (
   SELECT o.customerNumber
   FROM orders o
   WHERE strftime("%Y", o.orderDate) = '2004'
);


SELECT DISTINCT c.customerNumber
     , c.customerName
FROM customers c
JOIN orders o2003
   ON c.customerNumber = o2003.customerNumber 
  AND strftime('%Y', o2003.orderDate) = '2003' 
JOIN orders o2004
   ON c.customerNumber = o2004.customerNumber 
  AND strftime('%Y', o2004.orderDate) = '2004'

/* ----------------------------------------------------------------
   Q12. [NOT IN] 한 번도 주문하지 않은 고객 (잠재 이탈·미활성)
   -- 윈백(Win-back) 캠페인 대상
   -- 출력: customerNumber, customerName, country
   -- 테이블명: customers, orders
   ---------------------------------------------------------------- */
SELECT c.customerNumber
   , c.customerName
   , c.country
FROM customers c
WHERE c.customerNumber NOT IN(
   SELECT o.customerNumber
   FROM orders o
)


/* ----------------------------------------------------------------
   Q13. [FROM 서브쿼리] productLine별 매출 TOP 3
   -- 카테고리 마케팅: 라인별 매출 상위 3개만
   -- 출력: productLine, line_revenue
   -- 테이블명: products, orderdetails
   ---------------------------------------------------------------- */
SELECT productLine
   , line_revenue
FROM (
   SELECT p.productLine
      , ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS line_revenue
   FROM products p
   JOIN orderdetails od
      ON p.productCode = od.productCode
   GROUP BY p.productLine
) AS sub
ORDER BY line_revenue DESC
LIMIT 3;


/* ----------------------------------------------------------------
   Q14. [EXISTS] 'Shipped' 주문 이력이 있는 국가 목록
   -- 배송 완료 경험 국가 → 재구매 캠페인 지역
   -- 출력: country (중복 없이)
   -- 테이블명: customers, orders
   ---------------------------------------------------------------- */
SELECT c.country
FROM customers c
WHERE EXISTS (
   SELECT 1
   FROM orders o
   WHERE o.status = 'Shipped' AND c.customerNumber = o.customerNumber
)

SELECT c.country
FROM customers c
JOIN orders o
   ON c.customerNumber = o.customerNumber
WHERE o.status = 'Shipped'


/* ================================================================
   PART D. 윈도우 함수 (4)
   ================================================================ */


/* ----------------------------------------------------------------
   Q15. [RANK] 고객별 총 결제액 순위 TOP 10
   -- 마케팅 등급: 결제액 기준 VIP 순위
   -- 출력: customerNumber, customerName, total_payment, payment_rank
   -- 테이블명: customers, payments
   ---------------------------------------------------------------- */
SELECT c.customerNumber
   , c.customerName
   , SUM(p.amount) AS total_payment
   , RANK() OVER (ORDER BY SUM(p.amount) DESC) AS payment_rank
FROM customers c
JOIN payments p
   ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, p.customerNumber
ORDER BY payment_rank
LIMIT 10;

SELECT customerNumber
   , customerName
   , total_payment
   , payment_rank
FROM (
   SELECT c.customerNumber
   , c.customerName
   , SUM(p.amount) AS total_payment
   , RANK() OVER (ORDER BY SUM(p.amount) DESC) AS payment_rank
   FROM customers c
   JOIN payments p
      ON c.customerNumber = p.customerNumber
   GROUP BY c.customerNumber, p.customerNumber
)
ORDER BY payment_rank
LIMIT 10;

/* ----------------------------------------------------------------
   Q16. [PARTITION BY] 국가 내 creditLimit 순위
   -- 국가별 프리미엄 고객: 같은 country 안에서 신용한도 순위 (각 국가별 상위 3명씩)
   -- 출력: country, customerName, creditLimit, country_rank
   -- 정렬: country, country_rank
   -- 테이블명: customers
   ---------------------------------------------------------------- */
SELECT country
   , country_rank
FROM (
   SELECT s.country
      , s.customerName
      , s.creditLimit
      , RANK() OVER (PARTITION BY s.country ORDER BY creditLimit DESC) AS country_rank
   FROM customers s
) AS sub
WHERE country_rank <= 3
ORDER BY country, country_rank   

SELECT s.country
   , s.customerName
   , s.creditLimit
   , RANK() OVER (PARTITION BY s.country ORDER BY creditLimit DESC) AS country_rank
FROM customers s
WHERE country_rank <= 3
ORDER BY country_rank


/* ----------------------------------------------------------------
   Q17. [LAG] 월별 매출 및 전월 대비 증감
   -- 마케팅 트렌드: 월별 주문 매출 MoM(Month-over-Month)
   -- 출력: year_month, monthly_revenue, prev_month_revenue, mom_diff
   -- 테이블명: orders, orderdetails
   ---------------------------------------------------------------- */
SELECT year_month
   , monthly_revenue
   , prev_month_revenue
   , ROUND(monthly_revenue - prev_month_revenue) AS mom_diff
FROM (
   SELECT strftime("%Y-%m", o.orderDate) AS year_month
      , ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS monthly_revenue
      , LAG(ROUND(SUM(od.quantityOrdered * od.priceEach), 2), 1) OVER (
         ORDER BY strftime("%Y-%m", o.orderDate)) AS prev_month_revenue
   FROM orders o
   JOIN orderdetails od
      ON o.orderNumber = od.orderNumber
   GROUP BY year_month
) AS sub


/* ----------------------------------------------------------------
   Q18. [SUM OVER] productLine별 매출 비중 (Running ratio)
   -- 포트폴리오 분석: 라인별 매출 + 전체 대비 비율
   -- 출력: productLine, line_revenue, revenue_ratio
   -- 테이블명: products, orderdetails
   ---------------------------------------------------------------- */
SELECT productLine
   , line_revenue
   , ROUND((line_revenue / SUM(line_revenue) OVER ()), 2) AS revenue_ratio
FROM (
   SELECT p.productLine
      , ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS line_revenue
   FROM products p
   JOIN orderdetails od
      ON p.productCode = od.productCode
   GROUP BY p.productLine
) AS sub


/* ----------------------------------------------------------------
   Q19. [NOT EXISTS] 한 번도 판매되지 않은 제품 (재고·프로모션 검토)
   -- orderdetails에 없는 productCode
   -- 출력: productCode, productName, productLine, quantityInStock
   -- 테이블명: products, orderdetails
   ---------------------------------------------------------------- */
SELECT p.productCode, p.productName, p.productLine, p.quantityInStock
FROM products p
WHERE NOT EXISTS (
   SELECT 1
   FROM orderdetails od
   WHERE p.productCode = od.productCode
);

/* ================================================================
   PART E. 매우 어려운 복합 쿼리 (1)
   ================================================================ */


/* ----------------------------------------------------------------
   Q20. [복합] 국가 × productLine 마케팅 대시보드
   -- JOIN + 서브쿼리 + 윈도우 함수 + CTE
   --
   -- 요구사항:
   --   1) 국가·제품라인별 매출(line_revenue) 집계
   --   2) 해당 국가 내 productLine 매출 순위(country_line_rank)
   --   3) 국가 전체 매출(country_total) 대비 비중(pct_of_country)
   --   4) 국가 평균 라인 매출(country_avg_line_rev) 초과 여부(above_avg_flag)
   --   5) country_total 이 전체 국가 평균 초과인 country 만 (마케팅 집중 국가)
   -- 출력: country, productLine, line_revenue, country_line_rank,
   --       pct_of_country, above_avg_flag
   -- 정렬: country, country_line_rank
   -- 테이블명: customers, orders, orderdetails, products
   ---------------------------------------------------------------- */


-- ============================================================
-- End of Day0
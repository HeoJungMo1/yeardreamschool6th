/* =====================================================================
   Day04 종합 연습 — JOIN + 서브쿼리 (답지, 6문제)
   - 참고: Day04_1_Join_lecture.sql, Day04_2_subquery_lecture.sql
   - 사용 DB : classicmodels.db  (datasets/classicmodels.db)

   ====================
   문제별 활용 테이블 정리
   ====================
   1. orders
   2. orders, orderdetails, products
   3. customers, orders
   4. customers
   5. customers, orders
   6. customers, orders (customers 셀프 조인 포함)

   주요 테이블(스키마 참고):
     customers(customerNumber, customerName, country, salesRepEmployeeNumber, creditLimit, ...)
     employees(employeeNumber, firstName, lastName, officeCode, reportsTo, jobTitle)
     orders(orderNumber, orderDate, status, customerNumber)
     orderdetails(orderNumber, productCode, quantityOrdered, priceEach)
     products(productCode, productName, productLine, buyPrice, MSRP, ...)

   [SQLite 주의]
     - ALL / ANY               : 미지원 → MAX / MIN 서브쿼리로 대체
     - 다중열 서브쿼리         : (col1, col2) IN (서브쿼리) 형태 지원
   ===================================================================== */

SELECT sqlite_version();


/* ================================================================
   문제 1. [GROUP BY]
   -- 사용 테이블: orders
   ================================================================
   orders 테이블에서 status(주문 상태)별 주문 건수를 구하세요.
   출력 컬럼 : status, OrderCount
   정렬      : OrderCount 내림차순
   ================================================================ */
SELECT status, COUNT(*) AS OrderCount FROM orders
GROUP BY status
ORDER BY OrderCount DESC;


/* ================================================================
   문제 2. [EQUI JOIN + GROUP BY + WHERE]
   -- 사용 테이블: orders, orderdetails, products
   ================================================================
   orders, orderdetails, products 세 테이블을
   WHERE 절 등가 조인으로 연결하고,
   productLine이 'Planes'인 제품이 포함된 주문에 대해
   고객(customerNumber)별 총 주문금액을 구하세요.
   (총 주문금액 = SUM(quantityOrdered × priceEach))
   출력 컬럼 : customerNumber, TotalAmount
   정렬      : TotalAmount 내림차순, 상위 10건
   ================================================================ */
SELECT o.customerNumber, ROUND(SUM(quantityOrdered * priceEach), 2) AS Total_amount
FROM orders AS o, orderdetails AS od, products AS p
WHERE o.orderNumber = od.orderNumber
   AND od.productCode = p.productCode
   AND productLine = 'Planes'
GROUP BY o.customerNumber 
ORDER BY Total_amount DESC
LIMIT 10
;

SELECT * FROM products
WHERE productLine = 'Planes'


/* ================================================================
   문제 3. [다중행 서브쿼리 — IN]
   -- 사용 테이블: customers, orders
   ================================================================
   'Shipped' 상태의 주문을 한 번이라도 한 고객의
   customerName, country를 중복 없이 조회하세요.
   정렬 : customerName 오름차순
   ================================================================ */




/* ================================================================
   문제 4. [다중열 서브쿼리]
   -- 사용 테이블: customers
   ================================================================
   각 country(국가)별로 creditLimit(신용한도)이 가장 높은 고객을 조회하세요.
   출력 컬럼 : country, customerName, creditLimit
   정렬      : country 오름차순
   힌트      : (country, creditLimit) IN (서브쿼리) 활용
   ================================================================ */




/* ================================================================
   문제 5. [JOIN + GROUP BY + HAVING — 이탈(Churn) 고객 1단계]
   -- 사용 테이블: customers, orders
   ================================================================
   데이터 기준 마지막일: 2005-05-31

   과거 주문 이력이 있는 고객 중,
   마지막 주문일이 '2005-01-01' 이전인 고객(잠재 이탈 고객)을 찾으세요.
   (최근 5개월간 한 번도 주문하지 않은 고객)

   customers와 orders를 INNER JOIN하고,
   고객별 마지막 주문일·무주문 경과일을 구하세요.
   출력 컬럼 : customerName, country, LastOrderDate, DaysSinceLastOrder
   정렬      : DaysSinceLastOrder 내림차순, 상위 15건
   힌트      : DaysSinceLastOrder = julianday('2005-05-31') - julianday(마지막주문일)
   ================================================================ */

-- 이 쿼리는 '과거 주문 이력이 있으나 마지막 주문이 2005-01-01 이전인(즉 장기간 주문이 없는) 잠재 이탈 고객'을 찾는 쿼리
-- 주요 컬럼:
--   - customerName       : 고객명
--   - country            : 국가
--   - LastOrderDate      : 해당 고객의 마지막 주문일
--   - DaysSinceLastOrder : 마지막 주문일로부터 2005-05-31(데이터 기준일)까지 경과일 (정수, 일 단위)

-- julianday('YYYY-MM-DD') 함수는 해당 날짜를 '줄리안 데이'라는 실수값(날짜의 연속 일수)으로 변환.
-- 두 날짜의 줄리안 데이 값의 차이는 '일수 차이'를 의미
-- julianday('2005-05-31') - julianday('2004-12-31') = 151(일)




/* ================================================================
   실전 쿼리 [SELF JOIN + 서브쿼리 복합 — 이탈(Churn) 고객 2단계]
   -- 사용 테이블: customers, orders (customers 셀프 조인 포함)
   -- 풀지 마세요!
   ================================================================
   [문제 5와의 차이 — 한 줄 요약]
   문제 5: "오래 주문 안 한 고객" 전체를 찾음
   문제 6: 그중에서 "같은 나라에는 아직 거래하는 고객이 있는데,
           나 혼자만 유독 오래 끊긴 고객"을 골라 냄

   [상황 예시]
   프랑스 고객 A → 마지막 주문 2004년 (오래됨)
   프랑스 고객 B → 2005년에도 주문함 (아직 활성)
   → A는 "이탈 의심", B는 비교 대상(ActivePeer)

   [용어 정리]
   · 데이터 마지막일     : 2005-05-31  (오늘 날짜라고 가정)
   · 최근 활성 고객      : 2005-01-01 이후 주문이 1건이라도 있는 고객
   · 무주문 경과일       : 마지막 주문일 ~ 2005-05-31 사이 며칠인지
                           (문제 5에서 이미 계산해 봄)

   [풀이 순서 — 3단계로 생각하기]
   ① c1(이탈 의심 고객) 선별
      - 주문 이력이 있고
      - 마지막 주문일 < '2005-01-01'  ← 문제 5와 동일 조건

   ② customers 셀프 조인으로 c2(활성 고객) 연결
      - c1.country = c2.country  (같은 나라끼리만 비교)
      - c2는 2005-01-01 이후 주문한 고객 (EXISTS 서브쿼리)

   ③ c1이 "유독" 오래 끊겼는지 확인 (서브쿼리)
      - c1의 무주문 경과일 >
        같은 나라 활성 고객들의 평균 무주문 경과일
      - 의미: 나라 시장은 살아 있는데, c1만 평균보다 훨씬 오래 안 옴

   [출력 컬럼]
   ChurnCustomer      : 이탈 의심 고객 (c1)
   country            : 국가
   LastOrderDate      : c1의 마지막 주문일
   DaysSinceLastOrder : c1의 무주문 경과일 (문제 5와 같은 계산)
   ActivePeer         : 같은 나라의 활성 고객 (c2) — 비교용

   [정렬] country 오름차순 → DaysSinceLastOrder 내림차순, 상위 20행

   [힌트]
   · 무주문 경과일 = julianday('2005-05-31') - julianday(마지막주문일)
   · c1, c2 모두 customers 테이블 — 같은 테이블을 두 번 쓰는 것이 셀프 조인
   ================================================================ */




/* =====================================================================
   END OF Day04-answers.sql
   ===================================================================== */

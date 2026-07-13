-- ============================================================
--  Day 05. 그룹 함수 & 윈도우 함수 — 실습 문제 & 정답 (상세한 주석 및 설명 포함)
--  대상 DB : classicmodels.db  (datasets/classicmodels.db)
--  참고    : https://www.sqlitetutorial.net/sqlite-window-functions/
-- ============================================================
-- 테이블 구조 요약 
--    customers   : 고객 정보 (customerNumber, customerName, country, creditLimit, salesRepEmployeeNumber)
--    employees   : 직원 정보 (employeeNumber, firstName, lastName, jobTitle, officeCode)
--    offices     : 지점 정보 (officeCode, city, territory)
--    orders      : 주문 정보 (orderNumber, orderDate, status, customerNumber)
--    orderdetails: 주문 상세 (orderNumber, productCode, quantityOrdered, priceEach)
--    products    : 제품 정보 (productCode, productName, productLine, buyPrice, MSRP)
--    payments    : 결제 정보 (customerNumber, paymentDate, amount)
-- ============================================================


-- ============================================================
-- [문제 01] ROW_NUMBER — 단순 순번 부여
-- ============================================================
-- [설명]
-- 1. products 테이블에서 buyPrice(매입가)를 기준으로 내림차순 정렬합니다.
-- 2. 윈도우 함수 ROW_NUMBER()를 사용하여 순번(row_num)을 부여합니다.
-- 3. 가장 비싼 10개 제품을 조회합니다.
-- 
-- [출력 컬럼]
--   - productName : 제품명
--   - buyPrice    : 매입가
--   - row_num     : (매입가 내림차순 기준) 순번
SELECT productName, buyPrice
    , ROW_NUMBER() OVER (ORDER BY buyPrice DESC) AS row_num
FROM products
ORDER BY buyPrice DESC
LIMIT 10;


-- ============================================================
-- [문제 02] RANK / DENSE_RANK / ROW_NUMBER 비교
-- ============================================================
-- RANK_NUMBER : 공동등수 x 무조건 고유 등수, RANK : 공동등수 o 다음등수 건너뛰기, DENSE_RANK() : 공동등수 o 다음등수 촘촘하게
-- [설명]
-- 1. 고객별 총 결제 금액(totalPayment)을 집계합니다.
-- 2. 윈도우 함수 RANK/DENSE_RANK/ROW_NUMBER를 모두 적용하여 순위를 표현합니다.
--    (RANK는 동점자 순위 건너뜀, DENSE_RANK는 건너뛰지 않음, ROW_NUMBER는 무조건 1씩 증가)
-- 3. 결제금액이 가장 큰 상위 10개 고객만 출력합니다.
--
-- [출력 컬럼]
--   - customerNumber : 고객번호
--   - customerName   : 고객명
--   - totalPayment   : 총 결제액
--   - rnk            : RANK 순위
--   - dense_rnk      : DENSE_RANK 순위
--   - row_num        : ROW_NUMBER 순위
WITH CustomerPayments AS (
    SELECT c.customerNumber
        , c.customerName
        , SUM(p.amount) AS TotalPayment

        RANK() OVER (ORDER BY SUM(p.amount) DESC) AS rnk
        DENSE_RANK() OVER (ORDER BY SUM(p.amount) DESC) AS dense_rnk
        ROW_NUMBER() OVER (ORDER BY SUM(p.amount) DESC) AS row_num
    FROM customers c
    JOIN payments p
        ON p.customerNumber = c.customerNumber
    GROUP BY
        c.customerNumber, c.customerName
)

SELECT customerNumber, customerName
    , totalPayment
    , rnk
    , dense_rnk
    , row_num
FROM CustomerPayments
WHERE row_num <= 10
ORDER BY totalPayment DESC;


-- ============================================================
-- [문제 03] PARTITION BY — 국가별 파티션
-- ============================================================
-- [설명]
-- 1. customers 테이블에서 각 고객의 신용한도(creditLimit)와
--    같은 국가(country) 내의 평균 신용한도(avgCreditByCountry)를
--    윈도우 함수(서브쿼리 없이)로 함께 출력합니다.
-- 2. 국가별(country) 파티션을 기준으로 AVG(creditLimit) 적용.
-- 3. 국가명 오름차순, 신용한도 내림차순으로 정렬.
--
-- [출력 컬럼]
--   - customerName       : 고객명
--   - country            : 국가
--   - creditLimit        : 신용한도
--   - avgCreditByCountry : 해당 국가의 평균 신용한도
SELECT customerName
    , country
    , creditLimit
    , AVG(creditLimit) OVER (PARTITION BY country) AS 평균
    , creditLimit - AVG(creditLimit) OVER (PARTITION BY country) AS 증감
FROM customers
WHERE creditLimit IS NOT NULL -- NULL제외한 값 조회
ORDER BY country ASC, creditLimit DESC



-- ============================================================
-- [문제 04] PARTITION BY + 집계 — 연-월별 결제합계 및 해당 월 평균결제금액 1등 고객 조회
-- ============================================================
-- [설명]
-- 1. 결제일을 연-월(YYYY-MM) 형식(payYearMonth)으로 변환합니다.
-- 2. 연-월, 고객별로 그룹화 후 해당 기간 평균 결제금액(avgMonthAmount) 계산.
-- 3. RANK()를 이용해 월별 평균 결제액 순위(monthAvgRank) 부여.
-- 4. 월별 1등(monthAvgRank=1)만 출력합니다.
--    (서브쿼리 1개, WITH 절 없이 처리)
--
-- [출력 컬럼]
--   - customerNumber    : 고객번호
--   - customerName      : 고객명
--   - payYearMonth      : 결제 연월(YYYY-MM)
--   - avgMonthAmount    : (월별/고객별) 평균 결제금액
--   - monthAvgRank      : 월 내 평균 결제금액 순위(1위만 추출)
-- 공부할 때 확장해서 생각
-- 궁금증? 시분초? ==> 공식문서에 답이 다 있다


-- ============================================================
-- [문제 05] 누적 합계 (Running Total)
-- ============================================================
-- [설명]
-- 1. 결제일(paymentDate) 기준 오름차순으로 정렬.
-- 2. 각 행까지의 누적 결제액(runningTotal)을 윈도우 함수 SUM + ROWS BETWEEN으로 구함.
-- 3. 상위 15건만 출력
--
-- [출력 컬럼]
--   - customerNumber : 고객번호
--   - paymentDate    : 결제일
--   - amount         : 금액
--   - runningTotal   : 현재 행까지 누적 결제액
-- ROW BETWEEN
SELECT customerNumber
    , paymentDate
    , amount
    , SUM(amount) OVER (
        ORDER BY paymentDate -- 범위 지정
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
FROM payments
ORDER BY paymentDate ASC -- 결제일 오름차순 정렬
LIMIT 15;

-- ============================================================
-- [문제 06] LAG — 직전 결제 금액
-- ============================================================
-- [설명]
-- 1. 고객별(customerNumber) 파티션을 나누고,
-- 2. 결제일(paymentDate) 기준 오름차순으로 정렬.
-- 3. 바로 직전 결제금액(prevAmount)을 LAG 함수로 같이 출력.
-- 4. 상위 15건만 표시.
--
-- [출력 컬럼]
--   - customerNumber : 고객번호
--   - paymentDate    : 결제일
--   - amount         : 금액
--   - prevAmount     : 직전 결제 금액(첫 결제는 NULL)
SELECT
    customerNumber
    , paymentDate
    , amount
    , LAG(amount, 1) OVER (PARTITION BY customerNumber ORDER BY paymentDate ASC)
FROM payments;


-- ============================================================
-- [문제 07] LEAD — 다음 결제 금액
-- ============================================================
-- [설명]
-- 1. 고객별(customerNumber) 파티션 기준
-- 2. 결제일 오름차순 정렬 후, 다음 행의 결제금액(nextAmount)을 LEAD 함수로 추출
-- 3. 마지막 결제는 nextAmount가 NULL
-- 4. 상위 15건 표시
--
-- [출력 컬럼]
--   - customerNumber : 고객번호
--   - paymentDate    : 결제일
--   - amount         : 금액
--   - nextAmount     : 다음 결제 금액
SELECT
    customerNumber
    , paymentDate
    , amount
    , LEAD(amount, 1) OVER (PARTITION BY customerNumber ORDER BY paymentDate ASC)
FROM payments;

-- ============================================================
-- [문제 08] 국가별 최근 결제 고객 찾기 (FIRST_VALUE만 사용)
-- ============================================================
-- [설명]
-- 1. 각 국가(country) 내에서 결제일(paymentDate) 내림차순 정렬 후
-- 2. FIRST_VALUE 함수로 최근 결제 고객(customerName)과 날짜(paymentDate)를 추출
-- 3. 국가별로 1명(중복 없이)만 보여지도록 DISTINCT 처리 및 오름차순 정렬
--
-- [출력 컬럼]
--   - country          : 국가
--   - firstCustomer    : 국가 내 최근 결제한 고객명
--   - firstPaymentDate : 국가 내 최근 결제일
SELECT DISTINCT country
    , FIRST_VALUE(customerName) OVER (
        PARTITION BY country ORDER BY paymentDate DESC
    ) AS firstCustomer -- 가장 최근 값이 첫 번째로 등장
FROM (
    SELECT c.country
        , c.customerName
        , p.paymentDate
    FROM customers c
    INNER JOIN payments p ON c.customerNumber = p.customerNumber
);

-- 인라인 뷰로 활용
SELECT c.country
    , c.customerName
    , p.paymentDate
FROM customers c
INNER JOIN payments p ON c.customerNumber = p.customerNumber;


-- ============================================================
-- [문제 09] 연도별 NTILE — 4분위 2분위 총 매출 구하기
-- ============================================================
-- [설명]
-- 1. 고객별, 연도별로 결제 총액(totalPayment)을 구함
-- 2. 각 연도별(paymentYear) 파티션 기준, 총 결제액 내림차순으로 4분위수(NTILE(4)) 부여
-- 3. 2분위(paymentQuartile = 2)에 해당하는 고객들의 총 결제액만 모아 연도별 합산 출력
--
-- [출력 컬럼]
--   - year                        : 결제 연도
--   - totalPayment_2nd_quartile   : 해당 연도 2분위 고객 매출 총합
SELECT *
FROM 


-- ============================================================
--  PART 2. 실전 응용 (문제 10)
-- ============================================================


-- ============================================================
-- [문제 10] 실전 — 국가별 VIP 고객 식별 (결제 순위 + 평균 대비)
-- ============================================================
-- [설명]
-- 1. customers와 payments를 JOIN해 고객별 총 결제금액(totalPayment) 집계  
--    → 인라인 뷰(cust_pay)에서 처리 ==> 첫 번째 인라인 뷰
-- 2. 국가(country)별 파티션에서 결제금액 순으로 RANK 부여 (countryRank)
-- 3. 같은 국가 내 고객들의 평균 결제금액(countryAvgPayment)을 구하고,
--    각 고객의 결제액과 평균의 차이(diffFromAvg)도 추가
---- 2, 3쿼리를 묶어서 처리하고 => 인라인 뷰로 다시 정리
-- 4. 국가별 상위 3명(countryRank <= 3)만 최종 결과로 출력
---- WEHRE 절로 3이하만 필터링
--
-- [출력 컬럼]
--   - country            : 국가
--   - customerName       : 고객명
--   - totalPayment       : 고객 총 결제금액
--   - countryRank        : 국가 내 결제금액 순위
--   - countryAvgPayment  : 국가별 평균 결제액
--   - diffFromAvg        : 국가평균 대비 차이
-- [정렬] 국가, 국가내순위 오름차순


-- 앞으로 작성해야 하는 쿼리 흐름
-- 기본문법 + 서브쿼리 + 조인 + 윈도우 함수
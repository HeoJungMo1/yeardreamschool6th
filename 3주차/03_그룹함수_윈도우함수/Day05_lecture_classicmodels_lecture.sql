-- ============================================================
--  Day 04. 그룹 함수 & 윈도우 함수 — classicmodels 실전 강의
--  SQL로 데이터 다루기 2
--  대상 DB : classicmodels.db  (datasets/classicmodels.db)
-- ============================================================
--  주요 사용 테이블
--    customers   : customerNumber, customerName, country, city,
--                  salesRepEmployeeNumber, creditLimit
--    employees   : employeeNumber, firstName, lastName,
--                  jobTitle, officeCode, reportsTo
--    offices     : officeCode, city, country, territory
--    orders      : orderNumber, orderDate, status, customerNumber
--    orderdetails: orderNumber, productCode, quantityOrdered, priceEach
--    products    : productCode, productName, productLine, MSRP, buyPrice
--    payments    : customerNumber, checkNumber, paymentDate, amount
-- ============================================================
--  SQLite 지원 현황
--    윈도우 함수 (RANK, LAG, LEAD, NTILE 등) : SQLite 3.25.0+
--    버전 확인 : SELECT sqlite_version();
-- ============================================================

-- [설명] 현재 접속한 SQLite의 윈도우 함수 지원 버전 확인 (3.25.0 이상 필요)
SELECT sqlite_version();


-- ============================================================
--  PART 1. 윈도우 함수 실전 예제 (3문제)
-- ============================================================
--  아래 문제들은 classicmodels DB를 활용한 실무형 분석 시나리오입니다.
--  JOIN · 서브쿼리 · 윈도우 함수를 함께 쓰는 패턴을 익힙니다.


-- ------------------------------------------------------------
-- [실전 1] 영업 지역(Territory)별 영업사원 실적 순위
-- ------------------------------------------------------------
-- [문제 상세]
-- 1) 각 영업사원(Sales Rep)이 담당한 고객들(customerNumber) 중 'Shipped' 상태 주문의 매출 합계를 구함
-- 2) 각 사무실의 지역구분(territory) 단위로 구분(PARTITION)해서, 동일 지역 내 총매출 기준 내림차순 순위 부여
-- 3) 매출적 상위 영업사원 분포 파악이 목적
-- [상세 흐름]
-- - employees와 offices를 JOIN → 사무실별 territory 확인
-- - employees와 customers를 JOIN → 담당 고객 확인
-- - customers와 orders JOIN → 고객 주문 확인
-- - orders와 orderdetails를 JOIN → 주문 내역 및 매출 상세 계산
-- - 'Shipped' 주문만 필터
-- - GROUP BY로 Sales Rep과 territory별 집계, 윈도우 함수로 지역 내 순위 부여

SELECT 
    -- 영업사원 이름 (firstName + lastName 연결)
    e.firstName || ' ' || e.lastName       AS SalesRep,
    -- 사무실 지역
    off.territory,
    -- 해당 영업사원이 관리하는 고객의 수 (고유 customerNumber 개수)
    COUNT(DISTINCT c.customerNumber)       AS CustomerCount,
    -- 영업사원이 담당한 출하 주문 전체 매출 합계 (주문수량 * 단가 합)
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS TotalSales,
    -- 윈도우 함수: 같은 지역(territory) 내에서 매출기준 순위 부여 (1=최고)
    RANK() OVER (
        PARTITION BY off.territory  -- 지역 단위로 분할
        ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC  -- 매출 기준 내림차순
    )                                    AS TerritoryRank
FROM employees e
    JOIN offices     off ON e.officeCode = off.officeCode         -- 영업사원-사무실 연결
    JOIN customers   c   ON e.employeeNumber = c.salesRepEmployeeNumber  -- 영업사원-고객 연결
    JOIN orders      o   ON c.customerNumber = o.customerNumber         -- 고객-주문 연결
    JOIN orderdetails od ON o.orderNumber = od.orderNumber             -- 주문-주문상세 연결
WHERE 
    e.jobTitle LIKE '%Sales Rep%'    -- 영업사원만 대상
    AND o.status = 'Shipped'         -- 출하(Shipped) 주문에 한정
GROUP BY 
    e.employeeNumber, e.firstName, e.lastName, off.territory  -- 사원 및 지역별 집계
ORDER BY 
    off.territory, TerritoryRank;    -- 지역별, 순위순 정렬


-- ------------------------------------------------------------
-- [실전 2] 월별 출하 매출 추이 & 누적 매출 (Running Total)
-- ------------------------------------------------------------
-- [문제 상세]
-- 1) 출하된(Shipped) 상태의 주문을 월별로 집계 (서브쿼리)
-- 2) 월별 매출(MonthlyRevenue)에 대해 윈도우 함수로 누적 합계(RunningTotal)와 전체 매출(GrandTotal) 계산 
-- 3) 누적 매출 / 전체 매출 비율(CumulRatio, 누적율)도 계산해 "해당 달까지 목표 달성도" 표시
-- [상세 흐름]
-- - 내부 서브쿼리 monthly: 월(YYYY-MM) 단위로 매출 합계 산출
-- - 외부 쿼리에서
--   · SUM(MonthlyRevenue) OVER (ORDER BY YearMonth ...): 달별 누적 합계(RunningTotal)
--   · SUM(MonthlyRevenue) OVER (): 파티션 없이 전체 합(GrandTotal)
--   · 누적/총합 비율(CumulRatio) 계산
--   · ROUND로 표기소수 자릿수 정리

SELECT 
    YearMonth,                                                        -- 주문월(YYYY-MM)
    ROUND(MonthlyRevenue, 2)                    AS MonthlyRevenue,    -- 월 매출(2자리 반올림)
    ROUND(
        SUM(MonthlyRevenue) OVER (
            ORDER BY YearMonth                       -- 시간순 누적 정렬
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    )                                         AS RunningTotal,        -- 월별 누적매출 (해당월까지 전체합)
    ROUND(
        SUM(MonthlyRevenue) OVER (), 2
    )                                         AS GrandTotal,          -- 전체(모든월) 매출 총합
    ROUND(
        SUM(MonthlyRevenue) OVER (
            ORDER BY YearMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(MonthlyRevenue) OVER (), 4
    )                                         AS CumulRatio           -- 누적매출/총매출 비율 (목표대비 진척도)
FROM (
    -- 월(YYYY-MM)별 출하(Shipped) 주문의 매출 집계
    SELECT 
        strftime('%Y-%m', o.orderDate)         AS YearMonth,              -- 주문일을 연-월 포맷으로 변환
        SUM(od.quantityOrdered * od.priceEach) AS MonthlyRevenue          -- 월별 매출 총합 계산
    FROM orders o
        JOIN orderdetails od ON o.orderNumber = od.orderNumber           -- 주문-상세 연결
    WHERE o.status = 'Shipped'
    GROUP BY strftime('%Y-%m', o.orderDate)
) monthly
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- [실전 3] 국가별 고객 신용한도 3등급 세분화 (NTILE)
-- ------------------------------------------------------------
-- [문제 상세]
-- 1) 국가별로 고객을 파티션(PARTITION BY country)하여, 각 국가 내에서 신용한도(creditLimit) 내림차순 기준 등급 분할
-- 2) 윈도우 함수 NTILE(3)으로 3개 등급(1: 상위, 3: 하위)화
-- 3) 국가별 신용한도 평균도 함께 출력 (비교/시각화 용이)
-- [상세 흐름]
-- - customers 테이블에서 creditLimit이 있는 고객만 필터
-- - 국가별 신용한도 평균(AVG(creditLimit) OVER ...)
-- - 국가 내 신용한도 내림차순 등급(NTILE(3))
-- - 등급별, 국가별로 정렬

SELECT 
    customerName,                                                              -- 고객명
    country,                                                                   -- 국가
    creditLimit,                                                               -- 해당 고객 신용한도
    ROUND(AVG(creditLimit) OVER (PARTITION BY country), 2)  AS CountryAvgCredit, -- 국가평균 신용한도(소수2)
    NTILE(3) OVER (
        PARTITION BY country                   -- 국가별로 나눔
        ORDER BY creditLimit DESC              -- 신용한도 높은 순서 분할
    )                                      AS CreditTier
FROM customers
WHERE creditLimit IS NOT NULL                    -- 신용한도 없는 행 제외
ORDER BY country, CreditTier, creditLimit DESC;  -- 국가, 등급, 신용한도순 정렬


-- ============================================================
--  PART 2. 시계열 분석 — LAG · LEAD 활용 (3문제)
-- ============================================================
--  LAG  : 현재 행 기준 "이전" 값을 가져옴  (과거 비교)
--  LEAD : 현재 행 기준 "다음" 값을 가져옴  (미래 예측·패턴 파악)
--  시계열 분석의 핵심은 "시간 순서(ORDER BY)"와
--  "누구 기준으로 나눌지(PARTITION BY)"를 정확히 지정하는 것입니다.


-- ------------------------------------------------------------
-- [시계열 1] 월별 출하 매출 — 전월 대비 증감 (MoM, Month-over-Month)
-- ------------------------------------------------------------
-- [문제 상세]
-- 1) 월별로 Shipped 주문 매출 집계 (서브쿼리)
-- 2) LAG 윈도우 함수로 이전달 매출(PrevMonthRevenue) 구함
-- 3) 현재월-이전월로 전월대비 증감액(MoM_Change) 계산
-- 4) (증감액/이전월)*100으로 증감률(MoM_Pct, 백분율) 계산
-- [상세 흐름]
-- - 내부 서브쿼리에서 월별 매출 집계
-- - 외부쿼리에서 LAG로 previous month 추출, 변동액/율 산출 및 소수 자릿수 처리

SELECT 
    YearMonth,                                                        -- YYYY-MM 형식(월)
    ROUND(MonthlyRevenue, 2)                    AS MonthlyRevenue,    -- 해당월 매출
    ROUND(
        LAG(MonthlyRevenue, 1) OVER (
            ORDER BY YearMonth                  -- 시간순 정렬로 직전월 값 추출
        ), 2
    )                                         AS PrevMonthRevenue,    -- 직전월 매출 (첫 행은 NULL)
    ROUND(
        MonthlyRevenue -
        LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth), 2
    )                                         AS MoM_Change,          -- 전월대비 증감액
    ROUND(
        (MonthlyRevenue -
         LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth))
        / LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth), 4
    )                                         AS MoM_Pct              -- 전월대비 증감률
FROM (
    -- 월별(YYYY-MM) shipped 주문 매출 집계
    SELECT 
        strftime('%Y-%m', o.orderDate)         AS YearMonth,                  -- 연월 변환
        SUM(od.quantityOrdered * od.priceEach) AS MonthlyRevenue              -- 월간매출
    FROM orders o
        JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.status = 'Shipped'
    GROUP BY strftime('%Y-%m', o.orderDate)
) monthly
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- [시계열 2] 고객별 재주문 간격 분석 — LAG로 주문 간 며칠?
-- ------------------------------------------------------------
-- [문제 상세]
-- 1) 고객별, 주문일별로 매출 집계
-- 2) LAG 윈도우 함수로 같은 고객의 직전 주문일 추출(prevOrderDate)
-- 3) julianday(orderDate) - julianday(prevOrderDate)로 일수 차이 추출(DaysSincePrevOrder)
-- 4) DaysSincePrevOrder가 긴 고객 선별 (이탈 위험 감지)
-- [상세 흐름]
-- - customers→orders→orderdetails 순 JOIN으로 고객의 주문 집계, 일자별 묶음
-- - 각 고객 단위로 orderDate 기준 정렬하며 LAG로 직전 주문일 넣기
-- - 외부 쿼리에서 첫 주문(NULL)은 제외

SELECT
    customerName,                                   -- 고객명
    country,                                        -- 고객국가
    orderDate,                                      -- 주문일
    orderRevenue,                                   -- 주문 매출(해당 주문 총합)
    prevOrderDate,                                  -- 해당 고객의 직전 주문일(LAG)
    CAST(
        julianday(orderDate) - julianday(prevOrderDate)  -- 현 주문일-직전 주문일(일수)
    AS INTEGER)                                   AS DaysSincePrevOrder
FROM (
    SELECT 
        c.customerName,                             -- 고객명
        c.country,                                  -- 국가
        o.orderDate,                                -- 주문일
        ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS orderRevenue,   -- 주문별 매출합
        LAG(o.orderDate, 1) OVER (
            PARTITION BY c.customerNumber           -- 고객별로 분할
            ORDER BY o.orderDate                    -- 주문일 기준 과거순 정렬
        )                                          AS prevOrderDate
    FROM customers c
        JOIN orders o  ON c.customerNumber = o.customerNumber
        JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.status = 'Shipped'
    GROUP BY c.customerNumber, c.customerName, c.country,
             o.orderNumber, o.orderDate
) order_gap
WHERE prevOrderDate IS NOT NULL                        -- 첫 주문인 경우(NULL)는 제외
ORDER BY DaysSincePrevOrder DESC                       -- 주문간격 많은 순 정렬
LIMIT 20;


-- ------------------------------------------------------------
-- [시계열 3] 고객별 결제 패턴 — LAG · LEAD로 전후 결제 비교
-- ------------------------------------------------------------
-- [문제 상세]
-- 1) 결제 내역(payments) 4회 이상인 고객만 추림(리텐션, 안정성 분석용)
-- 2) customers-join-payments
-- 3) LAG(amount)로 직전 결제액, LEAD(amount)로 다음 결제액 구함
-- 4) 현재 결제액 - 직전 결제액 = 증감액(ChangeFromPrev)
-- [상세 흐름]
-- - 결제건수 4건 이상 고객을 서브쿼리로 선별
-- - 해당 고객 및 결제이력 JOIN
-- - 윈도우 함수로 이전, 다음 결제액 추출(LAG, LEAD), 증감 계산

SELECT
    c.customerName,                   -- 고객명
    p.paymentDate,                    -- 결제일
    ROUND(p.amount, 2)                    AS amount,             -- 결제금액
    ROUND(
        LAG(p.amount, 1) OVER (
            PARTITION BY c.customerNumber       -- 고객기준 분할
            ORDER BY p.paymentDate              -- 결제일 기준 과거순
        ), 2
    )                                AS PrevPayment,           -- 직전 결제금액(LAG)
    ROUND(
        LEAD(p.amount, 1) OVER (
            PARTITION BY c.customerNumber
            ORDER BY p.paymentDate
        ), 2
    )                                AS NextPayment,           -- 다음 결제금액(LEAD)
    ROUND(
        p.amount - LAG(p.amount, 1) OVER (
            PARTITION BY c.customerNumber
            ORDER BY p.paymentDate
        ), 2
    )                                AS ChangeFromPrev         -- 직전 결제 대비 증감액
FROM customers c
    JOIN payments p ON c.customerNumber = p.customerNumber
WHERE c.customerNumber IN (
    -- [상세] payments 테이블에서 결제내역 4회 이상 고객만 뽑기(패턴 신뢰도 확보 목적)
    SELECT customerNumber
    FROM payments
    GROUP BY customerNumber
    HAVING COUNT(*) >= 4
)
ORDER BY c.customerNumber, p.paymentDate            -- 고객, 결제일순 정렬(패턴 시각화 용이)
LIMIT 30;                                          -- 예시행 30건 제한


-- ============================================================
--  END OF Day04_lecture_classmodels.sql
-- ============================================================

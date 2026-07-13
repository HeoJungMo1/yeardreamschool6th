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

SELECT sqlite_version();


-- ============================================================
--  PART 1. 윈도우 함수 실전 예제 (3문제)
-- ============================================================
--  아래 문제들은 classicmodels DB를 활용한 실무형 분석 시나리오입니다.
--  JOIN · 서브쿼리 · 윈도우 함수를 함께 쓰는 패턴을 익힙니다.


-- ------------------------------------------------------------
-- [실전 1] 영업 지역(Territory)별 영업사원 실적 순위
-- ------------------------------------------------------------
-- [비즈니스 배경]
-- classicmodels는 전 세계(NA · EMEA · APAC)에 사무실을 두고
-- 영업사원(Sales Rep)이 담당 고객을 관리합니다.
-- 분기 실적 리뷰 전, 경영진은 "같은 지역 안에서 누가 잘하고 있는가?"를
-- 먼저 파악해야 공정한 인센티브를 설계할 수 있습니다.
--
-- [분석 목표]
--  · 각 영업사원이 담당하는 고객의 'Shipped' 주문 매출 합계를 구한다.
--  · territory(지역: NA / EMEA / APAC)별로 파티션을 나누어 순위를 매긴다.
--  · 지역 1위 영업사원을 빠르게 식별한다.
--
-- [활용 테이블]
--   employees → offices (사무실·지역)
--   employees → customers (담당 고객)
--   customers → orders → orderdetails (주문 매출)
--
-- [조회 컬럼]
--   SalesRep, territory, CustomerCount, TotalSales, TerritoryRank
--
-- [핵심 윈도우 함수]
--   RANK() OVER (PARTITION BY territory ORDER BY TotalSales DESC)
--   → 같은 지역 안에서만 순위를 매김 (PARTITION BY)
-- ------------------------------------------------------------

SELECT e.firstName || ' ' || e.lastName          AS SalesRep,
       off.territory,
       COUNT(DISTINCT c.customerNumber)          AS CustomerCount,
       ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS TotalSales,
       RANK() OVER (
           PARTITION BY off.territory
           ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC
       )                                         AS TerritoryRank
FROM   employees   e
JOIN   offices     off ON e.officeCode = off.officeCode
JOIN   customers   c   ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN   orders     o   ON c.customerNumber = o.customerNumber
JOIN   orderdetails od ON o.orderNumber = od.orderNumber
WHERE  e.jobTitle LIKE '%Sales Rep%'
  AND  o.status = 'Shipped'
GROUP BY e.employeeNumber, e.firstName, e.lastName, off.territory
ORDER BY off.territory, TerritoryRank;


-- ------------------------------------------------------------
-- [실전 2] 월별 출하 매출 추이 & 누적 매출 (Running Total)
-- ------------------------------------------------------------
-- [비즈니스 배경]
-- 재무팀은 "올해 누적 매출이 목표의 몇 %인가?"를 매월 확인합니다.
-- 단순 월별 합계만으로는 전체 그림이 안 보이므로,
-- 각 월 매출과 함께 '그 달까지의 누적 합계'를 나란히 봐야 합니다.
--
-- [분석 목표]
--  ① Shipped 주문만 대상으로 월별 매출을 집계한다. (서브쿼리)
--  ② 각 월 행에 전체 기간 누적 매출(RunningTotal)을 붙인다.
--  ③ 전체 매출(GrandTotal)도 함께 표시해 비중을 계산할 수 있게 한다.
--
-- [활용 테이블]
--   orders, orderdetails
--
-- [조회 컬럼]
--   YearMonth, MonthlyRevenue, RunningTotal, GrandTotal, CumulRatio
--
-- [핵심 윈도우 함수]
--   SUM(MonthlyRevenue) OVER (ORDER BY YearMonth ROWS UNBOUNDED PRECEDING)
--   → 시간 순서대로 이전 달까지 합산 (누적)
--   SUM(MonthlyRevenue) OVER ()
--   → 파티션·정렬 없이 전체 합 (전체 매출)
-- ------------------------------------------------------------

SELECT YearMonth,
       ROUND(MonthlyRevenue, 2)                              AS MonthlyRevenue,
       ROUND(SUM(MonthlyRevenue) OVER (
           ORDER BY YearMonth
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ), 2)                                                 AS RunningTotal,
       ROUND(SUM(MonthlyRevenue) OVER (), 2)                 AS GrandTotal,
       ROUND(
           SUM(MonthlyRevenue) OVER (
               ORDER BY YearMonth
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) / SUM(MonthlyRevenue) OVER ()
       , 4)                                                  AS CumulRatio
FROM (
    /* ① 월별 출하 매출 집계 — 서브쿼리로 먼저 정리 */
    SELECT strftime('%Y-%m', o.orderDate)                    AS YearMonth,
           SUM(od.quantityOrdered * od.priceEach)            AS MonthlyRevenue
    FROM   orders       o
    JOIN   orderdetails od ON o.orderNumber = od.orderNumber
    WHERE  o.status = 'Shipped'
    GROUP BY strftime('%Y-%m', o.orderDate)
) monthly
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- [실전 3] 국가별 고객 신용한도 3등급 세분화 (NTILE)
-- ------------------------------------------------------------
-- [비즈니스 배경]
-- 신용관리팀은 고객의 creditLimit(신용한도)을 기준으로
-- VIP · 일반 · 주의 그룹을 나누어 여신 정책을 다르게 적용합니다.
-- 단순 정렬만으로는 "이 고객이 자기 나라 안에서 어느 수준인가?"가
-- 보이지 않으므로, 국가별 파티션 안에서 3등급(NTILE)으로 나눕니다.
--
-- [분석 목표]
--  · 국가(country)별로 파티션을 나눈다.
--  · creditLimit 내림차순 기준 3그룹(1=상위, 3=하위)으로 분류한다.
--  · 각 행에 해당 국가 평균 신용한도도 함께 표시해 비교한다.
--
-- [활용 테이블]
--   customers
--
-- [조회 컬럼]
--   customerName, country, creditLimit, CountryAvgCredit, CreditTier
--
-- [핵심 윈도우 함수]
--   AVG(creditLimit) OVER (PARTITION BY country)  — 국가 평균
--   NTILE(3) OVER (PARTITION BY country ORDER BY creditLimit DESC)
--   → 국가 안에서 상·중·하 3등급
-- ------------------------------------------------------------

SELECT customerName,
       country,
       creditLimit,
       ROUND(AVG(creditLimit) OVER (PARTITION BY country), 2) AS CountryAvgCredit,
       NTILE(3) OVER (
           PARTITION BY country
           ORDER BY creditLimit DESC
       )                                                    AS CreditTier
FROM   customers
WHERE  creditLimit IS NOT NULL
ORDER BY country, CreditTier, creditLimit DESC;


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
-- [비즈니스 배경]
-- 경영 대시보드에서 가장 많이 쓰는 지표 중 하나가 '전월 대비(MoM)'입니다.
-- "이번 달 매출이 지난달보다 늘었는가, 줄었는가?"를 한눈에 보여줘야
-- 계절성·이상치를 빠르게 발견할 수 있습니다.
--
-- [분석 목표]
--  ① 월별 Shipped 매출을 서브쿼리로 집계한다.
--  ② LAG로 직전 월 매출(PrevMonthRevenue)을 가져온다.
--  ③ 현재 월 − 직전 월 = MoM_Change(전월 대비 증감액)을 계산한다.
--
-- [활용 테이블]
--   orders, orderdetails
--
-- [조회 컬럼]
--   YearMonth, MonthlyRevenue, PrevMonthRevenue, MoM_Change, MoM_Pct
--
-- [핵심 윈도우 함수]
--   LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth)
--   → 바로 이전 달 매출 (첫 달은 NULL)
--
-- [해석 팁]
--   MoM_Change > 0  → 전월 대비 성장
--   MoM_Change < 0  → 전월 대비 감소
--   2004-12 → 2005-01 구간에서 큰 폭 감소가 보이면 연말·연초 계절성을 의심
-- ------------------------------------------------------------

SELECT YearMonth,
       ROUND(MonthlyRevenue, 2)                              AS MonthlyRevenue,
       ROUND(LAG(MonthlyRevenue, 1) OVER (
           ORDER BY YearMonth
       ), 2)                                                 AS PrevMonthRevenue,
       ROUND(
           MonthlyRevenue -
           LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth)
       , 2)                                                  AS MoM_Change,
       ROUND(
           (MonthlyRevenue -
            LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth))
           / LAG(MonthlyRevenue, 1) OVER (ORDER BY YearMonth)
       , 4)                                                  AS MoM_Pct
FROM (
    SELECT strftime('%Y-%m', o.orderDate)                    AS YearMonth,
           SUM(od.quantityOrdered * od.priceEach)            AS MonthlyRevenue
    FROM   orders       o
    JOIN   orderdetails od ON o.orderNumber = od.orderNumber
    WHERE  o.status = 'Shipped'
    GROUP BY strftime('%Y-%m', o.orderDate)
) monthly
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- [시계열 2] 고객별 재주문 간격 분석 — LAG로 주문 간 며칠?
-- ------------------------------------------------------------
-- [비즈니스 배경]
-- CRM 팀은 "고객이 평소 얼마나 자주 주문하는가?"를 알아야
-- 이탈(Churn) 징후를 조기에 발견할 수 있습니다.
-- 예를 들어 평소 30일마다 주문하던 고객이 180일 동안 주문이 없으면
-- 리텐션 캠페인 대상입니다.
--
-- [분석 목표]
--  ① 고객별·주문일별 매출을 JOIN + GROUP BY로 정리한다.
--  ② LAG(orderDate)로 "직전 주문일"을 가져온다.
--     (PARTITION BY customerNumber → 고객마다 따로 계산)
--  ③ julianday로 두 주문 사이 며칠인지(DaysSincePrevOrder) 계산한다.
--  ④ 간격이 유독 긴 고객을 찾아 이탈 위험군으로 분류한다.
--
-- [활용 테이블]
--   customers, orders, orderdetails
--
-- [조회 컬럼]
--   customerName, country, orderDate, orderRevenue,
--   prevOrderDate, DaysSincePrevOrder
--
-- [핵심 윈도우 함수]
--   LAG(o.orderDate, 1) OVER (
--       PARTITION BY c.customerNumber
--       ORDER BY o.orderDate
--   )
--   → 같은 고객의 바로 이전 주문일
--
-- [해석 팁]
--   DaysSincePrevOrder가 500일 이상이면 재주문 주기가 매우 긴 편
--   → 영업사원에게 follow-up 요청 대상
-- ------------------------------------------------------------

SELECT customerName,
       country,
       orderDate,
       orderRevenue,
       prevOrderDate,
       CAST(
           julianday(orderDate) - julianday(prevOrderDate)
       AS INTEGER)                                           AS DaysSincePrevOrder
FROM (
    SELECT c.customerName,
           c.country,
           o.orderDate,
           ROUND(SUM(od.quantityOrdered * od.priceEach), 2)  AS orderRevenue,
           LAG(o.orderDate, 1) OVER (
               PARTITION BY c.customerNumber
               ORDER BY o.orderDate
           )                                                 AS prevOrderDate
    FROM   customers   c
    JOIN   orders     o  ON c.customerNumber = o.customerNumber
    JOIN   orderdetails od ON o.orderNumber = od.orderNumber
    WHERE  o.status = 'Shipped'
    GROUP BY c.customerNumber, c.customerName, c.country,
             o.orderNumber, o.orderDate
) order_gap
WHERE  prevOrderDate IS NOT NULL          /* 첫 주문은 비교 대상 제외 */
ORDER BY DaysSincePrevOrder DESC
LIMIT 20;


-- ------------------------------------------------------------
-- [시계열 3] 고객별 결제 패턴 — LAG · LEAD로 전후 결제 비교
-- ------------------------------------------------------------
-- [비즈니스 배경]
-- 회계팀은 고객이 결제 금액을 일정하게 유지하는지,
-- 갑자기 줄이거나 늘리는지를 모니터링합니다.
-- 결제 금액이 크게 줄면 현금 흐름 악화 신호일 수 있고,
-- 결제가 4회 이상 있는 '단골' 고객만 보면 패턴이 더 선명합니다.
--
-- [분석 목표]
--  ① 결제 4회 이상 고객만 서브쿼리로 필터링한다.
--  ② customers와 payments를 JOIN한다.
--  ③ LAG(amount)  → 직전 결제 금액 (PrevPayment)
--  ④ LEAD(amount)  → 다음 결제 금액 (NextPayment)
--  ⑤ 현재 결제 − 직전 결제 = ChangeFromPrev (증감액)
--
-- [활용 테이블]
--   customers, payments
--
-- [조회 컬럼]
--   customerName, paymentDate, amount,
--   PrevPayment, NextPayment, ChangeFromPrev
--
-- [핵심 윈도우 함수]
--   LAG(amount,  1) OVER (PARTITION BY customerNumber ORDER BY paymentDate)
--   LEAD(amount, 1) OVER (PARTITION BY customerNumber ORDER BY paymentDate)
--
-- [LAG vs LEAD 정리]
--   LAG  → 과거 방향 (이전 행의 값)
--   LEAD → 미래 방향 (다음 행의 값)
--   마지막 결제의 NextPayment는 NULL (다음 결제 없음)
--   첫 결제의 PrevPayment는 NULL (이전 결제 없음)
--
-- [해석 팁]
--   ChangeFromPrev가 큰 음수 → 직전보다 결제액 급감 (주의)
--   ChangeFromPrev가 큰 양수 → 직전보다 결제액 급증 (성장 또는 일시적 대금)
-- ------------------------------------------------------------

SELECT c.customerName,
       p.paymentDate,
       ROUND(p.amount, 2)                                    AS amount,
       ROUND(LAG(p.amount, 1) OVER (
           PARTITION BY c.customerNumber
           ORDER BY p.paymentDate
       ), 2)                                                 AS PrevPayment,
       ROUND(LEAD(p.amount, 1) OVER (
           PARTITION BY c.customerNumber
           ORDER BY p.paymentDate
       ), 2)                                                 AS NextPayment,
       ROUND(
           p.amount -
           LAG(p.amount, 1) OVER (
               PARTITION BY c.customerNumber
               ORDER BY p.paymentDate
           )
       , 2)                                                  AS ChangeFromPrev
FROM   customers c
JOIN   payments  p ON c.customerNumber = p.customerNumber
WHERE  c.customerNumber IN (
    /* 결제 4회 이상인 고객만 — 패턴 분석에 충분한 이력 */
    SELECT customerNumber
    FROM   payments
    GROUP BY customerNumber
    HAVING COUNT(*) >= 4
)
ORDER BY c.customerNumber, p.paymentDate
LIMIT 30;


-- ============================================================
--  END OF Day04_lecture_classicmodels.sql
-- ============================================================

-- ============================================================
--  Day 04. 그룹 함수 & 윈도우 함수 실습문제
--  SQL로 데이터 다루기 2
--  대상 DB : chinook.db (SQLite)
-- ============================================================
--  주요 사용 테이블
--    employees     : EmployeeId, FirstName, LastName, Title,
--                    ReportsTo, HireDate, City, Country
--    customers     : CustomerId, FirstName, LastName,
--                    Country, SupportRepId
--    invoices      : InvoiceId, CustomerId, InvoiceDate,
--                    BillingCountry, BillingCity, Total
--    invoice_items : InvoiceLineId, InvoiceId, TrackId,
--                    UnitPrice, Quantity
--    tracks        : TrackId, Name, AlbumId, GenreId,
--                    MediaTypeId, Milliseconds, UnitPrice
--    genres        : GenreId, Name
--    media_types   : MediaTypeId, Name
-- ============================================================

-- ============================================================
-- 1. 윈도우 함수 (Window Function)
-- ============================================================
-- 아래 문제들은 윈도우 함수의 기본적 활용 방법을 익히기 위한 실습문제입니다.
--
-- 1-1. 순위 함수 문제
-- ------------------------------------------------------------
-- [시나리오]
-- 우리는 고객들의 전체 구매액을 집계하여 상위 고객을 파악하고자 합니다.
-- 총 구매액 기준으로 다양한 순위 함수(RANK, DENSE_RANK, ROW_NUMBER)를 비교합니다.
--
-- [활용 테이블] customers, invoices
-- [조회 필드] CustomerId, CustomerName, Country, TotalPurchase, Rank, DenseRank, RowNumber
--
-- [문제1]
-- 고객별 총 구매액(TotalPurchase)을 계산하고, 내림차순 기준으로
-- RANK, DENSE_RANK, ROW_NUMBER 순위를 함께 조회하세요.


-- [문제2]
-- 각 국가별로 고객의 총 구매액 순위를 매기세요.
-- (즉, 국가별 1등~N등 고객)
-- [활용 테이블] customers, invoices
-- [조회 필드] Country, CustomerName, TotalPurchase, CountryRank



-- ------------------------------------------------------------
-- 1-2. 일반 집계 함수 (OVER와 함께 사용)
-- ------------------------------------------------------------
-- [시나리오]
-- 각 청구서별(BillingCountry)로 평균 청구금액을 함께 확인하고자 합니다.
-- 또한, 전체 매출 총합과 청구일자 순 누적합계도 조회합니다.
--
-- [문제3] (서브쿼리 & 윈도우 함수 비교)
-- 각 청구건의 국가별 평균 청구금액을 함께 출력하세요.
-- [활용 테이블] invoices
-- [조회 필드] InvoiceId, BillingCountry, Total, CountryAvgTotal

-- (서브쿼리 방식)


-- (윈도우 함수 방식)


-- [문제4]
-- 각 청구서에 대해 전체 합계(GrandTotal), 청구일 순 누적합계(RunningTotal)를 같이 조회하세요.
-- [활용 테이블] invoices
-- [조회 필드] InvoiceId, InvoiceDate, Total, GrandTotal, RunningTotal



-- ------------------------------------------------------------
-- 1-3. 그룹 내 행 순서 함수
-- ------------------------------------------------------------
-- [시나리오]
-- 국가별 각 청구서의 금액이 해당 국가에서 최저/최고 청구금액인지,
-- 그리고, 한 고객 청구에 대해 직전 혹은 다음 청구금액과 비교 정보가 필요합니다.
--
-- [문제5]
-- 각 청구서를 기준으로, 해당 국가에서의 최소/최대 청구금액도 함께 표시하세요.
-- [활용 테이블] invoices
-- [조회 필드] InvoiceId, BillingCountry, Total, CountryMinTotal, CountryMaxTotal


-- [문제6]
-- 각 청구서에 대해 날짜순으로 이전 청구금액, 다음 청구금액을 함께 출력하세요.
-- [활용 테이블] invoices
-- [조회 필드] InvoiceId, InvoiceDate, Total, PrevInvoiceTotal, NextInvoiceTotal


-- [문제7]
-- 전월 대비 매출 증감을 계산하여 연월, 월 매출, 전월 매출, 증감액을 구하세요.
-- [활용 테이블] invoices
-- [조회 필드] YearMonth, MonthlyTotal, PrevMonthTotal, MoM_Diff



-- ------------------------------------------------------------
-- 1-4. 그룹 내 비율 함수
-- ------------------------------------------------------------
-- [시나리오]
-- 국가별 매출 비율, 고객 구매액의 순위 백분율, 직원을 고용일 기준 그룹화하여 분석합니다.
--
-- [문제8]
-- 국가별 매출 총합, 전체 매출에서의 비율을 함께 조회하세요.
-- [활용 테이블] invoices
-- [조회 필드] BillingCountry, CountryTotal, GrandTotal, RevenueRatio


-- [문제9]
-- 상위 고객 10명에 대해, 구매액의 percent rank, 누적 백분율(cume_dist)도 함께 조회하세요.
-- [활용 테이블] customers, invoices
-- [조회 필드] CustomerId, CustomerName, TotalPurchase, PctRank, CumeDist


-- [문제10]
-- 모든 직원을 고용일 기준 3개의 그룹으로 분류하세요.
-- [활용 테이블] employees
-- [조회 필드] EmployeeId, EmployeeName, Title, HireDate, HireGroup


-- ============================================================
-- 2. 그룹 함수 (Group Function)
-- ============================================================
-- [시나리오]
-- 트랙(음원)을 장르/미디어타입 별로 집계하고, 차원 집계(ROLLUP, CUBE, GROUPING SETS)로 다양한 관점의 통계를 구합니다.
--
-- ------------------------------------------------------------
-- 2-1. GROUP BY (기본)
-- ------------------------------------------------------------
-- [문제11]
-- 장르와 미디어타입별로 트랙의 수(TrackCount)와 평균 단가(AvgPrice)를 구하세요.
-- [활용 테이블] tracks, genres, media_types
-- [조회 필드] Genre, MediaType, TrackCount, AvgPrice


-- ------------------------------------------------------------
-- 2-2. ROLLUP
-- ------------------------------------------------------------
-- [문제12]
-- 장르, 미디어타입별 통계 뿐만 아니라, 장르별 소계, 전체 합계도 함께 조회하세요.
-- ※ ROLLUP 미지원 DB이므로 UNION ALL 방식의 쿼리를 사용합니다.
-- [활용 테이블] tracks, genres, media_types
-- [조회 필드] Genre, MediaType, TrackCount, AvgPrice



-- ------------------------------------------------------------
-- 2-3. CUBE
-- ------------------------------------------------------------
-- [문제13]
-- 장르, 미디어타입별, 장르별, 미디어타입별, 전체합계까지 모든 조합의 집계 결과를 조회하세요.
-- ※ CUBE 미지원 DB이므로 UNION 방식의 쿼리를 사용합니다.
-- [활용 테이블] tracks, genres, media_types
-- [조회 필드] Genre, MediaType, TrackCount, AvgPrice



-- ------------------------------------------------------------
-- 2-4. GROUPING SETS
-- ------------------------------------------------------------
-- [문제14]
-- 장르별 통계 + 미디어타입별 통계를 각각 구하세요.
-- ※ GROUPING SETS 지원하지 않아 각 그룹별 쿼리를 UNION ALL로 나누어 작성합니다.
-- [활용 테이블] tracks, genres, media_types
-- [조회 필드] Genre, MediaType, TrackCount, AvgPrice



-- ============================================================
-- 3. 함수별 요약 정리표
-- ============================================================
-- [이 표는 참고용입니다.]
--
--  [순위 함수]
--  RANK()          동률 시 다음 순위 건너뜀    (1, 2, 3, 3, 5)
--  DENSE_RANK()    동률 시 건너뜀 없음          (1, 2, 3, 3, 4)
--  ROW_NUMBER()    항상 고유한 연속 번호         (1, 2, 3, 4, 5)
--
--  [행 순서 함수]
--  FIRST_VALUE()   파티션 내 첫 번째 값
--  LAST_VALUE()    파티션 내 마지막 값
--                  -> ROWS BETWEEN UNBOUNDED PRECEDING
--                        AND UNBOUNDED FOLLOWING 명시 필수
--  LAG(col, N)     N번째 이전 행 값  (없으면 NULL)
--  LEAD(col, N)    N번째 이후 행 값  (없으면 NULL)
--
--  [비율 함수]
--  RATIO_TO_REPORT  전체 SUM 대비 비율
--                   SQLite/MariaDB : 값 / SUM(값) OVER() 로 대체
--  PERCENT_RANK     순위 백분율  [0, 1]   최고 순위 = 0
--  CUME_DIST        누적 백분율  (0, 1]   0 미포함
--  NTILE(N)         N등분 그룹 번호
--
--  [그룹 함수]             생성 레벨              SQLite 지원
--  ROLLUP(A, B)    (A,B) + (A) + 전체    3가지   미지원 -> UNION ALL
--  CUBE(A, B)      모든 조합 + 전체       4가지   미지원 -> UNION
--  GROUPING SETS   (A) + (B)             2가지   미지원 -> UNION ALL
--
-- ============================================================

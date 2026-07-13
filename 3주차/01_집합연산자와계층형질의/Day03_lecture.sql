-- ============================================================
--  Day 03 강의 실습 SQL
--  주제: 집합 연산자 / 집계 함수 / 서브쿼리 / 계층형 질의
--  데이터베이스: SQLite Chinook DB
--  참고: https://www.sqlitetutorial.net/sqlite-sample-database/
--        https://www.sqlitetutorial.net/sqlite-union/
--        https://www.sqlitetutorial.net/sqlite-except/
--        https://www.sqlitetutorial.net/sqlite-intersect/
--        https://www.sqlitetutorial.net/sqlite-aggregate-functions/
--        https://www.sqlitetutorial.net/sqlite-subquery/
--        https://www.sqlitetutorial.net/sqlite-exists/
-- ============================================================
--
--  Chinook DB 테이블 (11개)
--  ┌─────────────────┬──────────────────────────────────────┐
--  │ 테이블           │ 설명                                  │
--  ├─────────────────┼──────────────────────────────────────┤
--  │ employees       │ 직원 (ReportsTo → 계층형 구조)         │
--  │ customers       │ 고객 (SupportRepId → employees FK)    │
--  │ invoices        │ 청구서 헤더                            │
--  │ invoice_items   │ 청구서 라인 아이템                      │
--  │ artists         │ 아티스트                               │
--  │ albums          │ 앨범 (ArtistId FK)                    │
--  │ tracks          │ 트랙 (AlbumId / GenreId / MediaTypeId)│
--  │ genres          │ 장르                                  │
--  │ media_types     │ 미디어 타입                            │
--  │ playlists       │ 플레이리스트                           │
--  │ playlist_track  │ 플레이리스트-트랙 (M:N 중간 테이블)     │
--  └─────────────────┴──────────────────────────────────────┘
-- ============================================================


-- ============================================================
-- PART 1. 집계 함수 (Aggregate Functions)
-- ============================================================
-- 집계 함수는 여러 행(row)을 입력받아 단일 값을 반환한다
-- GROUP BY, HAVING 절과 함께 자주 사용
--
-- SQLite 제공 집계 함수
--   COUNT()        : 행 수
--   SUM()          : 합계
--   AVG()          : 평균
--   MAX()          : 최댓값
--   MIN()          : 최솟값
--   GROUP_CONCAT() : 문자열 연결 (separator 지정 가능)
--
-- 문법: aggregate_function([DISTINCT | ALL] expression)
--   DISTINCT → 중복 제외 후 집계
--   ALL      → 중복 포함 집계 (기본값)
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 1-1. COUNT() - 행 수 반환
-- ──────────────────────────────────────────────────────────

-- (a) 전체 트랙 수
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT COUNT(*) AS 전체트랙수
FROM tracks;

-- (b) 앨범별 트랙 수 (내림차순)
SELECT AlbumId,
       COUNT(TrackId) AS track_count
FROM tracks
GROUP BY AlbumId
ORDER BY track_count DESC;


-- (c) 국가별 고객 수
SELECT Country,
       COUNT(CustomerId) AS 고객수
FROM customers
GROUP BY Country
ORDER BY 고객수 DESC;

-- (d) DISTINCT - 중복 제거 후 COUNT
--     실제 청구서가 발생한 고유 고객 수
SELECT COUNT(DISTINCT CustomerId) AS 구매고객수
FROM invoices;


-- ──────────────────────────────────────────────────────────
-- 1-2. SUM() - 합계
-- ──────────────────────────────────────────────────────────

-- (a) 앨범별 총 재생 시간 (분 단위)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT AlbumId,
       SUM(Milliseconds) / 60000 AS 총재생시간_분
FROM tracks
GROUP BY AlbumId
ORDER BY 총재생시간_분 DESC;

-- (b) 연도별 총 매출
SELECT strftime('%Y', InvoiceDate) AS 연도,
       ROUND(SUM(Total), 2)        AS 연매출
FROM invoices
GROUP BY 연도
ORDER BY 연도;

-- (c) 장르별 총 트랙 용량 (MB)
SELECT g.Name                              AS 장르,
       ROUND(SUM(t.Bytes) / 1048576.0, 1) AS 총용량_MB
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY 총용량_MB DESC;


-- ──────────────────────────────────────────────────────────
-- 1-3. AVG() - 평균
-- ──────────────────────────────────────────────────────────

-- (a) 앨범별 평균 트랙 길이 (분)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT AlbumId,
       ROUND(AVG(Milliseconds) / 60000.0, 1) AS 평균재생시간_분
FROM tracks
GROUP BY AlbumId;

-- (b) 고객 1인당 평균 청구 금액
SELECT ROUND(AVG(Total), 2) AS 평균청구금액
FROM invoices;

-- (c) 미디어 타입별 평균 단가
SELECT m.Name                    AS 미디어타입,
       ROUND(AVG(t.UnitPrice), 2) AS 평균단가
FROM tracks t
JOIN media_types m ON t.MediaTypeId = m.MediaTypeId
GROUP BY m.Name;


-- ──────────────────────────────────────────────────────────
-- 1-4. MAX() / MIN() - 최댓값·최솟값
-- ──────────────────────────────────────────────────────────

-- (a) 가장 긴 트랙의 재생 시간 (분)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT MAX(Milliseconds) / 10000 AS 최장재생시간_분
FROM tracks;

-- (b) 가장 짧은 트랙의 재생 시간 (분)
SELECT ROUND(MIN(Milliseconds) / 60000.0, 2) AS 최단재생시간_분
FROM tracks;


-- (c) 고객별 최대·최소 청구 금액
SELECT CustomerId,
       ROUND(MAX(Total), 2) AS 최대청구,
       ROUND(MIN(Total), 2) AS 최소청구,
       ROUND(AVG(Total), 2) AS 평균청구
FROM invoices
GROUP BY CustomerId
ORDER BY 최대청구 DESC;


-- ──────────────────────────────────────────────────────────
-- 1-5. GROUP_CONCAT() - 문자열 연결
-- ──────────────────────────────────────────────────────────

-- (a) 앨범 ID = 1 의 트랙 이름 목록 (쉼표 구분)
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT GROUP_CONCAT(Name) AS 트랙목록
FROM tracks
WHERE AlbumId = 1;

-- (b) 구분자를 ' / ' 로 변경
SELECT GROUP_CONCAT(Name, ' / ') AS 트랙목록
FROM tracks
WHERE AlbumId = 1;

-- (c) 장르별 미디어 타입 종류 나열
SELECT g.Name                              AS 장르,
       GROUP_CONCAT(DISTINCT m.Name)       AS 미디어타입목록
FROM tracks t
INNER JOIN genres g      ON t.GenreId     = g.GenreId
INNER JOIN media_types m ON t.MediaTypeId = m.MediaTypeId
GROUP BY g.Name;



-- ──────────────────────────────────────────────────────────
-- 1-6. HAVING - 집계 결과 필터링
--      WHERE 는 집계 전 개별 행 필터
--      HAVING 은 집계 후 그룹 필터
-- ──────────────────────────────────────────────────────────

-- (a) 트랙이 15개 이상인 앨범
SELECT AlbumId,
       COUNT(TrackId) AS 트랙수
FROM tracks
GROUP BY AlbumId
HAVING 트랙수 >= 15
ORDER BY 트랙수 DESC;

-- (b) 총 매출이 $40 이상인 고객
SELECT CustomerId,
       ROUND(SUM(Total), 2) AS 총매출
FROM invoices
GROUP BY CustomerId
HAVING 총매출 >= 40
ORDER BY 총매출 DESC;

-- (c) 평균 트랙 단가가 $0.99 초과인 장르
SELECT g.Name               AS 장르,
       ROUND(AVG(t.UnitPrice), 2) AS 평균단가
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name
HAVING 평균단가 > 0.99;


-- ============================================================
-- PART 2. 서브쿼리 (Subquery)
-- ============================================================
-- 서브쿼리(내부 쿼리/중첩 쿼리): 다른 SQL 문 안에 포함된 SELECT
-- 위치에 따른 분류
--   WHERE 절  : 조건 비교에 활용 (가장 일반적)
--   FROM  절  : 인라인 뷰(Inline View) / 파생 테이블(Derived Table)
--   SELECT 절 : 스칼라 서브쿼리 (행마다 단일값 반환)
--
-- 연관성에 따른 분류
--   비연관(Non-Correlated) : 외부 쿼리와 독립적으로 실행
--   연관(Correlated)       : 외부 쿼리의 값을 참조, 행마다 재실행
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 2-1. WHERE 절 서브쿼리 (비연관)
-- ──────────────────────────────────────────────────────────

-- (a) 가장 긴 트랙 정보 조회
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT TrackId, Name, Milliseconds
FROM tracks
WHERE Milliseconds = (
    SELECT MAX(Milliseconds)
    FROM tracks
);

-- (b) 가장 짧은 트랙 정보 조회
SELECT TrackId, Name, Milliseconds
FROM tracks
WHERE Milliseconds = (
    SELECT MIN(Milliseconds)
    FROM tracks
);

-- (c) 평균 청구 금액보다 높은 청구서 목록
SELECT InvoiceId, CustomerId,
       ROUND(Total, 2) AS 청구금액
FROM invoices
WHERE Total > (
    SELECT AVG(Total)
    FROM invoices
)
ORDER BY Total DESC;

-- (d) IN 서브쿼리 - Rock 장르 트랙 조회
SELECT TrackId, Name
FROM tracks
WHERE GenreId IN (
    SELECT GenreId
    FROM genres
    WHERE Name = 'Rock'
)
ORDER BY Name;

-- (e) NOT IN 서브쿼리 - 한 번도 판매되지 않은 트랙
SELECT TrackId, Name
FROM tracks
WHERE TrackId NOT IN (
    SELECT DISTINCT TrackId
    FROM invoice_items
)
ORDER BY TrackId;


-- ──────────────────────────────────────────────────────────
-- 2-2. FROM 절 서브쿼리 - 인라인 뷰 (Derived Table)
--      서브쿼리 결과를 임시 테이블처럼 사용
-- ──────────────────────────────────────────────────────────

-- (a) 고객별 총 매출 TOP 5
SELECT sub.CustomerId,
       c.FirstName || ' ' || c.LastName AS 고객명,
       sub.총매출
FROM (
    SELECT CustomerId,
           ROUND(SUM(Total), 2) AS 총매출
    FROM invoices
    GROUP BY CustomerId
) AS sub
JOIN customers c ON sub.CustomerId = c.CustomerId
ORDER BY sub.총매출 DESC
LIMIT 5;

-- (b) 앨범별 트랙 수 평균보다 많은 앨범 조회
SELECT a.AlbumId,
       a.Title,
       sub.트랙수
FROM albums a
JOIN (
    SELECT AlbumId,
           COUNT(TrackId) AS 트랙수
    FROM tracks
    GROUP BY AlbumId
) AS sub ON a.AlbumId = sub.AlbumId
WHERE sub.트랙수 > (
    SELECT AVG(트랙수)
    FROM (
        SELECT COUNT(TrackId) AS 트랙수
        FROM tracks
        GROUP BY AlbumId
    )
)
ORDER BY sub.트랙수 DESC;

-- (c) 용량이 10MB 미만인 앨범 조회
-- ref: sqlitetutorial.net 서브쿼리 예제 패턴
SELECT a.AlbumId, a.Title
FROM albums a
WHERE 10000000 > (
    SELECT SUM(Bytes)
    FROM tracks
    WHERE tracks.AlbumId = a.AlbumId
)
ORDER BY a.Title;


-- ──────────────────────────────────────────────────────────
-- 2-3. SELECT 절 서브쿼리 - 스칼라 서브쿼리
--      행마다 단일 값을 반환 (연관 서브쿼리)
-- ──────────────────────────────────────────────────────────

-- (a) 앨범별 트랙 수를 SELECT 절에서 계산
-- ref: https://www.sqlitetutorial.net/sqlite-aggregate-functions/
SELECT AlbumId,
       Title,
       (
           SELECT COUNT(TrackId)
           FROM tracks
           WHERE tracks.AlbumId = albums.AlbumId
       ) AS 트랙수
FROM albums
ORDER BY 트랙수 DESC;

-- (b) 고객별 최근 청구 날짜를 SELECT 절에서 계산
SELECT c.CustomerId,
       c.FirstName || ' ' || c.LastName AS 고객명,
       (
           SELECT MAX(InvoiceDate)
           FROM invoices i
           WHERE i.CustomerId = c.CustomerId
       ) AS 최근청구일
FROM customers c
ORDER BY 최근청구일 DESC;

-- (c) 트랙 이름과 해당 장르 이름을 스칼라 서브쿼리로 조회
SELECT t.TrackId,
       t.Name AS 트랙명,
       (
           SELECT g.Name
           FROM genres g
           WHERE g.GenreId = t.GenreId
       ) AS 장르명
FROM tracks t
ORDER BY 장르명, 트랙명
LIMIT 20;


-- ──────────────────────────────────────────────────────────
-- 2-4. 연관 서브쿼리 (Correlated Subquery)
--      외부 쿼리의 값을 참조 → 행마다 서브쿼리 재실행
--      ※ 대용량 데이터에서는 성능 주의
-- ──────────────────────────────────────────────────────────

-- (a) 자신이 속한 장르의 평균 단가보다 비싼 트랙
SELECT t.TrackId,
       t.Name,
       t.UnitPrice,
       g.Name AS 장르
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
WHERE t.UnitPrice > (
    SELECT AVG(t2.UnitPrice)
    FROM tracks t2
    WHERE t2.GenreId = t.GenreId   -- 외부 쿼리의 GenreId 참조
)
ORDER BY g.Name, t.UnitPrice DESC;

-- (b) 평균 트랙 수보다 많은 트랙을 가진 앨범
SELECT a.AlbumId, a.Title
FROM albums a
WHERE (
    SELECT COUNT(*)
    FROM tracks t
    WHERE t.AlbumId = a.AlbumId    -- 외부 쿼리의 AlbumId 참조
) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM tracks
        GROUP BY AlbumId
    )
)
ORDER BY a.AlbumId;


-- ──────────────────────────────────────────────────────────
-- 2-5. EXISTS / NOT EXISTS
--      서브쿼리가 행을 반환하면 TRUE, 없으면 FALSE
--      ※ 결과 집합이 클 때 IN 보다 빠른 경향
-- ──────────────────────────────────────────────────────────

-- (a) 청구서가 있는 고객 조회 (EXISTS)
-- ref: https://www.sqlitetutorial.net/sqlite-exists/
SELECT c.CustomerId,
       c.FirstName || ' ' || c.LastName AS 고객명,
       c.Country
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM invoices i
    WHERE i.CustomerId = c.CustomerId
)
ORDER BY c.CustomerId;

-- (b) 앨범이 없는 아티스트 조회 (NOT EXISTS)
-- ref: https://www.sqlitetutorial.net/sqlite-exists/
SELECT *
FROM artists a
WHERE NOT EXISTS (
    SELECT 1
    FROM albums
    WHERE ArtistId = a.ArtistId
)
ORDER BY Name;

-- (c) 한 번도 판매된 적 없는 트랙 조회 (NOT EXISTS)
SELECT t.TrackId, t.Name, g.Name AS 장르
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
WHERE NOT EXISTS (
    SELECT 1
    FROM invoice_items ii
    WHERE ii.TrackId = t.TrackId
)
ORDER BY g.Name, t.Name;


-- ──────────────────────────────────────────────────────────
-- 2-6. 서브쿼리 활용 종합 예제
-- ──────────────────────────────────────────────────────────

-- (a) 각 고객의 총 구매액이 전체 고객 평균 이상인 VIP 고객
SELECT c.CustomerId,
       c.FirstName || ' ' || c.LastName AS 고객명,
       c.Country,
       ROUND(SUM(i.Total), 2)           AS 총구매액
FROM customers c
JOIN invoices i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
HAVING 총구매액 >= (
    SELECT AVG(고객별합계)
    FROM (
        SELECT SUM(Total) AS 고객별합계
        FROM invoices
        GROUP BY CustomerId
    )
)
ORDER BY 총구매액 DESC;

-- (b) 가장 많이 팔린 장르 TOP 3
SELECT g.Name AS 장르,
       SUM(ii.Quantity) AS 판매수량
FROM invoice_items ii
JOIN tracks t  ON ii.TrackId = t.TrackId
JOIN genres g  ON t.GenreId  = g.GenreId
GROUP BY g.Name
ORDER BY 판매수량 DESC
LIMIT 3;

-- (c) 각 아티스트의 앨범 수 + 총 트랙 수 (서브쿼리 in FROM)
SELECT ar.Name                 AS 아티스트,
       COUNT(DISTINCT al.AlbumId) AS 앨범수,
       SUM(sub.트랙수)            AS 총트랙수
FROM artists ar
JOIN albums al ON ar.ArtistId = al.ArtistId
JOIN (
    SELECT AlbumId, COUNT(*) AS 트랙수
    FROM tracks
    GROUP BY AlbumId
) sub ON al.AlbumId = sub.AlbumId
GROUP BY ar.ArtistId
ORDER BY 총트랙수 DESC
LIMIT 10;


-- ============================================================
-- PART 3. 집합 연산자 (Set Operators)
-- ============================================================
--  연산자      | 중복제거 | 정렬발생 | 역할
--  ------------|----------|----------|-----------
--  UNION       |    O     |    O     | 합집합
--  UNION ALL   |    X     |    X     | 합집합(빠름)
--  INTERSECT   |    O     |    O     | 교집합
--  EXCEPT      |    O     |    O     | 차집합
--
--  공통 규칙
--   1) SELECT 컬럼 수가 동일해야 한다
--   2) 대응 컬럼의 데이터 타입이 호환되어야 한다
--   3) 첫 번째 쿼리의 컬럼명이 최종 결과셋 컬럼명
--   4) ORDER BY 는 최종 결합 결과에만 적용
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 3-1. UNION - 합집합 (중복 제거)
-- ──────────────────────────────────────────────────────────

-- (a) 직원 이름 + 고객 이름 통합 목록
-- ref: https://www.sqlitetutorial.net/sqlite-union/
SELECT FirstName, LastName, 'Employee' AS Type
FROM employees

UNION

SELECT FirstName, LastName, 'Customer'
FROM customers

ORDER BY FirstName, LastName;

-- (b) 구매 이력 유무별 고객 분류
SELECT CustomerId,
       FirstName || ' ' || LastName AS 고객명,
       'Has Invoice'                AS 상태
FROM customers
WHERE CustomerId IN (SELECT DISTINCT CustomerId FROM invoices)

UNION

SELECT CustomerId,
       FirstName || ' ' || LastName AS 고객명,
       'No Invoice'                 AS 상태
FROM customers
WHERE CustomerId NOT IN (SELECT DISTINCT CustomerId FROM invoices)

ORDER BY CustomerId;


-- ──────────────────────────────────────────────────────────
-- 3-2. UNION ALL - 합집합 (중복 포함, 더 빠름)
-- ──────────────────────────────────────────────────────────

-- (a) 연도별 매출 + 전체 합계 리포트 (소계 패턴)
SELECT strftime('%Y', InvoiceDate) AS 연도,
       ROUND(SUM(Total), 2)        AS 매출합계
FROM invoices
GROUP BY 연도

UNION ALL

SELECT '── 전체합계',
       ROUND(SUM(Total), 2)
FROM invoices

ORDER BY 연도;

-- (b) 장르별 트랙 수 + 전체 합계
SELECT g.Name            AS 장르명,
       COUNT(t.TrackId)  AS 트랙수
FROM genres g
LEFT JOIN tracks t ON g.GenreId = t.GenreId
GROUP BY g.Name

UNION ALL

SELECT '■ 전체합계',
       COUNT(*)
FROM tracks

ORDER BY 장르명;


-- ──────────────────────────────────────────────────────────
-- 3-3. INTERSECT - 교집합
-- ──────────────────────────────────────────────────────────

-- (a) 청구서가 있는 고객 (INTERSECT 방식)
-- ref: https://www.sqlitetutorial.net/sqlite-intersect/
SELECT CustomerId, FirstName, LastName
FROM customers

INTERSECT

SELECT CustomerId, FirstName, LastName
FROM invoices
INNER JOIN customers USING (CustomerId)

ORDER BY CustomerId;


-- (b) 2009년과 2010년 모두 구매한 고객 ID
SELECT CustomerId
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2009'

INTERSECT

SELECT CustomerId
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2010'

ORDER BY CustomerId;

SELECT c.CustomerId, c.FirstName, c.LastName
FROM customers c
INNER JOIN (

SELECT CustomerId
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2009'

INTERSECT

SELECT CustomerId
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2010'

ORDER BY CustomerId
) inv ON inv.CustomerId = c.CustomerId;



-- ──────────────────────────────────────────────────────────
-- 3-4. EXCEPT - 차집합
-- ──────────────────────────────────────────────────────────

-- (a) 청구서 없는 고객 (전체 - 청구서 있는 고객)
-- ref: https://www.sqlitetutorial.net/sqlite-except/
SELECT CustomerId, FirstName, LastName
FROM customers

EXCEPT

SELECT CustomerId, FirstName, LastName
FROM invoices
INNER JOIN customers USING (CustomerId)

ORDER BY CustomerId;

-- (b) 2009년 구매 고객 중 2010년에 구매 안 한 고객
SELECT CustomerId
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2009'

EXCEPT

SELECT CustomerId
FROM invoices
WHERE strftime('%Y', InvoiceDate) = '2010'

ORDER BY CustomerId;

-- (c) 플레이리스트에 없는 트랙 (미포함 트랙)
SELECT TrackId, Name
FROM tracks

EXCEPT

SELECT t.TrackId, t.Name
FROM tracks t
JOIN playlist_track pt ON t.TrackId = pt.TrackId

ORDER BY TrackId;


-- ============================================================
-- PART 4. 집계 함수 + 서브쿼리 + 집합 연산자 복합 활용
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 4-1. 집계 + 서브쿼리 + UNION ALL
--      장르별 매출 통계 리포트 (합계 행 포함)
-- ──────────────────────────────────────────────────────────
SELECT g.Name                          AS 장르,
       COUNT(DISTINCT ii.InvoiceId)    AS 청구서수,
       SUM(ii.Quantity)                AS 판매수량,
       ROUND(SUM(ii.UnitPrice * ii.Quantity), 2) AS 총매출
FROM invoice_items ii
INNER JOIN tracks t ON ii.TrackId = t.TrackId
INNER JOIN genres g ON t.GenreId  = g.GenreId
GROUP BY g.Name

UNION ALL

SELECT '── 전체합계',
       COUNT(DISTINCT InvoiceId),
       SUM(Quantity),
       ROUND(SUM(UnitPrice * Quantity), 2)
FROM invoice_items

ORDER BY 장르;


-- ──────────────────────────────────────────────────────────
-- 4-2. 서브쿼리 + EXCEPT
--      판매 실적이 있는 트랙 중 현재 플레이리스트에 없는 트랙
-- ──────────────────────────────────────────────────────────
-- 확인 1: 판매된 트랙 수
SELECT COUNT(DISTINCT TrackId) AS 판매된트랙수
FROM invoice_items;

-- 확인 2: 플레이리스트에 있는 트랙 수
SELECT COUNT(DISTINCT TrackId) AS 플리트랙수
FROM playlist_track;

-- 확인 3: 판매됐지만 플리에 없는 트랙
    SELECT DISTINCT TrackId FROM invoice_items
    EXCEPT
    SELECT DISTINCT TrackId FROM playlist_track
);

-- 확인 4: 플리에 있지만 판매 안 된 트랙 (반대 방향)
SELECT DISTINCT t.TrackId AS TrackId, t.Name AS 트랙명
FROM tracks t
JOIN playlist_track pt ON t.TrackId = pt.TrackId

EXCEPT

SELECT DISTINCT t.TrackId, t.Name
FROM invoice_items ii
JOIN tracks t ON ii.TrackId = t.TrackId

ORDER BY TrackId;


-- ──────────────────────────────────────────────────────────
-- 4-3. 집계 + HAVING + EXISTS 조합
--      앨범이 2개 이상이면서 총 트랙이 30개 이상인 아티스트
-- ──────────────────────────────────────────────────────────
SELECT ar.Name                       AS 아티스트,
       COUNT(DISTINCT al.AlbumId)    AS 앨범수,
       COUNT(t.TrackId)              AS 총트랙수
FROM artists ar
JOIN albums al ON ar.ArtistId = al.ArtistId
JOIN tracks t  ON al.AlbumId  = t.AlbumId
WHERE EXISTS (
    SELECT 1
    FROM albums a2
    WHERE a2.ArtistId = ar.ArtistId
    GROUP BY a2.ArtistId          -- ← GROUP BY 추가
    HAVING COUNT(*) >= 2
)
GROUP BY ar.ArtistId
HAVING 총트랙수 >= 30
ORDER BY 총트랙수 DESC;


-- ──────────────────────────────────────────────────────────
-- 4-4. 인라인 뷰 + UNION ALL - 월별 매출 + 분기 소계
-- ──────────────────────────────────────────────────────────
SELECT strftime('%Y', InvoiceDate)        AS 연도,
       strftime('%m', InvoiceDate)        AS 월,
       ROUND(SUM(Total), 2)               AS 월매출
FROM invoices
GROUP BY 연도, 월

UNION ALL

SELECT strftime('%Y', InvoiceDate)        AS 연도,
       '합계'                              AS 월,
       ROUND(SUM(Total), 2)               AS 월매출
FROM invoices
GROUP BY 연도

ORDER BY 연도, 월;


-- ============================================================
-- PART 5. 계층형 질의 (Hierarchical Query)
-- ============================================================
-- SQLite 방식: WITH RECURSIVE CTE
-- 대상 테이블: employees
--   EmployeeId : PK
--   ReportsTo  : 상위 관리자 FK (NULL = 최상위 Root)
-- ============================================================

-- ──────────────────────────────────────────────────────────
-- 5-1. 기본 계층형 질의 - 보고 체계 전체 조회
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_hierarchy(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    -- Anchor: 최상위 직원 (Root)
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo,
           0 AS lvl
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    -- Recursive: 직속 부하 반복 탐색
    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, h.lvl + 1
    FROM employees e
    JOIN emp_hierarchy h ON e.ReportsTo = h.EmployeeId
)
SELECT lvl                                                AS 계층레벨,
       EmployeeId                                         AS 직원ID,
       SUBSTR('                ', 1, lvl * 4)
           || FirstName || ' ' || LastName                AS 직원명,
       Title                                              AS 직책,
       ReportsTo                                          AS 관리자ID
FROM emp_hierarchy
ORDER BY lvl, EmployeeId;


-- ──────────────────────────────────────────────────────────
-- 5-2. 계층형 + 집계 - 직원별 담당 고객 수 포함 조회
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_hier(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo, 0 AS lvl
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, h.lvl + 1
    FROM employees e
    JOIN emp_hier h ON e.ReportsTo = h.EmployeeId
)
SELECT h.lvl        AS 계층레벨,
       h.EmployeeId AS 직원ID,
       SUBSTR('                ', 1, h.lvl * 4)
           || h.FirstName || ' ' || h.LastName AS 직원명,
       h.Title      AS 직책,
       COUNT(c.CustomerId)                     AS 담당고객수,
       ROUND(SUM(i.Total), 2)                  AS 담당매출합계
FROM emp_hier h
LEFT JOIN customers c ON h.EmployeeId = c.SupportRepId
LEFT JOIN invoices  i ON c.CustomerId  = i.CustomerId
GROUP BY h.EmployeeId, h.lvl, h.FirstName, h.LastName, h.Title
ORDER BY h.lvl, h.EmployeeId;


-- ──────────────────────────────────────────────────────────
-- 5-3. 경로(PATH) + 리프(Leaf) 노드 판별
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_path(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl, path
) AS (
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo,
           0,
           FirstName || ' ' || LastName AS path
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, p.lvl + 1,
           p.path || ' > ' || e.FirstName || ' ' || e.LastName
    FROM employees e
    JOIN emp_path p ON e.ReportsTo = p.EmployeeId
)
SELECT lvl        AS 계층레벨,
       EmployeeId AS 직원ID,
       path       AS 조직경로,
       Title      AS 직책,
       CASE
           WHEN EmployeeId NOT IN (
               SELECT ReportsTo
               FROM employees
               WHERE ReportsTo IS NOT NULL
           ) THEN 'Leaf'
           ELSE 'Branch'
       END AS 노드유형
FROM emp_path
ORDER BY path;


-- ──────────────────────────────────────────────────────────
-- 5-4. 계층형 + UNION ALL - 레벨별 인원 + 전체 합계
-- ──────────────────────────────────────────────────────────
WITH RECURSIVE emp_cte(
    EmployeeId, FirstName, LastName, Title, ReportsTo, lvl
) AS (
    SELECT EmployeeId, FirstName, LastName, Title, ReportsTo, 0
    FROM employees
    WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.FirstName, e.LastName,
           e.Title, e.ReportsTo, c.lvl + 1
    FROM employees e
    JOIN emp_cte c ON e.ReportsTo = c.EmployeeId
)
SELECT 'Level ' || CAST(lvl AS TEXT) AS 계층레벨,
       COUNT(*)                      AS 직원수
FROM emp_cte
GROUP BY lvl

UNION ALL

SELECT '── 합계', COUNT(*)
FROM emp_cte

ORDER BY 계층레벨;


-- ============================================================
-- [참고] Oracle 계층형 질의 구문 (SQLite 미지원 - 비교용)
-- ============================================================
/*
SELECT LEVEL,
       LPAD(' ', 4*(LEVEL-1)) || EmployeeId         AS 직원ID,
       FirstName || ' ' || LastName                 AS 직원명,
       Title,
       ReportsTo,
       CONNECT_BY_ROOT  FirstName || ' ' || LastName AS 루트직원,
       CONNECT_BY_ISLEAF                             AS 리프여부,
       SYS_CONNECT_BY_PATH(LastName, '/')            AS 경로
FROM   employees
START  WITH ReportsTo IS NULL
CONNECT BY  PRIOR EmployeeId = ReportsTo
ORDER  SIBLINGS BY LastName;
*/

-- ============================================================
-- End of Day03_lecture.sql
-- ============================================================
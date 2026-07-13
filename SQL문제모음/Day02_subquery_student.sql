/* =====================================================================
   5장 서브쿼리 — 실습 문제 모음 (답지 포함)
   - 강의자료 순서 준수:
       01 단일 행 서브쿼리   (WHERE 절 + 비교 연산자 =, >, <, ...)
       02 다중 행 서브쿼리   (IN / NOT IN, 그리고 ANY/ALL의 SQLite 대체)
       03 위치에 따른 분류   (스칼라(SELECT절) / FROM절 파생테이블 / EXISTS·상관)
   - 사용 DB: SQLite Tutorial 샘플 데이터베이스 (chinook)
     주요 테이블: artists, albums, tracks, genres,
                  invoices, invoice_items, customers, employees
   - 관계 요약:
       artists.ArtistId      <-> albums.ArtistId
       albums.AlbumId        <-> tracks.AlbumId
       genres.GenreId        <-> tracks.GenreId
       invoices.CustomerId   <-> customers.CustomerId
       invoice_items.TrackId <-> tracks.TrackId
       customers.SupportRepId<-> employees.EmployeeId
   - SQLite는 ANY / ALL 연산자를 지원하지 않음 → MIN / MAX 로 대체
   ===================================================================== */


/* ===============  01. 단일 행 서브쿼리 (WHERE, 비교 연산자)  =========== */

-- 문제 1.
-- 'Balls to the Wall' 트랙보다 재생시간(Milliseconds)이 긴 트랙의
-- 이름과 재생시간을 조회하세요. (단일 행, > 연산자)
SELECT t1.Name, t1.Milliseconds
FROM tracks t1
WHERE t1.Milliseconds > (
    SELECT t2.Milliseconds 
    FROM tracks t2
    WHERE t2.Name = 'Balls to the Wall'
);

-- 문제 2.
-- 전체 트랙의 평균 재생시간보다 긴 트랙의 이름과 재생시간을 조회하세요.
-- 힌트: 서브쿼리에서 AVG를 쓰면 한 값만 반환 = 단일 행.
SELECT t1.Name, t1.Milliseconds
FROM tracks t1
WHERE t1.Milliseconds > (
    SELECT AVG(Milliseconds) AS avg_mill
    FROM tracks
);

-- 문제 3.
-- 단가(UnitPrice)가 가장 비싼 트랙과 '같은' 단가를 가진 트랙의
-- 이름과 단가를 조회하세요. (= 연산자, MAX)
SELECT t.Name, t.UnitPrice
FROM tracks t
JOIN invoice_items i
    ON t.TrackId = i.TrackId
WHERE t.UnitPrice = (
    SELECT MAX(UnitPrice)
    FROM invoice_items
);


-- 문제 4.
-- 앨범 'Let There Be Rock'에 수록된 트랙의 이름을 조회하세요.
-- 힌트: 앨범 1개의 AlbumId는 단일 행 → = 연산자 사용.
SELECT Name
FROM tracks
WHERE AlbumId = (
    SELECT AlbumId
    FROM albums
    WHERE Title = 'Let There Be Rock'
);

-- 문제 5.
-- 인보이스 총액(Total)이 전체 평균 총액보다 '작은'(<) 인보이스의
-- InvoiceId와 Total을 조회하세요.
SELECT InvoiceId, Total
FROM invoices
WHERE Total < (
    SELECT Total
    FROM AVG(Total) FROM invoices
)

/* ===================  02. 다중 행 서브쿼리 (IN / NOT IN)  ============== */

-- 문제 6.
-- 'AC/DC'가 발매한 앨범에 속한 모든 트랙의 이름을 조회하세요.
-- 힌트: 아티스트→여러 앨범(다중 행)이므로 IN. (서브쿼리 중첩)
SELECT Name
FROM tracks
WHERE AlbumId IN (
    SELECT AlbumId
    FROM albums
    WHERE ArtistId = (
        SELECT ArtistId
        FROM artists
        WHERE Name = 'AC/DC'
    )
);

-- 문제 7.
-- 담당 직원(SupportRepId)이 캐나다(Country = 'Canada')에 근무하는
-- 고객의 이름(FirstName, LastName)을 조회하세요. (IN)
SELECT FirstName || ' ' || LastName
FROM customers
WHERE SupportRepId IN (
    SELECT EmployeeId
    FROM employees
    WHERE Country = 'Canada'
);

-- 문제 8.
-- 한 번이라도 구매된 적이 있는(invoice_items에 등장한) 트랙의 이름을
-- 조회하세요. (IN)
SELECT Name
FROM tracks
WHERE TrackId IN (
    SELECT TrackId
    FROM invoice_items
);

-- 문제 9.
-- 한 번도 구매되지 않은 트랙의 이름을 조회하세요. (NOT IN)
-- 주의: 서브쿼리 결과에 NULL이 섞이면 NOT IN은 아무 것도 반환하지 않을 수
--       있음 → 문제 19의 NOT EXISTS 방식이 더 안전.
SELECT Name
FROM tracks
WHERE TrackId NOT IN (
    SELECT TrackId
    FROM invoice_items
);

-- 문제 10.
-- 'Rock' 장르의 트랙이 한 곡이라도 포함된 앨범의 제목을 조회하세요. (IN)
SELECT Title
FROM albums
WHERE AlbumId IN (
    SELECT AlbumId
    FROM tracks
    WHERE GenreId = (
        SELECT GenreId
        FROM genres
        WHERE Name = 'Rock'
    )
);


/* ----  [SQLite 보강] 강의자료의 ANY / ALL → SQLite에서는 MIN / MAX  ---- */

-- 문제 11.  (강의자료의 ALL 개념)
-- 'Rock' 장르의 '모든' 트랙보다 재생시간이 긴 트랙의 이름을 조회하세요.
-- SQLite 미지원: WHERE Milliseconds > ALL (SELECT Milliseconds ...)
-- 대체: ALL → MAX (모든 값보다 크다 = 최댓값보다 크다)
SELECT Name
FROM tracks
WHERE Milliseconds > (
    SELECT MAX(Milliseconds)
    FROM tracks
    WHERE GenreId = (
        SELECT GenreId
        FROM genres
        WHERE Name = 'Rock'
    )
);

-- 문제 12.  (강의자료의 ANY 개념)
-- 'Jazz' 장르 트랙 중 '하나라도'보다 재생시간이 긴 트랙의 이름을 조회하세요.
-- SQLite 미지원: WHERE Milliseconds > ANY (...)
-- 대체: ANY → MIN (하나라도보다 크다 = 최솟값보다 크다)


/* ============  03. 위치에 따른 분류 — 스칼라 서브쿼리 (SELECT 절)  ===== */

-- 문제 13.
-- 각 앨범의 제목과, 그 앨범에 속한 트랙 수를 스칼라 서브쿼리로 함께
-- 조회하세요. (상관 서브쿼리: 바깥의 a.AlbumId 참조)
SELECT Title
    , (
        SELECT COUNT(*)
        FROM tracks t
        WHERE a.AlbumId = t.albumId
    ) AS track_cnt
FROM albums a;

-- 문제 14.
-- 각 고객의 이름과, 그 고객의 총 결제 금액(SUM(Total))을 스칼라 서브쿼리로
-- 조회하세요.
SELECT c.FirstName || ' ' || c.LastName
    , (
        SELECT SUM(Total)
        FROM invoices i
        WHERE c.CustomerId = i.CustomerId
    )
FROM customers c;

-- 문제 15.
-- 각 트랙의 이름과, 그 트랙이 속한 앨범 제목을 스칼라 서브쿼리로 조회하세요.
-- (강의자료 포인트: 스칼라 서브쿼리는 JOIN과 같은 결과)

-- 문제 15-1.  (참고) 위 문제 15를 JOIN으로 바꾼 동일 결과


/* -------------  [보강] FROM 절 서브쿼리 (파생 테이블, 별칭 필수)  ------- */

-- 문제 16.
-- 앨범별 트랙 수를 먼저 구한 뒤, 그 트랙 수의 '전체 평균'을 구하세요.
-- 힌트: FROM 절 서브쿼리에는 반드시 별칭(AS ...)을 붙입니다.
SELECT AVG(sub.TrackCount) AS AverageTracksPerAlbum
FROM (
    -- ┌────────────────────────────────────────────────────────┐
    -- │[1층: 인라인 뷰] 앨범별로 트랙 수를 먼저 싹 구해서 표를 만듦│
    -- └────────────────────────────────────────────────────────┘
    SELECT AlbumId, COUNT(TrackId) AS TrackCount
    FROM tracks
    GROUP BY AlbumId
) AS sub; -- ◀ 힌트에 나온 것처럼 이 가상 테이블에 'sub'라는 별칭을 부여!

-- 문제 17.
-- 국가별 매출 합계를 구한 파생 테이블에서, 매출이 높은 상위 5개 국가를
-- 조회하세요.
SELECT BillingCountry
FROM (
    SELECT BillingCountry, SUM(Total)
    FROM invoices
    GROUP BY BillingCountry
    ORDER BY SUM(Total) DESC
    LIMIT 5
) AS t


/* ----------------  [보강] EXISTS / 상관 서브쿼리  -------------------- */

-- 문제 18.
-- 트랙이 한 곡이라도 존재하는 앨범의 제목을 EXISTS로 조회하세요.

-- 문제 19.
-- 한 번도 구매된 적이 없는 트랙의 이름을 NOT EXISTS로 조회하세요.
-- (문제 9의 NOT IN보다 NULL 안전한 방식)

-- 문제 20.  (종합)
-- 각 직원에 대해 그 직원이 담당하는 고객 수를 스칼라 서브쿼리로 구하되,
-- 담당 고객이 한 명 이상인 직원만 조회하세요.
-- (스칼라 서브쿼리 + WHERE 절 다중 행 서브쿼리 동시 사용)



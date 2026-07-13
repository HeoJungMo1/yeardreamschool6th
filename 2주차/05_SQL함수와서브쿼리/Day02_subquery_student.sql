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
-- 메인쿼리 : 이름과 재생시간 조회
-- 서브쿼리 : 'Balls to the Wall'의 재생시간 조회

-- 메인쿼리
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > 342562
;

-- 서브쿼리
SELECT Milliseconds FROM tracks WHERE Name = 'Balls to the Wall';

-- 메인 쿼리 + 서브 쿼리
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > (SELECT Milliseconds FROM tracks WHERE Name = 'Balls to the Wall')
;

-- 문제 2.
-- 전체 트랙의 평균 재생시간보다 긴 트랙의 이름과 재생시간을 조회하세요.
-- 힌트: 서브쿼리에서 AVG를 쓰면 한 값만 반환 = 단일 행.
-- 메인 : 트랙의 이름과 재생시간 조회
SELECT Name, Milliseconds FROM tracks;

-- 서브 : 전체 트랙의 평균 재생시간 
SELECT AVG(Milliseconds) FROM tracks;

SELECT Name, Milliseconds FROM tracks
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM tracks);


-- 문제 3.
-- 단가(UnitPrice)가 가장 비싼 트랙과 '같은' 단가를 가진 트랙의
-- 이름과 단가를 조회하세요. (= 연산자, MAX)
-- 메인
SELECT Name, UnitPrice FROM tracks;

-- 서브
SELECT MAX(UnitPrice) FROM tracks;

-- 메인 + 서브
SELECT Name, UnitPrice FROM tracks
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM tracks)
;

-- 문제 4.
-- 앨범 'Let There Be Rock'에 수록된 트랙의 이름을 조회하세요.
-- 힌트: 앨범 1개의 AlbumId는 단일 행 → = 연산자 사용.
-- 메인 : 트랙의 Name 조회
-- 서브 : 'Let There Be Rock'의 AlbumID를 조회

SELECT Name FROM tracks
WHERE AlbumId = (SELECT AlbumId FROM albums WHERE Title = 'Let There Be Rock');

SELECT AlbumId FROM albums WHERE Title = 'Let There Be Rock';

-- 강사님 답안
SELECT Name
FROM tracks
WHERE AlbumId = (
    SELECT AlbumId FROM albums WHERE Title = 'Let There Be Rock'
);


-- 문제 5.
-- 인보이스 총액(Total)이 전체 평균 총액보다 '작은'(<) 인보이스의
-- InvoiceId와 Total을 조회하세요.
-- 메인 : InvoiceID와 Total 조회
-- 서브 : 인보이스 Total의 평균 Total구하기
SELECT InvoiceId, Total 
From invoices
WHERE Total < (
    SELECT AVG(Total) FROM invoices
);

SELECT AVG(Total) FROM invoices

-- 강사님 답안
SELECT InvoiceId, Total
FROM invoices
WHERE Total < (
    SELECT AVG(Total) FROM invoices
);

/* ===================  02. 다중 행 서브쿼리 (IN / NOT IN)  ============== */

-- 문제 6.
-- 'AC/DC'가 발매한 앨범에 속한 모든 트랙의 이름을 조회하세요.
-- 힌트: 아티스트→여러 앨범(다중 행)이므로 IN. (서브쿼리 중첩)
-- 메인 : 트랙의 Name 조회
-- 메인쿼리 : 트랙의 이름 조회
SELECT Name FROM tracks;

-- 서브쿼리 : 'AC/DC'가 발매한 앨범ID
---- 서브쿼리의 메인쿼리 : AlbumID FROM Albums
SELECT AlbumId FROM albums;
---- 서브쿼리의 서브쿼리 : AC/DC의 ArtistID조회
SELECT ArtistId FROM artists WHERE Name = 'AC/DC';

-- 서브쿼리 합치기
SELECT AlbumId FROM albums
WHERE ArtistId = (
    SELECT ArtistId FROM artists WHERE Name = 'AC/DC'
);

-- 메인쿼리 : 트랙의 이름 조회
SELECT Name FROM tracks 
WHERE AlbumID IN (
    SELECT AlbumId FROM albums
    WHERE ArtistId = (SELECT ArtistId FROM artists WHERE Name = 'AC/DC')
);


-- 문제 7.
-- 담당 직원(SupportRepId)이 캐나다(Country = 'Canada')에 근무하는
-- 고객의 이름(FirstName, LastName)을 조회하세요. (IN)

-- 메인 : 고객의 이름 조회
SELECT FirstName, LastName FROM customers;

-- 서브 : 담당 직원이 캐나다에 근무
SELECT EmployeeId FROM employees WHERE Counrty = 'Canda';

-- 메인 + 서브
SELECT FirstName, LastName FROM customers
WHERE SupportRepId IN (
    SELECT EmployeeId FROM employees WHERE Country = 'Canda'
)
;

-- JOIN문 변환했을 때
SELECT c.FirstName, c.LastName
FROM customers c
JOIN employees e ON c.SupportRepId = e.EmployeeId
WHERE e.Country = 'Canada';

-- 문제 8.
-- 한 번이라도 구매된 적이 있는(invoice_items에 등장한) 트랙의 이름을
-- 조회하세요. (IN)
-- 메인 : Track 이름
SELECT Name FROM trakcs
-- 서브 : invoice_items의 track ID 조회
-- 메인 + 서브
SELECT TrackId FROM invoice_items;
WHERE TrackId IN (SELECT TrackId FROM invoice_items);


-- 문제 9.
-- 한 번도 구매되지 않은 트랙의 이름을 조회하세요. (NOT IN)
-- 주의: 서브쿼리 결과에 NULL이 섞이면 NOT IN은 아무 것도 반환하지 않을 수
--       있음 → 문제 19의 NOT EXISTS 방식이 더 안전.
SELECT TrackId FROM invoice_items;
WHERE TrackId NOT IN (SELECT TrackId FROM invoice_items);

-- 문제 10.
-- 'Rock' 장르의 트랙이 한 곡이라도 포함된 앨범의 제목을 조회하세요. (IN)
-- albums, tracks, genres
-- 메인
SELECT Title FROM albums
-- 서브 : Rock 장르의 트랙이 담긴 앨범 ID
---- 메인쿼리 : tracks의 앨범 ID
---- 서브쿼리 ㅣ 'Rock'의 장르 ID

-- Rock 장르 GenreId 추출
SELECT GenreId FROM genres WHERE Name = 'Rock'

SELECT Title FROM albums
WHERE AlbumId IN (
    SELECT AlbumId FROM tracks
WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')
)
;

SELECT Title FROM albums
WHERE AlbumId IN (
    SELECT AlbumId FROM tracks
WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')
)

-- tracks에서
SELECT AlbumId FROM tracks
WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')

-- 강사님 답안
SELECT Title
FROM albums
WHERE AlbumId IN (
    SELECT AlbumId FROM tracks
    WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')
);



/* ----  [SQLite 보강] 강의자료의 ANY / ALL → SQLite에서는 MIN / MAX  ---- */

-- 문제 11.  (강의자료의 ALL 개념)
-- 'Rock' 장르의 '모든' 트랙보다 재생시간이 긴 트랙의 이름을 조회하세요.
-- SQLite 미지원: WHERE Milliseconds > ALL (SELECT Milliseconds ...)
-- 대체: ALL → MAX (모든 값보다 크다 = 최댓값보다 크다)
-- 메인 : Name, Milliseconds 

-- 강사님 답안
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > (
    SELECT MAX(Milliseconds) FROM tracks
    WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Rock')
);

SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > 1612329
;

-- 서브 : 
-- Rock 장르와 관련된 것은 Genres 테이블, GenreId

SELECT MAX(Milliseconds) FROM tracks
WHERE GenreId = 1;

SELECT GenreId FROM Genres WHERE Name = 'Rock';

-- 서브쿼리를 잘하고 싶다! 분할하고 합치기 


-- 문제 12.  (강의자료의 ANY 개념)
-- 'Jazz' 장르 트랙 중 '하나라도'보다 재생시간이 긴 트랙의 이름을 조회하세요.
-- SQLite 미지원: WHERE Milliseconds > ANY (...)
-- 대체: ANY → MIN (하나라도보다 크다 = 최솟값보다 크다)

-- 강사님 답안
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > (
    SELECT MIN(Milliseconds) FROM tracks
    WHERE GenreId = (SELECT GenreId FROM genres WHERE Name = 'Jazz')
);

SELECT Name, Milliseconds
FROM tracks

-- 장르 트랙 ID뽑기
SELECT GenreId FROM genres WHERE Name = 'Jazz'

SELECT MIN(Milliseconds) FROM tracks


/* ============  03. 위치에 따른 분류 — 스칼라 서브쿼리 (SELECT 절)  ===== */

-- 문제 13.
-- 각 앨범의 제목과, 그 앨범에 속한 트랙 수를 스칼라 서브쿼리로 함께
-- 조회하세요. (상관 서브쿼리: 바깥의 a.AlbumId 참조)
-- 메인 : 엘범의 제목
-- 서브 : 앨범에 속한 트랙 수 
SELECT
    a.Title
    , (SELECT COUNT(*) FROM tracks t WHERE t.AlbumID = a.AlbumID) AS track_cnt
FROM albums a;

SELECT * FROM albums;

-- 문제 14.
-- 각 고객의 이름과, 그 고객의 총 결제 금액(SUM(Total))을 스칼라 서브쿼리로
-- 조회하세요.
-- 메인 : 고객 이름
-- 서브 : 총 결제 금액 (고객 아이디 매칭)
SELECT c.FirstName
        , c.LastName
        , (SELECT SUM(i.Total) FROM invoices AS i WHERE i.CustomerId = c.CustomerId) AS total_spent
FROM customers AS c
;

SELECT * FROM invoices;


-- 문제 15.
-- 각 트랙의 이름과, 그 트랙이 속한 앨범 제목을 스칼라 서브쿼리로 조회하세요.
-- (강의자료 포인트: 스칼라 서브쿼리는 JOIN과 같은 결과)
-- 메인 : 트랙이름
-- 서브 : 트랙이 속한 앨범 제목

SELECT t.Name
        , (SELECT Title FROM albums AS al WHERE al.albumId = t.AlbumID) AS album_title
FROM tracks AS t
;

SELECT Title FROM albums;

-- 문제 15-1.  (참고) 위 문제 15를 JOIN으로 바꾼 동일 결과
SELECT t.Name, al.Title AS album_title
FROM tracks t
LEFT JOIN albums al ON al.AlbumId = t.AlbumId;


/* -------------  [보강] FROM 절 서브쿼리 (파생 테이블, 별칭 필수)  ------- */

-- 문제 16.
-- 앨범별 트랙 수를 먼저 구한 뒤, 그 트랙 수의 '전체 평균'을 구하세요.
-- 힌트: FROM 절 서브쿼리에는 반드시 별칭(AS ...)을 붙입니다.

-- 문제 17.
-- 국가별 매출 합계를 구한 파생 테이블에서, 매출이 높은 상위 5개 국가를
-- 조회하세요.
-- 메인 : 매출높은 국가
-- 서브 : 
SELECT BillingCountry FROM (
    SELECT BillingCountry, SUM(Total) FROM invoices GROUP BY BillingCountry
    ORDER BY 2 DESC LIMIT 5
);

SELECT BillingCountry, SUM(Total) FROM invoices GROUP BY BillingCountry
ORDER BY 2 DESC LIMIT 5;



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



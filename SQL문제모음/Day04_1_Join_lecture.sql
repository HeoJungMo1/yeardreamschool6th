/* =====================================================================
   4장 JOIN 심화 — 실습 문제 모음 (답지 포함)
   - 강의자료 순서 준수:
       01 EQUI JOIN / Non EQUI JOIN          (문제  1~ 5)
       02 INNER JOIN (ON / USING / NATURAL)  (문제  6~12)
       03 CROSS JOIN                          (문제 13~15)
       04 OUTER JOIN (LEFT / RIGHT / FULL)   (문제 16~23)
       05 셀프 조인 (Self Join)               (문제 24~27)
       06 복합 JOIN & WHERE 조건              (문제 28~30)
   - 사용 DB : SQLite Tutorial 샘플 데이터베이스 (chinook.db)
     주요 테이블:
       artists(ArtistId, Name)
       albums(AlbumId, Title, ArtistId)
       tracks(TrackId, Name, AlbumId, MediaTypeId, GenreId,
              Composer, Milliseconds, Bytes, UnitPrice)
       genres(GenreId, Name)
       media_types(MediaTypeId, Name)
       playlists(PlaylistId, Name)
       playlist_track(PlaylistId, TrackId)
       customers(CustomerId, FirstName, LastName, Company, Address,
                 City, State, Country, PostalCode, Phone, Fax,
                 Email, SupportRepId)
       invoices(InvoiceId, CustomerId, InvoiceDate, BillingAddress,
                BillingCity, BillingState, BillingCountry,
                BillingPostalCode, Total)
       invoice_items(InvoiceLineId, InvoiceId, TrackId,
                     UnitPrice, Quantity)
       employees(EmployeeId, LastName, FirstName, Title,
                 ReportsTo, BirthDate, HireDate, Address,
                 City, State, Country, PostalCode, Phone,
                 Fax, Email)

    SQLite JOIN 버전별 지원 현황
   ─────────────────────────────────────────────────────────────
   JOIN 종류           | 지원 여부
   ─────────────────────────────────────────────────────────────
   INNER JOIN          |  항상 지원
   LEFT OUTER JOIN     |  항상 지원
   CROSS JOIN          |  항상 지원
   NATURAL JOIN        |  항상 지원 (단, 별칭 금지)
   USING 조건절        |  항상 지원 (단, 별칭 금지)
   RIGHT OUTER JOIN    |  SQLite 3.39.0(2022-06-25) 이상만 지원
   FULL OUTER JOIN     |  SQLite 3.39.0 이상만 지원
   ─────────────────────────────────────────────────────────────
   → 버전 확인: SELECT sqlite_version();
   → RIGHT/FULL 이전 버전 대안: 테이블 순서 바꿔 LEFT JOIN 사용
   ===================================================================== */

SELECT sqlite_version();


/* ================================================================
   01. EQUI JOIN / Non EQUI JOIN
   ================================================================ */

-- 문제 1. [EQUI JOIN - WHERE 절]
-- 앨범(albums) 테이블과 아티스트(artists) 테이블을
-- WHERE 절 등가 조인으로 연결하여
-- 앨범 제목(Title)과 아티스트 이름(Name)을 조회하세요.
-- 결과는 앨범 제목 오름차순으로 정렬하세요.
SELECT al.Title AS AlbumTitle,
       ar.Name  AS ArtistName
FROM albums al, artists ar
WHERE al.ArtistId = ar.ArtistId
ORDER BY al.Title;


-- 문제 2. [EQUI JOIN - 세 테이블]
-- 트랙(tracks), 앨범(albums), 아티스트(artists) 세 테이블을
-- WHERE 절 등가 조인으로 연결하여
-- 트랙명, 앨범 제목, 아티스트 이름을 조회하세요. (상위 10행)
SELECT t.Name    AS TrackName,
       al.Title  AS AlbumTitle,
       ar.Name   AS ArtistName
FROM tracks t, albums al, artists ar
WHERE t.AlbumId   = al.AlbumId
  AND al.ArtistId = ar.ArtistId
LIMIT 10;


-- 문제 3. [Non EQUI JOIN - BETWEEN]
-- 트랙의 단가(UnitPrice)를 기준으로,
-- 아래 price_range 기준표(인라인 뷰)와 Non EQUI JOIN하여
-- 각 트랙의 이름, 단가, 등급을 조회하세요.
-- price_range: 0.99 이하 → 'Standard', 1.00~1.29 → 'Premium'
--              1.30 이상  → 'High'
-- (힌트: CASE WHEN으로 등급 컬럼을 직접 만들어도 됩니다.)
SELECT Name,
       UnitPrice,
       CASE
           WHEN UnitPrice <= 0.99 THEN 'Standard'
           WHEN UnitPrice <= 1.29 THEN 'Premium'
           ELSE 'High'
       END AS PriceGrade
FROM tracks
ORDER BY UnitPrice DESC;


-- 문제 4. [Non EQUI JOIN - 비교 연산자]
-- 재생시간(Milliseconds)이 300,000ms(5분) 이상인 트랙과
-- 동일 앨범에 속하면서 재생시간이 그 트랙보다 짧은 트랙을
-- 찾아 (기준 트랙명, 기준 재생시간, 짧은 트랙명, 짧은 재생시간) 형태로 조회하세요.
-- (힌트: 같은 tracks 테이블을 두 번 사용, 별칭 t1·t2)
SELECT t1.Name  AS LongTrack,
       t1.Milliseconds AS LongMs,
       t2.Name  AS ShortTrack,
       t2.Milliseconds AS ShortMs
FROM tracks t1, tracks t2
WHERE t1.AlbumId     =  t2.AlbumId
  AND t1.Milliseconds >= 300000
  AND t2.Milliseconds <  t1.Milliseconds
ORDER BY t1.Name, t2.Milliseconds;


-- 문제 5. [Non EQUI JOIN - 다중 조건]
-- 고객(customers) 중 국가(Country)가 'USA'인 고객과
-- 같은 국가의 다른 고객을 Non EQUI JOIN(!=)으로 연결하여
-- (고객 A 이름, 고객 B 이름, 국가)를 조회하세요. (상위 10행)
-- (목적: 동일 국가 고객 쌍 확인)
SELECT c1.FirstName || ' ' || c1.LastName AS CustomerA,
       c2.FirstName || ' ' || c2.LastName AS CustomerB,
       c1.Country
FROM customers c1, customers c2
WHERE c1.Country    = c2.Country
  AND c1.Country    = 'USA'
  AND c1.CustomerId != c2.CustomerId
  AND c1.CustomerId <  c2.CustomerId   -- 중복 쌍 제거
ORDER BY CustomerA
LIMIT 10;


/* ================================================================
   02. INNER JOIN (ON / USING / NATURAL)
   ================================================================ */

-- 문제 6. [INNER JOIN - ON 절, 기본]
-- 트랙(tracks)과 장르(genres)를 INNER JOIN하여
-- 트랙명(Name)과 장르명(Name)을 조회하세요.
-- 장르명은 g.Name으로 구분하고, 결과는 장르명 오름차순으로 정렬하세요.
SELECT t.Name   AS TrackName,
       g.Name   AS GenreName
FROM tracks t
INNER JOIN genres g ON t.GenreId = g.GenreId
ORDER BY g.Name;


-- 문제 7. [INNER JOIN - ON 절, 세 테이블]
-- 인보이스 아이템(invoice_items), 트랙(tracks), 장르(genres)를
-- INNER JOIN으로 연결하여
-- (인보이스 아이템 ID, 트랙명, 장르명, 단가, 수량)을 조회하세요. (상위 15행)
SELECT ii.InvoiceLineId,
       t.Name  AS TrackName,
       g.Name  AS GenreName,
       ii.UnitPrice,
       ii.Quantity
FROM invoice_items ii
INNER JOIN tracks t ON ii.TrackId  = t.TrackId
INNER JOIN genres g ON t.GenreId   = g.GenreId
LIMIT 15;


-- 문제 8. [INNER JOIN - ON 절 + WHERE 조건]
-- 고객(customers)과 인보이스(invoices)를 INNER JOIN하여
-- 국가(Country)가 'Brazil'인 고객의
-- (고객 이름, 이메일, 인보이스 날짜, 총액)을 조회하세요.
SELECT c.FirstName || ' ' || c.LastName AS CustomerName,
       c.Email,
       i.InvoiceDate,
       i.Total
FROM customers c
INNER JOIN invoices i ON c.CustomerId = i.CustomerId
WHERE c.Country = 'Brazil'
ORDER BY i.InvoiceDate;


-- 문제 9. [INNER JOIN - USING 절]
--  USING 절 사용 시 컬럼/테이블에 별칭을 붙일 수 없습니다.
-- 앨범(albums)과 아티스트(artists)를 USING(ArtistId)으로 조인하여
-- 앨범 제목과 아티스트 이름을 조회하세요. (상위 10행)
SELECT albums.Title  AS AlbumTitle,
       artists.Name  AS ArtistName
FROM albums
INNER JOIN artists USING (ArtistId)
ORDER BY albums.Title
LIMIT 10;


-- 문제 10. [NATURAL JOIN]
-- NATURAL JOIN은 이름이 같은 모든 컬럼을 자동으로 등가 조인 조건으로 사용합니다.
--    ON·USING·WHERE에서 추가 JOIN 조건을 정의할 수 없으며 별칭도 금지입니다.
-- tracks-genres는 공통 컬럼이 GenreId와 Name 두 개이므로 NATURAL JOIN 불가
--    (트랙명 ≠ 장르명이라 결과가 0행이 됩니다.)
--    → 공통 컬럼이 ArtistId 하나뿐인 Album-Artist 쌍을 사용합니다.
--
-- Album와 Artist를 NATURAL JOIN하여
-- 앨범 제목(Title)과 아티스트 이름(Name)을 조회하세요. (상위 10행)
-- albums와 artists를 NATURAL JOIN하여
-- 앨범 제목(Title)과 아티스트 이름(Name)을 조회하세요. (상위 10행)
SELECT albums.Title  AS AlbumTitle,
       artists.Name  AS ArtistName
FROM albums
NATURAL JOIN artists
ORDER BY albums.Title
LIMIT 10;


-- 문제 11. [INNER JOIN - 집계와 결합]
-- 아티스트(artists)별 앨범 수를 조회하세요.
-- (아티스트 이름, 앨범 수) — 앨범 수 내림차순 정렬, 상위 10명
SELECT ar.Name       AS ArtistName,
       COUNT(al.AlbumId) AS AlbumCount
FROM artists ar
INNER JOIN albums al ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY AlbumCount DESC
LIMIT 10;


-- 문제 12. [INNER JOIN - 네 테이블]
-- 인보이스(invoices), 인보이스 아이템(invoice_items),
-- 트랙(tracks), 앨범(albums)을 연결하여
-- (인보이스 ID, 트랙명, 앨범 제목, 단가 × 수량 = 소계)를 조회하세요.
-- 소계 내림차순 정렬, 상위 10행.
SELECT i.InvoiceId,
       t.Name   AS TrackName,
       al.Title AS AlbumTitle,
       (ii.UnitPrice * ii.Quantity) AS SubTotal
FROM invoices i
INNER JOIN invoice_items ii ON i.InvoiceId  = ii.InvoiceId
INNER JOIN tracks         t  ON ii.TrackId   = t.TrackId
INNER JOIN albums         al ON t.AlbumId    = al.AlbumId
ORDER BY SubTotal DESC
LIMIT 10;


/* ================================================================
   03. CROSS JOIN
   ================================================================ */

-- 문제 13. [CROSS JOIN - 기본]
-- 장르(genres)와 미디어 타입(media_types)을
-- CROSS JOIN하여 모든 조합을 조회하세요.
-- (장르명, 미디어타입명) — 총 행 수는 장르 수 × 미디어타입 수
SELECT g.Name  AS GenreName,
       m.Name  AS MediaTypeName
FROM genres g
CROSS JOIN media_types m
ORDER BY g.Name, m.Name;


-- 문제 14. [CROSS JOIN - 행 수 확인]
-- 문제 13의 결과가 몇 행인지 COUNT로 확인하세요.
-- 예상값: (SELECT COUNT(*) FROM genres) × (SELECT COUNT(*) FROM media_types)
SELECT COUNT(*) AS TotalRows
FROM genres
CROSS JOIN media_types;


-- 문제 15. [CROSS JOIN - 실용 예시]
-- 플레이리스트(playlists) 5개(PlaylistId 1~5)와
-- 장르(genres) 3개(GenreId 1~3)의 모든 조합을 만드세요.
-- 결과: (플레이리스트명, 장르명) — 총 15행 예상
SELECT p.Name  AS PlaylistName,
       g.Name  AS GenreName
FROM playlists p
CROSS JOIN genres g
WHERE p.PlaylistId BETWEEN 1 AND 5
  AND g.GenreId    BETWEEN 1 AND 3
ORDER BY p.PlaylistId, g.GenreId;


/* ================================================================
   04. OUTER JOIN (LEFT / RIGHT / FULL)
   ================================================================ */

-- 문제 16. [LEFT JOIN - 기본]
-- 모든 아티스트와 그에 해당하는 앨범을 LEFT JOIN으로 조회하세요.
-- 앨범이 없는 아티스트도 결과에 포함해야 하며,
-- 앨범이 없는 경우 Title은 NULL로 표시됩니다.
SELECT ar.Name   AS ArtistName,
       al.Title  AS AlbumTitle
FROM artists ar
LEFT JOIN albums al ON ar.ArtistId = al.ArtistId
ORDER BY ar.Name;


-- 문제 17. [LEFT JOIN - NULL 필터로 "없는" 데이터 찾기]
-- 앨범이 단 한 장도 없는 아티스트의 이름만 조회하세요.
-- (힌트: LEFT JOIN 후 WHERE al.AlbumId IS NULL)
SELECT ar.Name AS ArtistName
FROM artists ar
LEFT JOIN albums al ON ar.ArtistId = al.ArtistId
WHERE al.AlbumId IS NULL
ORDER BY ar.Name;


-- 문제 18. [LEFT JOIN - 세 테이블, NULL 포함]
-- 모든 고객(customers)과 해당 고객의 인보이스(invoices)를
-- LEFT JOIN으로 조회하고, 인보이스가 없는 고객도 포함하세요.
-- (고객명, 인보이스 ID, 인보이스 날짜, 총액)
SELECT c.FirstName || ' ' || c.LastName AS CustomerName,
       i.InvoiceId,
       i.InvoiceDate,
       i.Total
FROM customers c
LEFT JOIN invoices i ON c.CustomerId = i.CustomerId
ORDER BY CustomerName;


-- 문제 19. [LEFT JOIN - 집계 + NULL 처리]
-- 각 아티스트의 앨범 수를 LEFT JOIN으로 집계하세요.
-- 앨범이 없는 아티스트는 앨범 수를 0으로 표시해야 합니다.
-- (힌트: COUNT(al.AlbumId) — NULL인 경우 0으로 계산됨)
SELECT ar.Name              AS ArtistName,
       COUNT(al.AlbumId)    AS AlbumCount
FROM artists ar
LEFT JOIN albums al ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY AlbumCount DESC;


-- 문제 20. [RIGHT JOIN]
--  SQLite 3.39.0 이상에서만 지원됩니다.
-- 먼저 버전을 확인하세요: SELECT sqlite_version();
--
-- 모든 장르(genres)와 해당 장르에 속한 트랙 수를 RIGHT JOIN으로 조회하세요.
-- 트랙이 없는 장르도 포함하며, 트랙 수 내림차순 정렬.
SELECT g.Name          AS GenreName,
       COUNT(t.TrackId) AS TrackCount
FROM tracks t
RIGHT JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY TrackCount DESC;


-- 문제 21. [RIGHT JOIN → LEFT JOIN 변환]
-- 문제 20을 LEFT JOIN으로 동일하게 작성하세요.
-- (테이블 순서를 바꾸면 RIGHT JOIN = LEFT JOIN)
SELECT g.Name          AS GenreName,
       COUNT(t.TrackId) AS TrackCount
FROM genres g
LEFT JOIN tracks t ON g.GenreId = t.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY TrackCount DESC;


-- 문제 22. [FULL OUTER JOIN - 표준 SQL]
--  SQLite 3.39.0 이상에서만 지원됩니다.
-- artists와 albums를 FULL OUTER JOIN하여
-- 앨범이 없는 아티스트와 ArtistId가 NULL인 앨범(고아 앨범)을 모두 포함한
-- 전체 목록을 조회하세요.
SELECT ar.Name   AS ArtistName,
       al.Title  AS AlbumTitle
FROM artists ar
FULL OUTER JOIN albums al ON ar.ArtistId = al.ArtistId
ORDER BY ar.Name NULLS LAST;


-- 문제 23. [FULL OUTER JOIN - MySQL 방식 (구버전 SQLite 대안)]
-- UNION을 사용하여 문제 22와 동일한 결과를 만드세요.
-- (LEFT JOIN UNION RIGHT JOIN → 중복 제거)
SELECT ar.Name   AS ArtistName,
       al.Title  AS AlbumTitle
FROM artists ar
LEFT JOIN albums al ON ar.ArtistId = al.ArtistId

UNION

SELECT ar.Name   AS ArtistName,
       al.Title  AS AlbumTitle
FROM artists ar
RIGHT JOIN albums al ON ar.ArtistId = al.ArtistId

ORDER BY ArtistName NULLS LAST;


/* ================================================================
   05. 셀프 조인 (Self Join)
   ================================================================ */

-- 문제 24. [셀프 조인 - 계층형: 직원 관리자 조회]
-- employees 테이블에서 각 직원의 이름과 그 직원의 관리자 이름을 조회하세요.
-- (ReportsTo 컬럼이 관리자의 EmployeeId를 가리킵니다.)
-- 관리자가 없는 최상위 직원도 포함하세요. (LEFT JOIN 셀프 조인)
SELECT e.FirstName || ' ' || e.LastName  AS EmployeeName,
       e.Title                           AS EmployeeTitle,
       m.FirstName || ' ' || m.LastName  AS ManagerName,
       m.Title                           AS ManagerTitle
FROM employees e
LEFT JOIN employees m ON e.ReportsTo = m.EmployeeId
ORDER BY e.EmployeeId;


-- 문제 25. [셀프 조인 - 계층형: 차상위 관리자]
-- 강의자료의 "차상위 관리자" 예시와 동일하게,
-- 각 직원의 이름, 직속 관리자, 차상위 관리자를 조회하세요.
-- (직원 → 관리자 → 차상위 관리자 3단계 셀프 조인)
SELECT e.FirstName || ' ' || e.LastName  AS Employee,
       m.FirstName || ' ' || m.LastName  AS DirectManager,
       g.FirstName || ' ' || g.LastName  AS GrandManager
FROM employees e
LEFT JOIN employees m ON e.ReportsTo  = m.EmployeeId
LEFT JOIN employees g ON m.ReportsTo  = g.EmployeeId
ORDER BY e.EmployeeId;


-- 문제 26. [셀프 조인 - 동일 국가 고객 쌍]
-- 같은 국가(Country)에 속한 고객 쌍을 찾아
-- (고객A 이름, 고객B 이름, 국가)를 조회하세요.
-- 단, CustomerId가 작은 쪽을 A로 하여 중복 쌍을 제거하세요.
SELECT c1.FirstName || ' ' || c1.LastName AS CustomerA,
       c2.FirstName || ' ' || c2.LastName AS CustomerB,
       c1.Country
FROM customers c1
JOIN customers c2
  ON c1.Country    = c2.Country
 AND c1.CustomerId < c2.CustomerId
ORDER BY c1.Country, CustomerA
LIMIT 20;


-- 문제 27. [셀프 조인 - 같은 앨범 내 트랙 비교]
-- 동일 앨범(AlbumId)에 속한 트랙 쌍 중
-- 재생시간 차이가 60,000ms(1분) 이내인 쌍을 찾아
-- (트랙A, 트랙B, 재생시간A, 재생시간B, 차이)를 조회하세요. (상위 15행)
SELECT t1.Name        AS TrackA,
       t2.Name        AS TrackB,
       t1.Milliseconds AS MsA,
       t2.Milliseconds AS MsB,
       ABS(t1.Milliseconds - t2.Milliseconds) AS MsDiff
FROM tracks t1
JOIN tracks t2
  ON t1.AlbumId   =  t2.AlbumId
 AND t1.TrackId   <  t2.TrackId
 AND ABS(t1.Milliseconds - t2.Milliseconds) <= 60000
ORDER BY MsDiff
LIMIT 15;


/* ================================================================
   06. 복합 JOIN & WHERE 조건 (응용)
   ================================================================ */

-- 문제 28. [INNER JOIN + WHERE + 집계]
-- 'Rock' 장르 트랙을 가진 플레이리스트와 해당 플레이리스트의
-- Rock 트랙 수를 조회하세요.
-- (플레이리스트명, Rock 트랙 수) — Rock 트랙 수 내림차순
SELECT p.Name          AS PlaylistName,
       COUNT(t.TrackId) AS RockTrackCount
FROM playlists p
INNER JOIN playlist_track pt ON p.PlaylistId = pt.PlaylistId
INNER JOIN tracks          t  ON pt.TrackId   = t.TrackId
INNER JOIN genres          g  ON t.GenreId    = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY p.PlaylistId, p.Name
ORDER BY RockTrackCount DESC;


-- 문제 29. [LEFT JOIN + IS NULL + 서브쿼리 없이]
-- 단 한 번도 인보이스 아이템(invoice_items)에 포함되지 않은,
-- 즉 한 번도 팔리지 않은 트랙의 이름과 앨범 제목을 조회하세요.
-- (힌트: tracks LEFT JOIN invoice_items → WHERE InvoiceLineId IS NULL)
SELECT t.Name   AS TrackName,
       al.Title AS AlbumTitle
FROM tracks t
LEFT JOIN invoice_items ii ON t.TrackId = ii.TrackId
LEFT JOIN albums         al ON t.AlbumId = al.AlbumId
WHERE ii.InvoiceLineId IS NULL
ORDER BY al.Title, t.Name;


-- 문제 30. [다중 JOIN 종합]
-- 각 직원(employees)이 담당하는 고객 수와
-- 그 고객들의 총 인보이스 합계를 함께 조회하세요.
-- 직원이 담당하는 고객이 없더라도 포함(LEFT JOIN).
-- (직원명, 직함, 담당 고객 수, 인보이스 총합)
-- 인보이스 총합 내림차순 정렬.
SELECT e.FirstName || ' ' || e.LastName AS EmployeeName,
       e.Title,
       COUNT(DISTINCT c.CustomerId)     AS CustomerCount,
       ROUND(SUM(i.Total), 2)           AS TotalSales
FROM employees e
LEFT JOIN customers c ON e.EmployeeId = c.SupportRepId
LEFT JOIN invoices  i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName, e.Title
ORDER BY TotalSales DESC NULLS LAST;


/* =====================================================================
   ■ 핵심 개념 정리
   =====================================================================

   1. EQUI vs Non EQUI JOIN
      - EQUI JOIN   : 등가 연산자(=)를 사용, 기본키-외래키 관계에서 주로 사용
      - Non EQUI JOIN: >, >=, <, <=, BETWEEN 등 비등가 연산자 사용

   2. INNER JOIN
      - 두 테이블에서 조인 조건을 만족하는 행만 반환 (교집합)
      - INNER 키워드는 생략 가능: JOIN 만 써도 동일
      - ON 절 : 컬럼명이 달라도 사용 가능
      - USING 절: 동일한 이름의 컬럼에 사용, 별칭 금지
      - NATURAL : 이름 같은 모든 컬럼으로 자동 등가 조인, 별칭 금지,
                  ON/USING/WHERE 추가 조건 불가

   3. CROSS JOIN
      - 조인 조건 없이 두 테이블의 모든 행 조합 (카테시안 곱)
      - 결과 행 수 = 테이블A 행 수 × 테이블B 행 수

   4. OUTER JOIN
      - LEFT OUTER JOIN  : 왼쪽 테이블 모든 행 보존, 오른쪽 불일치는 NULL
      - RIGHT OUTER JOIN :  SQLite 3.39.0 이상만 지원
                           이전 버전: 테이블 순서 바꿔 LEFT JOIN으로 대체
      - FULL OUTER JOIN  :  SQLite 3.39.0 이상만 지원
                           이전 버전: LEFT JOIN UNION RIGHT JOIN 으로 대체
                           (UNION은 중복 제거)

   5. 셀프 조인 (Self Join)
      - 동일 테이블을 두 번 사용, 반드시 별칭 필요
      - 계층형 데이터(상사-부하, 카테고리 부모-자식) 처리에 유용
      - 문법: FROM 테이블 A, 테이블 B  또는  FROM 테이블 A JOIN 테이블 B

   6. WHERE 조건과 ON 조건의 차이 (OUTER JOIN에서 중요)
      - ON 조건   : 조인 조건 — LEFT JOIN에서 불일치 행도 NULL로 포함
      - WHERE 조건: 조인 후 필터링 — NULL 행도 걸러냄
      따라서 OUTER JOIN 후 "짝이 없는 행"을 찾으려면
      WHERE 오른쪽테이블.키컬럼 IS NULL 패턴을 사용.

   ===================================================================== */

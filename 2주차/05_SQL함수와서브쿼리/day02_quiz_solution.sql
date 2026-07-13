/* ===================================================================
   PART 1. GROUP BY (4문제)
   =================================================================== */

/* -------------------------------------------------------------------
   문제 1. [GROUP BY]
   시나리오:
   디지털 스토어는 MPEG, AAC 등 미디어 포맷별로 보유 트랙 수를 파악하려 합니다.
   tracks 테이블을 미디어 타입(MediaTypeId)별로 그룹지어
   포맷별 트랙 수(track_count)를 조회하세요.
   ------------------------------------------------------------------- */
SELECT MediaTypeId, COUNT(*) AS track_count
FROM tracks
GROUP BY MediaTypeId;


/* -------------------------------------------------------------------
   문제 2. [GROUP BY + ORDER BY]
   시나리오:
   물류·정산팀이 청구 도시(BillingCity)별 주문(인보이스) 건수를 분석합니다.
   invoices 테이블을 BillingCity별로 그룹지어 도시별 인보이스 건수를 구하고,
   주문이 많은 도시부터 내림차순으로 정렬하세요.
   ------------------------------------------------------------------- */
SELECT BillingCity, COUNT(*) AS invoice_count
FROM invoices
GROUP BY BillingCity
ORDER BY invoice_count DESC;


/* -------------------------------------------------------------------
   문제 3. [GROUP BY + HAVING]
   시나리오:
   고객 지원 센터는 담당 고객이 많은 직원의 업무 부담을 점검합니다.
   customers 테이블을 담당 직원(SupportRepId)별로 그룹지어
   직원별 담당 고객 수를 구하되, 담당 고객이 10명 이상인 직원만 출력하세요.
   ------------------------------------------------------------------- */
SELECT SupportRepId, COUNT(*) AS customer_count
FROM customers
GROUP BY SupportRepId
HAVING COUNT(*) >= 10;


/* -------------------------------------------------------------------
   문제 4. [GROUP BY + 집계 함수]
   시나리오:
   콘텐츠 기획팀이 장르별로 가장 긴 곡이 얼마나 되는지 비교하려 합니다.
   tracks 테이블을 장르(GenreId)별로 그룹지어
   장르별 최대 재생시간(max_ms)을 조회하고,
   재생시간이 긴 장르부터 내림차순으로 정렬하세요.
   ------------------------------------------------------------------- */
SELECT GenreId, MAX(Milliseconds) AS max_ms
FROM tracks
GROUP BY GenreId
ORDER BY max_ms DESC;


/* ===================================================================
   PART 2. JOIN (3문제)
   =================================================================== */

/* -------------------------------------------------------------------
   문제 5. [INNER JOIN]
   시나리오:
   트랙 상세 화면에 해당 곡의 미디어 포맷(예: MPEG audio file)을 표시해야 합니다.
   tracks 테이블과 media_types 테이블을 INNER JOIN하여
   트랙 이름(track_name)과 미디어 타입 이름(media_type)을 조회하세요.
   (연결 조건: tracks.MediaTypeId = media_types.MediaTypeId)
   ------------------------------------------------------------------- */
SELECT tracks.Name AS track_name, media_types.Name AS media_type
FROM tracks
INNER JOIN media_types
  ON tracks.MediaTypeId = media_types.MediaTypeId;


/* -------------------------------------------------------------------
   문제 6. [INNER JOIN — 판매·고객]
   시나리오:
   회계팀이 인보이스마다 어떤 고객에게 청구되었는지 확인하려 합니다.
   invoices 테이블과 customers 테이블을 INNER JOIN하여
   인보이스 ID(InvoiceId), 결제 금액(Total), 청구 국가(BillingCountry),
   고객 성(LastName), 고객 이름(FirstName)을 함께 조회하세요.
   ------------------------------------------------------------------- */
SELECT invoices.InvoiceId,
       invoices.Total,
       invoices.BillingCountry,
       customers.LastName,
       customers.FirstName
FROM invoices
INNER JOIN customers
  ON invoices.CustomerId = customers.CustomerId;


/* -------------------------------------------------------------------
   문제 7. [다중 INNER JOIN — 플레이리스트]
   시나리오:
   큐레이션 팀이 각 플레이리스트에 어떤 곡이 들어 있는지 목록을 뽑으려 합니다.
   playlists, playlist_track, tracks 세 테이블을 INNER JOIN하여
   플레이리스트 이름(playlist_name)과 트랙 이름(track_name)을 조회하세요.
   (playlist_track이 playlists와 tracks를 연결하는 중간 테이블입니다)
   ------------------------------------------------------------------- */
SELECT playlists.Name AS playlist_name,
       tracks.Name AS track_name
FROM playlists
INNER JOIN playlist_track
  ON playlists.PlaylistId = playlist_track.PlaylistId
INNER JOIN tracks
  ON playlist_track.TrackId = tracks.TrackId;


/* ===================================================================
   PART 3. 서브쿼리 (3문제)
   =================================================================== */

/* -------------------------------------------------------------------
   문제 8. [단일 행 서브쿼리 — WHERE + > / AVG]
   시나리오:
   VIP 고객 관리를 위해 평소보다 많이 결제한 '고액 주문' 인보이스를 찾습니다.
   결제 금액(Total)이 전체 인보이스 평균 총액보다 큰 인보이스의
   InvoiceId, CustomerId, Total을 조회하세요.
   힌트: 서브쿼리에서 AVG(Total)을 사용하면 단일 행이 반환됩니다.
   ------------------------------------------------------------------- */
SELECT InvoiceId, CustomerId, Total
FROM invoices
WHERE Total > (
    SELECT AVG(Total) FROM invoices
);


/* -------------------------------------------------------------------
   문제 9. [다중 행 서브쿼리 — IN]
   시나리오:
   브라질(BillingCountry = 'Brazil')로 청구된 주문이 한 번이라도 있는
   고객에게 지역 프로모션 메일을 내려 합니다.
   invoices에 브라질 청구 기록이 있는 고객의
   이름(FirstName), 성(LastName), 이메일(Email)을 조회하세요.
   힌트: 먼저 invoices에서 해당 국가의 CustomerId 목록을 구한 뒤 IN으로 연결합니다.
   ------------------------------------------------------------------- */
SELECT FirstName, LastName, Email
FROM customers
WHERE CustomerId IN (
    SELECT CustomerId FROM invoices WHERE BillingCountry = 'Brazil'
);


/* -------------------------------------------------------------------
   문제 10. [FROM 절 서브쿼리 — 파생 테이블]
   시나리오:
   경영진 보고용으로 국가별 매출 순위 상위 5개국만 뽑아야 합니다.
   먼저 invoices에서 국가(BillingCountry)별 매출 합계를 구한 뒤,
   그 결과를 파생 테이블로 사용해 매출이 높은 상위 5개 국가를 조회하세요.
   힌트: FROM 절 서브쿼리에는 반드시 별칭(AS ...)을 붙입니다.
   ------------------------------------------------------------------- */
SELECT BillingCountry, total_sales
FROM (
    SELECT BillingCountry, SUM(Total) AS total_sales
    FROM invoices
    GROUP BY BillingCountry
) AS country_sales
ORDER BY total_sales DESC
LIMIT 5;

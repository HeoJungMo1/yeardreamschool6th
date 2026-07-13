/* =====================================================================
   4장 다수의 테이블 제어하기 — 실습 문제 20제 (답지 포함)
   - 강의자료 순서 준수:
       01 GROUP BY (데이터 그룹 짓기)
       02 HAVING   (데이터 그룹에 조건 적용)
       03 INNER JOIN (두 테이블 조회)
       04 INNER JOIN ... ON (조건을 적용해 두 테이블 조회)
       05 LEFT JOIN
       06 RIGHT JOIN
   - 사용 DB: SQLite Tutorial 샘플 데이터베이스 (chinook)
     주요 테이블: albums, artists, tracks, invoices, invoice_items,
                  customers, employees, genres, playlists
   - chinook의 PK/FK 관계 예
       artists.ArtistId      <-> albums.ArtistId
       albums.AlbumId        <-> tracks.AlbumId
       genres.GenreId        <-> tracks.GenreId
       invoices.InvoiceId    <-> invoice_items.InvoiceId
       customers.CustomerId  <-> invoices.CustomerId
       employees.EmployeeId  <-> customers.SupportRepId
   ===================================================================== */


/* =====================  01. GROUP BY (그룹 짓기)  =================== */

-- 문제 1.
-- 앨범(albums)을 아티스트(ArtistId)별로 그룹지어, 아티스트별 앨범 수를 보여주세요.

-- 문제 2.
-- 트랙(tracks)을 앨범(AlbumId)별로 그룹지어, 앨범별 트랙 수를 보여주세요.

-- 문제 3.
-- 인보이스(invoices)를 청구 국가(BillingCountry)별로 그룹지어,
-- 국가별 매출 합계(SUM(Total))를 보여주세요.

-- 문제 4.
-- 트랙(tracks)을 장르(GenreId)별로 그룹지어,
-- 장르별 평균 재생시간(AVG(Milliseconds))을 보여주세요.

-- 문제 5.
-- 고객(customers)을 국가(Country)별로 그룹지어,
-- 국가별 고객 수를 고객이 많은 순으로 보여주세요.


/* ===================  02. HAVING (그룹에 조건)  ==================== */

-- 문제 6.
-- 아티스트별 앨범 수를 구하되, 앨범이 5개 이상인 아티스트만 보여주세요.

-- 문제 7.
-- 앨범별 트랙 수를 구하되, 트랙이 15개를 초과하는 앨범만 보여주세요.

-- 문제 8.
-- 국가별 매출 합계를 구하되, 매출 합계가 100을 초과하는 국가만 보여주세요.

-- 문제 9.
-- 고객별(CustomerId) 인보이스 건수를 구하되,
-- 인보이스가 7건 이상인 고객만 보여주세요.

-- 문제 10.
-- 장르별 트랙 수를 구하되, 트랙이 100개 이상인 장르만
-- 트랙이 많은 순으로 보여주세요.


/* ===================  03. INNER JOIN (두 테이블)  ================== */

-- 문제 11.
-- 앨범(albums)과 아티스트(artists)를 연결해
-- 앨범 제목(Title)과 아티스트 이름(Name)을 함께 보여주세요.

-- 문제 12.
-- 트랙(tracks)과 장르(genres)를 연결해
-- 트랙 이름(Name)과 장르 이름(Name)을 함께 보여주세요. (별칭으로 컬럼 구분)


/* ============  04. INNER JOIN ... ON (조건 적용 조회)  ============= */

-- 문제 13.
-- 인보이스(invoices)와 고객(customers)을 연결해
-- 인보이스 ID, 결제 금액(Total), 고객 이름(FirstName, LastName)을 보여주세요.

-- 문제 14.
-- 인보이스 상세(invoice_items)와 트랙(tracks)을 연결해
-- 인보이스 항목 ID, 트랙 이름, 단가(UnitPrice), 수량(Quantity)을 보여주세요.

-- 문제 15.
-- 고객(customers)과 담당 직원(employees)을 연결해
-- 고객 이름과 담당 직원 이름을 보여주세요.
-- (customers.SupportRepId = employees.EmployeeId)

-- 문제 16.
-- 트랙-앨범-아티스트 3개 테이블을 연결해
-- 트랙 이름, 앨범 제목, 아티스트 이름을 함께 보여주세요. (앞 20건)


/* ========================  05. LEFT JOIN  ========================= */

-- 문제 17.
-- 모든 아티스트(artists)를 기준으로 앨범(albums)을 연결하세요.
-- 앨범이 하나도 없는 아티스트도 포함해 출력해야 합니다.

-- 문제 18.
-- 17번을 활용해 '앨범이 하나도 없는' 아티스트만 골라 이름을 보여주세요.
-- 힌트: LEFT JOIN 후 오른쪽 테이블 컬럼이 NULL인 행을 거릅니다.


/* ========================  06. RIGHT JOIN  ======================== */

-- 문제 19.
-- 모든 앨범(albums)을 기준으로 아티스트(artists)를 연결하세요.
-- (RIGHT JOIN 사용: 오른쪽 테이블 albums의 모든 행을 출력)
-- 주의: RIGHT JOIN은 SQLite 3.39.0 이상에서만 동작합니다.

-- 문제 20.
-- 19번과 '같은 결과'를 RIGHT JOIN 없이 LEFT JOIN으로 작성해 보세요.
-- (구버전 SQLite 호환: 테이블 순서를 뒤집어 왼쪽을 albums로 둡니다.)

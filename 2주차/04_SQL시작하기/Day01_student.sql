/*------------ 1. SELECT문 연습 ------------*/
 
-- 문제 1.
-- 신입 사원이 우리 회사가 보유한 앨범 목록을 보고 싶어합니다.
-- albums 테이블에서 앨범 제목(Title)만 모두 보여주세요.
-- SELECT * FROM albums;
SELECT Title FROM albums;

-- 문제 2.
-- 마케팅팀이 아티스트 전체 명단을 요청했습니다.
-- artists 테이블의 모든 정보를 보여주세요.
SELECT * FROM artists

 
-- 문제 3.
-- 곡(track) 데이터가 어떻게 생겼는지 빠르게 확인하려 합니다.
-- tracks 테이블의 모든 컬럼을, 데이터가 많으니 앞 10건만 보여주세요.
SELECT * FROM tracks LIMIT 10;


 
-- 문제 4.
-- 고객지원팀이 "곡 이름과 그 곡의 가격"만 정리한 표를 원합니다.
-- tracks 테이블에서 곡 이름(Name)과 단가(UnitPrice)만 보여주세요. (앞 10건)
SELECT Name, UnitPrice FROM tracks LIMIT 10;
 
 
/*------------ 2. DISTINCT — 중복 제거 ------------*/
 
-- 문제 1.
-- 우리 고객들이 어느 나라에 있는지 "나라 목록"을 정리하려 합니다.
-- customers 테이블에서 Country를 중복 없이 보여주세요.
SELECT DISTINCT Country FROM customers;

 
-- 문제 2.
-- 곡 단가가 몇 종류인지 확인하려 합니다.
-- tracks 테이블에서 UnitPrice의 종류를 중복 없이 보여주세요.

SELECT DISTINCT UnitPrice FROM tracks;

 
-- 문제 3.
-- "도시 + 나라" 조합 기준으로 고객 분포를 보려 합니다.
-- City와 Country를 함께 중복 없이 보여주세요.
SELECT DISTINCT City, Country FROM customers;
 
 
/*------------ 3. WHERE + 비교 연산자 ------------*/
 
-- 문제 1.
-- 미국(USA) 고객만 따로 확인하려 합니다.
-- customers 테이블에서 Country가 'USA'인 고객을 모두 보여주세요.
SELECT * FROM customers WHERE Country = 'USA';


 
-- 문제 2.
-- 단가가 0.99달러보다 비싼 곡을 찾으려 합니다.
-- tracks 테이블에서 UnitPrice가 0.99 초과인 곡을 보여주세요. (앞 10건)
SELECT * FROM tracks WHERE UnitPrice > 0.99 LIMIT 10;
SELECT
    Name
    , GenreID
    , UnitPrice
FROM tracks
WHERE UnitPrice > 0.99
LIMIT
;

 
-- 문제 3.
-- 결제 금액이 큰 인보이스를 점검하려 합니다.
-- invoices 테이블에서 Total이 10 이상인 건을 보여주세요.
-- SELECT * FROM invoices WHERE Total >= 10
SELECT *
FROM invoices
WHERE Total >= 10
;



 
/*------------ 4. 복합 조건 (AND / OR / NOT) ------------*/
 
-- 문제 1.
-- 미국에 있으면서 캘리포니아(CA) 주에 사는 고객을 찾으려 합니다.
-- Country가 'USA' "그리고" State가 'CA'인 고객을 보여주세요.
SELECT * FROM customers WHERE Country = 'USA' AND State = 'CA';
 
-- 문제 2.
-- 미국 또는 캐나다 고객을 한 번에 보려 합니다.
-- Country가 'USA' "이거나" 'Canada'인 고객을 보여주세요.
SELECT * FROM customers WHERE Country = "USA" OR Country = 'Canada';

 
-- 문제 3.
-- 미국이 "아닌" 해외 고객만 보려 합니다.
-- Country가 'USA'가 아닌 고객을 보여주세요.
-- SELECT * FROM customers WHERE Not Country = 'USA'
SELECT * FROM customers
WHERE Country != 'USA';

 
/*------------ 5. 기타 연산자 (BETWEEN / IN / NOT IN) ------------*/
 
-- 문제 1.
-- 결제 금액이 5~10달러 사이인 인보이스를 보려 합니다. (5와 10 포함)
SELECT *
FROM invoices
WHERE Total BETWEEN 5 AND 10;

 
-- 문제 2.
-- 미국, 캐나다, 브라질 고객만 한 번에 뽑으려 합니다.
SELECT * FROM customers
WHERE Country = 'USA' OR Country = 'Canada' OR Country = 'Brazil';

SELECT * FROM customers
WHERE Country IN ('USA', 'Canada', 'Brazil');

 
-- 문제 3.
-- 위 세 나라를 "제외한" 나머지 나라 고객을 보려 합니다.
SELECT * FROM customers
WHERE Country NOT IN ('USA', 'Canada', 'Brazil');

 
 
/*------------ 6. LIKE — 유사한 값 찾기 ------------*/
-- 문자열 있는 컬럼을 조회할 때 사용

 
-- 문제 1.
-- 제목이 'Rock'으로 시작하는 앨범을 찾으려 합니다.
SELECT *
FROM albums
WHERE Title LIKE '%K%';


 
-- 문제 2.
-- 제목이 'Live'로 끝나는(라이브 앨범) 앨범을 찾으려 합니다.
SELECT *
FROM albums
WHERE Title LIKE '%Live';

 
-- 문제 3.
-- 제목 어딘가에 'Love'가 들어간 곡을 찾으려 합니다. (앞 10건)
SELECT *
FROM tracks
WHERE Name LIKE "%Love%"
LIMIT 10;
 
 
/*------------ 7. ORDER BY — 정렬 ------------*/
 
-- 문제 1.
-- 가장 비싼 곡부터 보고 싶습니다.
-- tracks를 UnitPrice 내림차순(DESC)으로 정렬해 보여주세요. (앞 10건)
-- 각 DBMS 마다 문법이 조금씩 다를 수 있다!!
SELECT Name, UnitPrice
FROM tracks
ORDER BY UnitPrice DESC
LIMIT 10
;

SELECT Name AS "앨범이름", UnitPrice
FROM tracks
ORDER BY 1 DESC
;

SELECT Name AS "앨범이름", UnitPrice
FROM tracks
ORDER BY "앨범이름" DESC
;

SELECT Name AS "앨범이름", UnitPrice
FROM tracks
ORDER BY Name DESC
;
 
-- 문제 2.
-- 결제 금액이 가장 큰 인보이스 5건을 보려 합니다.
SELECT *
FROM invoices
ORDER BY Total DESC
LIMIT 5
;

 
-- 문제 3.
-- 앨범 제목을 알파벳 오름차순(ASC)으로 정렬해 보여주세요. (앞 10건)
SELECT Title
FROM albums
ORDER BY Title ASC
LIMIT 10;





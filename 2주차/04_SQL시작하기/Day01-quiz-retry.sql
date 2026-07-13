/*============================================================
  Chinook SQL 퀴즈 20문제 (수강생용)
  - 실행 대상: chinook.db
  - 범위: SELECT / DISTINCT / WHERE / 비교 / AND·OR·NOT
          / BETWEEN·IN·NOT IN / LIKE / ORDER BY
============================================================*/


/*------------ SELECT 기본 ------------*/

-- Q1. 마케팅팀이 우리가 보유한 모든 앨범의 제목 목록을 요청했습니다.
--     albums 테이블에서 제목(Title)만 보여주세요.
-- 테이블 albums
SELECT Title
FROM albums;


-- Q2. 고객 명부에서 이름/성/이메일만 추려 달라는 요청입니다.
--     customers 테이블에서 FirstName, LastName, Email 을 보여주세요.
-- 테이블 customers
SELECT FirstName, LastName, Email
FROM customers;



/*------------ DISTINCT ------------*/

-- Q3. 우리 고객이 어느 나라들에 분포하는지 "나라 목록"이 궁금합니다.
--     customers 의 Country 를 중복 없이 보여주세요.
-- 테이블 customers
SELECT DISTINCT Country
FROM customers;


/*------------ WHERE + 비교 연산자 ------------*/

-- Q4. 브라질(Brazil) 고객만 따로 확인하려 합니다.
--     customers 에서 Country 가 'Brazil' 인 고객을 모두 보여주세요.
-- 테이블 customers
SELECT *
FROM customers
WHERE Country = 'Brazil'


-- Q5. 재생 시간이 5분(=300000 밀리초)을 넘는 긴 곡을 찾으려 합니다.
--     tracks 에서 Milliseconds 가 300000 초과인 곡을 보여주세요. (앞 10건)
-- 테이블 tracks
SELECT Name, Milliseconds
FROM tracks
WHERE Milliseconds > 300000
LIMIT 10;



-- Q6. 결제 금액이 큰 인보이스를 점검합니다.
--     invoices 에서 Total 이 15 이상인 건을 보여주세요.
-- 테이블 invoices
SELECT *
FROM invoices
WHERe Total >= 15;


-- Q7. 단가가 0.99 가 아닌(특별 단가) 곡을 찾으려 합니다.
--     tracks 에서 UnitPrice 가 0.99 가 아닌 곡을 보여주세요. (앞 10건)
-- 테이블 tracks
SELECT Name, UnitPrice
FROM tracks
WHERE UnitPrice <> 0.99
LIMIT 10;


/*------------ 복합 조건 (AND / OR / NOT) ------------*/

-- Q8. 미국 캘리포니아(CA) 거주 고객을 찾습니다.
--     customers 에서 Country 가 'USA' 그리고 State 가 'CA' 인 고객을 보여주세요.
-- 테이블 customers
SELECT *
FROM customers
WHERE Country = 'USA' AND State = 'CA';



-- Q9. 미국 또는 캐나다 고객을 한 번에 보려 합니다.
--     customers 에서 Country 가 'USA' 이거나 'Canada' 인 고객을 보여주세요.
-- 테이블 customers
SELECT *
FROM customers
WHERE Country = 'USA' OR Country = 'Canada';



-- Q10. 미국이 아닌 해외 고객만 보려 합니다.
--      customers 에서 Country 가 'USA' 가 아닌 고객을 보여주세요.
-- 테이블 customers
SELECT *
FROM customers
WHERE Country <> 'USA';



/*------------ 기타 연산자 (BETWEEN / IN / NOT IN) ------------*/

-- Q11. 결제 금액이 5~10달러 사이인 인보이스를 보려 합니다. (5와 10 포함)
-- 테이블 invoices
SELECT *
FROM invoices
WHERE Total BETWEEN 5 AND 10;



-- Q12. 독일/프랑스/포르투갈 고객만 한 번에 뽑으려 합니다.
--      customers 에서 Country 가 'Germany','France','Portugal' 중 하나인 고객.
-- 테이블 customers
SELECT *
FROM customers
WHERE Country IN ('Germany','France','Portugal');


-- Q13. 위 세 나라를 제외한 나머지 나라 고객을 보려 합니다.
-- 테이블 customers
SELECT *
FROM customers
WHERE Country NOT IN('Germany','France','Portugal');



/*------------ LIKE — 유사한 값 찾기 ------------*/

-- Q14. 제목이 'The' 로 시작하는 곡을 찾으려 합니다.
--      tracks 에서 Name 이 'The' 로 시작하는 곡을 보여주세요. (앞 10건)
-- 테이블 tracks
SELECT *
FROM tracks
WHERE Name Like 'The%'
LIMIT 10;


-- Q15. 'Live' 로 끝나는(라이브) 앨범을 찾으려 합니다.
--      albums 에서 Title 이 'Live' 로 끝나는 앨범을 보여주세요.
-- 테이블 albums
SELECT *
FROM albums
WHERE Title LIKE '%Live';



-- Q16. 곡 제목 어딘가에 'Love' 가 들어간 곡을 찾으려 합니다. (앞 10건)
-- 테이블 tracks
SELECT Name
FROM tracks
WHERE Name Like '%Love%'
LIMIT 10;



-- Q17. gmail 을 쓰는 고객을 찾으려 합니다.
--      customers 에서 Email 이 '@gmail.com' 으로 끝나는 고객을 보여주세요.
-- 테이블 customers
SELECT FirstName, LastName, Email
FROM customers
WHERE Email LIKE '%@gmail.com';


/*------------ ORDER BY — 정렬 ------------*/

-- Q18. 재생 시간이 가장 긴 곡부터 보고 싶습니다.
--      tracks 를 Milliseconds 내림차순으로 정렬해 보여주세요. (앞 10건)
-- 테이블 tracks
SELECT *
FROM tracks
ORDER BY Milliseconds DESC
LIMIT 10;


-- Q19. 결제 금액이 가장 큰 인보이스 5건을 보려 합니다.
-- 테이블 invoices
SELECT *
FROM invoices
ORDER BY Total DESC
LIMIT 5;


/*------------ 종합 (조건 + 정렬) ------------*/

-- Q20. 미국에서 발생한 인보이스 중 금액이 큰 순으로 상위 5건을 보려 합니다.
--      invoices 에서 BillingCountry 가 'USA' 인 건을 Total 내림차순으로 5건.
-- 테이블 invoices
SELECT *
FROM invoices
WHERE BillingCountry = 'USA'
ORDER BY Total DESC
LIMIT 5;
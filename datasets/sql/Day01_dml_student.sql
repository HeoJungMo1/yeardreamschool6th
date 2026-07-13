/*============================================================
  Day01 DML 연습 (INSERT / UPDATE / DELETE)
  - 실행 대상: book.db (SQLTools 에서 이 연결을 활성화한 뒤 실행)
  - 데이터 출처: https://books.toscrape.com/ (스크래핑 연습용 사이트)
  - 제목/가격은 사이트 값, 카테고리/평점/재고는 연습용 값
============================================================*/


/*------------ 준비 — 테이블 생성 (재실행 가능) ------------*/

-- 이미 있으면 지우고 새로 만들어, 몇 번을 실행해도 에러가 안 나게 함
DROP TABLE IF EXISTS book;


CREATE TABLE book (
    id       INTEGER PRIMARY KEY,
    title    TEXT,
    category TEXT,
    price    REAL,     -- 단위: £ (사이트 값, 무작위라 의미는 없음)
    rating   INTEGER,  -- 1~5 (연습용)
    stock    INTEGER   -- 재고 수량 (연습용)
);


/*------------ 시드 데이터 삽입 ------------*/

INSERT INTO book (id, title, category, price, rating, stock) VALUES
(1,  'A Light in the Attic',                 'Poetry',             51.77, 3, 22),
(2,  'Tipping the Velvet',                   'Historical Fiction', 53.74, 1, 20),
(3,  'Soumission',                           'Fiction',            50.10, 1, 20),
(4,  'Sharp Objects',                        'Mystery',            47.82, 4, 20),
(5,  'Sapiens: A Brief History of Humankind','History',            54.23, 5, 20),
(6,  'The Requiem Red',                       'Young Adult',        22.65, 1, 19),
(7,  'The Dirty Little Secrets of Getting Your Dream Job', 'Business', 33.34, 4, 19),
(8,  'The Black Maria',                       'Poetry',             52.15, 1, 19),
(9,  'Starving Hearts',                       'Fiction',            13.99, 2, 18),
(10, 'Shakespeare''s Sonnets',                'Poetry',             20.66, 4, 18),
(11, 'Scott Pilgrim''s Precious Little Life', 'Sequential Art',     52.29, 5, 16),
(12, 'Rip it Up and Start Again',             'Music',              35.02, 5, 15);

-- 시드가 잘 들어갔는지 확인
SELECT * FROM book;


/*============================================================
  여기서부터 DML 연습 (시나리오)
============================================================*/


/*------------ 8. INSERT — 삽입 ------------*/

-- 문제 1.
-- 신간 'It''s Only the Himalayas' (Travel, £45.17, 평점 2, 재고 19) 가 입고됐습니다.
-- book 테이블에 추가하세요. (작은따옴표는 두 번 '' 으로 입력)


-- 문제 2.
-- 컬럼명을 생략하면 테이블 정의 순서대로 값이 들어갑니다.
-- 'Set Me Free' (Young Adult, £17.46, 평점 5, 재고 19) 를 컬럼 생략 방식으로 추가하세요.

SELECT * FROM book;


/*------------ 9. UPDATE — 수정 ------------*/

-- 문제 1.
-- 'Soumission' 의 가격이 50.10 -> 39.99 로 할인되었습니다. 가격을 변경하세요.

SELECT * FROM book;

-- 문제 2.
-- Poetry 카테고리 책들의 재고가 일괄 5권씩 입고됐습니다.
-- Poetry 책들의 stock 을 기존 값 + 5 로 변경하세요.


SELECT * FROM book;


/*------------ 10. DELETE — 삭제 ------------*/

-- 문제 1.
-- 평점이 1점인 책들을 카탈로그에서 내리기로 했습니다. 모두 삭제하세요.


SELECT * FROM book;

-- 문제 2.
-- 재고(stock)가 16권 미만인 책을 절판 처리하여 삭제하세요.


SELECT * FROM book;

-- ★ 주의: UPDATE / DELETE 에서 WHERE 를 빼면 전체 행이 수정·삭제됩니다.
--         예) DELETE FROM book;  -> book 전체 삭제


/*============================================================
  (보너스) SELECT 연산자들을 이 book 테이블로도 복습
============================================================*/

-- 카테고리 종류만 보기 (DISTINCT)

-- 가격이 40 이상인 책 (비교 연산자)


-- 제목에 'the' 가 들어간 책 (LIKE, 대소문자 무시됨)


-- 가격이 비싼 순으로 정렬 (ORDER BY)
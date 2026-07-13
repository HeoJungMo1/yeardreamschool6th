-- ============================================================
-- Day 05 | 데이터베이스 구성하기
-- DB명: school_db
-- 주제: 제약 조건 (Constraints) & 키 (Keys)
-- ============================================================

-- school_db 데이터베이스 작업을 위한 파일
-- SQLite에서는 USE 구문 대신 DB 파일을 따로 생성/지정합니다.
-- 예시: school_db.sqlite3 라는 파일을 사용해야 합니다.

-- SQLite에서는 외래키(Foreign Key) 제약 조건이 기본적으로 비활성화되어 있으므로
-- 반드시 아래와 같이 PRAGMA 명령문을 통해 활성화시켜야 합니다.
-- 이 코드는 DB 커넥션이 생성된 이후에 제일 먼저 실행해야 외래키 제약 조건이 적용됩니다.
PRAGMA foreign_keys = ON; -- 외래키 활성화 (반드시 최상단에 선언)

-- ============================================================
-- 테이블 생성 전, 기존에 같은 이름의 테이블이 있다면 삭제
-- 반드시 FK(외래키) 참조 관계의 '자식' 테이블부터 삭제해야 에러가 발생하지 않습니다.
-- 테이블 삭제는 맨 마지막에 실행합니다.

-- ============================================================
-- [학과 테이블] department: 학과별 코드, 이름, 위치 저장
CREATE TABLE department (
    dept_id     VARCHAR(10) PRIMARY KEY,
    dept_name   VARCHAR(50) NOT NULL,
    location    VARCHAR(50) DEFAULT '미정'
);

-- ============================================================
-- [교수 테이블] professor: 교수 고유 ID, 이름, 이메일, 소속 학과, 임용년도 저장
CREATE TABLE professor (
    prof_id     VARCHAR(10) PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    email       VARCHAR(50) NOT NULL UNIQUE,
    dept_id     VARCHAR(10),
    hire_year   INT CHECK (hire_year >= 1980),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- ============================================================
-- [학생 테이블] student: 학생 고유ID, 이름, 이메일, 생년, 소속 학과, 학년, 등록금 납부여부 저장
CREATE TABLE student (
    student_id   VARCHAR(10) PRIMARY KEY,
    name         VARCHAR(20) NOT NULL,
    email        VARCHAR(50) UNIQUE,
    birth_year   INT CHECK (birth_year >= 1990 AND birth_year <= 2010),
    dept_id      VARCHAR(10),
    grade        INT CHECK (grade >= 1 AND grade <= 4),
    tuition_paid VARCHAR(1)  DEFAULT 'N',
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- ============================================================
-- [강의 테이블] course: 강의 코드, 제목, 학점, 담당 교수, 최대 수강 인원 정보 저장
CREATE TABLE course (
    course_id    VARCHAR(10)  PRIMARY KEY,
    title        VARCHAR(100) NOT NULL,
    credit       INT          NOT NULL CHECK (credit >= 1 AND credit <= 3),
    prof_id      VARCHAR(10),
    max_students INT          DEFAULT 30,
    FOREIGN KEY (prof_id) REFERENCES professor(prof_id)
);

-- ============================================================
-- [수강 테이블] enrollment: 학생-강의 N:M 관계를 위한 중간 테이블 (수강 정보)
CREATE TABLE enrollment (
    student_id  VARCHAR(10),
    course_id   VARCHAR(10),
    enroll_date DATE NOT NULL,
    score       INT  CHECK (score >= 0 AND score <= 100),
    CONSTRAINT enrollment_pk PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (course_id)  REFERENCES course(course_id)
);

-- ============================================================
-- 예제 01: NOT NULL 제약 시연 - 필수 입력 값
INSERT INTO department (dept_id, dept_name, location)
VALUES
    ('CSE',  '컴퓨터공학과', '공학관 3층'), -- 정상
    ('ENG',  '영어영문학과', '인문관 2층'),
    ('MATH', '수학과',       '미정');      -- location 미입력 시 '미정' 자동

-- ============================================================
-- 예제 02: NOT NULL 위반 시 에러 발생 확인
-- 에러 발생 구문
-- INSERT INTO department (dept_id, location)
-- VALUES ('ART', '예술관 1층');
-- 정상 동작 예시
INSERT INTO department (dept_id, dept_name, location)
VALUES ('ART', '예술학과', '예술관 1층');

-- ============================================================
-- 예제 03: UNIQUE 제약 시연 - 중복 이메일 금지
INSERT INTO professor (prof_id, name, email, dept_id, hire_year)
VALUES
    ('P001', '김민준', 'minjun@school.ac.kr',  'CSE',  2005),
    ('P002', '이서연', 'seoyeon@school.ac.kr', 'ENG',  2010),
    ('P003', '박도현', 'dohyeon@school.ac.kr', 'MATH', 1998);

-- ============================================================
-- 예제 04: UNIQUE 제약 위반 시 에러 발생 확인
-- 에러 발생 구문
-- INSERT INTO professor (prof_id, name, email, dept_id, hire_year)
-- VALUES ('P004', '최지우', 'minjun@school.ac.kr', 'CSE', 2020);
-- 정상 동작 예시
INSERT INTO professor (prof_id, name, email, dept_id, hire_year)
VALUES ('P004', '최지우', 'jiwoo@school.ac.kr', 'CSE', 2020);

-- ============================================================
-- 예제 05: DEFAULT 값 시연 - 값이 없으면 자동으로 기본값 입력됨
CREATE TABLE test_course (
    course_id    VARCHAR(10) PRIMARY KEY,
    title        VARCHAR(100) NOT NULL,
    max_students INT          DEFAULT 30
);

INSERT INTO test_course (course_id, title)
VALUES ('T001', '테스트 강의A');

INSERT INTO test_course (course_id, title, max_students)
VALUES ('T002', '테스트 강의B', 15);

SELECT * FROM test_course;
DROP TABLE test_course;

-- 실제 course 테이블에도 강의 데이터 입력
INSERT INTO course (course_id, title, credit, prof_id, max_students)
VALUES
    ('CS101',   '파이썬 기초',     3, 'P001', 30),
    ('CS102',   '데이터베이스',    3, 'P001', 25),
    ('ENG201',  '영미문학의 이해', 2, 'P002', 30),
    ('MATH301', '선형대수학',      3, 'P003', 20);

-- ============================================================
-- 예제 06: CHECK 제약 - 학점 범위(1~3)
-- 에러 발생 구문
-- INSERT INTO course (course_id, title, credit, prof_id)
-- VALUES ('CS999', '잘못된 강의', 5, 'P001');
-- 정상 동작 예시
INSERT INTO course (course_id, title, credit, prof_id)
VALUES ('CS999', '정상 강의', 3, 'P001');

-- ============================================================
-- 예제 07: CHECK 제약 - 교수 임용 연도 1980년 이상만 가능
-- 에러 발생 구문
-- INSERT INTO professor (prof_id, name, email, dept_id, hire_year)
-- VALUES ('P099', '오류교수', 'error@school.ac.kr', 'CSE', 1950);
-- 정상 동작 예시
INSERT INTO professor (prof_id, name, email, dept_id, hire_year)
VALUES ('P099', '올바른교수', 'okay@school.ac.kr', 'CSE', 2005);

-- ============================================================
-- 예제 08: 학생 데이터 삽입
INSERT INTO student (student_id, name, email, birth_year, dept_id, grade, tuition_paid)
VALUES
    ('S2021001', '정하은', 'haeun@mail.com',  2002, 'CSE',  2, 'N'),
    ('S2021002', '윤재원', 'jaewon@mail.com', 2001, 'ENG',  3, 'N'),
    ('S2022001', '송지민', 'jimin@mail.com',  2003, 'MATH', 1, 'N'),
    ('S2020001', '한수빈', 'subin@mail.com',  2000, 'CSE',  4, 'N'),
    ('S2022002', '임태양', NULL,              2003, 'ENG',  1, 'N');

-- ============================================================
-- 예제 09: CHECK 제약 위반 - 학년(grade)
-- 에러 발생 구문
-- INSERT INTO student (student_id, name, birth_year, dept_id, grade)
-- VALUES ('S9999', '오류학생', 2002, 'CSE', 5);
-- 정상 동작 예시
INSERT INTO student (student_id, name, birth_year, dept_id, grade)
VALUES ('S9999', '정상학생', 2002, 'CSE', 4);

-- ============================================================
-- 예제 10: PRIMARY KEY 제약 위반 - 중복 student_id
-- 에러 발생 구문
-- INSERT INTO student (student_id, name, birth_year, dept_id, grade)
-- VALUES ('S2021001', '복제학생', 2002, 'CSE', 2);
-- 정상 동작 예시
INSERT INTO student (student_id, name, birth_year, dept_id, grade)
VALUES ('S2021999', '새학생', 2002, 'CSE', 2);

SELECT * FROM student;

-- ============================================================
-- 예제 11: FOREIGN KEY 제약 위반 - 없는 학과 참조
-- 에러 발생 구문
-- INSERT INTO student (student_id, name, birth_year, dept_id, grade)
-- VALUES ('S9998', '유령학생', 2002, 'GHOST', 1);
-- 정상 동작 예시
INSERT INTO student (student_id, name, birth_year, dept_id, grade)
VALUES ('S9998', '실제학생', 2002, 'CSE', 1);

INSERT INTO student (student_id, name, birth_year, dept_id, grade)
VALUES ('S9998', '유령학생', 2002, 'GHOST', 1);

SELECT * FROM student;
SELECT * FROM department;

-- ============================================================
-- 예제 12: 복합 PRIMARY KEY (Composite Key)
INSERT INTO enrollment (student_id, course_id, enroll_date, score)
VALUES
    ('S2021001', 'CS101',   '2024-03-02', 95),
    ('S2021001', 'CS102',   '2024-03-02', 88),
    ('S2021002', 'ENG201',  '2024-03-02', 76),
    ('S2022001', 'MATH301', '2024-03-02', 91),
    ('S2020001', 'CS101',   '2024-03-02', 82),
    ('S2020001', 'MATH301', '2024-03-02', 67);

-- 에러 발생 구문 (동일 학생-강의 쌍 중복 입력)
-- INSERT INTO enrollment (student_id, course_id, enroll_date)
-- VALUES ('S2021001', 'CS101', '2024-09-01');
-- 정상 동작 예시
INSERT INTO enrollment (student_id, course_id, enroll_date)
VALUES ('S2021002', 'CS101', '2024-09-01');

-- ============================================================
-- 예제 13: CONSTRAINT 이름 부여 관리 예시
CREATE TABLE classroom (
    room_id   VARCHAR(10),
    building  VARCHAR(20) NOT NULL,
    capacity  INT,
    CONSTRAINT classroom_pk   PRIMARY KEY (room_id),
    CONSTRAINT capacity_check CHECK (capacity > 0 AND capacity <= 200)
);

INSERT INTO classroom VALUES
    ('A101', '공학관', 50),
    ('B201', '인문관', 40),
    ('C301', '자연관', 30);

-- ============================================================
-- 예제 14: building 컬럼에 UNIQUE 제약 추가 (테이블 새로 생성)
CREATE TABLE classroom_new (
    room_id   VARCHAR(10),
    building  VARCHAR(20) NOT NULL UNIQUE,
    capacity  INT,
    CONSTRAINT classroom_pk   PRIMARY KEY (room_id),
    CONSTRAINT capacity_check CHECK (capacity > 0 AND capacity <= 200)
);

INSERT INTO classroom_new SELECT * FROM classroom;
ALTER TABLE classroom_new RENAME TO classroom;
SELECT * FROM classroom;

-- ============================================================
-- 예제 15: DEFAULT 값 변경 (capacity 기본 50으로, SQLite는 ALTER 불가)
CREATE TABLE classroom_new (
    room_id   VARCHAR(10),
    building  VARCHAR(20) NOT NULL UNIQUE,
    capacity  INT         DEFAULT 50,
    CONSTRAINT classroom_pk   PRIMARY KEY (room_id),
    CONSTRAINT capacity_check CHECK (capacity > 0 AND capacity <= 200)
);

INSERT INTO classroom_new SELECT * FROM classroom;
ALTER TABLE classroom_new RENAME TO classroom;

INSERT INTO classroom (room_id, building) VALUES ('D401', '경영관');
SELECT * FROM classroom;

-- ============================================================
-- 예제 16: 제약 조건 삭제 (DROP CONSTRAINT 불가) - CHECK 제외
CREATE TABLE classroom_new (
    room_id   VARCHAR(10),
    building  VARCHAR(20) NOT NULL UNIQUE,
    capacity  INT         DEFAULT 50,
    CONSTRAINT classroom_pk PRIMARY KEY (room_id)
);

INSERT INTO classroom_new SELECT * FROM classroom;
ALTER TABLE classroom_new RENAME TO classroom;

-- CHECK 제약 조건(capacity_check)이 사라진 상태에서 발생하는 에러/정상 동작 시연
-- 에러 발생 구문 (PK room_id 중복 - 이 에러는 여전히 발생)
-- INSERT INTO classroom (room_id, building, capacity) VALUES ('A101', '체육관', 20);
-- 정상 동작 예시 (PK 및 CHECK 모두 위반하지 않음)
INSERT INTO classroom (room_id, building, capacity) VALUES ('E501', '체육관', 500);
SELECT * FROM classroom;

-- ============================================================
-- 예제 17: 개체 무결성(ENTITY INTEGRITY)
-- 에러 발생 구문 (PK 중복)
-- INSERT INTO department (dept_id, dept_name)
-- VALUES ('CSE', '중복학과');
-- 정상 동작 예시
INSERT INTO department (dept_id, dept_name)
VALUES ('LIFE', '생명과학과');
SELECT * FROM department;

-- ============================================================
-- 예제 18: 참조 무결성(REFERENTIAL INTEGRITY)
-- 에러 발생 구문 (존재하지 않는 교수 id)
-- INSERT INTO course (course_id, title, credit, prof_id)
-- VALUES ('XX999', '유령강의', 2, 'P999');
-- 정상 동작 예시
INSERT INTO course (course_id, title, credit, prof_id)
VALUES ('XX999', '정상강의', 2, 'P001');

-- 에러 발생 구문 (참조 무결성 위반 삭제)
-- DELETE FROM professor WHERE prof_id = 'P001';
-- 정상 동작 예시
DELETE FROM professor WHERE prof_id = 'P004';
SELECT * FROM course;

-- ============================================================
-- 예제 19: 데이터 전체 조회 - 각 제약 조건 결과 확인
SELECT * FROM department;
SELECT * FROM professor;
SELECT * FROM student;
SELECT * FROM course;
SELECT
    e.student_id,
    s.name  AS student_name,
    e.course_id,
    c.title AS course_title,
    e.score
FROM enrollment e
JOIN student s ON e.student_id = s.student_id
JOIN course  c ON e.course_id  = c.course_id
ORDER BY e.student_id;

-- ============================================================
-- 예제 20: PRAGMA 명령으로 제약 조건 정보 조회
PRAGMA table_info(student);
PRAGMA table_info(course);
PRAGMA table_info(enrollment);
PRAGMA foreign_key_list(student);
PRAGMA foreign_key_list(course);
PRAGMA foreign_key_list(enrollment);

-- 파일 최상단에서 이미 PRAGMA foreign_keys = ON; 으로 FK가 활성화되어 있음

-- ============================================================
-- 추가 예제 10개
-- ============================================================

-- 예제 21: UNIQUE + NULL 동작 확인 (UNIQUE는 NULL 중복 허용)
INSERT INTO student (student_id, name, email, birth_year, dept_id, grade)
VALUES ('S8888', '테스트NULL', NULL, 1999, 'CSE', 2);
INSERT INTO student (student_id, name, email, birth_year, dept_id, grade)
VALUES ('S8889', '테스트NULL2', NULL, 2000, 'ENG', 3);

-- ============================================================
-- 예제 22: DEFAULT 자동 적용된 등록금 납부여부(tuition_paid)
INSERT INTO student (student_id, name, birth_year, dept_id, grade)
VALUES ('S6789', '디폴트테스트', 2000, 'CSE', 1);
SELECT student_id, tuition_paid FROM student WHERE student_id = 'S6789';

-- ============================================================
-- 예제 23: score CHECK 위반 (enrollment 0~100 범위 초과)
-- 에러 발생 구문
-- INSERT INTO enrollment (student_id, course_id, enroll_date, score)
-- VALUES ('S2021002', 'MATH301', '2024-05-01', 200);
-- 정상 동작 예시
INSERT INTO enrollment (student_id, course_id, enroll_date, score)
VALUES ('S2021002', 'MATH301', '2024-05-01', 100);

-- ============================================================
-- 예제 24: FOREIGN KEY on DELETE 제한 동작 (참조 존재하면 삭제 불가)
-- 정상 동작 방법: enrollment에서 해당 강의(course_id)를 참조하는 행을 먼저 삭제한 뒤 course를 삭제해야 함
DELETE FROM enrollment WHERE course_id = 'CS101';
DELETE FROM course WHERE course_id = 'CS101';

-- ============================================================
-- 예제 25: 강의실 building UNIQUE 위반
-- 정상 동작 방법: building 값이 '공학관'인 데이터가 없다면 삽입 가능
INSERT INTO classroom (room_id, building, capacity)
VALUES ('X999', '새강의관', 20); -- building 값이 기존에 없으면 정상 삽입

-- ============================================================
-- 예제 26: CHECK 여러 개 동시 위반 (capacity <= 0, room_id 중복)
-- 정상 동작 방법: 중복 room_id가 아니고, capacity가 1 이상의 값이어야 함
INSERT INTO classroom (room_id, building, capacity)
VALUES ('B102', '신관', 30); -- 기존에 없는 room_id, capacity 양수

-- ============================================================
-- 예제 27: 테이블의 제약 조건 정보 PRAGMA로 조회 (전체 컬럼)
PRAGMA table_info(department);
PRAGMA table_info(professor);
PRAGMA table_info(student);
PRAGMA table_info(classroom);

-- ============================================================
-- 예제 28: ALTER TABLE로 컬럼 추가
ALTER TABLE student ADD COLUMN phone VARCHAR(20);
UPDATE student SET phone = '010-1234-5678' WHERE student_id = 'S2021001';
SELECT student_id, phone FROM student WHERE student_id = 'S2021001';

-- ============================================================
-- 예제 29: enrollment의 외래키 제약 위반 (존재하지 않는 student_id)
-- 정상 동작 방법: student 테이블에 존재하는 student_id 값을 사용해야 함
INSERT INTO enrollment (student_id, course_id, enroll_date)
VALUES ('S2021001', 'CS101', '2024-05-01');

-- ============================================================
-- 예제 30: enrollment PK 복합 위반 (동일 학생-강의 중복)
-- 정상 동작 방법: 아직 등록되지 않은 (student_id, course_id) 쌍이어야 함
INSERT INTO enrollment (student_id, course_id, enroll_date)
VALUES ('S2021003', 'CS101', '2024-06-01');

-- ============================================================
-- 각종 제약 조건 요약
-- ============================================================
-- NOT NULL     : 널 값(빈 값) 허용 안함 → 반드시 값 입력해야 함
-- UNIQUE       : 중복 값 입력 불가, 단 NULL(빈값)은 중복 허용
-- DEFAULT      : 값 입력이 생략되면 자동으로 기본값이 채워짐
-- CHECK        : 특정 조건이 맞지 않으면 입력 불가
-- PRIMARY KEY  : NOT NULL + UNIQUE (테이블마다 1개), 행 고유 식별자
-- FOREIGN KEY  : 다른 테이블의 PK를 참조해서 데이터 일관성(무결성) 보장
-- CONSTRAINT   : 각 제약 조건에 이름을 붙여 나중에 쉽게 식별 및 변경 가능
-- ============================================================

-- ============================================================
-- 테이블 삭제(정리): 반드시 맨 마지막에 수행
-- (참조관계에 맞게 자식 테이블부터 삭제)
DROP TABLE IF EXISTS enrollment;
DROP TABLE IF EXISTS classroom;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS professor;
DROP TABLE IF EXISTS department;
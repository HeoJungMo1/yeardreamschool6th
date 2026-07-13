PRAGMA foreign_keys = ON; -- 외래키 활성화 (반드시 최상단에 선언)

-- ============================================================
-- [학과 테이블] department: 학과별 코드, 이름, 위치 저장
CREATE TABLE department (
    dept_id     VARCHAR(10) PRIMARY KEY,   -- 기본키
    dept_name   VARCHAR(50) NOT NULL,      -- NULL 미 허용
    location    VARCHAR(50) DEFAULT '미정'  -- 기본값 미정
);

-- ============================================================
-- [교수 테이블] professor: 교수 고유 ID, 이름, 이메일, 소속 학과, 임용년도 저장
CREATE TABLE professor (
    prof_id  VARCHAR(10)  PRIMARY KEY, 
    name     VARCHAR(20)  NOT NULL, 
    email    VARCHAR(50)  NOT NULL UNIQUE, 
    dept_id  VARCHAR(10), 
    hire_year INT CHECK (hire_year >= 1980), 
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);


-- ============================================================
-- [학생 테이블] student: 학생 고유ID, 이름, 이메일, 생년, 소속 학과, 학년, 등록금 납부여부 저장
CREATE TABLE student (
    student_id   VARCHAR(10) PRIMARY KEY, 
    name         VARCHAR(20) NOT NULL, 
    email        VARCHAR(50) UNIQUE,
    birth_year   INT CHECK (birth_year >= 1990 AND birth_year <= 2007), 
    dept_id      VARCHAR(10), 
    grade        INT CHECK (grade >= 1 AND grade <= 4),
    tuition_paid VARCHAR(1) DEFAULT 'N', 
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
)
;


-- ============================================================
-- [강의 테이블] course: 강의 코드, 제목, 학점, 담당 교수, 최대 수강 인원 정보 저장

CREATE TABLE course (
    course_id    VARCHAR(10) PRIMARY KEY, 
    title        VARCHAR(100) NOT NULL, 
    credit       INT NOT NULL CHECK(credit >= 1 AND credit <= 3), 
    prof_id      VARCHAR(10), 
    max_students INT DEFAULT 30, 
    FOREIGN KEY (prof_id) REFERENCES professor(prof_id)
)
;

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

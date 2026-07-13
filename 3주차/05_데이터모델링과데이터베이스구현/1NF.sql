-- ============================================================
--  1NF SQL (ERD Editor import용 — CREATE TABLE only)
--  제1정규형 — 원자값, 복합 PK
-- ============================================================

CREATE TABLE student_course_1nf (
    student_id       INTEGER,
    course_id        TEXT,
    student_name     TEXT,
    course_name      TEXT,
    grade            TEXT,
    professor_name   TEXT,
    professor_office TEXT,
    dept_code        TEXT,
    dept_name        TEXT,
    dept_building    TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- ============================================================
--  2NF SQL (ERD Editor import용 — CREATE TABLE only)
--  제2정규형 — student / course / enrollment 분리
-- ============================================================

CREATE TABLE student_2nf (
    student_id    INTEGER PRIMARY KEY,
    student_name  TEXT NOT NULL,
    dept_code     TEXT,
    dept_name     TEXT,
    dept_building TEXT
);

CREATE TABLE course_2nf (
    course_id        TEXT PRIMARY KEY,
    course_name      TEXT NOT NULL,
    professor_name   TEXT,
    professor_office TEXT
);

CREATE TABLE enrollment (
    student_id INTEGER NOT NULL,
    course_id  TEXT    NOT NULL,
    grade      TEXT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES student_2nf(student_id),
    FOREIGN KEY (course_id)  REFERENCES course_2nf(course_id)
);

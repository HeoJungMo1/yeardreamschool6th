-- ============================================================
--  3NF SQL (ERD Editor import용 — CREATE TABLE only)
--  제3정규형 — department / professor / student / course / enrollment
-- ============================================================

CREATE TABLE department (
    dept_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    dept_code     TEXT UNIQUE NOT NULL,
    dept_name     TEXT NOT NULL,
    dept_building TEXT NOT NULL
);

CREATE TABLE professor (
    professor_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    professor_name   TEXT NOT NULL,
    professor_office TEXT,
    dept_id          INTEGER,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE student (
    student_id   INTEGER PRIMARY KEY,
    student_name TEXT NOT NULL,
    dept_id      INTEGER NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE course (
    course_id    TEXT PRIMARY KEY,
    course_name  TEXT NOT NULL,
    professor_id INTEGER NOT NULL,
    FOREIGN KEY (professor_id) REFERENCES professor(professor_id)
);

CREATE TABLE enrollment_3nf (
    student_id INTEGER NOT NULL,
    course_id  TEXT    NOT NULL,
    grade      TEXT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (course_id)  REFERENCES course(course_id)
);

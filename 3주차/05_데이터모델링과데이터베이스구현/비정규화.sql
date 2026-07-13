-- ============================================================
--  비정규화 SQL (ERD Editor import용 — CREATE TABLE only)
--  0단계: Unnormalized Form
-- ============================================================

CREATE TABLE student_course_all (
    student_id       INTEGER,
    student_name     TEXT,
    course_ids       TEXT,
    course_names     TEXT,
    grades           TEXT,
    professor_name   TEXT,
    professor_office TEXT,
    dept_code        TEXT,
    dept_name        TEXT,
    dept_building    TEXT
);

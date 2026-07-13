"""정규화 4단계 SQLite DB — 학생·수강 예제 (비정규화 → 3NF)"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any

DB_PATH = Path(__file__).parent / "normalization.db"

# ── 공통 시드 (모든 단계에서 동일한 의미의 데이터) ─────────────────────────
# 학생 101 김민준(CS): CS301 A+, CS302 A
# 학생 102 이서연(EE): CS301 B+
# 과목 CS301 데이터베이스(김교수 301호), CS302 운영체제(박교수 302호)


def get_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def _rows(conn: sqlite3.Connection, sql: str, params: tuple = ()) -> list[dict[str, Any]]:
    return [dict(r) for r in conn.execute(sql, params).fetchall()]


def init_db() -> None:
    conn = get_connection()
    try:
        conn.executescript("""
            DROP TABLE IF EXISTS enrollment_3nf;
            DROP TABLE IF EXISTS course;
            DROP TABLE IF EXISTS student;
            DROP TABLE IF EXISTS professor;
            DROP TABLE IF EXISTS department;
            DROP TABLE IF EXISTS enrollment;
            DROP TABLE IF EXISTS course_2nf;
            DROP TABLE IF EXISTS student_2nf;
            DROP TABLE IF EXISTS student_course_1nf;
            DROP TABLE IF EXISTS student_course_all;

            -- 0단계: 비정규화 (다중값 속성)
            CREATE TABLE student_course_all (
                student_id       INTEGER PRIMARY KEY,
                student_name     TEXT,
                course_ids       TEXT,
                course_names     TEXT,
                grades           TEXT,
                professor_names  TEXT,
                professor_offices TEXT,
                dept_code        TEXT,
                dept_name        TEXT,
                dept_building    TEXT
            );

            -- 1NF: 원자값 + 복합 PK
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

            -- 2NF: 부분 함수 종속 제거
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

            -- 3NF: 이행 함수 종속 제거
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
                dept_id          INTEGER NOT NULL,
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
        """)

        conn.execute(
            """
            INSERT INTO student_course_all VALUES
            (101, '김민준', 'CS301,CS302', '데이터베이스,운영체제', 'A+,A',
             '김교수,박교수', '301호,302호', 'CS', '컴퓨터공학', '공학관 A동'),
            (102, '이서연', 'CS301', '데이터베이스', 'B+',
             '김교수', '301호', 'EE', '전자공학', '공학관 B동')
            """
        )
        conn.executemany(
            """
            INSERT INTO student_course_1nf VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (101, "CS301", "김민준", "데이터베이스", "A+", "김교수", "301호", "CS", "컴퓨터공학", "공학관 A동"),
                (101, "CS302", "김민준", "운영체제", "A", "박교수", "302호", "CS", "컴퓨터공학", "공학관 A동"),
                (102, "CS301", "이서연", "데이터베이스", "B+", "김교수", "301호", "EE", "전자공학", "공학관 B동"),
            ],
        )
        conn.executemany(
            "INSERT INTO student_2nf VALUES (?, ?, ?, ?, ?)",
            [
                (101, "김민준", "CS", "컴퓨터공학", "공학관 A동"),
                (102, "이서연", "EE", "전자공학", "공학관 B동"),
            ],
        )
        conn.executemany(
            "INSERT INTO course_2nf VALUES (?, ?, ?, ?)",
            [
                ("CS301", "데이터베이스", "김교수", "301호"),
                ("CS302", "운영체제", "박교수", "302호"),
            ],
        )
        conn.executemany(
            "INSERT INTO enrollment VALUES (?, ?, ?)",
            [(101, "CS301", "A+"), (101, "CS302", "A"), (102, "CS301", "B+")],
        )
        conn.executemany(
            "INSERT INTO department (dept_code, dept_name, dept_building) VALUES (?, ?, ?)",
            [("CS", "컴퓨터공학", "공학관 A동"), ("EE", "전자공학", "공학관 B동")],
        )
        dept_cs = conn.execute("SELECT dept_id FROM department WHERE dept_code='CS'").fetchone()["dept_id"]
        dept_ee = conn.execute("SELECT dept_id FROM department WHERE dept_code='EE'").fetchone()["dept_id"]
        conn.executemany(
            "INSERT INTO professor (professor_name, professor_office, dept_id) VALUES (?, ?, ?)",
            [("김교수", "301호", dept_cs), ("박교수", "302호", dept_cs)],
        )
        prof_kim = conn.execute("SELECT professor_id FROM professor WHERE professor_name='김교수'").fetchone()[
            "professor_id"
        ]
        prof_park = conn.execute("SELECT professor_id FROM professor WHERE professor_name='박교수'").fetchone()[
            "professor_id"
        ]
        conn.executemany(
            "INSERT INTO student VALUES (?, ?, ?)",
            [(101, "김민준", dept_cs), (102, "이서연", dept_ee)],
        )
        conn.executemany(
            "INSERT INTO course VALUES (?, ?, ?)",
            [("CS301", "데이터베이스", prof_kim), ("CS302", "운영체제", prof_park)],
        )
        conn.executemany(
            "INSERT INTO enrollment_3nf VALUES (?, ?, ?)",
            [(101, "CS301", "A+"), (101, "CS302", "A"), (102, "CS301", "B+")],
        )
        conn.commit()
    finally:
        conn.close()


def fetch_table(table: str) -> list[dict[str, Any]]:
    conn = get_connection()
    try:
        return _rows(conn, f"SELECT * FROM {table}")
    finally:
        conn.close()


def fetch_enrollment_view(stage: str) -> list[dict[str, Any]]:
    """단계별 수강 통합 조회 (JOIN 또는 원본)"""
    conn = get_connection()
    try:
        if stage == "0nf":
            return _rows(conn, "SELECT * FROM student_course_all ORDER BY student_id")
        if stage == "1nf":
            return _rows(conn, "SELECT * FROM student_course_1nf ORDER BY student_id, course_id")
        if stage == "2nf":
            return _rows(
                conn,
                """
                SELECT e.student_id, s.student_name, e.course_id, c.course_name, e.grade,
                       c.professor_name, c.professor_office,
                       s.dept_code, s.dept_name, s.dept_building
                FROM enrollment e
                JOIN student_2nf s ON e.student_id = s.student_id
                JOIN course_2nf c  ON e.course_id  = c.course_id
                ORDER BY e.student_id, e.course_id
                """,
            )
        return _rows(
            conn,
            """
            SELECT e.student_id, st.student_name, e.course_id, c.course_name, e.grade,
                   p.professor_name, p.professor_office,
                   d.dept_code, d.dept_name, d.dept_building
            FROM enrollment_3nf e
            JOIN student st ON e.student_id = st.student_id
            JOIN course c   ON e.course_id  = c.course_id
            JOIN professor p ON c.professor_id = p.professor_id
            JOIN department d ON st.dept_id = d.dept_id
            ORDER BY e.student_id, e.course_id
            """,
        )
    finally:
        conn.close()


def _run(conn: sqlite3.Connection, sql: str, params: tuple = ()) -> tuple[str, int]:
    cur = conn.execute(sql, params)
    conn.commit()
    display = sql.strip()
    if params:
        display += f"\n-- params: {params}"
    return display, cur.rowcount


# ── 시나리오: 학과 건물 변경 (갱신 이상) ───────────────────────────────────

def update_dept_building(stage: str, dept_code: str, new_building: str, first_row_only: bool) -> tuple[str, str, int]:
    dept_code = dept_code.strip()
    new_building = new_building.strip()
    conn = get_connection()
    try:
        if stage == "0nf":
            if first_row_only:
                sql = """
                    UPDATE student_course_all SET dept_building = ?
                    WHERE dept_code = ? AND student_id = (
                        SELECT MIN(student_id) FROM student_course_all WHERE dept_code = ?
                    )
                """
            else:
                sql = "UPDATE student_course_all SET dept_building = ? WHERE dept_code = ?"
            executed, n = _run(conn, sql, (new_building, dept_code, dept_code) if first_row_only else (new_building, dept_code))
        elif stage == "1nf":
            if first_row_only:
                sql = """
                    UPDATE student_course_1nf SET dept_building = ?
                    WHERE dept_code = ? AND rowid = (
                        SELECT rowid FROM student_course_1nf WHERE dept_code = ? LIMIT 1
                    )
                """
                executed, n = _run(conn, sql, (new_building, dept_code, dept_code))
            else:
                sql = "UPDATE student_course_1nf SET dept_building = ? WHERE dept_code = ?"
                executed, n = _run(conn, sql, (new_building, dept_code))
        elif stage == "2nf":
            if first_row_only:
                sql = """
                    UPDATE student_2nf SET dept_building = ?
                    WHERE dept_code = ? AND student_id = (
                        SELECT MIN(student_id) FROM student_2nf WHERE dept_code = ?
                    )
                """
                executed, n = _run(conn, sql, (new_building, dept_code, dept_code))
            else:
                sql = "UPDATE student_2nf SET dept_building = ? WHERE dept_code = ?"
                executed, n = _run(conn, sql, (new_building, dept_code))
        else:
            sql = "UPDATE department SET dept_building = ? WHERE dept_code = ?"
            executed, n = _run(conn, sql, (new_building, dept_code))

        hint = "첫 row만 수정 → 같은 학과 정보가 row마다 달라질 수 있음" if first_row_only and stage != "3nf" else "학과 마스터 1곳만 수정"
        return executed, hint, n
    finally:
        conn.close()


# ── 시나리오: 교수 연구실 변경 (갱신 이상) ─────────────────────────────────

def update_professor_office(stage: str, course_id: str, new_office: str, first_row_only: bool) -> tuple[str, str, int]:
    course_id = course_id.strip()
    new_office = new_office.strip()
    conn = get_connection()
    try:
        if stage == "0nf":
            rows = conn.execute(
                "SELECT student_id, professor_offices, course_ids FROM student_course_all WHERE course_ids LIKE ?",
                (f"%{course_id}%",),
            ).fetchall()
            if not rows:
                return "-- 해당 과목 없음", "과목을 찾을 수 없습니다", 0

            affected = 0
            parts: list[str] = []
            target_rows = rows[:1] if first_row_only else rows
            for row in target_rows:
                ids = row["course_ids"].split(",")
                offices = row["professor_offices"].split(",")
                if course_id in ids:
                    offices[ids.index(course_id)] = new_office
                sql = "UPDATE student_course_all SET professor_offices = ? WHERE student_id = ?"
                _run(conn, sql, (",".join(offices), row["student_id"]))
                parts.append(
                    f"UPDATE student_course_all SET professor_offices = '{','.join(offices)}' "
                    f"WHERE student_id = {row['student_id']}"
                )
                affected += 1
            executed = "\n".join(parts)
            hint = (
                "일부 학생 row만 수정 → 같은 과목 교수 연구실이 학생마다 다를 수 있음"
                if first_row_only
                else "다중값 셀 전체를 다시 저장해야 함"
            )
            return executed, hint, affected

        if stage == "1nf":
            if first_row_only:
                sql = """
                    UPDATE student_course_1nf SET professor_office = ?
                    WHERE course_id = ? AND rowid = (
                        SELECT rowid FROM student_course_1nf WHERE course_id = ? LIMIT 1
                    )
                """
                executed, n = _run(conn, sql, (new_office, course_id, course_id))
            else:
                sql = "UPDATE student_course_1nf SET professor_office = ? WHERE course_id = ?"
                executed, n = _run(conn, sql, (new_office, course_id))
            hint = "첫 row만 수정 → 같은 과목 교수 연구실이 수강 row마다 다를 수 있음" if first_row_only else "해당 과목의 모든 row 수정"
            return executed, hint, n

        if stage == "2nf":
            sql = "UPDATE course_2nf SET professor_office = ? WHERE course_id = ?"
            executed, n = _run(conn, sql, (new_office, course_id))
            return executed, "course 테이블 1 row 수정 → 모든 수강 조회에 반영", n

        sql = """
            UPDATE professor SET professor_office = ?
            WHERE professor_id = (SELECT professor_id FROM course WHERE course_id = ?)
        """
        executed, n = _run(conn, sql, (new_office, course_id))
        return executed, "professor 테이블 1 row 수정 → 모든 수강 조회에 반영", n
    finally:
        conn.close()


# ── 시나리오: 수강 등록 (삽입 이상) ───────────────────────────────────────

def add_enrollment(
    stage: str,
    student_id: int,
    course_id: str,
    grade: str,
    course_name: str = "네트워크",
    professor_name: str = "최교수",
    professor_office: str = "401호",
) -> tuple[str, str, int]:
    course_id = course_id.strip()
    grade = grade.strip()
    conn = get_connection()
    try:
        if stage == "0nf":
            row = conn.execute(
                "SELECT * FROM student_course_all WHERE student_id = ?", (student_id,)
            ).fetchone()
            if not row:
                return "-- 학생 없음", "비정규화 테이블에 학생 row가 없으면 삽입 불가", 0
            cur = conn.execute(
                """
                UPDATE student_course_all SET
                    course_ids = course_ids || ?,
                    course_names = course_names || ?,
                    grades = grades || ?,
                    professor_names = professor_names || ?,
                    professor_offices = professor_offices || ?
                WHERE student_id = ?
                """,
                (
                    f",{course_id}",
                    f",{course_name}",
                    f",{grade}",
                    f",{professor_name}",
                    f",{professor_office}",
                    student_id,
                ),
            )
            conn.commit()
            executed = (
                f"UPDATE student_course_all SET\n"
                f"  course_ids = course_ids || ',{course_id}', ...\n"
                f"WHERE student_id = {student_id}"
            )
            return executed, "다중값 셀에 콤마로 이어 붙임 — 원자값·무결성 위반", cur.rowcount

        if stage == "1nf":
            name_row = conn.execute(
                "SELECT student_name, dept_code, dept_name, dept_building FROM student_course_1nf WHERE student_id = ? LIMIT 1",
                (student_id,),
            ).fetchone()
            if not name_row:
                return "-- 학생 없음", "기존 수강 row에서 학생 정보를 찾을 수 없습니다", 0
            sql = """
                INSERT INTO student_course_1nf
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            executed, n = _run(
                conn,
                sql,
                (
                    student_id,
                    course_id,
                    name_row["student_name"],
                    course_name,
                    grade,
                    professor_name,
                    professor_office,
                    name_row["dept_code"],
                    name_row["dept_name"],
                    name_row["dept_building"],
                ),
            )
            return executed, "원자값 삽입 가능 — 단, 학과·교수 정보가 row마다 중복 저장됨", n

        if stage == "2nf":
            if not conn.execute("SELECT 1 FROM student_2nf WHERE student_id=?", (student_id,)).fetchone():
                return "-- 학생 없음", "student_2nf에 학생이 없습니다", 0
            if not conn.execute("SELECT 1 FROM course_2nf WHERE course_id=?", (course_id,)).fetchone():
                sql = "INSERT INTO course_2nf VALUES (?, ?, ?, ?)"
                _run(conn, sql, (course_id, course_name, professor_name, professor_office))
            sql = "INSERT INTO enrollment VALUES (?, ?, ?)"
            executed, n = _run(conn, sql, (student_id, course_id, grade))
            return executed, "enrollment에 성적만 추가 — 학생·과목은 각 마스터 테이블", n

        if not conn.execute("SELECT 1 FROM student WHERE student_id=?", (student_id,)).fetchone():
            return "-- 학생 없음", "student 테이블에 학생이 없습니다", 0
        if not conn.execute("SELECT 1 FROM course WHERE course_id=?", (course_id,)).fetchone():
            dept_id = conn.execute("SELECT dept_id FROM department WHERE dept_code='CS'").fetchone()["dept_id"]
            cur = conn.execute(
                "INSERT INTO professor (professor_name, professor_office, dept_id) VALUES (?, ?, ?)",
                (professor_name, professor_office, dept_id),
            )
            prof_id = cur.lastrowid
            _run(conn, "INSERT INTO course VALUES (?, ?, ?)", (course_id, course_name, prof_id))
        sql = "INSERT INTO enrollment_3nf VALUES (?, ?, ?)"
        executed, n = _run(conn, sql, (student_id, course_id, grade))
        return executed, "과목·교수·학과 분리 — enrollment에는 성적만 추가", n
    finally:
        conn.close()


# ── 시나리오: 학생 수강 삭제 (삭제 이상) ───────────────────────────────────

def delete_student_records(stage: str, student_id: int) -> tuple[str, str, int]:
    conn = get_connection()
    try:
        if stage == "0nf":
            sql = "DELETE FROM student_course_all WHERE student_id = ?"
            executed, n = _run(conn, sql, (student_id,))
            return executed, "학생 row 삭제 → 해당 학생·수강·학과 정보가 모두 사라짐", n
        if stage == "1nf":
            sql = "DELETE FROM student_course_1nf WHERE student_id = ?"
            executed, n = _run(conn, sql, (student_id,))
            return executed, "수강 row 삭제 — 학생 마스터 없음, 학생 정보 복구 불가", n
        if stage == "2nf":
            sql = "DELETE FROM enrollment WHERE student_id = ?"
            executed, n = _run(conn, sql, (student_id,))
            student_left = conn.execute(
                "SELECT COUNT(*) AS c FROM student_2nf WHERE student_id = ?", (student_id,)
            ).fetchone()["c"]
            hint = f"수강만 삭제 — student_2nf에 학생 {'유지' if student_left else '없음'}"
            return executed, hint, n
        sql = "DELETE FROM enrollment_3nf WHERE student_id = ?"
        executed, n = _run(conn, sql, (student_id,))
        student_left = conn.execute(
            "SELECT COUNT(*) AS c FROM student WHERE student_id = ?", (student_id,)
        ).fetchone()["c"]
        hint = f"수강만 삭제 — student 테이블에 학생 {'유지' if student_left else '없음'}"
        return executed, hint, n
    finally:
        conn.close()


def check_data_issues(stage: str) -> list[str]:
    """현재 DB 데이터에서 실제 불일치 탐지"""
    issues: list[str] = []
    conn = get_connection()
    try:
        if stage == "0nf":
            for row in _rows(conn, "SELECT * FROM student_course_all"):
                ids = row["course_ids"].split(",")
                if len(ids) != len(set(ids)):
                    issues.append(f"학생 {row['student_id']}: course_ids에 중복 값")
            return issues

        if stage == "1nf":
            for row in _rows(
                conn,
                """
                SELECT student_id, COUNT(DISTINCT dept_building) AS cnt
                FROM student_course_1nf GROUP BY student_id HAVING cnt > 1
                """,
            ):
                issues.append(f"학생 {row['student_id']}: 같은 학생인데 dept_building이 row마다 다름")
            for row in _rows(
                conn,
                """
                SELECT course_id, COUNT(DISTINCT professor_office) AS cnt
                FROM student_course_1nf GROUP BY course_id HAVING cnt > 1
                """,
            ):
                issues.append(f"과목 {row['course_id']}: 교수 연구실이 row마다 다름")
            return issues

        if stage == "2nf":
            for row in _rows(
                conn,
                """
                SELECT dept_code, COUNT(DISTINCT dept_building) AS cnt
                FROM student_2nf GROUP BY dept_code HAVING cnt > 1
                """,
            ):
                issues.append(f"학과 {row['dept_code']}: dept_building이 학생 row마다 다름")
            return issues

        for row in _rows(
            conn,
            """
            SELECT dept_code, COUNT(DISTINCT dept_building) AS cnt
            FROM department GROUP BY dept_code HAVING cnt > 1
            """,
        ):
            issues.append(f"학과 {row['dept_code']}: department 테이블 불일치")
        return issues
    finally:
        conn.close()


# ── 단계·시나리오별 이상 현상 구조적 상태 ───────────────────────────────────
# risk   = 설계상 이상 현상 존재
# partial = 일부 시나리오만 해소 (2NF 학과 갱신 등)
# ok     = 해당 시나리오 정상

SCENARIO_KEYS = ("dept_update", "prof_update", "insert", "delete")

SCENARIO_ANOMALY: dict[str, dict[str, str]] = {
    "0nf": {
        "dept_update": "risk",
        "prof_update": "risk",
        "insert": "risk",
        "delete": "risk",
    },
    "1nf": {
        "dept_update": "risk",
        "prof_update": "risk",
        "insert": "risk",
        "delete": "risk",
    },
    "2nf": {
        "dept_update": "partial",
        "prof_update": "ok",
        "insert": "ok",
        "delete": "ok",
    },
    "3nf": {
        "dept_update": "ok",
        "prof_update": "ok",
        "insert": "ok",
        "delete": "ok",
    },
}

ANOMALY_META = {
    "risk": {
        "label": "존재",
        "short": "이상 존재",
        "detail": "설계상 갱신·삽입·삭제 이상이 발생할 수 있는 구조입니다.",
    },
    "partial": {
        "label": "잔존",
        "short": "일부 잔존",
        "detail": "부분 종속은 해소됐지만, 이행 종속 때문에 일부 갱신 이상이 남아 있습니다.",
    },
    "ok": {
        "label": "정상",
        "short": "정상",
        "detail": "해당 시나리오에서 이상 현상이 구조적으로 발생하지 않습니다.",
    },
}

SCENARIO_TITLES = {
    "dept_update": ("갱신 이상", "학과 건물 변경"),
    "prof_update": ("갱신 이상", "교수 연구실 변경"),
    "insert": ("삽입 이상", "수강 등록"),
    "delete": ("삭제 이상", "학생 수강 삭제"),
}


def get_scenario_status(stage: str, scenario: str) -> dict[str, str]:
    """시나리오 하나의 구조적 이상 상태"""
    level = SCENARIO_ANOMALY[stage][scenario]
    kind, title = SCENARIO_TITLES[scenario]
    meta = ANOMALY_META[level]
    return {
        "level": level,
        "kind": kind,
        "title": title,
        "label": meta["label"],
        "short": f"{kind} · {meta['label']}",
        "detail": meta["detail"],
    }


def get_stage_anomaly_summary(stage: str) -> dict[str, Any]:
    """탭 상단 요약 + 현재 데이터 이슈"""
    scenarios = {key: get_scenario_status(stage, key) for key in SCENARIO_KEYS}
    data_issues = check_data_issues(stage)
    levels = [scenarios[k]["level"] for k in SCENARIO_KEYS]

    if "risk" in levels:
        overall = "risk"
        overall_text = "갱신·삽입·삭제 이상 구조 존재"
    elif "partial" in levels:
        overall = "partial"
        overall_text = "일부 갱신 이상 잔존 (학과 이행 종속)"
    else:
        overall = "ok"
        overall_text = "갱신·삽입·삭제 모두 정상 구조"

    return {
        "overall": overall,
        "overall_text": overall_text,
        "scenarios": scenarios,
        "data_issues": data_issues,
        "has_data_issue": len(data_issues) > 0,
    }


def check_consistency(stage: str) -> list[str]:
    """하위 호환 — 문자열 목록 반환"""
    summary = get_stage_anomaly_summary(stage)
    lines: list[str] = []
    if summary["has_data_issue"]:
        lines.extend(summary["data_issues"])
    else:
        overall = summary["overall"]
        if overall == "ok":
            lines.append("현재 데이터 일관성 유지 · 3NF 구조상 이상 없음")
        elif overall == "partial":
            lines.append("구조: 학과 갱신 이상 잔존 · 현재 데이터는 일관")
        else:
            lines.append("구조: 갱신·삽입·삭제 이상 취약 · 시나리오 실행 후 데이터 불일치 가능")
    return lines

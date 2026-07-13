"""
제약 조건이 과도하거나 잘못 설계된 DB (bad.db) — 강의 시연용

good.db와 동일한 UI·동일한 INSERT SQL을 사용하지만,
CHECK / FK 설계 오류 때문에 가입이 실패하는 경우를 보여줍니다.
app.py 우측(Bad DB) 패널에서 import 되어 사용됩니다.
"""

import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent / "bad.db"


def get_connection() -> sqlite3.Connection:
    """SQLite 연결을 생성하고 FK 제약을 활성화합니다."""
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db() -> None:
    """
    bad.db를 초기 상태로 재생성합니다.

    membership_plans(부모) + users(자식) 두 테이블을 만들며,
    의도적으로 잘못된 DEFAULT FK('VIP')와 과도한 CHECK를 포함합니다.
    """
    conn = get_connection()
    try:
        conn.executescript("""
            DROP TABLE IF EXISTS users;
            DROP TABLE IF EXISTS membership_plans;

            -- FK 참조 대상 테이블 (plan_id의 부모)
            CREATE TABLE membership_plans (
                plan_id   TEXT PRIMARY KEY,
                plan_name TEXT NOT NULL
            );
            -- 'BASIC'만 존재 — 'VIP'는 없음 (아래 DEFAULT와 불일치)
            INSERT INTO membership_plans (plan_id, plan_name)
            VALUES ('BASIC', '일반 회원');

            CREATE TABLE users (
                user_id    INTEGER PRIMARY KEY AUTOINCREMENT,
                username   TEXT NOT NULL UNIQUE,
                email      TEXT NOT NULL UNIQUE,
                password   TEXT NOT NULL,
                -- 앱은 plan_id를 INSERT에 넣지 않음 → DEFAULT 'VIP' 적용
                plan_id    TEXT NOT NULL DEFAULT 'VIP',
                created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
                -- 과도한 CHECK (강의 Day05 제약조건 비교용)
                CHECK (length(username) >= 10 AND length(username) <= 12),
                CHECK (username GLOB '[a-z0-9]*'),
                CHECK (email LIKE '%@school.ac.kr'),
                CHECK (length(password) = 8),
                CHECK (password GLOB '*[0-9]*' AND password GLOB '*[A-Z]*'),
                FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id)
            );
        """)
        conn.commit()
    finally:
        conn.close()


# app.py expander에 표시되는 제약 조건 설명 (마크다운 표)
CONSTRAINT_GUIDE = """
| 제약 | 내용 | 왜 문제인가 |
|------|------|------------|
| CHECK username | 10~12자, 소문자·숫자만 | 일반적인 짧은 아이디(user1) 불가 |
| CHECK email | @school.ac.kr 만 허용 | gmail, naver 등 실사용 이메일 불가 |
| CHECK password | 정확히 8자 + 숫자·대문자 포함 | 4자 이상이면 충분한데 과도함 |
| FK plan_id | DEFAULT 'VIP' → 테이블에 없음 | 가입 SQL이 항상 FK 위반 |
"""


def signup(username: str, email: str, password: str) -> tuple[bool, str, str]:
    """
    회원가입 — good_db와 동일한 INSERT이지만 bad.db 제약으로 실패합니다.

    plan_id를 명시하지 않으므로 DEFAULT 'VIP'가 적용되고,
    CHECK를 모두 통과해도 FK 위반으로 최종 실패할 수 있습니다.
    """
    sql = """
        INSERT INTO users (username, email, password)
        VALUES (?, ?, ?)
    """
    conn = get_connection()
    try:
        conn.execute(sql, (username.strip(), email.strip(), password))
        conn.commit()
        return True, sql.strip(), "회원가입 성공"
    except sqlite3.IntegrityError as e:
        return False, sql.strip(), _friendly_error(str(e))
    except sqlite3.Error as e:
        return False, sql.strip(), str(e)
    finally:
        conn.close()


def login(username_or_email: str, password: str) -> tuple[bool, str, str, dict | None]:
    """
    로그인 — good_db와 동일한 방식, plan_id 컬럼 추가 조회.

    bad.db는 가입이 어려워 로그인 성공 케이스는 제한적입니다.
    """
    sql = """
        SELECT user_id, username, email, plan_id, created_at
        FROM users
        WHERE (username = ? OR email = ?)
          AND password = ?
    """
    conn = get_connection()
    try:
        key = username_or_email.strip()
        row = conn.execute(sql, (key, key, password)).fetchone()
        if row:
            return True, sql.strip(), "로그인 성공", dict(row)
        return False, sql.strip(), "아이디 또는 비밀번호가 올바르지 않습니다.", None
    finally:
        conn.close()


def list_users() -> list[dict]:
    """등록된 전체 회원 목록 (plan_id 포함)을 반환합니다."""
    conn = get_connection()
    try:
        rows = conn.execute(
            "SELECT user_id, username, email, plan_id, created_at FROM users ORDER BY user_id"
        ).fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


def _friendly_error(msg: str) -> str:
    """
    bad.db 전용 오류 메시지 변환.

    FK / CHECK / UNIQUE 위반을 학습자가 이해하기 쉬운 문장으로 바꿉니다.
    """
    if "FOREIGN KEY" in msg:
        return (
            "FOREIGN KEY 위반: plan_id 기본값 'VIP'가 membership_plans에 없습니다. "
            "앱은 plan_id를 보내지 않는데 DB가 존재하지 않는 값을 강제합니다."
        )
    if "UNIQUE" in msg:
        return f"UNIQUE 제약 위반: {msg}"
    if "CHECK constraint failed" in msg or "CHECK" in msg:
        if "username" in msg.lower() or "GLOB" in msg:
            return "CHECK 위반: 아이디는 소문자·숫자만, 10~12자여야 합니다."
        if "email" in msg.lower() or "school.ac.kr" in msg:
            return "CHECK 위반: 이메일은 @school.ac.kr 도메인만 허용됩니다."
        if "password" in msg.lower():
            return "CHECK 위반: 비밀번호는 정확히 8자, 숫자·대문자를 포함해야 합니다."
        return f"CHECK 제약 위반: {msg}"
    return msg

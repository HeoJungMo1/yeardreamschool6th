"""
제약 조건이 적절히 설계된 DB (good.db)

Day 05 강의용 — NOT NULL, UNIQUE, CHECK, PRIMARY KEY를
실무에 가까운 수준으로 적용한 회원 테이블을 다룹니다.
app.py 좌측(Good DB) 패널에서 import 되어 사용됩니다.
"""

import sqlite3
from pathlib import Path

# database/ 폴더 기준 good.db 파일 경로 (SQLite는 파일 = DB)
DB_PATH = Path(__file__).parent / "good.db"


def get_connection() -> sqlite3.Connection:
    """SQLite 연결을 생성하고 FK 제약을 활성화합니다."""
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    # 컬럼명으로 접근 가능하게 설정 (dict(row) 변환에 사용)
    conn.row_factory = sqlite3.Row
    # SQLite는 기본값 OFF → FK 검사를 켜야 REFERENCES가 동작
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db() -> None:
    """
    good.db를 초기 상태로 재생성합니다.
    앱 최초 실행 시, 또는 '두 DB 모두 초기화' 버튼 클릭 시 호출됩니다.
    """
    conn = get_connection()
    try:
        conn.executescript("""
            DROP TABLE IF EXISTS users;

            CREATE TABLE users (
                user_id    INTEGER PRIMARY KEY AUTOINCREMENT,  -- PK: 자동 증가
                username   TEXT NOT NULL UNIQUE,                 -- NOT NULL + UNIQUE
                email      TEXT NOT NULL UNIQUE,                 -- NOT NULL + UNIQUE
                password   TEXT NOT NULL,                        -- NOT NULL (교육용 평문)
                created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
                -- CHECK: 최소 길이·이메일 형식만 검증 (과도하지 않음)
                CHECK (length(username) >= 3),
                CHECK (length(password) >= 4),
                CHECK (email LIKE '%@%.%')
            );
        """)
        conn.commit()
    finally:
        conn.close()


def signup(username: str, email: str, password: str) -> tuple[bool, str, str]:
    """
    회원가입 — INSERT 실행 후 제약 위반 여부를 반환합니다.

    Returns:
        (성공 여부, 실행 SQL 문자열, 사용자 메시지)
    """
    sql = """
        INSERT INTO users (username, email, password)
        VALUES (?, ?, ?)
    """
    conn = get_connection()
    try:
        # ? 플레이스홀더로 SQL Injection 방지
        conn.execute(sql, (username.strip(), email.strip(), password))
        conn.commit()
        return True, sql.strip(), "회원가입 성공"
    except sqlite3.IntegrityError as e:
        # UNIQUE / CHECK / FK 등 무결성 제약 위반
        return False, sql.strip(), _friendly_error(str(e))
    except sqlite3.Error as e:
        return False, sql.strip(), str(e)
    finally:
        conn.close()


def login(username_or_email: str, password: str) -> tuple[bool, str, str, dict | None]:
    """
    로그인 — 아이디 또는 이메일 + 비밀번호로 사용자를 조회합니다.

    Returns:
        (성공 여부, 실행 SQL, 메시지, 사용자 dict 또는 None)
    """
    sql = """
        SELECT user_id, username, email, created_at
        FROM users
        WHERE (username = ? OR email = ?)
          AND password = ?
    """
    conn = get_connection()
    try:
        key = username_or_email.strip()
        # 동일 key를 username / email 양쪽에 바인딩
        row = conn.execute(sql, (key, key, password)).fetchone()
        if row:
            return True, sql.strip(), "로그인 성공", dict(row)
        return False, sql.strip(), "아이디 또는 비밀번호가 올바르지 않습니다.", None
    finally:
        conn.close()


def list_users() -> list[dict]:
    """등록된 전체 회원 목록을 user_id 순으로 반환합니다."""
    conn = get_connection()
    try:
        rows = conn.execute(
            "SELECT user_id, username, email, created_at FROM users ORDER BY user_id"
        ).fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


def _friendly_error(msg: str) -> str:
    """SQLite 원문 오류를 학습용 한글 메시지로 변환합니다."""
    if "UNIQUE" in msg and "username" in msg:
        return "이미 사용 중인 아이디입니다. (UNIQUE 제약)"
    if "UNIQUE" in msg and "email" in msg:
        return "이미 등록된 이메일입니다. (UNIQUE 제약)"
    if "CHECK" in msg:
        return f"입력값이 CHECK 제약을 만족하지 않습니다. ({msg})"
    return msg

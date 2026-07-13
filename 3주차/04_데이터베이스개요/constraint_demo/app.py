"""
제약 조건 비교 시연 — Streamlit 회원가입 / 로그인
같은 UI, 다른 DB 설계 → 결과가 달라지는 이유를 체험합니다.

Streamlit API (deprecation warning 방지):
  - width="stretch" | "content" 사용 (use_container_width 금지)
  - st.experimental_* 대신 st.* 공식 API 사용
  - 레이아웃·차트·버튼 등 width/height는 문자열 리터럴 우선
"""

import streamlit as st

from database import bad_db, good_db

# Streamlit 앱 전역 설정
st.set_page_config(
    page_title="제약 조건 비교 데모",  # 브라우저 탭에 표시될 제목
    page_icon=None,
    layout="wide",  # 넓은 레이아웃 사용(2단 그리드 표현에 유리)
)

# 세션마다 DB를 1회만 초기화 하여 중복 삭제 방지
if "db_ready" not in st.session_state:
    good_db.init_db()  # 적절한 제약을 가진 DB 초기화
    bad_db.init_db()   # 과도한/잘못된 제약을 가진 DB 초기화
    st.session_state.db_ready = True  # 초기화 플래그


def render_auth_panel(
    title: str,
    panel_type: str,
    signup_fn,
    login_fn,
    list_fn,
    guide: str | None = None,
) -> None:
    """
    동일한 회원가입/로그인 UI를 인자로 받은 DB 함수마다 따로 렌더링합니다.

    Args:
        title (str): 각 패널(컬럼) 제목
        panel_type (str): 구분값('good' 또는 'bad')
        signup_fn (function): 회원가입 함수
        login_fn (function): 로그인 함수
        list_fn (function): 전체 회원 목록 조회 함수
        guide (str | None): 제약조건 설명서 (마크다운)

    Returns:
        None
    """
    st.subheader(title)

    # 제약조건 설명서. bad 패널만 기본 펼침.
    if guide:
        with st.expander("이 DB의 제약 조건 설명", expanded=(panel_type == "bad")):
            st.markdown(guide)

    # 탭 구성: 회원가입/로그인/회원 목록
    tab_signup, tab_login, tab_users = st.tabs(["회원가입", "로그인", "회원 목록"])

    # --- 회원가입 폼 ---
    with tab_signup:
        st.caption("아이디 · 이메일 · 비밀번호 (양쪽 DB 동일 입력 폼)")
        username = st.text_input("아이디", key=f"{panel_type}_su_user", placeholder="예: kimminjun")
        email = st.text_input("이메일", key=f"{panel_type}_su_email", placeholder="예: kim@example.com")
        password = st.text_input("비밀번호", type="password", key=f"{panel_type}_su_pw")
        password2 = st.text_input("비밀번호 확인", type="password", key=f"{panel_type}_su_pw2")

        # 가입하기 버튼 클릭 시 입력값 검증, DB 함수 호출
        if st.button("가입하기", key=f"{panel_type}_signup_btn", type="primary"):
            if not username or not email or not password:
                st.error("모든 항목을 입력하세요.")  # 빈 값 체크
            elif password != password2:
                st.error("비밀번호가 일치하지 않습니다.")  # 비밀번호 일치 검증
            else:
                ok, sql, msg = signup_fn(username, email, password)  # DB별 가입 처리
                st.code(sql, language="sql")  # 실행된 SQL 구문 출력
                if ok:
                    st.success(msg)  # 가입 성공
                else:
                    st.error(msg)    # DB 제약 오류 등 실패

    # --- 로그인 폼 ---
    with tab_login:
        login_id = st.text_input("아이디 또는 이메일", key=f"{panel_type}_lg_id")
        login_pw = st.text_input("비밀번호", type="password", key=f"{panel_type}_lg_pw")

        # 로그인 버튼 클릭 시 DB 함수 호출 및 결과 표시
        if st.button("로그인", key=f"{panel_type}_login_btn"):
            ok, sql, msg, user = login_fn(login_id, login_pw)
            st.code(sql, language="sql")  # 실행된 SQL 구문 출력
            if ok:
                st.success(f"{msg} — 환영합니다, {user['username']}님")  # 성공 메시지
                st.json(user)  # 사용자 정보 JSON으로 확인
            else:
                st.warning(msg)  # 로그인 실패

    # --- 회원 목록 출력 ---
    with tab_users:
        users = list_fn()  # 전체 회원 목록 불러오기
        if users:
            st.dataframe(users, width="stretch", hide_index=True)
        else:
            st.info("등록된 회원이 없습니다.")  # 회원 없음 안내


# ── 헤더 ──────────────────────────────────────────────────────
st.title("제약 조건(Constraints) 비교 — 회원가입 / 로그인")
st.markdown(
    """
**Day 05 강의 주제**: NOT NULL · UNIQUE · CHECK · PRIMARY KEY · FOREIGN KEY  
동일한 화면에서 **잘 설계된 DB(good.db)** 와 **과도한 제약 DB(bad.db)** 를 비교합니다.
"""
)

# 2단 패널(컬럼) 구성 — good과 bad DB 동시 표시
col_good, col_bad = st.columns(2)

# good.db 패널의 제약조건 설명서
GOOD_GUIDE = """
**good.db — 적절한 제약**

| 제약 | 내용 |
|------|------|
| NOT NULL | username, email, password 필수 |
| UNIQUE | username, email 중복 불가 |
| CHECK | 아이디 3자 이상, 비밀번호 4자 이상, 이메일 형식 |
| PK | user_id 자동 증가 |

일반적인 가입 정보로 정상 동작합니다.
"""

# 좌측: good DB용 패널과 UI 렌더링
with col_good:
    st.markdown('<div style="background:#f5fff5;padding:1rem;border-radius:8px;border:1px solid #b2f2bb">',
                unsafe_allow_html=True)
    render_auth_panel(
        title="Good DB — 적절한 제약",
        panel_type="good",
        signup_fn=good_db.signup,       # good DB 회원가입 함수
        login_fn=good_db.login,         # good DB 로그인 함수
        list_fn=good_db.list_users,     # good DB 회원목록 함수
        guide=GOOD_GUIDE,
    )
    st.markdown("</div>", unsafe_allow_html=True)

# 우측: bad DB용 패널과 UI 렌더링
with col_bad:
    st.markdown('<div style="background:#fff5f5;padding:1rem;border-radius:8px;border:1px solid #ffc9c9">',
                unsafe_allow_html=True)
    render_auth_panel(
        title="Bad DB — 과도한 / 잘못된 제약",
        panel_type="bad",
        signup_fn=bad_db.signup,        # bad DB 회원가입 함수
        login_fn=bad_db.login,          # bad DB 로그인 함수
        list_fn=bad_db.list_users,      # bad DB 회원목록 함수
        guide=bad_db.CONSTRAINT_GUIDE,  # bad DB 제약 표 설명
    )
    st.markdown("</div>", unsafe_allow_html=True)

# ── 하단: 실습 가이드 ─────────────────────────────────────────
st.divider()
st.markdown("### 실습 가이드")
st.markdown(
    """
1. **Good DB**에 `kim` / `kim@test.com` / `1234` 로 가입해 보세요 → 성공
2. **Bad DB**에 **같은 값**으로 가입해 보세요 → CHECK / FK 오류 발생
3. Bad DB에만 통과할 법한 값(`kimminjun01` / `minjun@school.ac.kr` / `Pass1234`)을 넣어도
   **plan_id FK(VIP 미존재)** 때문에 실패하는지 확인하세요
4. 실행된 SQL과 오류 메시지를 비교하며, **제약 조건은 데이터 무결성을 지키되
   비즈니스에 맞게 설계**해야 함을 정리하세요
"""
)

# DB 재초기화(회원정보 초기화) 버튼 구현
if st.button("두 DB 모두 초기화 (회원 데이터 삭제)"):
    good_db.init_db()
    bad_db.init_db()
    st.success("good.db, bad.db 가 초기 상태로 재설정되었습니다.")
    st.rerun()

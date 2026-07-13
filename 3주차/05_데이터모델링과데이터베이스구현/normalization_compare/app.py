"""
정규화 4단계 비교 — Streamlit 시연
비정규화 · 1NF · 2NF · 3NF (학생·수강 예제)
"""

import streamlit as st
import pandas as pd

import norm_db as db

st.set_page_config(page_title="정규화 비교", layout="wide")

STAGES = {
    "0nf": {
        "title": "비정규화 (0NF)",
        "badge": "다중값 속성",
        "desc": (
            "한 row에 `CS301,CS302`처럼 **콤마로 여러 과목**을 저장합니다. "
            "수강 추가·교수 변경 시 문자열을 직접 수정해야 하고, 원자값·무결성을 깨기 쉽습니다."
        ),
        "tables": ["student_course_all"],
    },
    "1nf": {
        "title": "제1정규형 (1NF)",
        "badge": "원자값 + 복합 PK",
        "desc": (
            "과목·성적을 **row마다 분리**했지만, 학생명·학과·교수 정보가 **수강 row마다 중복**됩니다. "
            "갱신 시 일부 row만 바꾸면 같은 학생/과목 정보가 불일치합니다."
        ),
        "tables": ["student_course_1nf"],
    },
    "2nf": {
        "title": "제2정규형 (2NF)",
        "badge": "부분 함수 종속 제거",
        "desc": (
            "`student_2nf` · `course_2nf` · `enrollment`로 분리해 **복합 PK의 부분 종속**을 제거했습니다. "
            "다만 학과명·건물은 `dept_code`에 종속 → student에 **이행 종속**이 남습니다."
        ),
        "tables": ["student_2nf", "course_2nf", "enrollment"],
    },
    "3nf": {
        "title": "제3정규형 (3NF)",
        "badge": "이행 함수 종속 제거",
        "desc": (
            "`department` · `professor` · `student` · `course` · `enrollment_3nf`로 분리. "
            "학과·교수 정보는 **각 마스터 테이블 1곳**에만 저장됩니다."
        ),
        "tables": ["department", "professor", "student", "course", "enrollment_3nf"],
    },
}


def _badge_html(level: str, text: str) -> str:
    colors = {
        "risk": ("#ffe3e3", "#c92a2a", "존재"),
        "partial": ("#fff3bf", "#e67700", "잔존"),
        "ok": ("#d3f9d8", "#2b8a3e", "정상"),
    }
    bg, fg, _ = colors.get(level, colors["ok"])
    return (
        f'<span style="background:{bg};color:{fg};padding:0.2rem 0.55rem;'
        f'border-radius:999px;font-size:0.78rem;font-weight:700;">{text}</span>'
    )


def render_anomaly_summary(stage_key: str) -> None:
    """탭 상단 — 단계별 이상 현상 존재 여부"""
    summary = db.get_stage_anomaly_summary(stage_key)
    overall = summary["overall"]

    st.markdown("**이상 현상 상태 (설계 기준)**")

    if overall == "risk":
        st.error(f"**{summary['overall_text']}** — 갱신·삽입·삭제 이상이 모두 발생할 수 있는 구조입니다.")
    elif overall == "partial":
        st.warning(f"**{summary['overall_text']}** — 삽입·삭제는 정상, 학과 갱신만 이행 종속으로 잔존합니다.")
    else:
        st.success(f"**{summary['overall_text']}** — 마스터 테이블 분리로 이상 현상이 구조적으로 해소되었습니다.")

    cols = st.columns(4)
    scenario_order = [
        ("dept_update", "갱신 (학과)"),
        ("prof_update", "갱신 (교수)"),
        ("insert", "삽입"),
        ("delete", "삭제"),
    ]
    for col, (skey, heading) in zip(cols, scenario_order):
        info = summary["scenarios"][skey]
        with col:
            st.markdown(
                f"{heading}<br>{_badge_html(info['level'], info['short'])}",
                unsafe_allow_html=True,
            )

    if summary["has_data_issue"]:
        st.warning("**현재 데이터 불일치 감지**")
        for issue in summary["data_issues"]:
            st.markdown(f"- {issue}")
    else:
        st.caption("현재 저장된 데이터에는 불일치가 없습니다. (시나리오 실행 후 다시 확인)")


def scenario_heading(stage_key: str, scenario_key: str, number: int) -> None:
    """시나리오 제목 + 해당 단계의 이상 상태 뱃지"""
    info = db.get_scenario_status(stage_key, scenario_key)
    st.markdown(
        f"##### {number}. {info['title']} "
        f"{_badge_html(info['level'], info['short'])}",
        unsafe_allow_html=True,
    )


def render_stage(stage_key: str) -> None:
    meta = STAGES[stage_key]
    st.subheader(meta["title"])
    st.caption(meta["badge"])
    st.markdown(meta["desc"])

    render_anomaly_summary(stage_key)
    st.divider()

    st.markdown("**수강 통합 조회**")
    view = db.fetch_enrollment_view(stage_key)
    st.dataframe(pd.DataFrame(view), width="stretch", hide_index=True)

    with st.expander("테이블 원본 보기", expanded=False):
        for table in meta["tables"]:
            st.markdown(f"`{table}`")
            st.dataframe(pd.DataFrame(db.fetch_table(table)), width="stretch", hide_index=True)

    st.divider()
    st.markdown("**시나리오 — 직접 입력 후 실행**")

    c1, c2 = st.columns(2)

    with c1:
        scenario_heading(stage_key, "dept_update", 1)
        dept_code = st.text_input("학과 코드", value="CS", key=f"{stage_key}_dept")
        new_building = st.text_input("새 건물명", value="공학관 신관", key=f"{stage_key}_bldg")
        first_only = st.checkbox(
            "첫 row만 수정 (실수 시뮬레이션)",
            value=(stage_key != "3nf"),
            key=f"{stage_key}_dept_first",
            disabled=(stage_key == "3nf"),
        )
        if st.button("학과 건물 변경", key=f"{stage_key}_btn_dept", type="primary"):
            sql, msg, n = db.update_dept_building(stage_key, dept_code, new_building, first_only)
            st.session_state[f"{stage_key}_last_sql"] = sql
            st.session_state[f"{stage_key}_last_msg"] = f"{msg} ({n}건 영향)"
            st.rerun()

    with c2:
        scenario_heading(stage_key, "prof_update", 2)
        course_id = st.text_input("과목 코드", value="CS301", key=f"{stage_key}_course")
        new_office = st.text_input("새 연구실", value="401호", key=f"{stage_key}_office")
        prof_first = st.checkbox(
            "첫 row만 수정 (실수 시뮬레이션)",
            value=(stage_key in ("0nf", "1nf")),
            key=f"{stage_key}_prof_first",
            disabled=(stage_key in ("2nf", "3nf")),
        )
        if st.button("연구실 변경", key=f"{stage_key}_btn_prof"):
            sql, msg, n = db.update_professor_office(stage_key, course_id, new_office, prof_first)
            st.session_state[f"{stage_key}_last_sql"] = sql
            st.session_state[f"{stage_key}_last_msg"] = f"{msg} ({n}건 영향)"
            st.rerun()

    c3, c4 = st.columns(2)

    with c3:
        scenario_heading(stage_key, "insert", 3)
        sid = st.number_input("학번", min_value=100, value=101, step=1, key=f"{stage_key}_sid")
        cid = st.text_input("과목 코드", value="CS303", key=f"{stage_key}_cid")
        grade = st.text_input("성적", value="A", key=f"{stage_key}_grade")
        if st.button("수강 등록", key=f"{stage_key}_btn_add"):
            sql, msg, n = db.add_enrollment(stage_key, int(sid), cid, grade)
            st.session_state[f"{stage_key}_last_sql"] = sql
            st.session_state[f"{stage_key}_last_msg"] = f"{msg} ({n}건 영향)"
            st.rerun()

    with c4:
        scenario_heading(stage_key, "delete", 4)
        del_sid = st.number_input("삭제할 학번", min_value=100, value=102, step=1, key=f"{stage_key}_del_sid")
        if st.button("수강 기록 삭제", key=f"{stage_key}_btn_del"):
            sql, msg, n = db.delete_student_records(stage_key, int(del_sid))
            st.session_state[f"{stage_key}_last_sql"] = sql
            st.session_state[f"{stage_key}_last_msg"] = f"{msg} ({n}건 영향)"
            st.rerun()

    if f"{stage_key}_last_sql" in st.session_state:
        st.code(st.session_state[f"{stage_key}_last_sql"], language="sql")
        st.info(st.session_state.get(f"{stage_key}_last_msg", ""))

    summary = db.get_stage_anomaly_summary(stage_key)
    with st.expander("일관성 체크 상세", expanded=summary["has_data_issue"]):
        for skey in db.SCENARIO_KEYS:
            info = summary["scenarios"][skey]
            line = f"**{info['kind']} ({info['title']})** — {info['label']}: {info['detail']}"
            if info["level"] == "ok":
                st.success(line)
            elif info["level"] == "partial":
                st.warning(line)
            else:
                st.error(line)
        if summary["has_data_issue"]:
            st.markdown("**실제 데이터 문제**")
            for issue in summary["data_issues"]:
                st.warning(issue)


# ── 메인 ────────────────────────────────────────────────────────────────────

st.title("정규화 단계별 비교 — 학생·수강 DB")
st.markdown(
    "동일한 시나리오(학과 변경 · 교수 변경 · 수강 등록 · 수강 삭제)를 "
    "**비정규화 → 1NF → 2NF → 3NF** 테이블에 적용해 보세요. "
    "각 탭 상단에서 **이상 현상 존재 / 잔존 / 정상** 상태를 확인할 수 있습니다."
)

col_reset, col_info = st.columns([1, 4])
with col_reset:
    if st.button("전체 DB 초기화", type="secondary"):
        db.init_db()
        for key in list(st.session_state.keys()):
            if key.endswith("_last_sql") or key.endswith("_last_msg"):
                del st.session_state[key]
        st.success("초기 데이터로 복구했습니다.")
        st.rerun()

with col_info:
    st.caption(
        "초기 데이터 — 101 김민준(CS): CS301·CS302 수강 / 102 이서연(EE): CS301 수강"
    )

if "db_ready" not in st.session_state:
    db.init_db()
    st.session_state.db_ready = True

tab0, tab1, tab2, tab3 = st.tabs(["비정규화", "1NF", "2NF", "3NF"])

with tab0:
    render_stage("0nf")
with tab1:
    render_stage("1nf")
with tab2:
    render_stage("2nf")
with tab3:
    render_stage("3nf")

# ============================================================
# 파일: main.py
# 역할: 미니 프로젝트 2 - 클래스 + 모듈 연계 메인 파일
#
# 이 파일에서 불러오는 모듈:
#   - department.py (같은 폴더): 팀원/팀 클래스 정의
#   - company.py    (같은 폴더): 회사 전체 관리 클래스
#   - time (표준 라이브러리)  : 시각 처리
#
# 실행 방법:
#   $ python main.py
# ============================================================

# ── 같은 폴더의 모듈 불러오기 ──────────────────────────────
# company.py → company 모듈 전체를 불러옴
from company import Company

# department.py → 필요한 클래스만 선택적으로 불러옴
from department import (
    TeamMember,
    DevTeam,
    PlanningTeam,
    SalesTeam,
    AnalyticsTeam,
)

# ── 표준 라이브러리 ─────────────────────────────────────────
import time   # 공식 문서: https://docs.python.org/ko/3/library/time.html


# ── 헬퍼 함수 ───────────────────────────────────────────────

def section(title):
    """구분선과 제목을 출력하는 헬퍼 함수"""
    print(f"\n{'━' * 52}")
    print(f"  {title}")
    print(f"{'━' * 52}")


# ── 진입점 ─────────────────────────────────────────────────
# if __name__ == "__main__":
#   이 파일을 직접 실행할 때만 아래 블록이 실행됩니다.
#   다른 파일이 import main 해도 자동 실행되지 않습니다.

if __name__ == "__main__":

    # ─────────────────────────────────────────────────────────
    # Step 1. 팀원 채용 (TeamMember 인스턴스 생성)
    # ─────────────────────────────────────────────────────────
    section("Step 1. 팀원 채용")

    # 개발팀 팀원
    alice  = TeamMember("Alice",  "시니어 백엔드 개발자", 6500,
                        skills=["Python", "Django", "PostgreSQL", "Docker"])
    derek  = TeamMember("Derek",  "프론트엔드 개발자",   4800,
                        skills=["React", "TypeScript", "CSS"])
    eve    = TeamMember("Eve",    "주니어 백엔드 개발자", 3600,
                        skills=["Python", "FastAPI"])

    # 기획팀 팀원
    bob    = TeamMember.from_string("Bob:시니어 기획자:5200:서비스기획,UX,데이터분석")
    fiona  = TeamMember("Fiona",  "UX 디자이너",         4300,
                        skills=["Figma", "Prototyping", "User Research"])

    # 영업팀 팀원
    carol  = TeamMember("Carol",  "영업 팀장",           5800,
                        skills=["협상", "CRM", "프레젠테이션"])
    george = TeamMember("George", "영업 담당자",          3900,
                        skills=["B2B 영업", "제안서 작성"])

    # 분석팀 팀원
    helen  = TeamMember("Helen",  "데이터 사이언티스트", 5500,
                        skills=["Python", "ML", "Tableau"])
    ivan   = TeamMember("Ivan",   "데이터 분석가",        4200,
                        skills=["SQL", "BigQuery", "Excel"])

    print(f"\n  총 {TeamMember.get_total_members()}명 채용 완료!")

    # 연봉 유효성 검사 (정적 메서드 활용)
    print(f"\n  연봉 유효성 검사 (정적 메서드 TeamMember.is_valid_salary):")
    for m in [alice, bob, carol]:
        valid = TeamMember.is_valid_salary(m.salary)
        status = "O" if valid else "X"
        print(f"    {status} {m.name}: {m.salary:,}만원")

    # ─────────────────────────────────────────────────────────
    # Step 2. 팀(부서) 생성
    # ─────────────────────────────────────────────────────────
    section("Step 2. 팀(부서) 생성")

    dev_team       = DevTeam(budget=50000,  tech_stack=["Python", "React", "PostgreSQL", "Docker"])
    planning_team  = PlanningTeam(budget=20000)
    sales_team     = SalesTeam(budget=30000, monthly_target=100000)
    analytics_team = AnalyticsTeam(budget=25000, tools=["Python", "Tableau", "BigQuery", "SQL"])

    print("  4개 팀 생성 완료!")

    # ─────────────────────────────────────────────────────────
    # Step 3. 회사 설립 & 팀 등록
    # ─────────────────────────────────────────────────────────
    section("Step 3. 회사 설립 & 팀 등록")

    techcorp = Company("TechCorp Korea")
    techcorp.add_team(dev_team)
    techcorp.add_team(planning_team)
    techcorp.add_team(sales_team)
    techcorp.add_team(analytics_team)

    # ─────────────────────────────────────────────────────────
    # Step 4. 팀에 팀원 배정
    # ─────────────────────────────────────────────────────────
    section("Step 4. 팀원 배정")

    # 개발팀에 배정
    dev_team.add_member(alice)
    dev_team.add_member(derek)
    dev_team.add_member(eve)

    # 기획팀에 배정
    planning_team.add_member(bob)
    planning_team.add_member(fiona)

    # 영업팀에 배정
    sales_team.add_member(carol)
    sales_team.add_member(george)

    # 분석팀에 배정
    analytics_team.add_member(helen)
    analytics_team.add_member(ivan)

    # ─────────────────────────────────────────────────────────
    # Step 5. 각 팀 고유 업무 수행
    # ─────────────────────────────────────────────────────────
    section("Step 5. 팀별 업무 시작")

    print("\n  [개발팀 업무]")
    dev_team.show_tech_stack()
    dev_team.run_sprint("사용자 인증 기능 개발")
    dev_team.code_review("Alice", "Eve")

    print("\n  [기획팀 업무]")
    planning_team.start_planning("AI 기반 고객 추천 서비스")
    # 잠시 대기 (time.sleep 활용 예시 - 실제로는 0.1초만)
    # time.sleep: 지정한 초(초단위) 동안 프로그램 일시 정지
    # 공식 문서: https://docs.python.org/ko/3/library/time.html#time.sleep
    time.sleep(0.1)
    planning_team.complete_planning()
    planning_team.start_planning("모바일 앱 리뉴얼")

    print("\n  [영업팀 업무]")
    sales_team.close_deal(35000, "Carol")
    sales_team.close_deal(28000, "George")
    sales_team.close_deal(42000, "Carol")
    sales_team.show_deal_history()

    print("\n  [분석팀 업무]")
    analytics_team.publish_report("Q1 사용자 행동 분석 보고서", "Helen")
    analytics_team.publish_report("신규 기능 A/B 테스트 결과", "Ivan")
    analytics_team.publish_report("월간 KPI 대시보드", "Helen")

    # ─────────────────────────────────────────────────────────
    # Step 6. 팀 현황 확인
    # ─────────────────────────────────────────────────────────
    section("Step 6. 팀 현황 확인")

    for team in [dev_team, planning_team, sales_team, analytics_team]:
        team.show_members()

    # ─────────────────────────────────────────────────────────
    # Step 7. 전사 회의 (다형성 확인)
    # ─────────────────────────────────────────────────────────
    section("Step 7. 전사 회의 (다형성 - Polymorphism)")
    print("  ※ 같은 team_meeting() 호출이지만 팀마다 다르게 동작합니다.")

    techcorp.all_teams_meeting()

    # ─────────────────────────────────────────────────────────
    # Step 8. 회사 전체 보고서 출력
    # ─────────────────────────────────────────────────────────
    section("Step 8. 회사 전체 보고서")

    techcorp.company_report()

    # ─────────────────────────────────────────────────────────
    # Step 9. time 모듈 활용 - 재직 기간 & 입사 시각 확인
    # ─────────────────────────────────────────────────────────
    section("Step 9. time 모듈 활용: 입사 정보 확인")
    print("\n  팀원별 입사 정보:")
    for m in [alice, bob, carol, helen]:
        join_date = m.get_join_date_str()
        tenure    = m.get_tenure_days()
        print(f"    {m.name:8s} | 입사일시: {join_date} | 재직: {tenure}일")

    # ─────────────────────────────────────────────────────────
    # Step 10. 추가 시나리오: 연봉 인상 & 팀원 이동
    # ─────────────────────────────────────────────────────────
    section("Step 10. 연봉 인상 & 팀원 이동")

    print("\n  [연봉 인상]")
    old, new = alice.get_raise(500)
    print(f"  Alice 연봉: {old:,}만원 → {new:,}만원")
    old, new = carol.get_raise(300)
    print(f"  Carol 연봉: {old:,}만원 → {new:,}만원")

    print("\n  [팀원 이동: Eve → 분석팀으로 이동]")
    dev_team.remove_member("Eve")            # 개발팀에서 제거
    analytics_team.add_member(eve)           # 분석팀에 추가

    print(f"\n  개발팀 현재 인원: {len(dev_team)}명")
    print(f"  분석팀 현재 인원: {len(analytics_team)}명")

    # ─────────────────────────────────────────────────────────
    # Step 11. 최종 회사 상태 요약
    # ─────────────────────────────────────────────────────────
    section("Step 11. 최종 회사 상태")
    print(f"\n  {techcorp}")
    print(f"  회사 설립 후 경과: {techcorp.get_company_age_days()}일")
    highest = techcorp.get_highest_paid()
    print(f"  최고 연봉자: {highest.name} ({highest.salary:,}만원)")
    print(f"  전사 평균 연봉: {techcorp.get_average_salary():,}만원")

    print("\n\n  미니 프로젝트 2 실행 완료!")

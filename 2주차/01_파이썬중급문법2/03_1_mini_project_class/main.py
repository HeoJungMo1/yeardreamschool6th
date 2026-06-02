# ============================================================
# 파일: main.py
# 프로젝트: 03_1_mini_project_class
# 역할: TechCorp 대화형 HR 관리 프로그램
#
# 사용자가 터미널에서 직접 입력하여
# 팀원 채용 / 수정 / 이동 / 조회 / 영업 계약 등을
# while 루프 기반 메뉴로 운영합니다.
#
# 불러오는 모듈:
#   - department.py (같은 폴더): TeamMember, 각 팀 클래스
#   - company.py    (같은 폴더): Company 클래스
#
# 실행 방법:
#   $ python main.py
# ============================================================

# ── 같은 폴더 모듈 불러오기 ─────────────────────────────────
from department import (
    TeamMember,
    DevTeam,
    PlanningTeam,
    SalesTeam,
    AnalyticsTeam,
)
from company import Company


# ════════════════════════════════════════════════════════════
# 헬퍼 함수 모음
# ════════════════════════════════════════════════════════════

def divider(char="─", width=54):
    """구분선 출력"""
    print(char * width)

def header(title):
    """섹션 헤더 출력"""
    print()
    divider("═")
    print(f"  {title}")
    divider("═")

def sub_header(title):
    """서브 헤더 출력"""
    print(f"\n  ── {title} ──")

def input_int(prompt, min_val=None, max_val=None):
    """
    정수 입력을 받습니다.
    잘못된 값이 들어오면 다시 입력을 요청합니다.
    
    while 루프로 올바른 입력이 들어올 때까지 반복합니다.
    """
    while True:                                   # ← while 루프 ①: 유효 입력 반복
        try:
            val = int(input(prompt))
            if min_val is not None and val < min_val:
                print(f"  ! {min_val} 이상의 값을 입력하세요.")
                continue
            if max_val is not None and val > max_val:
                print(f"  ! {max_val} 이하의 값을 입력하세요.")
                continue
            return val
        except ValueError:
            print("  ! 숫자를 입력하세요.")

def input_str(prompt, allow_empty=False):
    """
    문자열 입력을 받습니다.
    빈 문자열을 허용하지 않는 경우 다시 입력을 요청합니다.
    
    while 루프로 빈 입력을 방지합니다.
    """
    while True:                                   # ← while 루프 ②: 빈 입력 방지
        val = input(prompt).strip()
        if val or allow_empty:
            return val
        print("  ! 값을 입력하세요.")

def choose_menu(options):
    """
    번호 메뉴를 출력하고 선택을 받습니다.
    
    매개변수:
        options (list[str]): 메뉴 항목 목록
    반환값:
        int: 선택된 번호 (1-based)
    """
    for i, opt in enumerate(options, 1):
        print(f"    [{i}] {opt}")
    return input_int("  선택 > ", min_val=1, max_val=len(options))

def pick_team(company):
    """
    회사에 등록된 팀 목록을 보여주고 선택받습니다.
    반환값: 선택된 팀 인스턴스 (없으면 None)
    """
    teams = list(company.teams.values())
    if not teams:
        print("  ! 등록된 팀이 없습니다.")
        return None
    print()
    for i, t in enumerate(teams, 1):
        print(f"    [{i}] {t.team_name}  ({len(t)}명)")
    idx = input_int("  팀 선택 > ", min_val=1, max_val=len(teams))
    return teams[idx - 1]

def pick_member_from_team(team):
    """
    팀 내 팀원 목록을 보여주고 선택받습니다.
    반환값: 선택된 TeamMember 인스턴스 (없으면 None)
    """
    if not team.members:
        print(f"  ! {team.team_name}에 팀원이 없습니다.")
        return None
    print()
    for i, m in enumerate(team.members, 1):
        print(f"    [{i}] {m.name}  ({m.role}, {m.salary:,}만원)")
    idx = input_int("  팀원 선택 > ", min_val=1, max_val=len(team.members))
    return team.members[idx - 1]

def pick_any_member(company):
    """
    전사 팀원 중에서 선택받습니다.
    반환값: (팀, 팀원) 튜플 또는 (None, None)
    """
    all_members = []
    for team in company.teams.values():
        for m in team.members:
            all_members.append((team, m))

    if not all_members:
        print("  ! 등록된 팀원이 없습니다.")
        return None, None

    print()
    for i, (team, m) in enumerate(all_members, 1):
        print(f"    [{i}] {m.name}  [{team.team_name}]  {m.role}  {m.salary:,}만원")

    idx = input_int("  팀원 선택 > ", min_val=1, max_val=len(all_members))
    return all_members[idx - 1]


# ════════════════════════════════════════════════════════════
# 메뉴별 기능 함수
# ════════════════════════════════════════════════════════════

# ── 1. 팀원 채용 ─────────────────────────────────────────────
def hire_member(company):
    """새 팀원을 채용하고 팀에 배정합니다."""
    header("팀원 채용")

    # 이름 / 직책 / 연봉 입력
    name = input_str("  이름       > ")
    role = input_str("  직책       > ")

    while True:                                   # ← while 루프 ③: 연봉 유효성 검사
        salary = input_int("  연봉(만원)  > ", min_val=1)
        if TeamMember.is_valid_salary(salary):
            break
        print(f"  ! 유효 범위(1,000 ~ 50,000만원)를 벗어났습니다. 다시 입력하세요.")

    skills_raw = input_str("  보유 기술 (쉼표 구분, 없으면 Enter) > ", allow_empty=True)
    skills = [s.strip() for s in skills_raw.split(",") if s.strip()]

    # TeamMember 인스턴스 생성
    new_member = TeamMember(name, role, salary, skills)
    print(f"\n  채용 완료: {new_member}")

    # 팀 배정
    sub_header("배정할 팀을 선택하세요")
    team = pick_team(company)
    if team:
        team.add_member(new_member)


# ── 2. 팀원 정보 수정 ────────────────────────────────────────
def edit_member(company):
    """팀원의 직책 또는 연봉을 수정합니다."""
    header("팀원 정보 수정")

    sub_header("수정할 팀원을 선택하세요")
    team, member = pick_any_member(company)
    if not member:
        return

    print(f"\n  현재 정보: {member}")
    print()

    # 수정할 항목 선택
    choice = choose_menu(["직책 변경", "연봉 인상", "기술 추가", "돌아가기"])

    if choice == 1:
        new_role = input_str("  새 직책 > ")
        member.role = new_role
        print(f"  직책이 '{new_role}'(으)로 변경되었습니다.")

    elif choice == 2:
        amount = input_int("  인상 금액(만원) > ", min_val=1)
        old, new = member.get_raise(amount)
        print(f"  연봉: {old:,}만원  →  {new:,}만원  (+{amount:,}만원)")

    elif choice == 3:
        new_skill = input_str("  추가할 기술 > ")
        if new_skill in member.skills:
            print(f"  ! '{new_skill}'은(는) 이미 등록된 기술입니다.")
        else:
            member.skills.append(new_skill)
            print(f"  '{new_skill}' 기술이 추가되었습니다.")

    else:
        print("  취소했습니다.")


# ── 3. 팀원 이동 ─────────────────────────────────────────────
def transfer_member(company):
    """팀원을 다른 팀으로 이동시킵니다."""
    header("팀원 이동")

    sub_header("이동시킬 팀원을 선택하세요")
    src_team, member = pick_any_member(company)
    if not member:
        return

    sub_header(f"'{member.name}'님을 이동시킬 팀을 선택하세요")
    dst_team = pick_team(company)
    if not dst_team:
        return

    if dst_team is src_team:
        print("  ! 현재 소속 팀과 동일합니다.")
        return

    src_team.remove_member(member.name)
    dst_team.add_member(member)
    print(f"\n  {member.name}님: {src_team.team_name}  →  {dst_team.team_name}")


# ── 4. 팀원 퇴사 ─────────────────────────────────────────────
def fire_member(company):
    """팀원을 퇴사 처리합니다."""
    header("팀원 퇴사 처리")

    sub_header("퇴사할 팀원을 선택하세요")
    team, member = pick_any_member(company)
    if not member:
        return

    confirm = input_str(f"  정말로 '{member.name}'님을 퇴사 처리하겠습니까? (yes / no) > ",
                        allow_empty=True)
    if confirm.lower() == "yes":
        team.remove_member(member.name)
        print(f"  {member.name}님 퇴사 처리 완료.")
    else:
        print("  취소했습니다.")


# ── 5. 팀 현황 조회 ──────────────────────────────────────────
def view_teams(company):
    """팀별 구성원 현황을 조회합니다."""
    header("팀 현황 조회")

    choice = choose_menu(["전체 팀 조회", "특정 팀 조회"])

    if choice == 1:
        for team in company.teams.values():
            team.show_members()
    else:
        sub_header("조회할 팀을 선택하세요")
        team = pick_team(company)
        if team:
            team.show_members()


# ── 6. 팀원 상세 조회 ────────────────────────────────────────
def view_member_detail(company):
    """특정 팀원의 상세 정보를 조회합니다."""
    header("팀원 상세 조회")

    sub_header("조회할 팀원을 선택하세요")
    team, member = pick_any_member(company)
    if not member:
        return

    print()
    divider()
    print(f"  이름     : {member.name}")
    print(f"  소속     : {team.team_name}")
    print(f"  직책     : {member.role}")
    print(f"  연봉     : {member.salary:,}만원")
    print(f"  기술     : {', '.join(member.skills) if member.skills else '없음'}")
    print(f"  입사일시  : {member.get_join_date_str()}")
    print(f"  재직 기간 : {member.get_tenure_days()}일")
    divider()


# ── 7. 영업 계약 성사 ────────────────────────────────────────
def record_deal(company):
    """영업팀 계약 성사를 기록합니다."""
    header("영업 계약 성사 기록")

    # 회사 내 영업팀 찾기
    sales_team = company.get_team("영업팀")
    if not sales_team:
        print("  ! 영업팀이 존재하지 않습니다.")
        return
    if not sales_team.members:
        print("  ! 영업팀에 팀원이 없습니다.")
        return

    # 계약 담당자 선택
    sub_header("계약 담당자를 선택하세요")
    member = pick_member_from_team(sales_team)
    if not member:
        return

    amount = input_int("  계약 금액(만원) > ", min_val=1)
    sales_team.close_deal(amount, member.name)


# ── 8. 영업 현황 조회 ────────────────────────────────────────
def view_sales(company):
    """영업팀 계약 내역과 달성률을 조회합니다."""
    header("영업 현황 조회")

    sales_team = company.get_team("영업팀")
    if not sales_team:
        print("  ! 영업팀이 존재하지 않습니다.")
        return

    rate   = sales_team.get_achievement_rate()
    status = "목표 초과!" if rate >= 100 else ("순항 중" if rate >= 70 else "분발 필요")

    print(f"\n  월 목표  : {sales_team.monthly_target:,}만원")
    print(f"  달성액  : {sales_team.monthly_achievement:,}만원")
    print(f"  달성률  : {rate:.1f}%  ({status})")
    sales_team.show_deal_history()


# ── 9. 전사 회의 ─────────────────────────────────────────────
def all_meeting(company):
    """전사 회의를 진행합니다. (다형성 확인)"""
    header("전사 회의")
    print("  ※ 같은 team_meeting() 메서드를 호출하지만 팀마다 다르게 동작합니다.\n")
    company.all_teams_meeting()


# ── 10. 회사 보고서 ──────────────────────────────────────────
def company_report(company):
    """회사 전체 현황 보고서를 출력합니다."""
    header("회사 전체 보고서")
    company.company_report()


# ════════════════════════════════════════════════════════════
# 초기 데이터 세팅
# ════════════════════════════════════════════════════════════

def setup_initial_data():
    """
    프로그램 시작 시 기본 팀과 팀원을 세팅합니다.
    실제 서비스라면 DB나 파일에서 불러오는 부분입니다.
    """
    # 회사 설립
    company = Company("TechCorp Korea")

    # 4개 팀 생성
    dev_team       = DevTeam(budget=50000, tech_stack=["Python", "React", "PostgreSQL", "Docker"])
    planning_team  = PlanningTeam(budget=20000)
    sales_team     = SalesTeam(budget=30000, monthly_target=100000)
    analytics_team = AnalyticsTeam(budget=25000, tools=["Python", "Tableau", "BigQuery"])

    company.add_team(dev_team)
    company.add_team(planning_team)
    company.add_team(sales_team)
    company.add_team(analytics_team)

    # 초기 팀원 등록
    members_data = [
        # (이름, 직책, 연봉, 기술, 소속팀)
        ("Alice",  "시니어 백엔드 개발자", 6500, ["Python", "Django", "Docker"],     dev_team),
        ("Derek",  "프론트엔드 개발자",   4800, ["React", "TypeScript"],             dev_team),
        ("Bob",    "시니어 기획자",       5200, ["서비스기획", "UX"],                  planning_team),
        ("Carol",  "영업 팀장",           5800, ["협상", "CRM"],                      sales_team),
        ("George", "영업 담당자",          3900, ["B2B 영업"],                         sales_team),
        ("Helen",  "데이터 사이언티스트", 5500, ["Python", "ML", "Tableau"],          analytics_team),
    ]

    for name, role, salary, skills, team in members_data:
        m = TeamMember(name, role, salary, skills)
        team.add_member(m)

    return company


# ════════════════════════════════════════════════════════════
# 메인 메뉴 & 실행 루프
# ════════════════════════════════════════════════════════════

MAIN_MENU = [
    "팀원 채용",           # 1
    "팀원 정보 수정",      # 2
    "팀원 이동",           # 3
    "팀원 퇴사 처리",      # 4
    "팀 현황 조회",        # 5
    "팀원 상세 조회",      # 6
    "영업 계약 성사 기록", # 7
    "영업 현황 조회",      # 8
    "전사 회의",           # 9
    "회사 보고서",         # 10
    "프로그램 종료",       # 11
]

# 메뉴 번호 → 실행 함수 매핑 (딕셔너리)
MENU_ACTIONS = {
    1:  hire_member,
    2:  edit_member,
    3:  transfer_member,
    4:  fire_member,
    5:  view_teams,
    6:  view_member_detail,
    7:  record_deal,
    8:  view_sales,
    9:  all_meeting,
    10: company_report,
}


def main():
    """
    프로그램 진입점.
    while 루프로 사용자가 '종료'를 선택하기 전까지 메뉴를 반복합니다.
    """
    print()
    divider("═")
    print("  TechCorp Korea  HR 관리 시스템")
    print("  초기 데이터를 불러오는 중...")
    divider("═")

    # 초기 데이터 세팅
    company = setup_initial_data()
    print("\n  준비 완료! 메뉴를 선택하세요.")

    # ── 메인 루프 ────────────────────────────────────────────
    # while True: 사용자가 '종료'를 선택할 때까지 메뉴를 반복합니다.
    while True:                                   # ← while 루프 ④: 메인 루프
        header("메인 메뉴")
        for i, name in enumerate(MAIN_MENU, 1):
            print(f"    [{i:2}] {name}")

        choice = input_int("\n  메뉴 선택 > ", min_val=1, max_val=len(MAIN_MENU))

        # 종료
        if choice == len(MAIN_MENU):
            print("\n  프로그램을 종료합니다. 수고하셨습니다!\n")
            break                                 # ← while 루프 탈출

        # 해당 메뉴 함수 실행
        action = MENU_ACTIONS.get(choice)
        if action:
            action(company)

        # 계속하려면 Enter
        input("\n  [Enter]를 누르면 메인 메뉴로 돌아갑니다...")


if __name__ == "__main__":
    main()

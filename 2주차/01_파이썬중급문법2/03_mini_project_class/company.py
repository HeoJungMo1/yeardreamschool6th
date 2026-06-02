# ============================================================
# 파일: company.py
# 역할: IT 회사 전체를 관리하는 Company 클래스 모듈
#
# 이 모듈은 department.py에서 정의한 클래스들을 불러와 사용합니다.
# → department.py (같은 폴더)
#
# 공식 문서:
#   time  모듈: https://docs.python.org/ko/3/library/time.html
#   math  모듈: https://docs.python.org/ko/3/library/math.html
# ============================================================

# ── 같은 폴더의 department.py에서 클래스 불러오기 ──────────
# department.py에서 정의한 모든 팀 클래스와 팀원 클래스를 가져옵니다.
from department import (
    TeamMember,
    DevTeam,
    PlanningTeam,
    SalesTeam,
    AnalyticsTeam,
)

# ── 표준 라이브러리 불러오기 ─────────────────────────────────
import time   # 공식 문서: https://docs.python.org/ko/3/library/time.html
import math   # 공식 문서: https://docs.python.org/ko/3/library/math.html


# ────────────────────────────────────────────────────────────
# Company 클래스
# ────────────────────────────────────────────────────────────

class Company:
    """
    IT 회사 전체를 표현하는 클래스.
    여러 팀(Department 인스턴스)을 관리합니다.
    
    속성:
        name       (str)  : 회사 이름
        founded_at (float): 설립 시각 (Unix timestamp)
        teams      (dict) : 팀 이름 → Department 인스턴스 매핑
    """
    
    def __init__(self, name):
        self.name       = name
        self.founded_at = time.time()   # 회사 설립 시각 기록
        self.teams      = {}            # { "개발팀": DevTeam(...), ... }
    
    # ── 팀 관리 ─────────────────────────────────────────────
    
    def add_team(self, team):
        """
        회사에 팀을 추가합니다.
        
        매개변수:
            team (Department 또는 자식 클래스): 추가할 팀 인스턴스
        """
        self.teams[team.team_name] = team
        print(f"  [{self.name}] '{team.team_name}' 팀이 추가되었습니다.")
    
    def get_team(self, team_name):
        """
        팀 이름으로 팀 인스턴스를 반환합니다.
        없으면 None을 반환합니다.
        """
        return self.teams.get(team_name, None)
    
    # ── 전사 통계 ────────────────────────────────────────────
    
    def get_total_headcount(self):
        """전 직원 수 반환"""
        return sum(len(team) for team in self.teams.values())
    
    def get_all_members(self):
        """전 직원 목록(TeamMember 리스트) 반환"""
        all_members = []
        for team in self.teams.values():
            all_members.extend(team.members)
        return all_members
    
    def get_total_salary_budget(self):
        """전사 연봉 총액 반환 (만원)"""
        return sum(team.get_total_salary() for team in self.teams.values())
    
    def get_average_salary(self):
        """
        전사 평균 연봉 반환 (만원).
        math.floor로 소수점 이하 버림.
        """
        total_headcount = self.get_total_headcount()
        if total_headcount == 0:
            return 0
        avg = self.get_total_salary_budget() / total_headcount
        return math.floor(avg)
    
    def get_highest_paid(self):
        """
        전사에서 연봉이 가장 높은 직원 반환.
        파이썬 내장 max() + lambda 활용.
        """
        all_members = self.get_all_members()
        if not all_members:
            return None
        return max(all_members, key=lambda m: m.salary)
    
    def get_company_age_days(self):
        """
        회사 설립 후 경과 일수 반환.
        time.time()과 math.floor 활용.
        """
        elapsed_sec  = time.time() - self.founded_at
        elapsed_days = math.floor(elapsed_sec / 86400)
        return elapsed_days
    
    # ── 전사 보고 ────────────────────────────────────────────
    
    def company_report(self):
        """
        회사 전체 현황 보고서를 출력합니다.
        """
        founded_str = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(self.founded_at))
        
        print()
        print("  ╔══════════════════════════════════════════════╗")
        print(f"  ║  {self.name:^44}║")
        print("  ╠══════════════════════════════════════════════╣")
        print(f"  ║  설립일시  : {founded_str:<32}║")
        print(f"  ║  전체 팀 수: {len(self.teams):<32}║")
        print(f"  ║  전체 직원 : {self.get_total_headcount():,}명{'':<27}║")
        print(f"  ║  연봉 총액 : {self.get_total_salary_budget():,}만원{'':<25}║")
        print(f"  ║  평균 연봉 : {self.get_average_salary():,}만원{'':<25}║")
        
        highest = self.get_highest_paid()
        if highest:
            print(f"  ║  최고 연봉 : {highest.name} ({highest.role}) {highest.salary:,}만원{'':^5}║")
        
        print("  ╠══════════════════════════════════════════════╣")
        print("  ║  팀별 현황                                   ║")
        print("  ╠══════════════════════════════════════════════╣")
        
        for team_name, team in self.teams.items():
            avg = team.get_average_salary()
            print(f"  ║  {team_name:<8} | {len(team):2}명 | "
                  f"평균연봉 {avg:,}만원{'':<8}║")
        
        print("  ╚══════════════════════════════════════════════╝")
    
    def all_teams_meeting(self):
        """
        전사 회의: 모든 팀의 team_meeting()을 순서대로 호출합니다.
        → 다형성(Polymorphism) 예시: 같은 메서드 이름, 팀마다 다른 동작
        """
        print(f"\n  [{self.name}] 전사 회의 시작!")
        print(f"  {'─' * 48}")
        for team in self.teams.values():
            team.team_meeting()
        print(f"  {'─' * 48}")
        print(f"  [{self.name}] 전사 회의 종료.")
    
    def __str__(self):
        return f"{self.name} (팀 {len(self.teams)}개, 직원 {self.get_total_headcount()}명)"
    
    def __repr__(self):
        return f"Company(name='{self.name}')"

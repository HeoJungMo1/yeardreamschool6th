# ============================================================
# 파일: department.py
# 역할: IT 회사 부서(팀)와 팀원 클래스 정의 모듈
#
# 이 모듈에서 제공하는 클래스:
#   - TeamMember   : 팀원 기본 클래스
#   - Department   : 부서(팀) 기본 클래스
#   - DevTeam      : 개발팀 (Department 상속)
#   - PlanningTeam : 기획팀 (Department 상속)
#   - SalesTeam    : 영업팀 (Department 상속)
#   - AnalyticsTeam: 분석팀 (Department 상속)
#
# 사용 예:
#   from department import TeamMember, DevTeam
#   alice = TeamMember("Alice", "시니어 개발자", 6000)
#   dev   = DevTeam(budget=50000, tech_stack=["Python"])
#   dev.add_member(alice)
# ============================================================

# time 모듈 활용: 입사일 기록, 재직 기간 계산 등
# 공식 문서: https://docs.python.org/ko/3/library/time.html
import time

# math 모듈 활용: 연봉 통계 계산
# 공식 문서: https://docs.python.org/ko/3/library/math.html
import math


# ────────────────────────────────────────────────────────────
# 1. TeamMember 클래스
# ────────────────────────────────────────────────────────────

class TeamMember:
    """
    IT 회사 팀원을 표현하는 클래스.
    
    속성:
        name         (str)  : 팀원 이름
        role         (str)  : 직책
        salary       (int)  : 연봉 (만원)
        join_time    (float): 입사 시각 (time.time() 값, Unix timestamp)
        projects     (list) : 참여 중인 프로젝트 목록
        skills       (list) : 보유 기술 목록
    """
    
    # 클래스 변수: 모든 TeamMember 인스턴스가 공유
    company_name  = "TechCorp"
    total_members = 0
    
    def __init__(self, name, role, salary, skills=None):
        # 인스턴스 변수
        self.name      = name
        self.role      = role
        self.salary    = salary
        self.projects  = []
        self.skills    = skills if skills else []
        
        # time.time(): 현재 시각을 Unix timestamp(초 단위 실수)로 반환
        # 공식 문서: https://docs.python.org/ko/3/library/time.html#time.time
        self.join_time = time.time()
        
        # 팀원 생성 시 클래스 변수 업데이트
        TeamMember.total_members += 1
    
    # ── 인스턴스 메서드 ──────────────────────────────────────
    
    def introduce(self):
        """자기소개 출력"""
        skill_str = ", ".join(self.skills) if self.skills else "없음"
        print(f"  안녕하세요! [{self.company_name}] {self.role} {self.name}입니다.")
        print(f"  보유 기술: {skill_str} | 연봉: {self.salary:,}만원")
    
    def join_project(self, project_name):
        """프로젝트 참여"""
        self.projects.append(project_name)
    
    def leave_project(self, project_name):
        """프로젝트 탈퇴"""
        if project_name in self.projects:
            self.projects.remove(project_name)
    
    def get_raise(self, amount):
        """
        연봉 인상.
        
        매개변수:
            amount (int): 인상 금액 (만원)
        """
        old_salary = self.salary
        self.salary += amount
        return old_salary, self.salary
    
    def get_tenure_days(self):
        """
        재직 기간(일)을 반환합니다.
        
        time.time()으로 현재 시각을 구하고, 입사 시각과의 차이를 계산합니다.
        공식 문서: https://docs.python.org/ko/3/library/time.html#time.time
        """
        elapsed_seconds = time.time() - self.join_time
        # 초 → 일 변환: 1일 = 86400초
        elapsed_days = elapsed_seconds / 86400
        # math.floor: 소수점 이하 버림
        return math.floor(elapsed_days)
    
    def get_join_date_str(self):
        """
        입사 날짜를 'YYYY-MM-DD HH:MM:SS' 형식 문자열로 반환합니다.
        
        time.localtime(): Unix timestamp → 로컬 시간 구조체
        time.strftime() : 시간 구조체 → 형식 문자열
        공식 문서: https://docs.python.org/ko/3/library/time.html#time.strftime
        """
        local_time = time.localtime(self.join_time)
        return time.strftime("%Y-%m-%d %H:%M:%S", local_time)
    
    # ── 클래스 메서드 ────────────────────────────────────────
    
    @classmethod
    def get_total_members(cls):
        """지금까지 생성된 전체 팀원 수 반환"""
        return cls.total_members
    
    @classmethod
    def from_string(cls, info_string):
        """
        '이름:직책:연봉:기술1,기술2' 형식 문자열로 팀원을 생성합니다.
        
        예시:
            TeamMember.from_string("Alice:시니어 개발자:6000:Python,Django")
        """
        parts  = info_string.split(":")
        name   = parts[0]
        role   = parts[1]
        salary = int(parts[2])
        skills = parts[3].split(",") if len(parts) > 3 else []
        return cls(name, role, salary, skills)
    
    # ── 정적 메서드 ──────────────────────────────────────────
    
    @staticmethod
    def is_valid_salary(salary):
        """연봉이 합리적인 범위(1000~50000만원)인지 검사"""
        return 1000 <= salary <= 50000
    
    # ── 매직 메서드 ──────────────────────────────────────────
    
    def __str__(self):
        return f"{self.role} {self.name} (연봉 {self.salary:,}만원)"
    
    def __repr__(self):
        return (f"TeamMember(name='{self.name}', role='{self.role}', "
                f"salary={self.salary})")
    
    def __eq__(self, other):
        """같은 이름과 직책이면 같은 팀원으로 간주"""
        if isinstance(other, TeamMember):
            return self.name == other.name and self.role == other.role
        return False


# ────────────────────────────────────────────────────────────
# 2. Department 기본 클래스 (부모)
# ────────────────────────────────────────────────────────────

class Department:
    """
    IT 회사 부서(팀)를 표현하는 기본(부모) 클래스.
    
    속성:
        team_name  (str)  : 팀 이름
        budget     (int)  : 팀 예산 (만원)
        members    (list) : 팀원 목록 (TeamMember 인스턴스)
        created_at (float): 팀 생성 시각 (Unix timestamp)
    """
    
    def __init__(self, team_name, budget):
        self.team_name  = team_name
        self.budget     = budget
        self.members    = []
        self.created_at = time.time()   # 팀 생성 시각 기록
    
    # ── 팀원 관리 ────────────────────────────────────────────
    
    def add_member(self, member):
        """팀원 추가. 이미 있으면 추가하지 않습니다."""
        if member not in self.members:
            self.members.append(member)
            print(f"  [{self.team_name}] | {member.name}({member.role}) 합류")
        else:
            print(f"  [{self.team_name}] | {member.name}님은 이미 팀원입니다.")
    
    def remove_member(self, name):
        """이름으로 팀원 제거"""
        for member in self.members:
            if member.name == name:
                self.members.remove(member)
                print(f"  [{self.team_name}] | {name}님이 퇴팀했습니다.")
                return
        print(f"  [{self.team_name}] '{name}'님을 찾을 수 없습니다.")
    
    def find_member(self, name):
        """이름으로 팀원 검색. 없으면 None 반환."""
        for member in self.members:
            if member.name == name:
                return member
        return None
    
    # ── 팀 통계 ─────────────────────────────────────────────
    
    def get_total_salary(self):
        """팀 전체 연봉 합계"""
        return sum(m.salary for m in self.members)
    
    def get_average_salary(self):
        """
        팀 평균 연봉 반환.
        math.floor를 이용하여 정수로 내림합니다.
        """
        if not self.members:
            return 0
        avg = self.get_total_salary() / len(self.members)
        return math.floor(avg)
    
    def get_max_salary_member(self):
        """연봉이 가장 높은 팀원 반환"""
        if not self.members:
            return None
        return max(self.members, key=lambda m: m.salary)
    
    # ── 팀 정보 출력 ─────────────────────────────────────────
    
    def show_members(self):
        """팀 구성원 목록 출력"""
        print(f"\n  ┌─ {self.team_name} ({len(self.members)}명) ─────────────────")
        if not self.members:
            print("  │  (팀원 없음)")
        for i, m in enumerate(self.members, 1):
            skill_str = ", ".join(m.skills[:3]) if m.skills else "-"
            print(f"  │  {i}. {m.role}: {m.name} | 연봉: {m.salary:,}만원 | 기술: {skill_str}")
        print(f"  │  연봉 합계: {self.get_total_salary():,}만원 | 평균: {self.get_average_salary():,}만원")
        print("  └─────────────────────────────────────────")
    
    def team_meeting(self):
        """
        팀 회의 진행. 자식 클래스에서 오버라이딩하여 각 팀에 맞게 재정의합니다.
        """
        print(f"  [{self.team_name}] | 정기 팀 미팅을 시작합니다.")
    
    def __str__(self):
        return f"{self.team_name} (팀원 {len(self.members)}명, 예산 {self.budget:,}만원)"
    
    def __repr__(self):
        return f"Department(team_name='{self.team_name}', budget={self.budget})"
    
    def __len__(self):
        """len(team) 호출 시 팀원 수를 반환"""
        return len(self.members)


# ────────────────────────────────────────────────────────────
# 3. 자식 클래스들: 각 팀별 특화 기능 추가
# ────────────────────────────────────────────────────────────

class DevTeam(Department):
    """
    개발팀 클래스. Department를 상속합니다.
    
    추가 속성:
        tech_stack    (list): 사용 기술 스택
        sprint_count  (int) : 진행된 스프린트 횟수
    """
    
    def __init__(self, budget, tech_stack):
        super().__init__("개발팀", budget)        # 부모 __init__ 호출
        self.tech_stack   = tech_stack
        self.sprint_count = 0
    
    def run_sprint(self, sprint_name):
        """스프린트 진행"""
        self.sprint_count += 1
        members_str = ", ".join(m.name for m in self.members)
        print(f"  [개발팀] | 스프린트 #{self.sprint_count} '{sprint_name}' 시작 (참여: {members_str})")
    
    def code_review(self, reviewer_name, reviewee_name):
        """코드 리뷰 기록"""
        reviewer = self.find_member(reviewer_name)
        reviewee = self.find_member(reviewee_name)
        if reviewer and reviewee:
            print(f"  [개발팀] 코드 리뷰: {reviewer.name} → {reviewee.name}")
        else:
            print("  [개발팀] 해당 팀원을 찾을 수 없습니다.")
    
    def show_tech_stack(self):
        """기술 스택 출력"""
        print(f"  [개발팀] |  기술 스택: {' | '.join(self.tech_stack)}")
    
    def team_meeting(self):
        """스프린트 계획 회의 (오버라이딩)"""
        print(f"  [개발팀] | 스프린트 계획 회의 | 누적 스프린트: {self.sprint_count}회")
        self.show_tech_stack()


class PlanningTeam(Department):
    """
    기획팀 클래스. Department를 상속합니다.
    
    추가 속성:
        current_plan  (str) : 현재 기획 중인 서비스명
        completed_plans(list): 완료된 기획 목록
    """
    
    def __init__(self, budget):
        super().__init__("기획팀", budget)
        self.current_plan    = None
        self.completed_plans = []
    
    def start_planning(self, service_name):
        """새 서비스 기획 시작"""
        self.current_plan = service_name
        print(f"  [기획팀] | '{service_name}' 기획 시작")
    
    def complete_planning(self):
        """기획 완료"""
        if self.current_plan:
            self.completed_plans.append(self.current_plan)
            print(f"  [기획팀] | '{self.current_plan}' 기획 완료! (총 {len(self.completed_plans)}건)")
            self.current_plan = None
        else:
            print("  [기획팀] 현재 진행 중인 기획이 없습니다.")
    
    def team_meeting(self):
        """기획 검토 회의 (오버라이딩)"""
        plan_info = f"현재 기획: {self.current_plan}" if self.current_plan else "진행 중인 기획 없음"
        print(f"  [기획팀] | 기획 검토 회의 | {plan_info} | 완료: {len(self.completed_plans)}건")


class SalesTeam(Department):
    """
    영업팀 클래스. Department를 상속합니다.
    
    추가 속성:
        monthly_target      (int): 월 매출 목표 (만원)
        monthly_achievement (int): 이번 달 매출 달성액 (만원)
        deal_history        (list): 계약 내역 [(금액, 담당자, 시각), ...]
    """
    
    def __init__(self, budget, monthly_target):
        super().__init__("영업팀", budget)
        self.monthly_target      = monthly_target
        self.monthly_achievement = 0
        self.deal_history        = []
    
    def close_deal(self, amount, member_name):
        """
        계약 성사 기록.
        
        time.strftime + time.localtime으로 거래 시각을 기록합니다.
        공식 문서: https://docs.python.org/ko/3/library/time.html
        """
        self.monthly_achievement += amount
        # 현재 시각을 읽기 좋은 문자열로 변환
        deal_time = time.strftime("%Y-%m-%d %H:%M", time.localtime())
        self.deal_history.append((amount, member_name, deal_time))
        
        rate = (self.monthly_achievement / self.monthly_target) * 100
        print(f"  [영업팀] | 계약 성사! {member_name} +{amount:,}만원 (달성률: {rate:.1f}%)")
    
    def get_achievement_rate(self):
        """달성률(%)을 반환"""
        return (self.monthly_achievement / self.monthly_target) * 100
    
    def show_deal_history(self):
        """계약 내역 출력"""
        print(f"  [영업팀] | 계약 내역 (총 {len(self.deal_history)}건, {self.monthly_achievement:,}만원)")
        for amount, member, t in self.deal_history:
            print(f"           • {t} | {member} | {amount:,}만원")
    
    def team_meeting(self):
        """영업 현황 회의 (오버라이딩)"""
        rate = self.get_achievement_rate()
        status = " 목표 초과" if rate >= 100 else (" 순항 중" if rate >= 70 else " 분발 필요")
        print(f"  [영업팀] | 영업 현황 회의 | 목표 {self.monthly_target:,}만원 | "
              f"달성 {self.monthly_achievement:,}만원 ({rate:.1f}%) {status}")


class AnalyticsTeam(Department):
    """
    분석팀 클래스. Department를 상속합니다.
    
    추가 속성:
        tools   (list): 사용 분석 도구
        reports (list): 발행된 분석 보고서 목록
    """
    
    def __init__(self, budget, tools):
        super().__init__("분석팀", budget)
        self.tools   = tools
        self.reports = []
    
    def publish_report(self, report_name, author_name):
        """분석 보고서 발행"""
        publish_time = time.strftime("%Y-%m-%d", time.localtime())
        self.reports.append({"title": report_name, "author": author_name, "date": publish_time})
        print(f"  [분석팀] 보고서 발행: '{report_name}' (작성: {author_name}, {publish_time})")
    
    def get_report_count(self):
        """발행된 보고서 수 반환"""
        return len(self.reports)
    
    def team_meeting(self):
        """데이터 리뷰 회의 (오버라이딩)"""
        print(f"  [분석팀] 데이터 리뷰 회의 | 도구: {', '.join(self.tools)} | "
              f"발행 보고서: {len(self.reports)}건")

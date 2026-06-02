# ============================================================
# 파일: calculator.py
# 역할: 기본 사칙연산 및 수학 유틸리티 함수 모음 모듈
#
# 강의 슬라이드 "모듈 만들기" 예제 확장판
# 사용 방법:
#   import calculator
#   calculator.add(3, 4)  →  7
#
#   또는
#   from calculator import add
#   add(3, 4)  →  7
# ============================================================

# 내장 math 모듈 활용
import math

# ── 모듈 수준 변수 (Module-level Variable) ──────────────────
# 이 모듈이 다루는 도구명
MODULE_NAME = "BasicCalculator"
VERSION     = "1.0.0"


# ── 기본 사칙연산 함수 ──────────────────────────────────────

def add(a, b):
    """
    두 수를 더한 결과를 반환합니다.
    
    매개변수:
        a (int | float): 첫 번째 피연산자
        b (int | float): 두 번째 피연산자
    반환값:
        int | float: a + b
    
    예시:
        >>> add(3, 4)
        7
        >>> add(2.5, 1.5)
        4.0
    """
    return a + b


def sub(a, b):
    """두 수를 뺀 결과를 반환합니다 (a - b)."""
    return a - b


def mul(a, b):
    """두 수를 곱한 결과를 반환합니다."""
    return a * b


def div(a, b):
    """
    두 수를 나눈 결과를 반환합니다 (a / b).
    
    주의:
        b가 0이면 ZeroDivisionError 대신 None을 반환합니다.
    """
    if b == 0:
        print("[경고] 0으로 나눌 수 없습니다. None을 반환합니다.")
        return None
    return a / b


def floor_div(a, b):
    """두 수를 나눈 몫(정수 부분)을 반환합니다 (a // b)."""
    if b == 0:
        print("[경고] 0으로 나눌 수 없습니다.")
        return None
    return a // b


def mod(a, b):
    """두 수를 나눈 나머지를 반환합니다 (a % b)."""
    if b == 0:
        print("[경고] 0으로 나눌 수 없습니다.")
        return None
    return a % b


def power(base, exponent):
    """
    거듭제곱 결과를 반환합니다 (base ** exponent).
    
    예시:
        >>> power(2, 10)
        1024
    """
    return base ** exponent


# ── math 모듈을 활용한 추가 기능 ────────────────────────────

def square_root(n):
    """
    n의 제곱근을 반환합니다. (내장 math 모듈의 math.sqrt 활용)
    
    공식 문서: https://docs.python.org/ko/3/library/math.html#math.sqrt
    
    매개변수:
        n (int | float): 제곱근을 구할 수 (음수 불가)
    반환값:
        float: √n
    예시:
        >>> square_root(9)
        3.0
        >>> square_root(2)
        1.4142135623730951
    """
    if n < 0:
        print(f"[경고] {n}은 음수입니다. 제곱근을 구할 수 없습니다.")
        return None
    return math.sqrt(n)


def circle_area(radius):
    """
    원의 넓이를 반환합니다. (math.pi 활용: π = 3.14159...)
    
    공식: 넓이 = π × r²
    
    매개변수:
        radius (int | float): 반지름
    반환값:
        float: 원의 넓이
    예시:
        >>> circle_area(5)
        78.53981633974483
    """
    return math.pi * power(radius, 2)


def factorial(n):
    """
    n의 팩토리얼을 반환합니다. (math.factorial 활용)
    
    공식 문서: https://docs.python.org/ko/3/library/math.html#math.factorial
    
    매개변수:
        n (int): 0 이상의 정수
    반환값:
        int: n!
    예시:
        >>> factorial(5)
        120
    """
    if n < 0:
        print(f"[경고] {n}은 음수입니다. 팩토리얼을 구할 수 없습니다.")
        return None
    return math.factorial(n)


def round_to(n, digits=2):
    """
    소수점 digits 자리까지 반올림한 값을 반환합니다.
    
    매개변수:
        n (float): 반올림할 수
        digits (int): 소수점 이하 자릿수 (기본값: 2)
    예시:
        >>> round_to(3.14159, 3)
        3.142
    """
    return round(n, digits)


# ── 유틸리티 함수 ────────────────────────────────────────────

def is_even(n):
    """n이 짝수인지 여부를 반환합니다."""
    return n % 2 == 0


def is_prime(n):
    """
    n이 소수인지 여부를 반환합니다.
    
    알고리즘: √n까지의 수로 나누어보는 방법
    공식 문서(math.isqrt): https://docs.python.org/ko/3/library/math.html#math.isqrt
    """
    if n < 2:
        return False
    # math.isqrt: 정수의 정수 제곱근 (Python 3.8+)
    for i in range(2, math.isqrt(n) + 1):
        if n % i == 0:
            return False
    return True


def gcd(a, b):
    """
    두 수의 최대공약수(GCD)를 반환합니다. (math.gcd 활용)
    
    공식 문서: https://docs.python.org/ko/3/library/math.html#math.gcd
    """
    return math.gcd(a, b)


def lcm(a, b):
    """
    두 수의 최소공배수(LCM)를 반환합니다. (math.lcm 활용, Python 3.9+)
    
    공식 문서: https://docs.python.org/ko/3/library/math.html#math.lcm
    """
    return math.lcm(a, b)

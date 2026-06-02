# ============================================================
# 파일: main.py
# 역할: 미니 프로젝트 1 - 모듈 사용 실습 메인 파일
#
# 이 파일에서는 두 개의 자체 제작 모듈을 불러와 사용합니다.
#   - calculator.py  : 수학 계산 모듈 (같은 폴더에 위치)
#   - string_utils.py: 문자열 처리 모듈 (같은 폴더에 위치)
#
# 실행 방법:
#   $ uv run python main.py        ← 터미널에서 실행
#   또는 Jupyter에서 %run main.py
# ============================================================

# ── 자체 제작 모듈 불러오기 ──────────────────────────────────
# calculator.py  →  같은 폴더(./)에 위치한 모듈
import calculator

# string_utils.py → 필요한 함수만 선택적으로 불러오기 (from ... import)
from string_utils import (
    count_words,
    count_chars,
    reverse_string,
    is_palindrome,
    capitalize_words,
    truncate,
    caesar_cipher,
)


# ── 진입점(Entry Point) 설정 ─────────────────────────────────
# if __name__ == "__main__":
#   이 파일을 직접 실행할 때만 아래 코드가 동작합니다.
#   다른 파일에서 import main 으로 불러와도 실행되지 않습니다.

if __name__ == "__main__":

    # ── 구분선 출력 헬퍼 ──────────────────────────────────────
    def section(title):
        print(f"\n{'=' * 50}")
        print(f"  {title}")
        print(f"{'=' * 50}")


    # ─────────────────────────────────────────────────────────
    # Part 1: calculator 모듈 사용
    # ─────────────────────────────────────────────────────────
    section("Part 1. calculator 모듈 사용")

    a, b = 36, 9
    print(f"\n  a = {a}, b = {b}")

    # calculator 모듈의 함수 호출: 모듈명.함수명()
    print(f"  덧셈  add({a}, {b})       = {calculator.add(a, b)}")
    print(f"  뺄셈  sub({a}, {b})       = {calculator.sub(a, b)}")
    print(f"  곱셈  mul({a}, {b})        = {calculator.mul(a, b)}")
    print(f"  나눗셈 div({a}, {b})        = {calculator.div(a, b)}")
    print(f"  몫    floor_div({a}, {b})  = {calculator.floor_div(a, b)}")
    print(f"  나머지 mod({a}, {b})        = {calculator.mod(a, b)}")
    print(f"  제곱  power(2, 10)        = {calculator.power(2, 10)}")

    print(f"\n  math 모듈 활용:")
    print(f"  √{a}          = {calculator.square_root(a)}")
    print(f"  원넓이(r=5)   = {calculator.circle_area(5):.4f}")
    print(f"  5!            = {calculator.factorial(5)}")
    print(f"  π 반올림(4자리) = {calculator.round_to(3.141592653589793, 4)}")

    print(f"\n  유틸리티:")
    print(f"  is_even(7)    = {calculator.is_even(7)}")
    print(f"  is_prime(17)  = {calculator.is_prime(17)}")
    print(f"  gcd(36, 9)    = {calculator.gcd(36, 9)}")
    print(f"  lcm(4, 6)     = {calculator.lcm(4, 6)}")

    # 0 나눗셈 예외 처리 확인
    print(f"\n  0으로 나누기 시도:")
    result = calculator.div(10, 0)
    print(f"  결과: {result}")

    # ─────────────────────────────────────────────────────────
    # Part 2: string_utils 모듈 사용 (from ... import)
    # ─────────────────────────────────────────────────────────
    section("Part 2. string_utils 모듈 사용")

    sample = "Python is a great programming language"
    print(f"\n  원본 문자열: \"{sample}\"")
    print(f"  단어 수         : {count_words(sample)}")
    print(f"  글자 수(공백포함): {count_chars(sample)}")
    print(f"  글자 수(공백제외): {count_chars(sample, include_spaces=False)}")
    print(f"  역순           : \"{reverse_string(sample)}\"")
    print(f"  각 단어 첫 글자 대문자: \"{capitalize_words(sample)}\"")
    print(f"  30자로 자르기  : \"{truncate(sample, 30)}\"")

    print(f"\n  팰린드롬 검사:")
    for word in ["racecar", "hello", "A man a plan a canal Panama", "Python"]:
        print(f"    '{word}' → {is_palindrome(word)}")

    print(f"\n  시저 암호 (shift=3):")
    original  = "Hello Python"
    encrypted = caesar_cipher(original, 3)
    decrypted = caesar_cipher(encrypted, -3)
    print(f"    원본     : {original}")
    print(f"    암호화   : {encrypted}")
    print(f"    복호화   : {decrypted}")

    # ─────────────────────────────────────────────────────────
    # Part 3: 모듈 메타 정보 확인
    # ─────────────────────────────────────────────────────────
    section("Part 3. 모듈 메타 정보")

    # 모듈 수준 변수 접근
    print(f"\n  calculator 모듈 이름  : {calculator.MODULE_NAME}")
    print(f"  calculator 버전      : {calculator.VERSION}")

    # __name__ 확인
    # 직접 실행 시 → __main__
    # import 시    → 모듈 파일명 (calculator)
    print(f"\n  현재 파일의 __name__ : {__name__}")
    print(f"  calculator.__name__  : {calculator.__name__}")

    print("\n실행 완료!")

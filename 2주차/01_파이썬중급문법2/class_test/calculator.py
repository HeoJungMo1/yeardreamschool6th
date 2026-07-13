# calculator.py — 계산기 클래스 (상속) 빈칸 채우기
# 정답 확인: test0605_answers/calculator.py

# [문제 9] operations.py에서 get_operation 함수를 가져오세요.
from operations import get_operation


class Calculator:
    """기본 계산기"""

    def calc(self, symbol, a, b):
        op = get_operation(symbol)
        if op is None:
            print("연산자는 +, -, *, / 만 가능합니다.")
            return None
        return op.calculate(a, b)


# [문제 10] RunCalculator가 Calculator를 상속받도록 괄호 안을 채우세요.
class RunCalculator(Calculator):
    """Calculator를 상속 — input()으로 계산하기"""

    def run(self):
        print("=== 사칙연산 계산기 ===")
        print("종료하려면 연산자에 q 입력")
        print()

        # [문제 11] 계산을 반복하는 while 문을 완성하세요. (True)
        while True:
            symbol = input("연산자 (+ - * /) > ").strip()
            if symbol == "q":
                print("종료합니다.")
                break

            # [문제 12] input()으로 받은 문자열을 실수로 바꾸는 함수 이름을 채우세요.
            a = float(input("첫 번째 숫자 > "))
            # [문제 13] 두 번째 숫자도 같은 방식으로 실수로 변환하세요.
            b = float(input("두 번째 숫자 > "))

            result = self.calc(symbol, a, b)
            if result is not None:
                print(f"결과: {a} {symbol} {b} = {result}")
            print()

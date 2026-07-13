# calculator.py — 계산기 클래스 (상속)

from operations import get_operation


class Calculator:
    """기본 계산기"""

    def calc(self, symbol, a, b):
        op = get_operation(symbol)
        if op is None:
            print("연산자는 +, -, *, / 만 가능합니다.")
            return None
        return op.calculate(a, b)


class RunCalculator(Calculator):
    """Calculator를 상속 — input()으로 계산하기"""

    def run(self):
        print("=== 사칙연산 계산기 ===")
        print("종료하려면 연산자에 q 입력")
        print()

        while True:
            symbol = input("연산자 (+ - * /) > ").strip()
            if symbol == "q":
                print("종료합니다.")
                break

            a = float(input("첫 번째 숫자 > "))
            b = float(input("두 번째 숫자 > "))

            result = self.calc(symbol, a, b)
            if result is not None:
                print(f"결과: {a} {symbol} {b} = {result}")
            print()

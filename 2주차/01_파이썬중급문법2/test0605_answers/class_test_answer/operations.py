# operations.py — 사칙연산 클래스 (상속)


class Operation:
    """연산 부모 클래스"""

    name = "연산"

    def calculate(self, a, b):
        """자식 클래스에서 다시 정의(오버라이딩)합니다."""
        pass


class AddOperation(Operation):
    name = "덧셈"

    def calculate(self, a, b):
        return a + b


class SubOperation(Operation):
    name = "뺄셈"

    def calculate(self, a, b):
        return a - b


class MulOperation(Operation):
    name = "곱셈"

    def calculate(self, a, b):
        return a * b

class DivOperation(Operation):
    name = "나눗셈"

    def calculate(self, a, b):
        if b == 0:
            print("0으로 나눌 수 없습니다.")
            return None
        return a / b


# 연산 기호 → 객체
OPS = {
    "+": AddOperation(),
    "-": SubOperation(),
    "*": MulOperation(),
    "/": DivOperation(),
}


def get_operation(symbol):
    """기호로 연산 객체 가져오기"""
    return OPS.get(symbol)

# operations.py — 사칙연산 클래스 (상속) 빈칸 채우기
# 정답 확인: test0605_answers/operations.py


class Operation:
    """연산 부모 클래스"""

    name = "연산"

    def calculate(self, a, b):
        """자식 클래스에서 다시 정의(오버라이딩)합니다."""
        pass


# [문제 1] AddOperation이 부모 클래스 Operation을 상속받도록 괄호 안을 채우세요.
class AddOperation(Operation):
    name = "덧셈"

    def calculate(self, a, b):
        # [문제 2] 두 수 a, b를 더한 값을 return 하세요. (연산자 +)
        return a + b


# [문제 3] SubOperation도 Operation을 상속받도록 작성하고, 뺄셈 결과를 return 하세요.
class SubOperation(Operation):
    name = "뺄셈"

    def calculate(self, a, b):
        return a - b


# [문제 4] MulOperation을 Operation의 자식 클래스로 만들고, 곱셈 결과를 return 하세요.
class MulOperation(Operation):
    name = "곱셈"

    def calculate(self, a, b):
        return a * b


class DivOperation(Operation):
    name = "나눗셈"

    def calculate(self, a, b):
        # [문제 5] b가 0인지 비교하는 조건문을 완성하세요. (== 사용)
        if b == 0:
            print("0으로 나눌 수 없습니다.")
            return None
        # [문제 6] a를 b로 나눈 값을 return 하세요. (연산자 /)
        return a / b


# 연산 기호 → 객체
OPS = {
    # [문제 7] "+" 키에 덧셈 연산 객체를 넣으세요. (클래스 이름 + 괄호)
    "+": AddOperation(),
    "-": SubOperation(),
    "*": MulOperation(),
    "/": DivOperation(),
}


def get_operation(symbol):
    """기호로 연산 객체 가져오기"""
    # [문제 8] OPS 딕셔너리에서 symbol 키로 값을 꺼내는 메서드 이름을 채우세요.
    return OPS.get(symbol)

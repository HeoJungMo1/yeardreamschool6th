# ============================================================
# 파일: string_utils.py
# 역할: 문자열 처리에 자주 사용되는 유틸리티 함수 모음 모듈
#
# 사용 방법:
#   import string_utils
#   string_utils.count_words("Hello World")  →  2
# ============================================================


# ── 기본 문자열 처리 함수 ────────────────────────────────────

def count_words(text):
    """
    문자열에서 단어 수를 반환합니다.
    
    매개변수:
        text (str): 분석할 문자열
    반환값:
        int: 단어 수
    예시:
        >>> count_words("Hello World Python")
        3
    """
    # 공백 기준으로 분리 후 빈 문자열 제거
    words = [w for w in text.split() if w]
    return len(words)


def count_chars(text, include_spaces=True):
    """
    문자열의 글자 수를 반환합니다.
    
    매개변수:
        text (str): 분석할 문자열
        include_spaces (bool): 공백 포함 여부 (기본값: True)
    예시:
        >>> count_chars("Hello World")
        11
        >>> count_chars("Hello World", include_spaces=False)
        10
    """
    if include_spaces:
        return len(text)
    return len(text.replace(" ", ""))


def reverse_string(text):
    """
    문자열을 뒤집어 반환합니다.
    
    예시:
        >>> reverse_string("Python")
        'nohtyP'
    """
    # 슬라이싱을 활용한 역순: [시작:끝:스텝]  →  [::-1]
    return text[::-1]


def is_palindrome(text):
    """
    문자열이 팰린드롬(앞뒤가 같은 단어)인지 확인합니다.
    대소문자와 공백을 무시합니다.
    
    예시:
        >>> is_palindrome("racecar")
        True
        >>> is_palindrome("A man a plan a canal Panama")
        True
        >>> is_palindrome("hello")
        False
    """
    # 소문자로 변환 + 공백 제거 후 비교
    cleaned = text.lower().replace(" ", "")
    return cleaned == reverse_string(cleaned)


def capitalize_words(text):
    """
    각 단어의 첫 글자를 대문자로 변환합니다.
    
    예시:
        >>> capitalize_words("hello world python")
        'Hello World Python'
    """
    return text.title()


def remove_duplicates_from_list(lst):
    """
    리스트에서 중복 요소를 제거하고 순서를 유지한 리스트를 반환합니다.
    
    매개변수:
        lst (list): 중복 제거할 리스트
    반환값:
        list: 중복이 제거된 리스트
    예시:
        >>> remove_duplicates_from_list([1, 2, 2, 3, 1, 4])
        [1, 2, 3, 4]
    """
    seen = set()
    result = []
    for item in lst:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def truncate(text, max_length=50, suffix="..."):
    """
    문자열을 최대 길이로 자르고 suffix를 붙입니다.
    
    매개변수:
        text (str): 원본 문자열
        max_length (int): 최대 허용 길이 (기본값: 50)
        suffix (str): 자른 경우 붙일 접미사 (기본값: '...')
    예시:
        >>> truncate("This is a very long string", max_length=15)
        'This is a very ...'
    """
    if len(text) <= max_length:
        return text
    return text[:max_length] + suffix


def caesar_cipher(text, shift):
    """
    시저 암호: 알파벳을 shift만큼 이동하여 암호화합니다.
    
    매개변수:
        text (str): 암호화할 문자열
        shift (int): 이동할 칸 수 (양수: 오른쪽, 음수: 복호화)
    예시:
        >>> caesar_cipher("Hello", 3)
        'Khoor'
        >>> caesar_cipher("Khoor", -3)   # 복호화
        'Hello'
    """
    result = []
    for char in text:
        if char.isalpha():
            # 대문자는 A(65), 소문자는 a(97)를 기준으로 이동
            base = ord('A') if char.isupper() else ord('a')
            shifted = (ord(char) - base + shift) % 26 + base
            result.append(chr(shifted))
        else:
            result.append(char)   # 알파벳이 아니면 그대로
    return "".join(result)

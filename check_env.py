# 설치된 라이브러리 버전을 확인하는 스크립트
# 실행: uv run python check_env.py

import sys

libs = [
    ("Python",      sys.version.split()[0]),
]

checks = [
    "numpy",
    "pandas",
    "matplotlib",
    "seaborn",
    "plotly",
    "scipy",
    "sklearn",
    "statsmodels",
    "pyarrow",
    "openpyxl",
]

for name in checks:
    try:
        mod = __import__(name)
        libs.append((name, mod.__version__))
    except ImportError:
        libs.append((name, "❌ 설치 안 됨"))

print("=" * 40)
print("  라이브러리 버전 확인")
print("=" * 40)
for name, version in libs:
    print(f"  {name:<14} {version}")
print("=" * 40)

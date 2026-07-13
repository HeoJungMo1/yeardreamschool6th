import csv
import os
import re
from collections import defaultdict
from datetime import datetime

BASE = r'C:/Users/chan1/Desktop/study/이어드림/team_project'
DATA = os.path.join(BASE, '00_data')
TIME_CSV = os.path.join(DATA, '서울시 지하철 호선별 역별 시간대별 승하차 인원 정보.csv')
CONG_CSV = os.path.join(DATA, '서울교통공사_지하철혼잡도정보_20260331.csv')
OUT = os.path.join(BASE, '혼잡도_SCQA_피크시간대_개선방안_TOP5.md')


def n(x):
    return f'{int(round(x)):,}'


def pct(x):
    return f'{x:.1f}%'


def parse_time_csv():
    hour_re = re.compile(r'(\d{2})시-(\d{2})시 (승차|하차)인원')
    station_hour = defaultdict(lambda: {'승차': 0, '하차': 0, '합계': 0})
    station_total = defaultdict(int)
    rows = 0
    months = set()
    with open(TIME_CSV, encoding='cp949', newline='') as f:
        reader = csv.reader(f)
        headers = next(reader)
        cols = []
        for i, h in enumerate(headers):
            m = hour_re.match(h)
            if m:
                cols.append((i, int(m.group(1)), m.group(3)))
        for row in reader:
            if not row:
                continue
            rows += 1
            months.add(row[0])
            if row[0] != '202605':
                continue
            line, station = row[1], row[2]
            for i, hour, typ in cols:
                try:
                    val = int(row[i].replace(',', ''))
                except Exception:
                    val = 0
                station_hour[(line, station, hour)][typ] += val
                station_hour[(line, station, hour)]['합계'] += val
                station_total[(line, station)] += val
    return station_hour, station_total, rows, min(months), max(months)


def parse_congestion_csv():
    items = []
    by_seg = defaultdict(dict)
    with open(CONG_CSV, encoding='cp949', newline='') as f:
        reader = csv.reader(f)
        headers = next(reader)
        time_cols = [(i, h) for i, h in enumerate(headers) if re.match(r'\d+시\d+분', h)]
        rows = 0
        for row in reader:
            if not row:
                continue
            rows += 1
            day, line, st_no, station, direction = row[:5]
            for i, t in time_cols:
                try:
                    val = float(row[i].strip())
                except Exception:
                    continue
                rec = {
                    'day': day,
                    'line': line,
                    'station': station,
                    'direction': direction,
                    'time': t,
                    'cong': val,
                }
                items.append(rec)
                by_seg[(day, line, station, direction)][t] = val
    return items, by_seg, rows


def get_station_hours(station_hour, line, station_patterns, hours):
    total = board = alight = 0
    matched = set()
    for (ln, st, h), vals in station_hour.items():
        if ln != line or h not in hours:
            continue
        if any(p in st for p in station_patterns):
            matched.add((ln, st))
            total += vals['합계']
            board += vals['승차']
            alight += vals['하차']
    return matched, total, board, alight


def cluster_stats(by_seg, station_hour, cluster):
    vals = []
    for seg in cluster['segments']:
        for t in cluster['times']:
            if t in by_seg[seg]:
                vals.append(by_seg[seg][t])
    matched, total, board, alight = get_station_hours(
        station_hour, cluster['ridership_line'], cluster['ridership_station_patterns'], cluster['ridership_hours']
    )
    return {
        'max': max(vals),
        'avg': sum(vals) / len(vals),
        'vals': vals,
        'matched': sorted(matched),
        'rider_total': total,
        'board': board,
        'alight': alight,
    }


def main():
    station_hour, station_total, time_rows, month_min, month_max = parse_time_csv()
    cong_items, by_seg, cong_rows = parse_congestion_csv()

    station_hour_top = sorted(station_hour.items(), key=lambda x: x[1]['합계'], reverse=True)[:10]
    cong_top_unique = {}
    for it in cong_items:
        key = (it['day'], it['line'], it['station'], it['direction'])
        if key not in cong_top_unique or it['cong'] > cong_top_unique[key]['cong']:
            cong_top_unique[key] = it
    cong_top10 = sorted(cong_top_unique.values(), key=lambda x: x['cong'], reverse=True)[:10]

    clusters = [
        {
            'rank': 1,
            'name': '2호선 사당 외선 오전 피크',
            'where': '평일 08:00~09:00, 사당 외선 방향',
            'segments': [('평일', '2호선', '사당', '외선')],
            'times': ['8시00분', '8시30분', '9시00분'],
            'ridership_line': '2호선',
            'ridership_station_patterns': ['사당'],
            'ridership_hours': [8, 9],
            'diagnosis': '열차 내 혼잡도가 전체 데이터 최고 수준입니다. 승강장 이용량보다 열차 내부 수용력 부족이 핵심입니다.',
            'actions': [
                '08:00~09:00 외선 방향 집중 증회 또는 단축 운행을 우선 검토',
                '사당역 승강장 대기열을 칸별로 분산하고, 혼잡 칸 회피 안내를 전광판에 고정 노출',
                '2·4호선 환승 동선에 일방향 유도선을 두어 승하차 충돌을 줄임',
            ],
        },
        {
            'rank': 2,
            'name': '7호선 철산 상선 오전 피크',
            'where': '평일 07:30~08:30, 철산 상선 방향',
            'segments': [('평일', '7호선', '철산', '상선')],
            'times': ['7시30분', '8시00분', '8시30분'],
            'ridership_line': '7호선',
            'ridership_station_patterns': ['철산'],
            'ridership_hours': [7, 8],
            'diagnosis': '주거지 출근 수요가 짧은 시간에 상선 방향으로 집중됩니다. 역 자체보다 해당 방향 열차 탑승 수요 분산이 중요합니다.',
            'actions': [
                '07:30~08:30 상선 방향 배차 간격 축소',
                '역 출입구·버스 환승 시간표를 열차 도착 간격과 맞춰 승강장 순간 유입을 완화',
                '혼잡 칸을 피하도록 승차 위치를 분산 안내',
            ],
        },
        {
            'rank': 3,
            'name': '8호선 몽촌토성·강동구청·천호 하선 오전 피크',
            'where': '평일 07:30~08:30, 8호선 하선 방향',
            'segments': [('평일', '8호선', '몽촌토성', '하선'), ('평일', '8호선', '강동구청', '하선'), ('평일', '8호선', '천호', '하선')],
            'times': ['7시30분', '8시00분', '8시30분'],
            'ridership_line': '8호선',
            'ridership_station_patterns': ['몽촌토성', '강동구청', '천호'],
            'ridership_hours': [7, 8],
            'diagnosis': '한 역 문제가 아니라 연속 구간 혼잡입니다. 단일 역 통제보다 구간 단위 배차·환승 관리가 맞습니다.',
            'actions': [
                '07:30~08:30 하선 방향 구간 증회 또는 예비열차 투입',
                '천호 환승 동선에서 승하차 흐름을 분리해 열차 지연을 줄임',
                '몽촌토성·강동구청·천호에 동일한 칸별 분산 안내를 적용',
            ],
        },
        {
            'rank': 4,
            'name': '2호선 방배·서초 내선 퇴근 피크',
            'where': '평일 18:00~19:00, 방배·서초 내선 방향',
            'segments': [('평일', '2호선', '방배', '내선'), ('평일', '2호선', '서초', '내선')],
            'times': ['18시00분', '18시30분', '19시00분'],
            'ridership_line': '2호선',
            'ridership_station_patterns': ['강남', '역삼', '선릉', '서초', '방배'],
            'ridership_hours': [18, 19],
            'diagnosis': '강남권 퇴근 수요가 내선 방향으로 누적됩니다. 18시 직후가 가장 위험하므로 퇴근 시간 분산과 승강장 체류 관리가 필요합니다.',
            'actions': [
                '18:00~18:30 내선 방향 집중 증회',
                '강남·역삼·선릉 기업 밀집지역 대상 10~20분 시차 퇴근 캠페인/인센티브',
                '강남역 승강장 혼잡 시 진입 속도 조절, 대합실 대기 유도',
            ],
        },
        {
            'rank': 5,
            'name': '7호선 군자·중곡·어린이대공원 하선 오전 피크',
            'where': '평일 07:30~08:30, 7호선 하선 방향',
            'segments': [('평일', '7호선', '군자', '하선'), ('평일', '7호선', '중곡', '하선'), ('평일', '7호선', '어린이대공원', '하선')],
            'times': ['7시30분', '8시00분', '8시30분'],
            'ridership_line': '7호선',
            'ridership_station_patterns': ['군자', '중곡', '어린이대공원'],
            'ridership_hours': [7, 8],
            'diagnosis': '군자 환승과 인접역 출근 수요가 겹치는 구간입니다. 환승객과 일반 승객의 충돌을 줄이는 것이 효과적입니다.',
            'actions': [
                '군자역 환승 통로와 7호선 승강장 진입 동선 분리',
                '07:30~08:30 하선 방향 혼잡 칸 회피 안내',
                '중곡·어린이대공원 승강장 안전요원 배치로 무리한 탑승 억제',
            ],
        },
    ]

    for c in clusters:
        c['stats'] = cluster_stats(by_seg, station_hour, c)

    md = []
    md.append('# 서울 지하철 피크시간대 혼잡도 개선 방안 TOP5 — SCQA 분석')
    md.append('')
    md.append(f'- 저장일: {datetime.now().strftime("%Y-%m-%d %H:%M")}')
    md.append(f'- 분석 폴더: `{BASE}`')
    md.append('- 결론: 혼잡 개선은 “전체 역 순위”보다 `평일 피크시간 × 방향 × 연속 구간` 기준으로 잡아야 합니다. 우선순위는 2호선 사당 외선 오전, 7호선 철산 상선 오전, 8호선 하선 오전, 2호선 강남권 내선 퇴근, 7호선 군자권 하선 오전입니다.')
    md.append('')
    md.append('## 0. 사용 데이터와 분석 기준')
    md.append('')
    md.append('| 데이터 | 역할 | 근거 |')
    md.append('|---|---|---:|')
    md.append(f'| `서울시 지하철 호선별 역별 시간대별 승하차 인원 정보.csv` | 역별·시간대별 수요 규모 파악 | {month_min}~{month_max}, {n(time_rows)}행 |')
    md.append(f'| `서울교통공사_지하철혼잡도정보_20260331.csv` | 실제 열차 혼잡도(%) 판단 | {n(cong_rows)}행 |')
    md.append('')
    md.append('분석 기준은 다음과 같습니다.')
    md.append('- 혼잡도 개선 대상 선정: 실제 열차 혼잡도(%)가 높은 `평일 피크시간·방향·구간`을 우선합니다.')
    md.append('- 승하차 인원 CSV는 “수요 규모와 동선 개선 필요성”을 보조 근거로 사용했습니다.')
    md.append('- 단순히 월 승하차량이 큰 역은 “사람이 많은 역”이고, 혼잡도(%)가 큰 구간은 “열차 안이 위험하게 붐비는 구간”입니다. 개선 우선순위는 후자를 중심으로 잡았습니다.')
    md.append('')
    md.append('## S — Situation: 현재 상황')
    md.append('')
    md.append('서울 지하철 혼잡은 모든 시간대에 고르게 발생하지 않습니다. 데이터상 혼잡은 평일 출근 07:30~09:00, 퇴근 18:00~19:00에 특정 방향과 구간으로 몰립니다.')
    md.append('')
    md.append('2026년 5월 시간대별 승하차 인원 기준, 사람이 가장 많이 몰리는 역·시간대는 다음과 같습니다.')
    md.append('')
    md.append('| 순위 | 호선 | 역 | 시간대 | 승차 | 하차 | 합계 |')
    md.append('|---:|---|---|---|---:|---:|---:|')
    for i, ((line, st, h), vals) in enumerate(station_hour_top[:5], 1):
        md.append(f'| {i} | {line} | {st} | {h:02d}-{(h+1)%24:02d}시 | {n(vals["승차"])} | {n(vals["하차"])} | {n(vals["합계"])} |')
    md.append('')
    md.append('하지만 “많이 타고 내리는 역”과 “열차 안이 가장 붐비는 구간”은 완전히 같지 않습니다. 따라서 실제 개선안은 혼잡도(%) 데이터를 같이 봐야 합니다.')
    md.append('')
    md.append('## C — Complication: 문제의 본질')
    md.append('')
    md.append('기존 분석처럼 “최신 데이터가 필요하다”에서 끝나면 실행안이 나오지 않습니다. 실제 문제는 다음 세 가지입니다.')
    md.append('')
    md.append('1. 피크 혼잡은 역 단위가 아니라 `방향·구간` 단위로 발생합니다.')
    md.append('2. 출근 혼잡은 주거지 → 업무지 방향, 퇴근 혼잡은 업무지 → 주거지 방향으로 비대칭입니다.')
    md.append('3. 개선책도 하나가 아닙니다. `증회`, `단축 운행`, `승강장 동선 분리`, `환승 통제`, `시차 출퇴근`, `혼잡 칸 분산 안내`를 구간별로 다르게 써야 합니다.')
    md.append('')
    md.append('## Q — Question: 우리가 답해야 할 질문')
    md.append('')
    md.append('“특정 피크시간대의 혼잡도를 낮추기 위해, 어느 구간부터 무엇을 해야 하는가?”')
    md.append('')
    md.append('## A — Answer: 우선 개선 대상 TOP5')
    md.append('')
    md.append('| 우선순위 | 개선 대상 | 피크 혼잡도 | 피크 평균 | 보조 수요 근거 | 핵심 처방 |')
    md.append('|---:|---|---:|---:|---:|---|')
    for c in clusters:
        s = c['stats']
        md.append(f'| {c["rank"]} | {c["name"]}<br>{c["where"]} | {pct(s["max"])} | {pct(s["avg"])} | {n(s["rider_total"])}명 | {c["actions"][0]} |')
    md.append('')
    md.append('## 1. TOP5 상세 개선안')
    md.append('')
    for c in clusters:
        s = c['stats']
        md.append(f'### {c["rank"]}. {c["name"]}')
        md.append('')
        md.append(f'- 대상: {c["where"]}')
        md.append(f'- 피크 혼잡도: 최대 `{pct(s["max"])}`, 피크 구간 평균 `{pct(s["avg"])}`')
        md.append(f'- 2026년 5월 관련 역 피크시간 승하차 보조 수요: `{n(s["rider_total"])}명`')
        if s['matched']:
            md.append('- 보조 수요 매칭 역: ' + ', '.join([f'{ln} {st}' for ln, st in s['matched']]))
        md.append(f'- 진단: {c["diagnosis"]}')
        md.append('- 실행안:')
        for a in c['actions']:
            md.append(f'  - {a}')
        md.append('')
    md.append('## 2. 실행 우선순위별 정책 묶음')
    md.append('')
    md.append('| 기간 | 할 일 | 적용 대상 |')
    md.append('|---|---|---|')
    md.append('| 즉시 | 혼잡 칸 회피 안내, 승강장 대기열 분리, 환승 동선 일방향화 | 사당, 군자, 천호, 강남권 |')
    md.append('| 단기 | 피크 30~60분 배차 간격 축소, 안전요원 집중 배치 | 2호선 사당·방배·서초, 7호선 철산·군자권, 8호선 하선 |')
    md.append('| 중기 | 단축 운행/예비열차 투입, 출근·퇴근 수요 분산 캠페인 | 2호선 외선 오전, 2호선 내선 퇴근, 7호선 상·하선 피크 |')
    md.append('| 장기 | 환승 통로 개선, 승강장 병목 구조 개선, 기업·학교와 시차 이동 제도화 | 강남권, 군자, 천호, 사당 |')
    md.append('')
    md.append('## 3. 발표용 핵심 메시지')
    md.append('')
    md.append('- 혼잡도 개선은 “사람이 많은 역 TOP5”가 아니라 “열차가 가장 붐비는 피크 구간 TOP5”부터 잡아야 합니다.')
    md.append('- 승하차 인원만 보면 강남·잠실·서울역·홍대입구가 크게 보이지만, 실제 열차 혼잡도는 사당 외선, 철산 상선, 8호선 하선, 방배·서초 내선, 군자권 하선에서 더 직접적으로 나타납니다.')
    md.append('- 따라서 우리 프로젝트의 제안은 `피크시간·방향·구간 기반 혼잡 개선 우선순위 모델`입니다.')
    md.append('')
    md.append('## 4. 한계')
    md.append('')
    md.append('- 시간대별 승하차 CSV는 월 누적 인원이고, 혼잡도 CSV는 서울교통공사 제공 혼잡도 기준입니다. 두 파일의 측정 단위가 달라 직접 곱하지 않고 보조 근거로 결합했습니다.')
    md.append('- 혼잡도 데이터는 열차 내 혼잡률 중심이라 승강장·환승통로 혼잡을 완전히 설명하지는 못합니다.')
    md.append('- 실제 정책 적용에는 열차 편성 수, 운전 시격, 회차 가능 위치, 안전 인력, 역 구조 데이터가 추가로 필요합니다.')
    md.append('')

    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md))
    print(OUT)
    print('time_rows', time_rows, 'months', month_min, month_max)
    print('cong_rows', cong_rows)
    print('clusters', len(clusters))
    for c in clusters:
        print(c['rank'], c['name'], pct(c['stats']['max']), pct(c['stats']['avg']), n(c['stats']['rider_total']))

if __name__ == '__main__':
    main()

# 주식 데이터 시각화 앱 (StockView)

- 데이터 제공 : https://www.alphavantage.co/
- 과거 주식 데이터 라인차트로 표시
- 일별, 주별, 월별, 연도별

# 기술 스택

- Flutter
- MVVM 패턴
- 상태관리는 라이브러리 사용 금지, ChangeNotifier + ListenableBuilder 조합으로 할 것

# 화면 구성

- 하단에 탭 4개 (Watchlist, 미정, 미정, 미정)

# 티커 관리 구조

- Watchlist 탭을 따로 두고, 관심 종목 리스트를 카드/리스트 형태로 보여주기.
- 개별 티커 카드는 현재가·등락률·미니 차트 등을 최소 정보로 담고, 탭 전환 없이 상세 화면으로 이동
  하도록 구성.
- 검색/추가는 상단 Search & Add 버튼 → 모달(또는 새로운 화면)로 티커 검색 + API 호출 → Watchlist
  에 추가.

# Notes

- API_KEY : .env
- State Holder 패턴을 사용
- 테스트용 가짜 데이터 활용
- 테스트용 데이터와 실제 데이터 간편하게 swap 가능한 구조 (DI)
- 데이터가 잘 가져와 지는지 유닛 테스트
- 클린 아키텍처 적용
- SOLID 원칙 적용
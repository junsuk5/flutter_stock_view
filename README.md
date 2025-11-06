# StockView - 주식 데이터 시각화 앱

Flutter로 만든 주식 데이터 시각화 애플리케이션입니다. AlphaVantage API를 통해 실시간 주식 데이터를 받아와 watchlist 형태로 관리할 수 있습니다.

## 주요 기능

- **Watchlist 관리**: 관심 종목을 카드 형태로 저장 및 관리
- **실시간 주가 데이터**: AlphaVantage API를 통한 최신 주가 정보 조회
- **상세 분석**: 과거 30일간의 가격 이력 및 통계 정보 제공
- **종목 검색**: 심볼 검색 기능으로 원하는 종목을 찾아 추가
- **하단 네비게이션**: 4개의 탭으로 구성 (Watchlist, Trending, Search, Settings)

## 기술 스택

- **Framework**: Flutter 3.9.2+
- **상태 관리**: ChangeNotifier + ListenableBuilder
- **아키텍처**: MVVM 패턴
- **API**: AlphaVantage API (https://www.alphavantage.co/)
- **주요 패키지**:
  - `http`: HTTP 요청 처리
  - `fl_chart`: 차트 라이브러리 (확장용)
  - `intl`: 국제화 및 날짜 포맷팅
  - `flutter_dotenv`: 환경 변수 관리

## 프로젝트 구조

```
lib/
├── main.dart                          # 애플리케이션 진입점
├── models/
│   └── stock_data.dart               # 주식 데이터 모델
├── services/
│   └── alpha_vantage_service.dart    # API 연동 서비스
├── viewmodels/
│   └── watchlist_viewmodel.dart      # Watchlist ViewModel
└── views/
    ├── screens/
    │   ├── watchlist_screen.dart     # Watchlist 화면
    │   └── stock_detail_screen.dart  # 상세 정보 화면
    └── widgets/
        ├── stock_card.dart           # 주식 카드 위젯
        └── add_stock_modal.dart      # 종목 추가 모달
```

## 시작하기

### 1. 환경 설정

```bash
# 의존성 설치
flutter pub get

# .env 파일 생성
echo "ALPHA_VANTAGE_API_KEY=your_api_key" > .env
```

### 2. API 키 설정

1. https://www.alphavantage.co/ 에서 무료 API 키 발급
2. `.env` 파일에 API 키 입력:
```
ALPHA_VANTAGE_API_KEY=YOUR_API_KEY_HERE
```

### 3. 앱 실행

```bash
# iOS 시뮬레이터
flutter run -t lib/main.dart

# Android 에뮬레이터
flutter run -t lib/main.dart

# 디바이스에 설치
flutter run -t lib/main.dart --release
```

## 화면 구성

### 1. Watchlist 탭
- 추가된 종목들을 카드 형태로 표시
- 각 카드에는 현재가, 등락률, 상태 아이콘 표시
- FAB 또는 상단 버튼으로 새 종목 추가
- 카드 클릭시 상세 화면으로 이동

### 2. 상세 화면
- 현재가 및 등락률 표시
- 과거 30일간 가격 이력 통계 (고가, 저가, 평균)
- 날짜별 가격 데이터 리스트

### 3. 검색 & 추가 모달
- 종목 심볼 검색
- AlphaVantage의 SYMBOL_SEARCH 기능 활용
- 검색 결과에서 선택하여 watchlist에 추가

### 4. 기타 탭
- Trending, Search, Settings 탭은 향후 개발 예정

## MVVM 아키텍처 설명

### Model (stock_data.dart)
- `StockData`: 주식 정보를 담는 데이터 클래스
- `PricePoint`: 시간별 가격 데이터 포인트

### View (screens & widgets)
- `WatchlistScreen`: 메인 watchlist 화면
- `StockDetailScreen`: 상세 정보 화면
- `StockCard`: 주식 정보 카드 위젯
- `AddStockModal`: 종목 추가 모달

### ViewModel (watchlist_viewmodel.dart)
- `WatchlistViewModel`: 상태 관리 및 비즈니스 로직
- ChangeNotifier를 상속하여 상태 변경 시 자동으로 UI 업데이트

### Service (alpha_vantage_service.dart)
- `AlphaVantageService`: API 호출 로직 캡슐화
- `getDailyStockData()`: 종목 일일 데이터 조회
- `searchSymbols()`: 종목 검색

## 상태 관리 방식

- **ChangeNotifier**: 상태 변경을 감지하는 기본 메커니즘
- **ListenableBuilder**: 상태 변경에 따라 UI 자동 갱신
- 외부 상태 관리 라이브러리(GetX, Provider 등)는 사용하지 않음

## 주요 기능 상세

### 종목 추가 (addStock)
```dart
await viewModel.addStock('AAPL');
```
- 중복 확인 후 API 호출
- 성공시 watchlist에 추가
- 실패시 에러 메시지 표시

### 전체 새로고침 (refreshAll)
```dart
await viewModel.refreshAll();
```
- 모든 watchlist 종목의 최신 데이터 갱신
- 병렬로 API 호출 (순차 처리)

### 종목 제거 (removeStock)
```dart
viewModel.removeStock('AAPL');
```
- watchlist에서 즉시 제거
- UI 자동 업데이트

## 주의사항

- AlphaVantage API는 무료 플랜에서 분당 5회 호출 제한
- API 응답 시간이 길 수 있으므로 로딩 표시 권장
- `.env` 파일은 `.gitignore`에 포함되어 있음 (안전)

## 향후 개선 사항

- [ ] 라인 차트로 가격 이력 시각화
- [ ] 일별/주별/월별/연도별 데이터 조회
- [ ] 종목 비교 기능
- [ ] 즐겨찾기 기능
- [ ] 알림/공지 기능
- [ ] 다크 모드 지원
- [ ] 로컬 저장소 활용 (SQLite/Hive)

## 라이센스

MIT License

## 개발자

StockView MVP - 2025

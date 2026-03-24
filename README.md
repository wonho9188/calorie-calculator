# 칼로리 계산기 🍽️

사진을 찍으면 AI가 음식을 인식하고 칼로리를 자동으로 계산해주는 Flutter 앱입니다.

## 주요 기능

- **📸 사진 분석**: 카메라 촬영 또는 갤러리에서 음식 사진을 선택
- **🤖 AI 음식 인식**: Google Gemini AI를 활용한 음식 자동 인식
- **📊 영양소 분석**: 칼로리, 단백질, 탄수화물, 지방 등 상세 영양 정보 제공
- **📈 일일 추적**: 하루 섭취 칼로리 추적 및 목표 대비 진행률 표시
- **📋 기록 관리**: 날짜별 분석 기록 저장 및 조회

## 기술 스택

- **Flutter** 3.x
- **Google Gemini AI** (google_generative_ai)
- **Provider** (상태 관리)
- **fl_chart** (영양소 차트)
- **image_picker** (카메라/갤러리)
- **shared_preferences** (로컬 저장소)

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 엔트리포인트
├── models/
│   ├── food_analysis_result.dart      # 음식 분석 결과 모델
│   └── daily_record.dart              # 일일 기록 모델
├── providers/
│   └── app_provider.dart              # 앱 상태 관리
├── screens/
│   ├── home_screen.dart               # 메인 홈 화면
│   ├── result_screen.dart             # 분석 결과 화면
│   └── history_screen.dart            # 기록 히스토리 화면
└── services/
    ├── food_analysis_service.dart      # AI 음식 분석 서비스
    ├── image_picker_service.dart       # 이미지 선택 서비스
    └── storage_service.dart            # 로컬 저장 서비스
```

## 시작하기

### 사전 요구사항

- Flutter SDK 3.2 이상
- Dart SDK 3.2 이상
- Google Gemini API 키 ([Google AI Studio](https://aistudio.google.com/)에서 발급)

### 설치 및 실행

1. **Flutter SDK 설치**
   ```bash
   # https://docs.flutter.dev/get-started/install 참고
   ```

2. **프로젝트 초기화**
   ```bash
   cd calorie-calculator
   flutter create . --org com.example --project-name calorie_calculator
   ```

3. **의존성 설치**
   ```bash
   flutter pub get
   ```

4. **앱 실행**
   ```bash
   flutter run
   ```

5. **API 키 설정**
   - 앱 실행 후 우측 상단 설정(⚙️) 아이콘을 탭
   - Google Gemini API 키를 입력
   - 일일 목표 칼로리를 설정 (기본값: 2000 kcal)

## 사용 방법

1. 홈 화면에서 **카메라** 또는 **갤러리** 버튼을 탭
2. 음식 사진을 촬영하거나 선택
3. **칼로리 분석하기** 버튼을 탭
4. AI가 음식을 분석하고 결과를 표시
5. 영양소 비율 차트와 상세 정보를 확인

## 플랫폼별 추가 설정

### Android

`android/app/src/main/AndroidManifest.xml`에 카메라 및 인터넷 권한이 필요합니다:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS

`ios/Runner/Info.plist`에 카메라 및 갤러리 접근 권한 설명을 추가해야 합니다:

```xml
<key>NSCameraUsageDescription</key>
<string>음식 사진을 촬영하여 칼로리를 분석합니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>음식 사진을 선택하여 칼로리를 분석합니다</string>
```

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
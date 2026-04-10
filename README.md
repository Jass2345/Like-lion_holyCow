# 💣 BombPass

4명이 그룹을 이뤄 4일~1주일간 폭탄을 돌리는 장기전 소셜 게임.

---

## 프로젝트 구조

```
bomebastick/
├── lib/
│   ├── main.dart                    # 앱 진입점 (Firebase 초기화, ProviderScope)
│   ├── firebase_options.dart        # flutterfire configure로 생성 (gitignore)
│   ├── core/
│   │   ├── constants/               # 앱 상수 (그룹 인원, 재화 등)
│   │   ├── router/                  # go_router 설정
│   │   ├── theme/                   # Material3 테마
│   │   └── utils/                   # 날짜 포맷 등 유틸
│   ├── data/
│   │   ├── firebase/                # Firebase provider (Auth, Firestore, FCM)
│   │   ├── models/                  # freezed + json_serializable 모델
│   │   └── repositories/            # Firestore CRUD 레포지토리
│   ├── features/
│   │   ├── auth/                    # 익명 로그인, 인증 게이트
│   │   ├── group/                   # 그룹 생성/참여, 대기실
│   │   ├── game/                    # 폭탄 전달, 타이머
│   │   ├── shop/                    # 아이템 구매, 재화
│   │   ├── mission/                 # 출석 체크, 미션
│   │   └── result/                  # 게임 결산, 명예의 전당, SNS 공유카드
│   └── widgets/                     # 공통 위젯
├── functions/                       # Firebase Cloud Functions (Node.js + TypeScript)
│   └── src/
│       ├── index.ts                 # 함수 진입점
│       ├── bomb/                    # 폭탄 만료 스케줄러, 폭발 트리거
│       ├── group/                   # 그룹 생성/멤버 합류 트리거
│       └── notification/            # FCM 푸시 알림 발송
└── android/, ios/                   # 플랫폼별 네이티브 파일
```

---

## 역할 분담 (4인 기준)

| 담당자 | 주요 영역 |
|--------|-----------|
| **A** | Firebase 설정, Auth, 그룹 생성/참여 (`features/auth`, `features/group`) |
| **B** | 게임 로직, 폭탄 타이머, Cloud Functions (`features/game`, `functions/`) |
| **C** | 상점, 미션, 출석 체크 (`features/shop`, `features/mission`) |
| **D** | 결과 정산, 공유카드, UI/테마 (`features/result`, `core/theme`) |

---

## Firebase 초기 설정

### 1. Firebase 프로젝트 생성

Firebase Console에서 새 프로젝트를 생성하고 아래 서비스를 활성화합니다:
- Authentication → 익명 로그인 활성화
- Firestore Database → 프로덕션 모드로 생성
- Cloud Messaging (FCM)
- Cloud Functions

### 2. FlutterFire CLI 설치 및 설정

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase CLI 로그인
firebase login

# Flutter 프로젝트에 Firebase 연결 (각자 로컬에서 실행)
flutterfire configure
```

`flutterfire configure` 실행 후 `lib/firebase_options.dart`가 자동 생성됩니다.
이 파일은 `.gitignore`에 포함되어 있으므로 **각자 로컬에서 실행**해야 합니다.

### 3. Android 설정

`google-services.json`을 `android/app/` 폴더에 배치합니다.

### 4. iOS 설정

`GoogleService-Info.plist`를 `ios/Runner/` 폴더에 배치합니다.

---

## Cloud Functions 설정

```bash
# functions 폴더로 이동
cd functions

# 의존성 설치
npm install

# TypeScript 빌드
npm run build

# 에뮬레이터로 로컬 테스트
npm run serve

# 배포
npm run deploy
```

### Firestore 보안 규칙 예시

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
      match /bombs/{bombId} {
        allow read: if request.auth != null;
        allow write: if false; // Cloud Functions에서만 쓰기
      }
    }
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

---

## 로컬 개발 환경 설정

```bash
# Flutter 패키지 설치
flutter pub get

# 코드 생성 (freezed, riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| Framework | Flutter (iOS + Android) |
| 상태관리 | Riverpod + @riverpod 어노테이션 |
| 라우팅 | go_router |
| Backend | Firebase (Firestore, Auth, FCM) |
| Cloud Functions | Node.js + TypeScript |
| 모델 | freezed + json_serializable |
| 코드 품질 | very_good_analysis + flutter_lints |
| 공유카드 | screenshot 패키지 |

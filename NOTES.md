# Bombastic 개발 노트

---

## ⚙️ 환경 설정 및 실행 방법

### 1. 사전 요구사항

- Flutter SDK `>=3.8.0`
- Firebase CLI (`npm install -g firebase-tools`)
- Node.js 20 이상 (Cloud Functions 빌드용)

### 2. 저장소 클론 & 의존성 설치

```bash
git clone <repo-url>
cd bombastic

# 의존성 설치 + freezed/riverpod 코드 자동 생성
bash setup.sh
```

> `setup.sh`가 없으면 아래 명령을 순서대로 실행하세요.
> ```bash
> flutter pub get
> dart run build_runner build --delete-conflicting-outputs
> ```

### 3. Firebase 연결 (최초 1회)

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트와 앱 연결 (lib/firebase_options.dart 자동 생성)
flutterfire configure --project=likelion-holycow
```

> `lib/firebase_options.dart`는 `.gitignore`에 포함되어 있으므로 **팀원 각자 로컬에서 생성**해야 합니다.

### 4. 플랫폼 설정 파일 배치

Firebase Console → 프로젝트 설정에서 각 파일을 다운로드해 아래 경로에 배치하세요.

| 파일 | 위치 |
|------|------|
| `google-services.json` | `android/app/` |
| `GoogleService-Info.plist` | `ios/Runner/` |

### 5. 앱 실행

```bash
flutter run
```

### 6. Cloud Functions 배포 (서버 로직 변경 시)

```bash
cd functions
npm install
npm run build      # TypeScript 컴파일
npm run deploy     # Firebase에 배포
```

로컬 에뮬레이터로 테스트하려면:
```bash
npm run serve
```

### 7. 코드 생성 (모델·provider 변경 시)

```bash
# 1회 실행
dart run build_runner build --delete-conflicting-outputs

# 개발 중 watch 모드
dart run build_runner watch --delete-conflicting-outputs
```

### 8. 기타 유용한 명령

```bash
flutter analyze          # 정적 분석
flutter test             # 테스트 실행
firebase deploy --only firestore:rules   # Firestore 보안 규칙만 배포
```

---

> 팀원 공용 메모판. 결정사항·방향성·논의 내용을 여기에 자유롭게 기록하세요.
> 커밋 메시지보다 덜 형식적으로, 이슈보다 더 빠르게.

## 최근 업데이트 (2026-04-13) — 나가기/공유/딥링크 안정화

- **나가기·방폐쇄 무한 로딩 수정**
    - 그룹 나가기/방 폐쇄 시 Firestore 문서 삭제 후 `watchGroup` 스트림이 권한 오류를 받아 깜빡이던 문제 해결
    - 해결 방법: 홈으로 **먼저 이동**하여 스트림을 해제한 뒤 `leaveGroup`을 fire-and-forget으로 호출
    - `GamePage`의 error 핸들러도 오류 텍스트 대신 홈으로 자동 이동하도록 변경 (안전망)
    - 적용 위치: `game_page.dart` (`_confirmAbort`, `_confirmLeave`), `settings_tab.dart` (`_confirmLeave`)
- **초대 딥링크 및 공유 버튼**
    - `bombastic://join?code=XXXXX` 딥링크 추가 (`app_links` 패키지)
    - 대기실에 초대 링크 공유 버튼 (`share_plus`) 추가
    - 카카오 링크 공유 연동 (`kakao_flutter_sdk_share`) 추가 후 수정
- **결과 공유 안정화**
    - `ResultController.shareResult`에 캡처 지연(20ms) + 에러 핸들링 2단계 (캡처 실패/공유 실패)
    - 공유 버튼에 로딩 스피너 + "공유 준비 중..." 상태 표시
    - 엔딩 크레딧 재생 시간 20초 → 28초로 조정

## 이전 업데이트 (2026-04-12) — 만료/출석/결과 요약 안정화

- **TICKET-1 (P0)**: `checkGameExpiry` 주기 60분 → 1분 복원 — 완료
- **TICKET-2 (P0)**: 결과 summary null-safe 저장 — `memberUids`/`penaltyCount` 누락 시 기본값 저장 — 완료
- **TICKET-3 (P1)**: 출석 기준 서버 시간 단일화 — `getTodayKey` Callable(Asia/Seoul) 추가 — 완료

## 이전 업데이트 (2026-04-11) — 변경사항 분석 반영

- 결과 페이지 고도화 (랭킹 카드 순차 등장 애니메이션, 통계 확장)
- 7일 경과 종료 로직 보강 (`checkGameExpiry` + `gameExpiresAt`)
- 상점 랜덤박스 서버 위임 (`openLootBox` Callable)
- 아이템 사용 로그 (`groups/{groupId}/itemUsages`) 기록 및 통계 연동
- FCM 서비스 신설, 스플래시 스크린 반영

---

## TODO 리스트

### 진행 순서 (권장)

1. **환경 설정** — Firebase 프로젝트 생성 → `flutterfire configure` → 플랫폼 파일 배치 → `build_runner` 실행
2. **인증 · 그룹** — 로그인 + 홈 화면 + 그룹 생성/참여 + 닉네임 설정
3. **백엔드 · 서버** — Firestore 보안 규칙 + Cloud Functions 배포
4. **게임 로직** — 폭탄 전달 + 타이머 + 종료 조건 + 아이템 효과
5. **상점 · 미션** — 재화 시스템 + 상점 방식 결정 후 구현
6. **UI · 디자인** — 결과 페이지 연출 + 공유카드 + 아이콘/스플래시

---

### 환경 설정
- [x] Firebase 프로젝트 생성 및 팀원 초대
- [x] `flutterfire configure` 실행 후 각자 `firebase_options.dart` 생성
- [x] `google-services.json` / `GoogleService-Info.plist` 배치
- [x] `dart run build_runner build` 실행 (freezed / riverpod 코드 생성)
- [ ] CI 구성 검토 (GitHub Actions + flutter test)

### 인증 · 그룹
- [x] 익명 로그인 완성 (AuthController → UserModel Firestore 저장)
- [x] AuthGate — 로그인 상태 실시간 감지 및 홈 화면 라우팅 연동
- [x] 홈 화면 구현 — 참여 중인 그룹 목록뷰 (그룹명 / 내 닉네임 / 간단 현황)
- [x] 그룹 생성 / 참여코드 입력 화면 구현
- [x] 그룹 참여 시점에 그룹별 닉네임 입력 화면 추가
- [x] 다중 그룹 참여 지원 — `UserModel`에 `groupIds` + `groupNicknames` + `groupCurrencies` + `groupOwnedItemIds`
- [x] 대기실 별도 라우트 제거 — 게임 화면 내 `waiting` 상태 UI로 처리
- [x] 대기실 상태 — 방장 권한 판단 (첫 번째 memberUid), 강퇴 기능
- [x] `UserRepository` — `watchUser`, `setUser`, `addGroupMembership`, `updateGroupNickname`, `removeGroupMembership`
- [x] 중복 참여 방지 — `joinGroup`에서 중복 멤버/정원 초과를 트랜잭션으로 검증
- [x] 참여코드 생성 클라이언트 유지 — 서버 `createGroup`에서 `already-exists` 검증 + 클라이언트 1회 재시도
- [x] 그룹 나가기/방 폐쇄 — 마지막 멤버 탈퇴 시 그룹 문서 삭제, 스트림 해제 후 비동기 처리
- [x] 딥링크 참여 (`bombastic://join?code=XXXXX`) + 카카오 링크 공유

### 백엔드 · 서버
- [x] `startGame` Callable Function — 방장 전용, 최소 2명 확인 후 폭탄 생성 + 그룹 `playing` 전환
- [x] `onGroupMemberJoined` 트리거 — `maxMembers` 동적 비교
- [x] Firestore 보안 규칙 완성 (`firestore.rules`, 160줄)
- [x] Firestore `shopItems` 시드 스크립트 (`functions/src/seeds/`)
- [x] Cloud Functions 배포 완료 (likelion-holycow, us-central1)
- [x] `checkBombExpiry` 스케줄러 (1분 주기) + `onBombExploded` Firestore trigger
- [x] `checkGameExpiry` 스케줄러 (1분 주기, 7일 경과 게임 자동 종료)
- [x] 폭탄 만료 시간 Functions 공통 설정(`BOMB_DEFAULT_DURATION_SECONDS`, 기본 86400초)
- [x] FCM 채널 ID 통일 (`bombastic_channel`)

### 게임 로직
- [x] `passBomb` — `memberUids` 인덱스 기반 순환 로직
- [x] `activeBombProvider` / `isMyTurnProvider` — groupId family provider
- [x] `GamePage` — `GroupStatus`에 따라 `_WaitingView` / `_PlayingTabView` / `_FinishedView` 분기
- [x] 7일 경과 정상 종료 처리 — `checkGameExpiry` + `gameExpiresAt`
- [x] 아이템 속성 분리: bombHolder 전용 / always 사용 가능 / passive 자동 발동
- [x] 아이템 효과 구현 (`swapOrder`, `reverseDirection`, `shrinkDuration`, `guardianAngel`)
- [x] 아이템 사용 UI — 인벤토리 가로 스크롤 바, 확인 다이얼로그, 사용 결과 스낵바
- [x] 미션 완료 판단 트리거 — `onPassCreated`/`onUserUpdated` Firestore trigger
- [x] 출석 체크 중복 방지 (서버 todayKey 기준)

### 상점 · 미션
- [x] 랜덤박스 서버 위임 구현 (`openLootBox` Callable, 가중치 랜덤 + 재화 차감 + 지급)
- [x] 재화 잔액 실시간 표시 (`GroupCurrencyBadge` AppBar 배지)
- [x] 일일 출석 체크 (서버 todayKey, 그룹별 1회, 50 재화)
- [x] 미션 7종 구현 (첫 패스, 첫 아이템, 5/10회 패스, 랜덤박스 3회, 10분 이내 빠른 패스)
- [ ] 개별 아이템 직접 구매 정책 확정 (현재 랜덤박스만 운영)

### 결과 페이지
- [x] `gameResult` provider — 폭발 횟수/패스 횟수/최장 홀딩/아이템 사용 집계
- [x] `ResultPage` — 순차 등장 애니메이션 (Fade/Slide, 150ms 간격)
- [x] `ResultShareCard` — 그라디언트 카드, 메달, 통계 표시
- [x] `share_plus` 연동 — 스크린샷 캡처 + 공유 (로딩/에러 처리 포함)
- [x] 엔딩 크레딧 — 28초 스크롤, 명예의 전당 어워드 6종, 패배자 전용 강조 UI

### UI · 디자인
- [x] 대기실 UI — 참여 코드 + 공유 버튼, 참여자 목록, 방장 게임 시작 버튼
- [x] 게임 화면 — 폭탄 보유자/타이머/전달 순서/인벤토리/전달 버튼
- [x] 다크모드 대응 (`AppTheme.dark`)
- [x] 테마 설정 (시스템/라이트/다크)
- [x] 관리자 도구 (6개 CLI 명령어 다이얼로그)
- [ ] 앱 아이콘 최종 작업 (스플래시는 반영 완료)
- [ ] 푸시 알림 게임 이벤트 연동 (FCM 인프라는 구축 완료, 게임 이벤트 트리거 미구현)

---

## 현재 프로젝트 구조

### Flutter App (`lib/`)

```
lib/
  main.dart                             # Firebase init, ProviderScope, MaterialApp.router, 딥링크 핸들링
  core/
    controllers/auth_controller.dart    # Firebase 익명 로그인
    repositories/auth_repository.dart   # Auth SDK 래퍼
    router/app_router.dart              # GoRouter (7 routes)
    theme/app_theme.dart                # Light/Dark 테마
    theme/theme_provider.dart           # 테마 상태 (SharedPreferences)
    services/fcm_service.dart           # FCM 채널/권한/토큰
    constants/app_constants.dart        # 상수 (폭탄 기본 시간, 그룹 최대 인원 등)
    utils/date_utils.dart               # 날짜 포맷
  data/
    firebase/firebase_providers.dart    # Firestore, Auth, Messaging, Functions providers
    models/                             # freezed 모델
      bomb_model.dart                   # active|exploded|defused, holderUid, expiresAt
      group_model.dart                  # waiting|playing|finished, memberUids, memberNicknames
      user_model.dart                   # groupIds, groupNicknames, groupCurrencies, groupOwnedItemIds
      shop_item_model.dart              # itemType, probability, usageType (bombHolder|always|passive)
      mission_model.dart                # 미션 정의
      game_result_model.dart            # PlayerResultModel + GameResultModel
    repositories/
      bomb_repository.dart              # watchActiveBomb, passBomb, fetchExplodedBombs, logPass
      group_repository.dart             # CRUD + watchGroup, leaveGroup, kickMember
      user_repository.dart              # watchUser, groupMembership 관리
      shop_repository.dart              # shopItems, 인벤토리
      mission_repository.dart           # 미션 조회
  features/
    auth/     — AuthGate (인증 상태 기반 라우팅)
    home/     — 그룹 목록, 생성/참여 진입점
    group/    — 그룹 생성/참여, 닉네임 입력, 딥링크 참여
    game/     — 게임 페이지 (waiting/playing/finished 분기)
      controllers/ — GameController, TimerController, CreditsController
      pages/tabs/  — HomeTab, LogTab, SettingsTab
      widgets/     — EndingCreditsOverlay
    mission/  — 일일 미션 + 출석 체크
    shop/     — 랜덤박스 구매 + 인벤토리
    result/   — 결과 랭킹 + 공유 카드
    admin/    — 관리자 CLI 도구
  widgets/    — LoadingOverlay, GroupCurrencyBadge, CurrencyIcon, ItemIcon
```

### Cloud Functions (`functions/src/`)

| 파일 | 함수 | 유형 | 설명 |
|------|------|------|------|
| `bomb/passBombCallable.ts` | `passBomb` | Callable | 폭탄 전달 (순환 순서, pass 로그) |
| `bomb/explodeBombCallable.ts` | `explodeBomb` | Callable | 폭발 처리 (수호천사 방어 +10초) |
| `bomb/bombExpireScheduler.ts` | `checkBombExpiry` | Schedule (1분) | 만료 폭탄 자동 처리 |
| | `checkGameExpiry` | Schedule (1분) | 7일 경과 게임 자동 종료 |
| | `onBombExploded` | Trigger | 폭발 시 게임 즉시 종료 |
| `items/itemController.ts` | `useItem` | Callable | 아이템 효과 적용 + 사용 로그 |
| `items/lootBoxController.ts` | `openLootBox` | Callable | 가중치 랜덤 뽑기 (재화 차감 + 지급) |
| `mission/missionController.ts` | `getTodayKey` | Callable | 서울 시간 기준 날짜 키 |
| | `checkIn` | Callable | 그룹별 일일 출석 (50 재화) |
| `mission/missionTriggers.ts` | `onPassCreated` | Trigger | 패스 시 미션 달성 검사 |
| | `onUserUpdated` | Trigger | 아이템/랜덤박스 미션 검사 |
| `group/groupTriggers.ts` | `startGame` | Callable | 방장 게임 시작 |
| | `onGroupMemberJoined` | Trigger | 인원 충족 시 자동 시작 |
| `admin/adminCallable.ts` | `adminCommand` | Callable | /money, /items, /mission, /steal, /explode, /endgame |
| `notification/fcmSender.ts` | — | (placeholder) | 푸시 알림 (미구현) |

### Firestore 구조

```
users/{uid}
  - uid, groupIds[], groupNicknames{}, groupCurrencies{}, groupOwnedItemIds{}
  - checkedInDates{groupId: [dateKeys]}, completedMissionIds{groupId: [ids]}

groups/{groupId}
  - name, joinCode, hostUid, maxMembers, status (waiting|playing|finished)
  - memberUids[], memberNicknames{}, createdAt, gameExpiresAt, gameEndedAt
  bombs/{bombId}          # holderUid, expiresAt, status, round, explodedUid
  passes/{passId}         # fromUid, toUid, timestamp
  itemUsages/{usageId}    # uid, itemType, usedAt
  results/{resultId}      # summary (memberUids, penaltyCount, reason, finalizedAt)

shopItems/{itemId}        # name, description, price, probability, usageType
missions/{missionId}      # 미션 정의
```

---

## 의존성 요약 (pubspec.yaml)

**런타임 (19개):**
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `cloud_functions`
- 상태관리: `flutter_riverpod`, `riverpod_annotation`
- 라우팅: `go_router`
- 코드생성: `freezed_annotation`, `json_annotation`
- 공유: `screenshot`, `share_plus`, `kakao_flutter_sdk_share`
- UI: `intl`, `gap`, `cached_network_image`
- 유틸: `uuid`, `shared_preferences`, `flutter_local_notifications`, `vibration`, `app_links`

**SDK**: Dart >=3.8.0 <4.0.0

---

## 코드 레벨 버그 / 주의 사항

> 해결된 항목은 접어두고, 현재 활성 이슈만 상단에 배치.

### 현재 활성 이슈

| 파일 | 문제 | 수정 방향 |
|------|------|-----------|
| `notification/fcmSender.ts` | FCM 인프라만 구축, 게임 이벤트(폭탄 전달, 폭발, 턴 알림) 푸시 미구현 | 각 Callable/Trigger에서 FCM 전송 로직 추가 |
| `settings_tab.dart` | `RadioListTile`의 `groupValue`/`onChanged` 속성 deprecated (Flutter 3.32+) | `RadioGroup` ancestor 패턴으로 전환 |

### 해결된 이슈

| 파일 | 문제 | 해결 |
|------|------|------|
| `game_page.dart` | 방 폐쇄/나가기 시 무한 로딩 + 권한 오류 | 홈 이동 후 비동기 `leaveGroup` + error 핸들러에서 홈 이동 |
| `group_repository.dart` | `joinGroup` 중복 참여/정원 초과 미검증 | 트랜잭션 내 검증 추가 |
| `result_controller.dart` | 공유 시 에러 핸들링 부재 | 2단계 에러 처리 + 로딩 상태 추가 |
| `bombExpireScheduler.ts` | `checkGameExpiry` 주기 60분으로 설정됨 | 1분으로 복원 |
| summary 저장 | `memberUids`/`penaltyCount` 누락 시 저장 실패 | null-safe 기본값 정책 적용 |

---

## 개발 방향성 & 결정 사항

### 아키텍처
- **단방향 데이터 흐름**: Firestore onSnapshot → Repository Stream → Riverpod Provider → UI
- **쓰기는 Cloud Functions 우선**: 폭탄 생성·폭발처럼 무결성이 중요한 쓰기는 Functions Callable/Trigger 경유
- **로컬 상태 최소화**: 타이머조차 `expiresAt` 서버값 기준으로 계산 (클라이언트 조작 방지)

### 네이밍 컨벤션
- Provider: `xxxProvider` (Riverpod @riverpod 자동 생성)
- Controller: `XxxController extends _$XxxController`
- Model: `XxxModel` (freezed)
- Page: `XxxPage` (ConsumerWidget or ConsumerStatefulWidget)
- Repository: `XxxRepository`

### 브랜치 전략
```
main        ← 배포 가능한 상태만
develop     ← 통합 브랜치
feat/xxx    ← 기능 브랜치
fix/xxx     ← 버그 수정
```

---

## 간단 방향성 메모

### 스크린 구성 및 흐름

```
AuthGate
  └─ 홈 (그룹 목록)
       ├─ 그룹 생성 / 참여코드 입력
       │    └─ 닉네임 설정 (그룹별 1회)
       │         └─ 게임 화면
       │              ├─ [waiting] 대기 UI — 인원 모이는 중
       │              ├─ [playing] 게임 UI — 5탭 (상점/미션/홈/로그/설정)
       │              └─ [finished] 종료 UI — 엔딩 크레딧 → 3탭 (홈/로그/설정)
       └─ 기존 그룹 항목 탭
             └─ 게임 화면 (동일, 현재 상태에 따라 UI 분기)
```

### 기능 설명
- 방장이 그룹 생성 시 **그룹 이름** + **참가 인원(2~10명)** 설정 → 참여코드/초대링크 공유
- 참여 시 그룹별 닉네임 설정 후 대기, 방장이 게임 시작 버튼 클릭 (최소 2명)
- 정해진 시간 이내에 아이템 적용 후 다음 친구에게 폭탄 전달, 실패 시 폭발 → 게임 즉시 종료
- 7일 경과 시에도 자동 종료 → 결과 페이지
- 기본 전제: 친구들끼리 내기를 걸고 플레이

### 세부 기능
- 일일 출석 + 미션 7종으로 재화 획득
- 재화로 랜덤박스(100 코인) 구매 → 가중치 랜덤 아이템 획득
- 아이템 4종: 순서 섞기, 방향 반전, 타이머 단축, 수호천사(패시브, 폭발 방어 +10초)
- 게임 종료 시 엔딩 크레딧(28초) + 명예의 전당 어워드 6종 + 결과 카드 SNS 공유

### 궁극적 목표
- 친한 친구들끼리 우리끼리만의 친밀 커뮤니케이션 도모
- 내기를 건 승부인 만큼 조마조마하며 즐길 수 있게 설계
- 앱을 자주 열게 만들어 상대방의 일상에 계속 존재감을 남기는 것

---

## 미결 사항

| # | 주제 | 비고 |
|---|------|------|
| 1 | **푸시 알림 게임 이벤트** | FCM 인프라 완료, 폭탄 전달/폭발/턴 알림 트리거 미구현 |
| 2 | **개별 아이템 직접 구매** | 현재 랜덤박스만 운영, 직접 구매 정책 미결 |
| 3 | **CI 구성** | GitHub Actions + flutter test 미설정 |
| 4 | **앱 아이콘** | 스플래시는 반영 완료, 아이콘 최종 작업 필요 |
| 5 | **RadioListTile deprecated** | Flutter 3.32+ `RadioGroup` 패턴 전환 필요 |

---

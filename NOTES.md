# 📋 Bombastic 개발 노트

> 팀원 공용 메모판. 결정사항·방향성·논의 내용을 여기에 자유롭게 기록하세요.
> 커밋 메시지보다 덜 형식적으로, 이슈보다 더 빠르게.

---

## ✅ TODO 리스트

### 공통 / 인프라
- [ ] Firebase 프로젝트 생성 및 팀원 초대
- [ ] `flutterfire configure` 실행 후 각자 `firebase_options.dart` 생성
- [ ] `google-services.json` / `GoogleService-Info.plist` 배치
- [ ] Firestore 보안 규칙 초안 작성 (`firestore.rules`)
- [ ] FCM 채널 ID 통일 (`bomb_pass_channel`)
- [ ] `dart run build_runner build` 실행 (freezed / riverpod 코드 생성)
- [ ] CI 구성 검토 (GitHub Actions + flutter test)

### A 담당 — Auth / Group
- [ ] 익명 로그인 완성 (AuthController → UserModel Firestore 저장)
- [ ] 참여코드 중복 검사 로직 (Cloud Functions Callable로 이동 검토)
- [ ] `currentGroupIdProvider` 구현 (UserModel.currentGroupId 기반)
- [ ] 대기실 — 방장 권한 판단 (첫 번째 memberUid)
- [ ] 그룹 탈주(중도 이탈) 처리 방침 결정 → 아래 **미결 사항** 참고

### B 담당 — Game / Cloud Functions
- [ ] `game_controller.dart` — `passBomb`의 groupId / nextHolder 실제 연결
- [ ] 고정 순서 순환 로직 구현 (`memberUids` 인덱스 기반)
- [ ] Cloud Functions 배포 및 에뮬레이터 테스트
- [ ] `checkBombExpiry` 스케줄러 동작 확인 (1분 주기)
- [ ] 폭발 후 다음 라운드 자동 폭탄 생성 (`onBombExploded` TODO 채우기)
- [ ] 게임 종료 조건 결정 → 아래 **미결 사항** 참고

### C 담당 — Shop / Mission
- [ ] Firestore `shopItems` 컬렉션 초기 데이터 시드 스크립트 작성
- [ ] 아이템 사용 로직 구현 (순서 바꾸기, 폭탄 추가, 패널티 강화)
- [ ] 미션 완료 판단 트리거 (Firestore 기반 또는 클라이언트 검증)
- [ ] 재화 잔액 실시간 표시 (UserModel 스트림 → AppBar 배지)
- [ ] 출석 체크 중복 방지 확인 (서버타임스탬프 기준)

### D 담당 — Result / UI
- [ ] `result_controller.dart` — groupId 연결, displayName 실제 조회
- [ ] 공유카드 디자인 완성 (`ResultShareCard`)
- [ ] `share_plus` 패키지 추가 및 이미지 공유 구현
- [ ] 앱 아이콘 / 스플래시 스크린 (`flutter_native_splash`)
- [ ] 다크모드 대응 확인
- [ ] 명예의 전당 — 과거 게임 기록 보존 여부 결정

---

## 🔀 개발 방향성 & 결정 사항

### 아키텍처
- **단방향 데이터 흐름**: Firestore onSnapshot → Repository Stream → Riverpod Provider → UI
- **쓰기는 Cloud Functions 우선**: 폭탄 생성·폭발처럼 무결성이 중요한 쓰기는 클라이언트 직접 쓰기 금지, Functions Callable or Trigger 경유
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
feat/A-xxx  ← 기능 브랜치 (담당자/작업명)
fix/xxx     ← 버그 수정
```

### 커밋 메시지
```
feat(game): 폭탄 전달 로직 구현
fix(group): 참여코드 중복 체크 누락 수정
chore: build_runner 생성 파일 제외
```

---

## ❓ 미결 사항 (논의 필요)

| # | 주제 | 옵션 | 담당 |
|---|------|------|------|
| 1 | **게임 종료 조건** | A) 고정 기간(4~7일) 만료 B) 총 라운드 수 도달 C) 수동 종료 | 전원 |
| 2 | **중도 이탈 처리** | A) 이탈 불가 B) 남은 3명으로 계속 C) 게임 종료 | 전원 |
| 3 | **참여코드 생성 위치** | A) 클라이언트(현재) B) Cloud Functions Callable | A |
| 4 | **displayName 입력** | A) 익명 유지(uid 앞 4자리) B) 닉네임 입력 화면 추가 | A·D |
| 5 | **아이템 사용 시점** | A) 즉시 발동 B) 다음 라운드부터 적용 | B·C |
| 6 | **진동/알람 세기** | 폭발 시 최대 진동 vs 단계적 강화 패널티 | C |

---

## 📝 회의록

### 2026-04-10 — 킥오프
- 프로젝트 뼈대 세팅 완료
- 역할 분담: A(Auth/Group), B(Game/Functions), C(Shop/Mission), D(Result/UI)
- 다음 목표: Firebase 프로젝트 생성 후 각자 로컬 환경 세팅

---

#!/usr/bin/env bash
# ============================================================
#  BombPass 개발 환경 초기 세팅 스크립트
#  사용법: bash setup.sh
#  처음 클론 후, 또는 의존성이 꼬였을 때 실행하세요.
# ============================================================

set -euo pipefail

# ── 색상 출력 헬퍼 ───────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${CYAN}━━━ $* ━━━${NC}"; }

# ── 0. 사전 조건 확인 ────────────────────────────────────────
step "사전 조건 확인"

command -v flutter >/dev/null 2>&1 || error "Flutter SDK가 없습니다. https://docs.flutter.dev/get-started/install"
command -v dart    >/dev/null 2>&1 || error "Dart SDK가 없습니다 (Flutter에 포함)."
command -v node    >/dev/null 2>&1 || error "Node.js가 없습니다. https://nodejs.org (권장: v20 LTS)"
command -v npm     >/dev/null 2>&1 || error "npm이 없습니다. Node.js 설치 시 함께 설치됩니다."
command -v firebase >/dev/null 2>&1 || warn "Firebase CLI가 없습니다. 설치: npm install -g firebase-tools"

flutter --version | head -1
node --version
npm --version
success "사전 조건 통과"

# ── 1. Flutter 패키지 설치 ───────────────────────────────────
step "Flutter 패키지 설치 (pub get)"

flutter pub get
success "Flutter 패키지 설치 완료"

# ── 2. 코드 생성 (freezed / riverpod_generator) ──────────────
step "코드 생성 (build_runner)"

dart run build_runner build --delete-conflicting-outputs
success "코드 생성 완료 (*.g.dart, *.freezed.dart)"

# ── 3. Cloud Functions 의존성 설치 ──────────────────────────
step "Cloud Functions 의존성 설치 (npm install)"

pushd functions > /dev/null
npm install
success "npm install 완료"

info "TypeScript 빌드 중..."
npm run build
success "Functions 빌드 완료 (functions/lib/)"
popd > /dev/null

# ── 4. Firebase 설정 안내 ────────────────────────────────────
step "Firebase 설정 확인"

FIREBASE_OPTIONS="lib/firebase_options.dart"
GOOGLE_SERVICES_ANDROID="android/app/google-services.json"
GOOGLE_SERVICES_IOS="ios/Runner/GoogleService-Info.plist"

MISSING=0

if grep -q "YOUR_ANDROID_API_KEY" "$FIREBASE_OPTIONS" 2>/dev/null; then
  warn "firebase_options.dart가 아직 placeholder 상태입니다."
  warn "  → 아래 명령어를 실행하세요:"
  warn "     dart pub global activate flutterfire_cli"
  warn "     flutterfire configure"
  MISSING=1
else
  success "firebase_options.dart 설정됨"
fi

if [ ! -f "$GOOGLE_SERVICES_ANDROID" ]; then
  warn "google-services.json이 없습니다 (android/app/ 에 배치 필요)"
  MISSING=1
else
  success "google-services.json 존재"
fi

if [ ! -f "$GOOGLE_SERVICES_IOS" ]; then
  warn "GoogleService-Info.plist가 없습니다 (ios/Runner/ 에 배치 필요)"
  MISSING=1
else
  success "GoogleService-Info.plist 존재"
fi

# ── 5. flutter doctor 요약 ───────────────────────────────────
step "Flutter 환경 진단 (flutter doctor)"

flutter doctor --no-analytics 2>&1 | grep -E "^\[|Flutter|Dart|Android|Xcode|Connected" || true

# ── 완료 ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  세팅 완료!${NC}"
echo -e "${GREEN}============================================${NC}"

if [ "$MISSING" -eq 1 ]; then
  echo -e "${YELLOW}  위 WARN 항목을 해결한 뒤 앱을 실행하세요.${NC}"
fi

echo ""
echo "  앱 실행:          flutter run"
echo "  코드 생성 (감시):  dart run build_runner watch"
echo "  Functions 에뮬:   cd functions && npm run serve"
echo ""

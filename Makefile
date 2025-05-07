.PHONY: all setup _requirements image-build compose-up compose-down compose-logs run clean help \
	download-samples mock-disk mock-network mock-process mock-video mock-upload test test-unit test-integration test-coverage

# 색상 정의 및 스타일
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
BOLD = \033[1m
UNDERLINE = \033[4m
NC = \033[0m # No Color

# 이미지 설정
IMAGE_NAME = kafka-cctv-streaming
DEFAULT_TAG = latest

# 기본 목표
.DEFAULT_GOAL := help

# 모든 작업 수행
all: setup image-build compose-up
	@echo "$(GREEN)$(BOLD)✓ 모든 작업이 완료되었습니다. 시스템이 실행 중입니다.$(NC)"

# 초기 환경 설정
setup: 
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)환경 설정 시작$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)$(BOLD)⚠ .env 파일이 없습니다. .env.example을 복사합니다.$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)$(BOLD)✓ .env 파일이 생성되었습니다. 필요한 값을 수정해주세요.$(NC)"; \
	fi
	@if [ ! -d localstack-data ]; then \
		echo "$(BLUE)$(BOLD)➤ localstack-data 디렉토리를 생성합니다.$(NC)"; \
		mkdir -p localstack-data; \
	fi
	@echo "$(GREEN)$(BOLD)✓ 환경 설정 완료$(NC)"

# Poetry 의존성 내보내기
_requirements:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)의존성 파일 생성 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@if ! command -v poetry &> /dev/null; then \
		echo "$(RED)$(BOLD)✗ Poetry가 설치되어 있지 않습니다. 설치해주세요.$(NC)"; \
		echo "설치 명령어: pip install poetry"; \
		exit 1; \
	fi
	@poetry --version | awk '{print "Poetry 버전: " $$NF}'
	@echo "의존성 내보내는 중..."
	@poetry export -f requirements.txt --output requirements.txt --without-hashes --with dev
	@if [ -f requirements.txt ]; then \
		echo "$(GREEN)$(BOLD)✓ 의존성 내보내기 완료$(NC)"; \
		echo "총 패키지 수: $$(wc -l < requirements.txt)"; \
	else \
		echo "$(RED)$(BOLD)✗ 의존성 내보내기 실패$(NC)"; \
	fi

# Docker 이미지 빌드
image-build: _requirements
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)Docker 이미지 빌드 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@echo "$(BLUE)$(BOLD)➤ Docker Image - $(IMAGE_NAME):$(DEFAULT_TAG) 생성 중...$(NC)"
	@docker build -t $(IMAGE_NAME):$(DEFAULT_TAG) .
	@echo "$(GREEN)$(BOLD)✓ Docker 이미지 빌드 완료$(NC)"

# Docker Compose 시작
compose-up: 
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)Docker 컨테이너 시작 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@docker compose up -d
	@echo "$(GREEN)$(BOLD)✓ Kafka CCTV 스트리밍 시스템이 백그라운드에서 실행 중입니다.$(NC)"
	@echo ""
	@echo "$(CYAN)컨테이너 상태:$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(CYAN)로그 확인 명령어:$(NC) make compose-logs"

# Docker Compose 중지
compose-down:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)Docker 컨테이너 중지 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@docker compose down
	@echo "$(GREEN)$(BOLD)✓ Kafka CCTV 스트리밍 시스템이 중지되었습니다.$(NC)"

# Docker Compose 로그 확인
compose-logs:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)Docker 컨테이너 로그 확인$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)로그 종료: Ctrl+C$(NC)"
	@echo ""
	@docker compose logs -f

# 로컬에서 실행
run:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)로컬에서 애플리케이션 실행 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@python -m app.cctv_producer.main

# 정리
clean:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)시스템 정리 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@echo "$(BLUE)$(BOLD)➤ Docker 컨테이너 및 이미지를 정리합니다.$(NC)"
	@docker compose down -v
	@if docker image inspect $(IMAGE_NAME):$(DEFAULT_TAG) > /dev/null 2>&1; then \
		docker rmi $(IMAGE_NAME):$(DEFAULT_TAG); \
	else \
		echo "$(YELLOW)$(BOLD)⚠ 이미지가 존재하지 않습니다.$(NC)"; \
	fi
	@echo "$(BLUE)$(BOLD)➤ 생성된 파일들을 정리합니다.$(NC)"
	@rm -f requirements.txt
	@find . -type d -name __pycache__ -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@echo "$(GREEN)$(BOLD)✓ 정리 완료$(NC)"

# 테스트 실행
test:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)테스트 실행 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@if ! command -v pytest &> /dev/null; then \
		echo "$(RED)$(BOLD)✗ pytest가 설치되어 있지 않습니다. 설치해주세요.$(NC)"; \
		echo "설치 명령어: pip install pytest"; \
		exit 1; \
	fi
	@if [ ! -d "tests" ]; then \
		echo "$(RED)$(BOLD)✗ tests 디렉토리가 존재하지 않습니다.$(NC)"; \
		exit 1; \
	fi
	@echo "$(CYAN)테스트 파일 목록:$(NC)"
	@find tests -name "test_*.py" | sort
	@echo ""
	@echo "$(CYAN)pytest 실행:$(NC)"
	@mkdir -p targets
	@pytest tests -v | tee targets/test_output.txt
	@echo "$(GREEN)$(BOLD)✓ 테스트 완료$(NC)"
	@echo "$(CYAN)테스트 결과가 targets/test_output.txt에 저장되었습니다.$(NC)"

# 단위 테스트만 실행
test-unit:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)단위 테스트 실행 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@if ! command -v pytest &> /dev/null; then \
		echo "$(RED)$(BOLD)✗ pytest가 설치되어 있지 않습니다. 설치해주세요.$(NC)"; \
		echo "설치 명령어: pip install pytest"; \
		exit 1; \
	fi
	@echo "$(CYAN)단위 테스트 파일 목록:$(NC)"
	@find tests/unit -name "test_*.py" 2>/dev/null | sort || echo "tests/unit 디렉토리가 없습니다."
	@echo ""
	@if [ -d "tests/unit" ]; then \
		echo "$(CYAN)단위 테스트 실행:$(NC)"; \
		mkdir -p targets; \
		pytest tests/unit -v | tee targets/unit_test_output.txt; \
		echo "$(GREEN)$(BOLD)✓ 단위 테스트 완료$(NC)"; \
		echo "$(CYAN)테스트 결과가 targets/unit_test_output.txt에 저장되었습니다.$(NC)"; \
	else \
		echo "$(YELLOW)$(BOLD)⚠ tests/unit 디렉토리가 없습니다. 테스트 디렉토리 구조를 확인해주세요.$(NC)"; \
	fi

# 통합 테스트만 실행
test-integration:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)통합 테스트 실행 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@if ! command -v pytest &> /dev/null; then \
		echo "$(RED)$(BOLD)✗ pytest가 설치되어 있지 않습니다. 설치해주세요.$(NC)"; \
		echo "설치 명령어: pip install pytest"; \
		exit 1; \
	fi
	@echo "$(CYAN)통합 테스트 파일 목록:$(NC)"
	@find tests/integration -name "test_*.py" 2>/dev/null | sort || echo "tests/integration 디렉토리가 없습니다."
	@echo ""
	@if [ -d "tests/integration" ]; then \
		echo "$(CYAN)통합 테스트 실행:$(NC)"; \
		mkdir -p targets; \
		pytest tests/integration -v | tee targets/integration_test_output.txt; \
		echo "$(GREEN)$(BOLD)✓ 통합 테스트 완료$(NC)"; \
		echo "$(CYAN)테스트 결과가 targets/integration_test_output.txt에 저장되었습니다.$(NC)"; \
	else \
		echo "$(YELLOW)$(BOLD)⚠ tests/integration 디렉토리가 없습니다. 테스트 디렉토리 구조를 확인해주세요.$(NC)"; \
	fi

# 테스트 커버리지 측정
test-coverage:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)테스트 커버리지 측정 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@if ! command -v pytest &> /dev/null || ! command -v pytest-cov &> /dev/null; then \
		echo "$(RED)$(BOLD)✗ pytest 또는 pytest-cov가 설치되어 있지 않습니다.$(NC)"; \
		echo "설치 명령어: pip install pytest pytest-cov"; \
		exit 1; \
	fi
	@if [ ! -d "tests" ]; then \
		echo "$(RED)$(BOLD)✗ tests 디렉토리가 존재하지 않습니다.$(NC)"; \
		exit 1; \
	fi
	@echo "$(CYAN)커버리지 측정 실행:$(NC)"
	@mkdir -p targets
	@pytest --cov=app.cctv_producer --cov=app.cctv_consumer tests/ --cov-report=term --cov-report=html:coverage_html --cov-report=xml:targets/coverage.xml | tee targets/coverage_output.txt
	@echo ""
	@echo "$(CYAN)HTML 커버리지 리포트가 coverage_html 디렉토리에 생성되었습니다.$(NC)"
	@echo "$(CYAN)XML 커버리지 결과가 targets/coverage.xml에 저장되었습니다.$(NC)"
	@echo "$(GREEN)$(BOLD)✓ 테스트 커버리지 측정 완료$(NC)"

# producer를 로컬에서 실행
producer:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)Producer 실행 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@python -m app.cctv_producer.main

# consumer를 로컬에서 실행
consumer:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(BLUE)$(UNDERLINE)Consumer 실행 중$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@python -m app.cctv_consumer.main

# 도움말
help:
	@echo ""
	@echo "$(CYAN)$(BOLD)┌──────────────────────────────────────────────────────┐$(NC)"
	@echo "$(CYAN)$(BOLD)│ $(PURPLE)$(BOLD)$(UNDERLINE)Kafka CCTV 스트리밍 시스템 명령어$(NC) $(CYAN)$(BOLD)│$(NC)"
	@echo "$(CYAN)$(BOLD)└──────────────────────────────────────────────────────┘$(NC)"
	@echo ""
	@echo "$(CYAN)$(BOLD)[ 기본 명령어 ]$(NC)"
	@echo "  $(GREEN)make setup$(NC)         - 초기 환경 설정"
	@echo "  $(GREEN)make image-build$(NC)   - Docker 이미지 빌드"
	@echo "  $(GREEN)make compose-up$(NC)    - Docker 컨테이너 시작"
	@echo "  $(GREEN)make compose-down$(NC)  - Docker 컨테이너 중지"
	@echo "  $(GREEN)make compose-logs$(NC)  - Docker 컨테이너 로그 확인"
	@echo "  $(GREEN)make producer$(NC)      - Producer 로컬에서 실행"
	@echo "  $(GREEN)make consumer$(NC)      - Consumer 로컬에서 실행"
	@echo "  $(GREEN)make clean$(NC)         - 정리"
	@echo "  $(GREEN)make all$(NC)           - 모든 작업 수행 (setup, image-build, compose-up)"
	@echo ""
	@echo "$(CYAN)$(BOLD)[ 테스트 ]$(NC)"
	@echo "  $(GREEN)make test$(NC)              - 모든 테스트 실행"
	@echo "  $(GREEN)make test-unit$(NC)         - 단위 테스트만 실행"
	@echo "  $(GREEN)make test-integration$(NC)  - 통합 테스트만 실행"
	@echo "  $(GREEN)make test-coverage$(NC)     - 테스트 커버리지 측정"
	@echo ""
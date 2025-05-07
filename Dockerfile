# 단일 스테이지 간소화된 Dockerfile
FROM python:3.12-slim

LABEL maintainer="Kafka CCTV Streaming System"
LABEL description="System for streaming and processing CCTV data from Korean National Transportation Information Center"

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt 파일 복사 (파일이 있는 경우)
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then \
    pip install --no-cache-dir -r requirements.txt; \
    else \
    echo "requirements.txt 파일이 없습니다. 필수 패키지를 설치합니다."; \
    pip install --no-cache-dir kafka-python pydantic requests python-dotenv loguru; \
    fi

# 로깅 디렉토리 생성
RUN mkdir -p /app/logs

# 애플리케이션 소스 코드 복사
COPY app/cctv_producer/ /app/cctv_producer/
COPY app/cctv_consumer/ /app/cctv_consumer/
COPY pyproject.toml* ./

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# 기본 명령어 설정
CMD ["python", "-m", "cctv_producer.main"]
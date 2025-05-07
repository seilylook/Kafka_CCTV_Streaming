# Kafka CCTV 스트리밍 프로젝트

국가교통정보센터에서 실시간 CCTV 데이터를 가져와 처리하는 간단한 Kafka 스트리밍 애플리케이션입니다.

## 개요

이 프로젝트는 다음 구성 요소로 이루어져 있습니다:

- **Producer**: API에서 CCTV 데이터를 가져와 Kafka 토픽으로 전송합니다
- **Consumer**: Kafka 토픽에서 CCTV 데이터를 소비하고 처리합니다
- **Kafka**: 스트리밍 데이터를 처리하는 메시지 브로커입니다
- **Zookeeper**: Kafka 조정에 필요합니다
- **Kafka UI**: Kafka 토픽을 모니터링하기 위한 웹 인터페이스입니다

## 사전 요구 사항

- Docker 및 Docker Compose
- Python 3.10+
- Poetry (Python 의존성 관리 도구)
- 국가교통정보센터에서 발급받은 API 키

## 시작하기

1. 이 저장소를 클론합니다:
   ```bash
   git clone <저장소-URL>
   cd kafka-cctv-streaming
   ```

2. 예제 파일에서 `.env` 파일을 생성합니다:
   ```bash
   make .env
   ```

3. `.env` 파일을 API 키 및 원하는 설정으로 업데이트합니다.

4. Docker 컨테이너를 시작합니다:
   ```bash
   make up
   ```

5. 로그를 확인합니다:
   ```bash
   make logs
   ```

6. 브라우저에서 [http://localhost:8080](http://localhost:8080)에 접속하여 Kafka UI를 확인합니다

7. 모든 컨테이너를 중지하려면:
   ```bash
   make down
   ```

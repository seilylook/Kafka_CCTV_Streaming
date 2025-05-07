import json
import time
from typing import Any, Dict, List

from kafka import KafkaProducer
from kafka.errors import KafkaError
from loguru import logger

from cctv_producer.api_client import get_client
from cctv_producer.config import settings


def create_kafka_producer() -> KafkaProducer:
    try:
        logger.info(f"Kafka에 연결 중: {settings.kafka_bootstrap_servers}")
        producer = KafkaProducer(
            bootstrap_servers=settings.kafka_bootstrap_servers,
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
            key_serializer=lambda v: v.encode("utf-8") if v else None,
        )
        logger.info("Kafka에 성공적으로 연결되었습니다.")
        return producer
    except KafkaError as e:
        logger.error(f"Kafka 연결 실패: {str(e)}")
        raise


def send_to_kafka(
    producer: KafkaProducer, topic: str, data: List[Dict[str, Any]]
) -> None:
    if not data:
        logger.warning("Kafka로 전송할 데이터가 없습니다.")
        return

    logger.info(f"Kafka 토픽 {topic}에 {len(data)}개의 레코드 전송 중...")
    for item in data:
        key = item.get("cctvname", None)
        future = producer.send(topic, key=key, value=item)

        try:
            future.get(timeout=10)
        except KafkaError as e:
            logger.error(f"Kafka로 메시지 전송 실패: {str(e)}")


def main() -> None:
    logger.info("CCTV Producer service 시작 중...")
    producer = create_kafka_producer()
    client = get_client()

    try:
        for _ in range(5):
            cctv_data = client.get_cctv_data()
            send_to_kafka(producer, settings.kafka_topic, cctv_data)

            logger.info(
                f"다음 데이터 가져오기까지 {settings.producer_fetch_interval} 초 대기 중..."
            )
            time.sleep(settings.producer_fetch_interval)
    except KeyboardInterrupt:
        logger.info("사용자에 의해 프로듀서 중지!")
    except Exception as e:
        logger.error(f"프로듀서 반복 중 오류: {str(e)}")
    finally:
        producer.flush()
        producer.close()
        logger.info("프로듀서 서비스 중지")


if __name__ == "__main__":
    main()

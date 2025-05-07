import json
from typing import Dict, Any, Optional

from kafka import KafkaConsumer
from kafka.errors import KafkaError
from loguru import logger

from cctv_consumer.config import settings
from cctv_consumer.processor import get_processor


def create_kafka_consumer() -> KafkaConsumer:
    try:
        logger.info(f"Kafka에 연결 중: {settings.kafka_bootstrap_servers}")
        consumer = KafkaConsumer(
            settings.kafka_topic,
            bootstrap_servers=settings.kafka_bootstrap_servers,
            group_id=settings.consumer_group_id,
            auto_offset_reset="earliest",
            enable_auto_commit=True,
            value_deserializer=lambda m: json.loads(m.decode("utf-8")),
            key_deserializer=lambda m: m.decode("utf-8") if m else None,
        )

        logger.info(
            f"Kafka에 성공적으로 연결되어 토픽 {settings.kafka_topic}을 구독했습니다."
        )
        return consumer

    except KafkaError as e:
        logger.error(f"Kafka 연결 실패: {str(e)}")
        return None


def process_message(
    processor, message_value: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    return processor.process_message(message_value)


def main() -> None:
    consumer = create_kafka_consumer()
    processor = get_processor()

    try:
        for message in consumer:
            try:
                processed_data = process_message(processor, message.value)

                if processed_data:
                    logger.info(
                        f"CCTV 데이터 처리 성공: {processed_data.get('name', '알 수 없음')}"
                    )

                    logger.debug(f"CCTV URL: {processed_data.get('url', 'N/A')}")
                    logger.debug(
                        f"위치: ({processed_data.get('location', {}).get('x', 0)}, "
                        f"{processed_data.get('location', {}).get('y', 0)})"
                    )

            except Exception as e:
                logger.error(f"메시지 처리 오류: {str(e)}")

    except KeyboardInterrupt:
        logger.info("키보드 인터럽트로 인해 컨슈머 중지")
    except Exception as e:
        logger.error(f"컨슈머 메인 루프 오류: {str(e)}")
    finally:
        # 리소스 정리
        consumer.close()
        logger.info("컨슈머 서비스 중지됨")


if __name__ == "__main__":
    main()

from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    kafka_bootstrap_servers: str = Field(..., env="KAFKA_BOOTSTRAP_SERVERS")
    kafka_topic: str = Field(..., env="KAFKA_TOPIC")

    apiKey: str = Field(..., env="apiKey")
    type: str = Field(..., env="type")  # 도로 유형(ex: 고속도로 / its: 국도)
    cctvType: str = Field(
        ..., env="cctvType"
    )  # CCTV 유형(1: 실시간 스트리밍 / 2: 동영상 파일 / 3: 정지 영상)

    minX: float = Field(..., env="minX")  # 최소 경도 영역
    maxX: float = Field(..., env="maxX")  # 최대 경도 영역
    minY: float = Field(..., env="minY")  # 최소 위도 영역
    maxY: float = Field(..., env="maxY")  # 최대 위도 영역
    getType: str = Field(..., env="getType")  # 출력 결과 형식(xml, json)

    # 프로듀서 설정
    producer_fetch_interval: int = Field(
        60, env="PRODUCER_FETCH_INTERVAL"
    )  # 데이터 가져오는 간격(초)

    # API URL (기본값은 실제 운영 URL)
    api_base_url: str = Field("https://openapi.its.go.kr:9443/cctvInfo")

    class Config:
        """Pydantic 설정."""

        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()

from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    kafka_bootstrap_servers: str = Field(..., env="KAFKA_BOOTSTRAP_SERVERS")
    kafka_topic: str = Field(..., env="KAFKA_TOPIC")
    consumer_group_id: str = Field(..., env="CONSUMER_GROUP_ID")

    class Config:
        """Pydantic 설정."""

        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()

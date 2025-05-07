import json
from typing import Any, Dict, List, Optional

import requests
from loguru import logger

from cctv_producer.config import settings


class CCTVApiClient:
    def __init__(self) -> None:
        self.base_url = settings.api_base_url
        self.apiKey = settings.apiKey
        self.type = settings.type
        self.cctvType = settings.cctvType
        self.minX = settings.minX
        self.maxX = settings.maxX
        self.minY = settings.minY
        self.maxY = settings.maxY
        self.getType = settings.getType

    def get_cctv_data(self) -> List[Dict[str, Any]]:
        # apiKey, type, cctvType, minX, maxX,
        params = {
            "apiKey": self.apiKey,
            "type": self.type,
            "cctvType": self.cctvType,
            "minX": self.minX,
            "maxX": self.maxX,
            "minY": self.minY,
            "maxY": self.maxY,
            "getType": self.getType,
        }

        try:
            logger.info("API에서 CCTV 데이터 가져오는 중")
            response = requests.get(self.base_url, params=params, timeout=30)
            response.raise_for_status()

            # get_type에 따라 응답 파싱
            if self.getType.lower() == "json":
                data = response.json()
                # 응답에서 데이터 추출 - API 응답 구조에 맞게 조정
                if "response" in data and "data" in data["response"]:
                    logger.info(
                        f"총 {len(data['response']['data'])}개의 CCTV 데이터를 가져왔습니다."
                    )
                    return data["response"]["data"]
                else:
                    logger.error(f"예상치 못한 API 응답 구조: {data}")
                    return []
            else:  # XML 응답
                logger.error("XML 응답 형식은 구현되지 않았습니다")
                return []

        except requests.exceptions.RequestException as e:
            logger.error(f"CCTV 데이터 가져오기 실패: {str(e)}")
            return []
        except json.JSONDecodeError as e:
            logger.error(f"JSON 응답 파싱 오류: {str(e)}")
            return []
        except Exception as e:
            logger.error(f"오류가 발생했습니다: {str(e)}")
            return []


def get_client() -> CCTVApiClient:
    return CCTVApiClient()

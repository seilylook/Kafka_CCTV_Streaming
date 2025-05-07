from typing import Any, Dict, Optional
from loguru import logger


class CCTVDataProcessor:
    def process_message(self, message: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            logger.info(f"CCTV 데이터 처리 중: {message.get("cctvname", "알 수 없음")}")

            processed = {
                "id": message.get("roadsectionid", "unknown"),
                "name": message.get("cctvname", "알 수 없음"),
                "url": message.get("cctvurl", ""),
                "location": {
                    "x": float(message.get("coordx", 0)),
                    "y": float(message.get("coordy", 0)),
                },
                "resolution": message.get("cctvresolution", ""),
                "format": message.get("cctvformat", ""),
                "timestamp": message.get("filecreatetime", ""),
            }

            return processed

        except Exception as e:
            logger.error(f"CCTV 데이터 처리 오류: {str(e)}")
            return None


def get_processor() -> CCTVDataProcessor:
    return CCTVDataProcessor()

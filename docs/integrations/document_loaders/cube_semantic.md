---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/cube_semantic.ipynb
description: Cube의 데이터 모델 메타데이터를 LLM에 전달할 수 있는 형식으로 검색하는 과정을 보여주는 노트북입니다.
---

# 큐브 시맨틱 레이어

이 노트북은 LLM에 임베딩으로 전달하기에 적합한 형식으로 큐브의 데이터 모델 메타데이터를 검색하는 과정을 보여줍니다. 이를 통해 맥락 정보를 향상시킬 수 있습니다.

### 큐브에 대하여

[큐브](https://cube.dev/)는 데이터 앱을 구축하기 위한 시맨틱 레이어입니다. 데이터 엔지니어와 애플리케이션 개발자가 현대 데이터 저장소에서 데이터를 액세스하고, 이를 일관된 정의로 구성하며, 모든 애플리케이션에 전달하는 데 도움을 줍니다.

큐브의 데이터 모델은 LLM이 데이터를 이해하고 올바른 쿼리를 생성하는 데 사용되는 구조와 정의를 제공합니다. LLM은 복잡한 조인 및 메트릭 계산을 탐색할 필요가 없으며, 큐브가 이를 추상화하고 비즈니스 수준 용어로 작동하는 간단한 인터페이스를 제공합니다. 이러한 단순화는 LLM이 오류를 덜 발생시키고 환각을 피하는 데 도움을 줍니다.

### 예시

**입력 인수 (필수)**

`큐브 시맨틱 로더`는 2개의 인수를 요구합니다:

- `cube_api_url`: 큐브 배포 REST API의 URL입니다. 기본 경로 구성에 대한 자세한 내용은 [큐브 문서](https://cube.dev/docs/http-api/rest#configuration-base-path)를 참조하십시오.
- `cube_api_token`: 큐브의 API 비밀을 기반으로 생성된 인증 토큰입니다. JSON 웹 토큰(JWT) 생성에 대한 지침은 [큐브 문서](https://cube.dev/docs/security#generating-json-web-tokens-jwt)를 참조하십시오.

**입력 인수 (선택 사항)**

- `load_dimension_values`: 모든 문자열 차원에 대한 차원 값을 로드할지 여부입니다.
- `dimension_values_limit`: 로드할 최대 차원 값 수입니다.
- `dimension_values_max_retries`: 차원 값을 로드하기 위한 최대 재시도 횟수입니다.
- `dimension_values_retry_delay`: 차원 값을 로드하기 위한 재시도 간 지연 시간입니다.

```python
<!--IMPORTS:[{"imported": "CubeSemanticLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.cube_semantic.CubeSemanticLoader.html", "title": "Cube Semantic Layer"}]-->
import jwt
from langchain_community.document_loaders import CubeSemanticLoader

api_url = "https://api-example.gcp-us-central1.cubecloudapp.dev/cubejs-api/v1/meta"
cubejs_api_secret = "api-secret-here"
security_context = {}
# Read more about security context here: https://cube.dev/docs/security
api_token = jwt.encode(security_context, cubejs_api_secret, algorithm="HS256")

loader = CubeSemanticLoader(api_url, api_token)

documents = loader.load()
```


다음 속성을 가진 문서 목록을 반환합니다:

- `page_content`
- `metadata`
  - `table_name`
  - `column_name`
  - `column_data_type`
  - `column_title`
  - `column_description`
  - `column_values`
  - `cube_data_obj_type`

```python
# Given string containing page content
page_content = "Users View City, None"

# Given dictionary containing metadata
metadata = {
    "table_name": "users_view",
    "column_name": "users_view.city",
    "column_data_type": "string",
    "column_title": "Users View City",
    "column_description": "None",
    "column_member_type": "dimension",
    "column_values": [
        "Austin",
        "Chicago",
        "Los Angeles",
        "Mountain View",
        "New York",
        "Palo Alto",
        "San Francisco",
        "Seattle",
    ],
    "cube_data_obj_type": "view",
}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/airbyte_json.ipynb
description: Airbyte를 사용하여 API, 데이터베이스 및 파일에서 로컬 JSON 파일로 데이터를 로드하는 방법을 설명합니다.
sidebar_class_name: hidden
---

# Airbyte JSON (사용 중단)

참고: `AirbyteJSONLoader`는 사용 중단되었습니다. 대신 [`AirbyteLoader`](/docs/integrations/document_loaders/airbyte)를 사용하시기 바랍니다.

> [Airbyte](https://github.com/airbytehq/airbyte)는 API, 데이터베이스 및 파일에서 데이터 웨어하우스 및 데이터 레이크로의 ELT 파이프라인을 위한 데이터 통합 플랫폼입니다. 데이터 웨어하우스 및 데이터베이스에 대한 ELT 커넥터의 가장 큰 카탈로그를 보유하고 있습니다.

이 문서는 Airbyte의 모든 소스를 로컬 JSON 파일로 로드하는 방법을 다룹니다. 이 파일은 문서로 읽을 수 있습니다.

사전 요구 사항:
Docker Desktop이 설치되어 있어야 합니다.

단계:

1. GitHub에서 Airbyte 클론하기 - `git clone https://github.com/airbytehq/airbyte.git`
2. Airbyte 디렉토리로 전환하기 - `cd airbyte`
3. Airbyte 시작하기 - `docker compose up`
4. 브라우저에서 http://localhost:8000을 방문하세요. 사용자 이름과 비밀번호를 입력하라는 메시지가 표시됩니다. 기본값은 사용자 이름 `airbyte`와 비밀번호 `password`입니다.
5. 원하는 소스를 설정하세요.
6. 목적지를 로컬 JSON으로 설정하고, 지정된 목적지 경로를 설정하세요 - 예를 들어 `/json_data`로 설정합니다. 수동 동기화를 설정하세요.
7. 연결을 실행하세요.
8. 생성된 파일을 보려면 다음으로 이동할 수 있습니다: `file:///tmp/airbyte_local`
9. 데이터를 찾아 경로를 복사하세요. 그 경로는 아래의 파일 변수에 저장되어야 합니다. `/tmp/airbyte_local`로 시작해야 합니다.

```python
<!--IMPORTS:[{"imported": "AirbyteJSONLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airbyte_json.AirbyteJSONLoader.html", "title": "Airbyte JSON (Deprecated)"}]-->
from langchain_community.document_loaders import AirbyteJSONLoader
```


```python
!ls /tmp/airbyte_local/json_data/
```

```output
_airbyte_raw_pokemon.jsonl
```


```python
loader = AirbyteJSONLoader("/tmp/airbyte_local/json_data/_airbyte_raw_pokemon.jsonl")
```


```python
data = loader.load()
```


```python
print(data[0].page_content[:500])
```

```output
abilities: 
ability: 
name: blaze
url: https://pokeapi.co/api/v2/ability/66/

is_hidden: False
slot: 1


ability: 
name: solar-power
url: https://pokeapi.co/api/v2/ability/94/

is_hidden: True
slot: 3

base_experience: 267
forms: 
name: charizard
url: https://pokeapi.co/api/v2/pokemon-form/6/

game_indices: 
game_index: 180
version: 
name: red
url: https://pokeapi.co/api/v2/version/1/



game_index: 180
version: 
name: blue
url: https://pokeapi.co/api/v2/version/2/



game_index: 180
version: 
n
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
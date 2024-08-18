---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/recursive_json_splitter.ipynb
description: JSON 데이터를 분할하는 방법을 설명하며, 청크 크기를 제어하고 중첩 객체를 유지하는 방법을 안내합니다.
---

# JSON 데이터 분할 방법

이 json 분할기는 청크 크기를 제어하면서 json 데이터를 분할합니다. json 데이터를 깊이 우선으로 탐색하고 더 작은 json 청크를 만듭니다. 중첩된 json 객체를 전체로 유지하려고 시도하지만, min_chunk_size와 max_chunk_size 사이의 청크를 유지하기 위해 필요하다면 분할합니다.

값이 중첩된 json이 아니라 매우 큰 문자열인 경우 문자열은 분할되지 않습니다. 청크 크기에 대한 엄격한 제한이 필요하다면 이러한 청크에 대해 Recursive Text splitter와 함께 구성하는 것을 고려하세요. 목록을 먼저 json (dict)로 변환한 다음 그렇게 분할하는 선택적 전처리 단계가 있습니다.

1. 텍스트가 분할되는 방법: json 값.
2. 청크 크기가 측정되는 방법: 문자 수로.

```python
%pip install -qU langchain-text-splitters
```


먼저 일부 json 데이터를 로드합니다:

```python
import json

import requests

# This is a large nested json object and will be loaded as a python dict
json_data = requests.get("https://api.smith.langchain.com/openapi.json").json()
```


## 기본 사용법

`max_chunk_size`를 지정하여 청크 크기를 제한합니다:

```python
<!--IMPORTS:[{"imported": "RecursiveJsonSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/json/langchain_text_splitters.json.RecursiveJsonSplitter.html", "title": "How to split JSON data"}]-->
from langchain_text_splitters import RecursiveJsonSplitter

splitter = RecursiveJsonSplitter(max_chunk_size=300)
```


json 청크를 얻으려면 `.split_json` 메서드를 사용하세요:

```python
# Recursively split json data - If you need to access/manipulate the smaller json chunks
json_chunks = splitter.split_json(json_data=json_data)

for chunk in json_chunks[:3]:
    print(chunk)
```

```output
{'openapi': '3.1.0', 'info': {'title': 'LangSmith', 'version': '0.1.0'}, 'servers': [{'url': 'https://api.smith.langchain.com', 'description': 'LangSmith API endpoint.'}]}
{'paths': {'/api/v1/sessions/{session_id}': {'get': {'tags': ['tracer-sessions'], 'summary': 'Read Tracer Session', 'description': 'Get a specific session.', 'operationId': 'read_tracer_session_api_v1_sessions__session_id__get'}}}}
{'paths': {'/api/v1/sessions/{session_id}': {'get': {'security': [{'API Key': []}, {'Tenant ID': []}, {'Bearer Auth': []}]}}}}
```

LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체를 얻으려면 `.create_documents` 메서드를 사용하세요:

```python
# The splitter can also output documents
docs = splitter.create_documents(texts=[json_data])

for doc in docs[:3]:
    print(doc)
```

```output
page_content='{"openapi": "3.1.0", "info": {"title": "LangSmith", "version": "0.1.0"}, "servers": [{"url": "https://api.smith.langchain.com", "description": "LangSmith API endpoint."}]}'
page_content='{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": ["tracer-sessions"], "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}'
page_content='{"paths": {"/api/v1/sessions/{session_id}": {"get": {"security": [{"API Key": []}, {"Tenant ID": []}, {"Bearer Auth": []}]}}}}'
```

또는 `.split_text`를 사용하여 문자열 내용을 직접 얻으세요:

```python
texts = splitter.split_text(json_data=json_data)

print(texts[0])
print(texts[1])
```

```output
{"openapi": "3.1.0", "info": {"title": "LangSmith", "version": "0.1.0"}, "servers": [{"url": "https://api.smith.langchain.com", "description": "LangSmith API endpoint."}]}
{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": ["tracer-sessions"], "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}
```

## 목록 콘텐츠에서 청크 크기 관리 방법

이 예제의 청크 중 하나가 지정된 `max_chunk_size` 300보다 크다는 점에 유의하세요. 더 큰 청크 중 하나를 검토해보면 목록 객체가 있습니다:

```python
print([len(text) for text in texts][:10])
print()
print(texts[3])
```

```output
[171, 231, 126, 469, 210, 213, 237, 271, 191, 232]

{"paths": {"/api/v1/sessions/{session_id}": {"get": {"parameters": [{"name": "session_id", "in": "path", "required": true, "schema": {"type": "string", "format": "uuid", "title": "Session Id"}}, {"name": "include_stats", "in": "query", "required": false, "schema": {"type": "boolean", "default": false, "title": "Include Stats"}}, {"name": "accept", "in": "header", "required": false, "schema": {"anyOf": [{"type": "string"}, {"type": "null"}], "title": "Accept"}}]}}}}
```

json 분할기는 기본적으로 목록을 분할하지 않습니다.

`convert_lists=True`를 지정하여 json을 전처리하고 목록 내용을 `index:item`을 `key:val` 쌍으로 변환하여 dict로 만듭니다:

```python
texts = splitter.split_text(json_data=json_data, convert_lists=True)
```


청크의 크기를 살펴보겠습니다. 이제 모두 최대 크기 이하입니다.

```python
print([len(text) for text in texts][:10])
```

```output
[176, 236, 141, 203, 212, 221, 210, 213, 242, 291]
```

목록은 dict로 변환되었지만, 여러 청크로 분할되더라도 필요한 모든 맥락 정보를 유지합니다:

```python
print(texts[1])
```

```output
{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": {"0": "tracer-sessions"}, "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}
```


```python
# We can also look at the documents
docs[1]
```


```output
Document(page_content='{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": ["tracer-sessions"], "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}')
```
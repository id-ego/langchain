---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/json.ipynb
description: 이 노트북은 JSON 문서 로더 사용을 위한 간단한 개요를 제공하며, JSONLoader의 기능 및 구성에 대한 자세한 문서를
  안내합니다.
---

# JSONLoader

이 노트북은 JSON [문서 로더](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 시작하는 데 필요한 간단한 개요를 제공합니다. JSONLoader의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.json_loader.JSONLoader.html)에서 확인할 수 있습니다.

- TODO: 기본 API에 대한 정보와 같은 기타 관련 링크 추가.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/document_loaders/file_loaders/json/)|
| :--- | :--- | :---: | :---: |  :---: |
| [JSONLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.json_loader.JSONLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ✅ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| JSONLoader | ✅ | ❌ | 

## 설정

JSON 문서 로더에 접근하려면 `langchain-community` 통합 패키지와 `jq` 파이썬 패키지를 설치해야 합니다.

### 자격 증명

`JSONLoader` 클래스를 사용하기 위해서는 자격 증명이 필요하지 않습니다.

모델 호출에 대한 자동 최상의 추적을 얻고 싶다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community** 및 **jq**를 설치합니다:

```python
%pip install -qU langchain_community jq 
```


## 초기화

이제 모델 객체를 인스턴스화하고 문서를 로드할 수 있습니다:

- TODO: 관련 매개변수로 모델 인스턴스화 업데이트.

```python
<!--IMPORTS:[{"imported": "JSONLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.json_loader.JSONLoader.html", "title": "JSONLoader"}]-->
from langchain_community.document_loaders import JSONLoader

loader = JSONLoader(
    file_path="./example_data/facebook_chat.json",
    jq_schema=".messages[].content",
    text_content=False,
)
```


## 로드

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': '/Users/isaachershenson/Documents/langchain/docs/docs/integrations/document_loaders/example_data/facebook_chat.json', 'seq_num': 1}, page_content='Bye!')
```


```python
print(docs[0].metadata)
```

```output
{'source': '/Users/isaachershenson/Documents/langchain/docs/docs/integrations/document_loaders/example_data/facebook_chat.json', 'seq_num': 1}
```

## 지연 로드

```python
pages = []
for doc in loader.lazy_load():
    pages.append(doc)
    if len(pages) >= 10:
        # do some paged operation, e.g.
        # index.upsert(pages)

        pages = []
```


## JSON Lines 파일에서 읽기

JSON Lines 파일에서 문서를 로드하려면 `json_lines=True`를 전달하고 `jq_schema`를 지정하여 단일 JSON 객체에서 `page_content`를 추출합니다.

```python
loader = JSONLoader(
    file_path="./example_data/facebook_chat_messages.jsonl",
    jq_schema=".content",
    text_content=False,
    json_lines=True,
)

docs = loader.load()
print(docs[0])
```

```output
page_content='Bye!' metadata={'source': '/Users/isaachershenson/Documents/langchain/docs/docs/integrations/document_loaders/example_data/facebook_chat_messages.jsonl', 'seq_num': 1}
```

## 특정 콘텐츠 키 읽기

또 다른 옵션은 `jq_schema='.'`를 설정하고 특정 콘텐츠만 로드하기 위해 `content_key`를 제공하는 것입니다:

```python
loader = JSONLoader(
    file_path="./example_data/facebook_chat_messages.jsonl",
    jq_schema=".",
    content_key="sender_name",
    json_lines=True,
)

docs = loader.load()
print(docs[0])
```

```output
page_content='User 2' metadata={'source': '/Users/isaachershenson/Documents/langchain/docs/docs/integrations/document_loaders/example_data/facebook_chat_messages.jsonl', 'seq_num': 1}
```

## jq 스키마 `content_key`가 있는 JSON 파일

`content_key`를 사용하여 JSON 파일에서 문서를 로드하려면 `is_content_key_jq_parsable=True`로 설정합니다. `content_key`가 호환 가능하고 jq 스키마를 사용하여 구문 분석할 수 있는지 확인합니다.

```python
loader = JSONLoader(
    file_path="./example_data/facebook_chat.json",
    jq_schema=".messages[]",
    content_key=".content",
    is_content_key_jq_parsable=True,
)

docs = loader.load()
print(docs[0])
```

```output
page_content='Bye!' metadata={'source': '/Users/isaachershenson/Documents/langchain/docs/docs/integrations/document_loaders/example_data/facebook_chat.json', 'seq_num': 1}
```

## 메타데이터 추출

일반적으로 우리는 JSON 파일에서 사용할 수 있는 메타데이터를 우리가 생성하는 문서에 포함시키고자 합니다.

다음은 `JSONLoader`를 사용하여 메타데이터를 추출하는 방법을 보여줍니다.

메타데이터를 수집하지 않았던 이전 예제와 비교하여 몇 가지 주요 변경 사항이 있습니다. 우리는 스키마에서 `page_content`의 값을 어디에서 추출할 수 있는지 직접 지정할 수 있었습니다.

이 예제에서는 로더에게 `messages` 필드의 레코드를 반복하도록 지시해야 합니다. 그러면 jq_schema는 `.messages[]`가 되어야 합니다.

이렇게 하면 레코드(딕셔너리)를 `metadata_func`에 전달할 수 있습니다. `metadata_func`는 레코드에서 메타데이터에 포함되어야 할 정보를 식별하는 역할을 합니다.

또한 이제 로더에서 `content_key` 인수를 통해 `page_content`의 값을 추출해야 하는 레코드의 키를 명시적으로 지정해야 합니다.

```python
# Define the metadata extraction function.
def metadata_func(record: dict, metadata: dict) -> dict:
    metadata["sender_name"] = record.get("sender_name")
    metadata["timestamp_ms"] = record.get("timestamp_ms")

    return metadata


loader = JSONLoader(
    file_path="./example_data/facebook_chat.json",
    jq_schema=".messages[]",
    content_key="content",
    metadata_func=metadata_func,
)

docs = loader.load()
print(docs[0].metadata)
```

```output
{'source': '/Users/isaachershenson/Documents/langchain/docs/docs/integrations/document_loaders/example_data/facebook_chat.json', 'seq_num': 1, 'sender_name': 'User 2', 'timestamp_ms': 1675597571851}
```

## API 참조

JSONLoader의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.json_loader.JSONLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
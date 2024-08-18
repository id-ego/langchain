---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/airbyte_gong.ipynb
description: 이 문서는 Airbyte Gong 커넥터의 문서 로더에 대한 정보를 제공하며, 사용자가 다양한 Gong 객체를 문서로 로드할
  수 있도록 안내합니다.
sidebar_class_name: hidden
---

# Airbyte Gong (사용 중단)

참고: 이 커넥터 전용 로더는 사용 중단되었습니다. 대신 [`AirbyteLoader`](/docs/integrations/document_loaders/airbyte)를 사용하십시오.

> [Airbyte](https://github.com/airbytehq/airbyte)는 API, 데이터베이스 및 파일에서 데이터 웨어하우스 및 데이터 레이크로의 ELT 파이프라인을 위한 데이터 통합 플랫폼입니다. 데이터 웨어하우스 및 데이터베이스에 대한 ELT 커넥터의 가장 큰 카탈로그를 보유하고 있습니다.

이 로더는 Gong 커넥터를 문서 로더로 노출하여 다양한 Gong 객체를 문서로 로드할 수 있게 합니다.

## 설치

먼저 `airbyte-source-gong` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  airbyte-source-gong
```


## 예제

리더를 구성하는 방법에 대한 자세한 내용은 [Airbyte 문서 페이지](https://docs.airbyte.com/integrations/sources/gong/)를 확인하십시오. 구성 객체가 준수해야 하는 JSON 스키마는 Github에서 확인할 수 있습니다: [https://github.com/airbytehq/airbyte/blob/master/airbyte-integrations/connectors/source-gong/source_gong/spec.yaml](https://github.com/airbytehq/airbyte/blob/master/airbyte-integrations/connectors/source-gong/source_gong/spec.yaml).

일반적인 형태는 다음과 같습니다:
```python
{
  "access_key": "<access key name>",
  "access_key_secret": "<access key secret>",
  "start_date": "<date from which to start retrieving records from in ISO format, e.g. 2020-10-20T00:00:00Z>",
}
```


기본적으로 모든 필드는 문서의 메타데이터로 저장되며 텍스트는 빈 문자열로 설정됩니다. 리더가 반환하는 문서를 변환하여 문서의 텍스트를 구성하십시오.

```python
<!--IMPORTS:[{"imported": "AirbyteGongLoader", "source": "langchain_community.document_loaders.airbyte", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airbyte.AirbyteGongLoader.html", "title": "Airbyte Gong (Deprecated)"}]-->
from langchain_community.document_loaders.airbyte import AirbyteGongLoader

config = {
    # your gong configuration
}

loader = AirbyteGongLoader(
    config=config, stream_name="calls"
)  # check the documentation linked above for a list of all streams
```


이제 일반적인 방법으로 문서를 로드할 수 있습니다.

```python
docs = loader.load()
```


`load`가 목록을 반환하므로 모든 문서가 로드될 때까지 차단됩니다. 이 프로세스를 더 잘 제어하려면 대신 이터레이터를 반환하는 `lazy_load` 메서드를 사용할 수도 있습니다:

```python
docs_iterator = loader.lazy_load()
```


기본적으로 페이지 내용은 비어 있으며 메타데이터 객체에는 레코드의 모든 정보가 포함되어 있다는 점을 기억하십시오. 문서를 처리하려면 기본 로더에서 상속된 클래스를 만들고 `_handle_records` 메서드를 직접 구현하십시오:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Airbyte Gong (Deprecated)"}]-->
from langchain_core.documents import Document


def handle_record(record, id):
    return Document(page_content=record.data["title"], metadata=record.data)


loader = AirbyteGongLoader(
    config=config, record_handler=handle_record, stream_name="calls"
)
docs = loader.load()
```


## 증분 로드

일부 스트림은 증분 로드를 허용합니다. 이는 소스가 동기화된 레코드를 추적하고 다시 로드하지 않음을 의미합니다. 이는 데이터 양이 많고 자주 업데이트되는 소스에 유용합니다.

이를 활용하려면 로더의 `last_state` 속성을 저장하고 로더를 다시 생성할 때 전달하십시오. 이렇게 하면 새로운 레코드만 로드됩니다.

```python
last_state = loader.last_state  # store safely

incremental_loader = AirbyteGongLoader(
    config=config, stream_name="calls", state=last_state
)

new_docs = incremental_loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
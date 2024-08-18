---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/airbyte_cdk.ipynb
description: Airbyte CDK는 API, 데이터베이스 및 파일에서 데이터 웨어하우스 및 레이크로의 ELT 파이프라인을 위한 데이터 통합
  플랫폼입니다.
sidebar_class_name: hidden
---

# Airbyte CDK (사용 중단)

참고: `AirbyteCDKLoader`는 사용 중단되었습니다. 대신 [`AirbyteLoader`](/docs/integrations/document_loaders/airbyte)를 사용해 주세요.

> [Airbyte](https://github.com/airbytehq/airbyte)는 API, 데이터베이스 및 파일에서 데이터 웨어하우스 및 데이터 레이크로의 ELT 파이프라인을 위한 데이터 통합 플랫폼입니다. 데이터 웨어하우스 및 데이터베이스에 대한 ELT 커넥터의 가장 큰 카탈로그를 보유하고 있습니다.

많은 소스 커넥터가 [Airbyte CDK](https://docs.airbyte.com/connector-development/cdk-python/)를 사용하여 구현되었습니다. 이 로더는 이러한 커넥터를 실행하고 데이터를 문서로 반환할 수 있게 해줍니다.

## 설치

먼저, `airbyte-cdk` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  airbyte-cdk
```


그런 다음, [Airbyte Github 저장소](https://github.com/airbytehq/airbyte/tree/master/airbyte-integrations/connectors)에서 기존 커넥터를 설치하거나 [Airbyte CDK](https://docs.airbyte.io/connector-development/connector-development)를 사용하여 자신의 커넥터를 생성하세요.

예를 들어, Github 커넥터를 설치하려면 다음을 실행하세요.

```python
%pip install --upgrade --quiet  "source_github@git+https://github.com/airbytehq/airbyte.git@master#subdirectory=airbyte-integrations/connectors/source-github"
```


일부 소스는 PyPI에서 일반 패키지로도 게시됩니다.

## 예제

이제 가져온 소스를 기반으로 `AirbyteCDKLoader`를 생성할 수 있습니다. 이는 커넥터에 전달되는 `config` 객체를 필요로 합니다. 또한, 가져올 레코드의 스트림을 이름(`stream_name`)으로 선택해야 합니다. `config` 객체와 사용 가능한 스트림에 대한 자세한 정보는 커넥터 문서 페이지와 사양 정의를 확인하세요. Github 커넥터의 경우 다음과 같습니다:

* [https://github.com/airbytehq/airbyte/blob/master/airbyte-integrations/connectors/source-github/source_github/spec.json](https://github.com/airbytehq/airbyte/blob/master/airbyte-integrations/connectors/source-github/source_github/spec.json).
* [https://docs.airbyte.com/integrations/sources/github/](https://docs.airbyte.com/integrations/sources/github/)

```python
<!--IMPORTS:[{"imported": "AirbyteCDKLoader", "source": "langchain_community.document_loaders.airbyte", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airbyte.AirbyteCDKLoader.html", "title": "Airbyte CDK (Deprecated)"}]-->
from langchain_community.document_loaders.airbyte import AirbyteCDKLoader
from source_github.source import SourceGithub  # plug in your own source here

config = {
    # your github configuration
    "credentials": {"api_url": "api.github.com", "personal_access_token": "<token>"},
    "repository": "<repo>",
    "start_date": "<date from which to start retrieving records from in ISO format, e.g. 2020-10-20T00:00:00Z>",
}

issues_loader = AirbyteCDKLoader(
    source_class=SourceGithub, config=config, stream_name="issues"
)
```


이제 문서를 일반적인 방법으로 로드할 수 있습니다.

```python
docs = issues_loader.load()
```


`load`가 목록을 반환하므로 모든 문서가 로드될 때까지 차단됩니다. 이 프로세스를 더 잘 제어하려면 대신 이터레이터를 반환하는 `lazy_load` 메서드를 사용할 수도 있습니다:

```python
docs_iterator = issues_loader.lazy_load()
```


기본적으로 페이지 내용은 비어 있으며 메타데이터 객체는 레코드의 모든 정보를 포함하고 있다는 점을 기억하세요. 다른 형식으로 문서를 생성하려면 로더를 생성할 때 record_handler 함수를 전달하세요:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Airbyte CDK (Deprecated)"}]-->
from langchain_core.documents import Document


def handle_record(record, id):
    return Document(
        page_content=record.data["title"] + "\n" + (record.data["body"] or ""),
        metadata=record.data,
    )


issues_loader = AirbyteCDKLoader(
    source_class=SourceGithub,
    config=config,
    stream_name="issues",
    record_handler=handle_record,
)

docs = issues_loader.load()
```


## 증분 로드

일부 스트림은 증분 로드를 허용합니다. 이는 소스가 동기화된 레코드를 추적하고 다시 로드하지 않음을 의미합니다. 이는 데이터 양이 많고 자주 업데이트되는 소스에 유용합니다.

이를 활용하려면 로더의 `last_state` 속성을 저장하고 로더를 다시 생성할 때 전달하세요. 이렇게 하면 새로운 레코드만 로드됩니다.

```python
last_state = issues_loader.last_state  # store safely

incremental_issue_loader = AirbyteCDKLoader(
    source_class=SourceGithub, config=config, stream_name="issues", state=last_state
)

new_docs = incremental_issue_loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
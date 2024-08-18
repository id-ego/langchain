---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/chatgpt-plugin.ipynb
description: ChatGPT 플러그인은 ChatGPT가 API와 상호작용하여 실시간 정보 검색 및 사용자 대행 작업을 수행할 수 있게 해줍니다.
---

# ChatGPT 플러그인

> [OpenAI 플러그인](https://platform.openai.com/docs/plugins/introduction)은 `ChatGPT`를 제3자 애플리케이션에 연결합니다. 이러한 플러그인은 `ChatGPT`가 개발자가 정의한 API와 상호작용할 수 있게 하여 `ChatGPT`의 기능을 향상시키고 다양한 작업을 수행할 수 있도록 합니다.

> 플러그인을 사용하면 `ChatGPT`가 다음과 같은 작업을 수행할 수 있습니다:
> - 실시간 정보 검색; 예: 스포츠 점수, 주식 가격, 최신 뉴스 등.
> - 지식 기반 정보 검색; 예: 회사 문서, 개인 메모 등.
> - 사용자를 대신하여 작업 수행; 예: 비행기 예약, 음식 주문 등.

이 노트북은 LangChain 내에서 ChatGPT 리트리버 플러그인을 사용하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "ChatGPT plugin"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "ChatGPT plugin"}]-->
# STEP 1: Load

# Load documents using LangChain's DocumentLoaders
# This is from https://langchain.readthedocs.io/en/latest/modules/document_loaders/examples/csv.html

from langchain_community.document_loaders import CSVLoader
from langchain_core.documents import Document

loader = CSVLoader(
    file_path="../../document_loaders/examples/example_data/mlb_teams_2012.csv"
)
data = loader.load()


# STEP 2: Convert

# Convert Document to format expected by https://github.com/openai/chatgpt-retrieval-plugin
import json
from typing import List


def write_json(path: str, documents: List[Document]) -> None:
    results = [{"text": doc.page_content} for doc in documents]
    with open(path, "w") as f:
        json.dump(results, f, indent=2)


write_json("foo.json", data)

# STEP 3: Use

# Ingest this as you would any other json file in https://github.com/openai/chatgpt-retrieval-plugin/tree/main/scripts/process_json
```


## ChatGPT 리트리버 플러그인 사용하기

좋습니다, 우리는 ChatGPT 리트리버 플러그인을 만들었지만, 실제로 어떻게 사용하는 걸까요?

아래 코드는 이를 수행하는 방법을 설명합니다.

우리는 `ChatGPTPluginRetriever`를 사용하고 싶으므로 OpenAI API 키를 가져와야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```output
OpenAI API Key: ········
```


```python
<!--IMPORTS:[{"imported": "ChatGPTPluginRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.chatgpt_plugin_retriever.ChatGPTPluginRetriever.html", "title": "ChatGPT plugin"}]-->
from langchain_community.retrievers import (
    ChatGPTPluginRetriever,
)
```


```python
retriever = ChatGPTPluginRetriever(url="http://0.0.0.0:8000", bearer_token="foo")
```


```python
retriever.invoke("alice's phone number")
```


```output
[Document(page_content="This is Alice's phone number: 123-456-7890", lookup_str='', metadata={'id': '456_0', 'metadata': {'source': 'email', 'source_id': '567', 'url': None, 'created_at': '1609592400.0', 'author': 'Alice', 'document_id': '456'}, 'embedding': None, 'score': 0.925571561}, lookup_index=0),
 Document(page_content='This is a document about something', lookup_str='', metadata={'id': '123_0', 'metadata': {'source': 'file', 'source_id': 'https://example.com/doc1', 'url': 'https://example.com/doc1', 'created_at': '1609502400.0', 'author': 'Alice', 'document_id': '123'}, 'embedding': None, 'score': 0.6987589}, lookup_index=0),
 Document(page_content='Team: Angels "Payroll (millions)": 154.49 "Wins": 89', lookup_str='', metadata={'id': '59c2c0c1-ae3f-4272-a1da-f44a723ea631_0', 'metadata': {'source': None, 'source_id': None, 'url': None, 'created_at': None, 'author': None, 'document_id': '59c2c0c1-ae3f-4272-a1da-f44a723ea631'}, 'embedding': None, 'score': 0.697888613}, lookup_index=0)]
```


## 관련

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)
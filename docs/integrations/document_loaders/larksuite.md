---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/larksuite.ipynb
description: LarkSuite REST API에서 데이터를 로드하여 LangChain에 적합한 형식으로 변환하는 방법과 텍스트 요약 예제를
  다룹니다.
---

# LarkSuite (FeiShu)

> [LarkSuite](https://www.larksuite.com/)는 ByteDance에서 개발한 기업 협업 플랫폼입니다.

이 노트북은 `LarkSuite` REST API에서 데이터를 로드하여 LangChain에 적합한 형식으로 변환하는 방법과 텍스트 요약을 위한 예제 사용법을 다룹니다.

LarkSuite API는 액세스 토큰(tenant_access_token 또는 user_access_token)을 요구합니다. API 세부정보는 [LarkSuite 오픈 플랫폼 문서](https://open.larksuite.com/document)를 확인하세요.

```python
<!--IMPORTS:[{"imported": "LarkSuiteDocLoader", "source": "langchain_community.document_loaders.larksuite", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.larksuite.LarkSuiteDocLoader.html", "title": "LarkSuite (FeiShu)"}, {"imported": "LarkSuiteWikiLoader", "source": "langchain_community.document_loaders.larksuite", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.larksuite.LarkSuiteWikiLoader.html", "title": "LarkSuite (FeiShu)"}]-->
from getpass import getpass

from langchain_community.document_loaders.larksuite import (
    LarkSuiteDocLoader,
    LarkSuiteWikiLoader,
)

DOMAIN = input("larksuite domain")
ACCESS_TOKEN = getpass("larksuite tenant_access_token or user_access_token")
DOCUMENT_ID = input("larksuite document id")
```


## 문서에서 로드

```python
from pprint import pprint

larksuite_loader = LarkSuiteDocLoader(DOMAIN, ACCESS_TOKEN, DOCUMENT_ID)
docs = larksuite_loader.load()

pprint(docs)
```

```output
[Document(page_content='Test Doc\nThis is a Test Doc\n\n1\n2\n3\n\n', metadata={'document_id': 'V76kdbd2HoBbYJxdiNNccajunPf', 'revision_id': 11, 'title': 'Test Doc'})]
```

## 위키에서 로드

```python
from pprint import pprint

DOCUMENT_ID = input("larksuite wiki id")
larksuite_loader = LarkSuiteWikiLoader(DOMAIN, ACCESS_TOKEN, DOCUMENT_ID)
docs = larksuite_loader.load()

pprint(docs)
```

```output
[Document(page_content='Test doc\nThis is a test wiki doc.\n', metadata={'document_id': 'TxOKdtMWaoSTDLxYS4ZcdEI7nwc', 'revision_id': 15, 'title': 'Test doc'})]
```


```python
<!--IMPORTS:[{"imported": "load_summarize_chain", "source": "langchain.chains.summarize", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.summarize.chain.load_summarize_chain.html", "title": "LarkSuite (FeiShu)"}, {"imported": "FakeListLLM", "source": "langchain_community.llms.fake", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.fake.FakeListLLM.html", "title": "LarkSuite (FeiShu)"}]-->
# see https://python.langchain.com/docs/use_cases/summarization for more details
from langchain.chains.summarize import load_summarize_chain
from langchain_community.llms.fake import FakeListLLM

llm = FakeListLLM()
chain = load_summarize_chain(llm, chain_type="map_reduce")
chain.run(docs)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
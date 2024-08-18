---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/async_chromium.ipynb
description: Chromium은 Playwright를 사용하여 브라우저 자동화를 제어하는 라이브러리로, 비헤드리스 모드에서 페이지를 로드하고
  변환하는 방법을 설명합니다.
---

# 비동기 크로미움

크로미움은 브라우저 자동화를 제어하는 데 사용되는 라이브러리인 Playwright에서 지원하는 브라우저 중 하나입니다.

`p.chromium.launch(headless=True)`를 실행함으로써, 우리는 헤드리스 크로미움 인스턴스를 시작하고 있습니다.

헤드리스 모드는 브라우저가 그래픽 사용자 인터페이스 없이 실행되고 있음을 의미합니다.

아래 예제에서는 `AsyncChromiumLoader`를 사용하여 페이지를 로드한 다음, [`Html2TextTransformer`](/docs/integrations/document_transformers/html2text/)를 사용하여 HTML 태그 및 기타 의미 정보를 제거합니다.

```python
%pip install --upgrade --quiet playwright beautifulsoup4 html2text
!playwright install
```


**참고:** Jupyter 노트북을 사용하는 경우, 문서를 이렇게 로드하기 전에 `nest_asyncio`를 설치하고 적용해야 할 수도 있습니다:

```python
!pip install nest-asyncio
import nest_asyncio

nest_asyncio.apply()
```


```python
<!--IMPORTS:[{"imported": "AsyncChromiumLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.chromium.AsyncChromiumLoader.html", "title": "Async Chromium"}]-->
from langchain_community.document_loaders import AsyncChromiumLoader

urls = ["https://docs.smith.langchain.com/"]
loader = AsyncChromiumLoader(urls, user_agent="MyAppUserAgent")
docs = loader.load()
docs[0].page_content[0:100]
```


```output
'<!DOCTYPE html><html lang="en" dir="ltr" class="docs-wrapper docs-doc-page docs-version-2.0 plugin-d'
```


이제 변환기를 사용하여 문서를 보다 읽기 쉬운 구문으로 변환해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "Html2TextTransformer", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.html2text.Html2TextTransformer.html", "title": "Async Chromium"}]-->
from langchain_community.document_transformers import Html2TextTransformer

html2text = Html2TextTransformer()
docs_transformed = html2text.transform_documents(docs)
docs_transformed[0].page_content[0:500]
```


```output
'Skip to main content\n\nGo to API Docs\n\nSearch`⌘``K`\n\nGo to App\n\n  * Quick start\n  * Tutorials\n\n  * How-to guides\n\n  * Concepts\n\n  * Reference\n\n  * Pricing\n  * Self-hosting\n\n  * LangGraph Cloud\n\n  *   * Quick start\n\nOn this page\n\n# Get started with LangSmith\n\n**LangSmith** is a platform for building production-grade LLM applications. It\nallows you to closely monitor and evaluate your application, so you can ship\nquickly and with confidence. Use of LangChain is not necessary - LangSmith\nworks on it'
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
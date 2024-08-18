---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/apify_dataset.ipynb
description: Apify 데이터셋은 웹 스크래핑 결과를 저장하고 다양한 형식으로 내보낼 수 있는 확장 가능한 저장소입니다. LangChain에
  로드하는 방법을 보여줍니다.
---

# Apify 데이터셋

> [Apify 데이터셋](https://docs.apify.com/platform/storage/dataset)은 구조화된 웹 스크래핑 결과(예: 제품 목록 또는 Google SERP)를 저장하기 위해 구축된 순차 접근 방식의 확장 가능한 추가 전용 저장소로, 이를 JSON, CSV 또는 Excel과 같은 다양한 형식으로 내보낼 수 있습니다. 데이터셋은 주로 [Apify 액터](https://apify.com/store)의 결과를 저장하는 데 사용됩니다. — 다양한 웹 스크래핑, 크롤링 및 데이터 추출 사용 사례를 위한 서버리스 클라우드 프로그램입니다.

이 노트북은 Apify 데이터셋을 LangChain에 로드하는 방법을 보여줍니다.

## 전제 조건

Apify 플랫폼에 기존 데이터셋이 있어야 합니다. 이 예제는 [웹사이트 콘텐츠 크롤러](https://apify.com/apify/website-content-crawler)가 생성한 데이터셋을 로드하는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet  apify-client
```


먼저, `ApifyDatasetLoader`를 소스 코드에 가져옵니다:

```python
<!--IMPORTS:[{"imported": "ApifyDatasetLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.apify_dataset.ApifyDatasetLoader.html", "title": "Apify Dataset"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Apify Dataset"}]-->
from langchain_community.document_loaders import ApifyDatasetLoader
from langchain_core.documents import Document
```


그런 다음 Apify 데이터셋 레코드 필드를 LangChain `Document` 형식에 매핑하는 함수를 제공합니다.

예를 들어, 데이터셋 항목이 다음과 같이 구조화되어 있다면:

```json
{
    "url": "https://apify.com",
    "text": "Apify is the best web scraping and automation platform."
}
```


아래 코드의 매핑 함수는 이를 LangChain `Document` 형식으로 변환하여, 이후에 어떤 LLM 모델(예: 질문 응답)에 대해 사용할 수 있도록 합니다.

```python
loader = ApifyDatasetLoader(
    dataset_id="your-dataset-id",
    dataset_mapping_function=lambda dataset_item: Document(
        page_content=dataset_item["text"], metadata={"source": dataset_item["url"]}
    ),
)
```


```python
data = loader.load()
```


## 질문 응답 예제

이 예제에서는 데이터셋의 데이터를 사용하여 질문에 답변합니다.

```python
<!--IMPORTS:[{"imported": "VectorstoreIndexCreator", "source": "langchain.indexes", "docs": "https://api.python.langchain.com/en/latest/indexes/langchain.indexes.vectorstore.VectorstoreIndexCreator.html", "title": "Apify Dataset"}, {"imported": "ApifyWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.apify.ApifyWrapper.html", "title": "Apify Dataset"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Apify Dataset"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Apify Dataset"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Apify Dataset"}]-->
from langchain.indexes import VectorstoreIndexCreator
from langchain_community.utilities import ApifyWrapper
from langchain_core.documents import Document
from langchain_openai import OpenAI
from langchain_openai.embeddings import OpenAIEmbeddings
```


```python
loader = ApifyDatasetLoader(
    dataset_id="your-dataset-id",
    dataset_mapping_function=lambda item: Document(
        page_content=item["text"] or "", metadata={"source": item["url"]}
    ),
)
```


```python
index = VectorstoreIndexCreator(embedding=OpenAIEmbeddings()).from_loaders([loader])
```


```python
query = "What is Apify?"
result = index.query_with_sources(query, llm=OpenAI())
```


```python
print(result["answer"])
print(result["sources"])
```

```output
 Apify is a platform for developing, running, and sharing serverless cloud programs. It enables users to create web scraping and automation tools and publish them on the Apify platform.

https://docs.apify.com/platform/actors, https://docs.apify.com/platform/actors/running/actors-in-store, https://docs.apify.com/platform/security, https://docs.apify.com/platform/actors/examples
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
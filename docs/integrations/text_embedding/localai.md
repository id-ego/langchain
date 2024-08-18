---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/localai.ipynb
description: LocalAI 임베딩 클래스를 로드하는 방법과 첫 번째 세대 모델 사용에 대한 설명을 제공합니다. 자세한 내용은 문서를 참조하세요.
---

# LocalAI

LocalAI 임베딩 클래스를 로드해 보겠습니다. LocalAI 임베딩 클래스를 사용하려면 LocalAI 서비스가 어디엔가 호스팅되어 있어야 하며 임베딩 모델을 구성해야 합니다. 문서는 https://localai.io/basics/getting_started/index.html 및 https://localai.io/features/embeddings/index.html에서 확인하세요.

```python
<!--IMPORTS:[{"imported": "LocalAIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.localai.LocalAIEmbeddings.html", "title": "LocalAI"}]-->
from langchain_community.embeddings import LocalAIEmbeddings
```


```python
embeddings = LocalAIEmbeddings(
    openai_api_base="http://localhost:8080", model="embedding-model-name"
)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_result = embeddings.embed_documents([text])
```


첫 번째 세대 모델(예: text-search-ada-doc-001/text-search-ada-query-001)로 LocalAI 임베딩 클래스를 로드해 보겠습니다. 주의: 이러한 모델은 권장되지 않습니다 - [여기](https://platform.openai.com/docs/guides/embeddings/what-are-embeddings)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "LocalAIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.localai.LocalAIEmbeddings.html", "title": "LocalAI"}]-->
from langchain_community.embeddings import LocalAIEmbeddings
```


```python
embeddings = LocalAIEmbeddings(
    openai_api_base="http://localhost:8080", model="embedding-model-name"
)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_result = embeddings.embed_documents([text])
```


```python
import os

# if you are behind an explicit proxy, you can use the OPENAI_PROXY environment variable to pass through
os.environ["OPENAI_PROXY"] = "http://proxy.yourcompany.com:8080"
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
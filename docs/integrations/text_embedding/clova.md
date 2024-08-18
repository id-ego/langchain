---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/clova.ipynb
description: Clova 임베딩 서비스를 사용하여 LangChain으로 텍스트 임베딩을 수행하는 방법을 설명합니다.
---

# 클로바 임베딩
[클로바](https://api.ncloud-docs.com/docs/ai-naver-clovastudio-summary)는 임베딩 서비스를 제공합니다.

이 예제는 LangChain을 사용하여 텍스트 임베딩을 위한 클로바 추론과 상호작용하는 방법을 설명합니다.

```python
import os

os.environ["CLOVA_EMB_API_KEY"] = ""
os.environ["CLOVA_EMB_APIGW_API_KEY"] = ""
os.environ["CLOVA_EMB_APP_ID"] = ""
```


```python
<!--IMPORTS:[{"imported": "ClovaEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.clova.ClovaEmbeddings.html", "title": "Clova Embeddings"}]-->
from langchain_community.embeddings import ClovaEmbeddings
```


```python
embeddings = ClovaEmbeddings()
```


```python
query_text = "This is a test query."
query_result = embeddings.embed_query(query_text)
```


```python
document_text = ["This is a test doc1.", "This is a test doc2."]
document_result = embeddings.embed_documents(document_text)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
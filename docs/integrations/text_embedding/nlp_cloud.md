---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/nlp_cloud.ipynb
description: NLP Cloud는 고급 AI 엔진을 사용하고, 사용자 데이터로 자체 엔진을 훈련할 수 있는 인공지능 플랫폼입니다.
---

# NLP Cloud

> [NLP Cloud](https://docs.nlpcloud.com/#introduction)는 가장 진보된 AI 엔진을 사용할 수 있게 해주는 인공지능 플랫폼이며, 자신의 데이터로 자신의 엔진을 훈련시킬 수도 있습니다.

[임베딩](https://docs.nlpcloud.com/#embeddings) 엔드포인트는 다음 모델을 제공합니다:

* `paraphrase-multilingual-mpnet-base-v2`: Paraphrase Multilingual MPNet Base V2는 50개 이상의 언어에서 임베딩 추출에 완벽하게 적합한 Sentence Transformers 기반의 매우 빠른 모델입니다 (전체 목록은 여기에서 확인하세요).

```python
%pip install --upgrade --quiet  nlpcloud
```


```python
<!--IMPORTS:[{"imported": "NLPCloudEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.nlpcloud.NLPCloudEmbeddings.html", "title": "NLP Cloud"}]-->
from langchain_community.embeddings import NLPCloudEmbeddings
```


```python
import os

os.environ["NLPCLOUD_API_KEY"] = "xxx"
nlpcloud_embd = NLPCloudEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = nlpcloud_embd.embed_query(text)
```


```python
doc_result = nlpcloud_embd.embed_documents([text])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
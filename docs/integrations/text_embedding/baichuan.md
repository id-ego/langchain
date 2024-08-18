---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/baichuan.ipynb
description: BaichuanTextEmbeddings는 C-MTEB 리더보드에서 1위를 차지한 중국어 텍스트 임베딩 모델입니다. 512
  토큰 창과 1024 차원 벡터를 지원합니다.
---

# Baichuan 텍스트 임베딩

오늘 날짜 기준(2024년 1월 25일) BaichuanTextEmbeddings는 C-MTEB(중국어 다중 작업 임베딩 벤치마크) 리더보드에서 1위를 차지하고 있습니다.

리더보드(전체 -> 중국어 섹션): https://huggingface.co/spaces/mteb/leaderboard

공식 웹사이트: https://platform.baichuan-ai.com/docs/text-Embedding

이 임베딩 모델을 사용하려면 API 키가 필요합니다. https://platform.baichuan-ai.com/docs/text-Embedding에서 등록하여 얻을 수 있습니다.

BaichuanTextEmbeddings는 512 토큰 윈도우를 지원하며 1024 차원의 벡터를 생성합니다.

BaichuanTextEmbeddings는 중국어 텍스트 임베딩만 지원합니다. 다국어 지원은 곧 제공될 예정입니다.

```python
<!--IMPORTS:[{"imported": "BaichuanTextEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.baichuan.BaichuanTextEmbeddings.html", "title": "Baichuan Text Embeddings"}]-->
from langchain_community.embeddings import BaichuanTextEmbeddings

embeddings = BaichuanTextEmbeddings(baichuan_api_key="sk-*")
```


또는 다음과 같이 API 키를 설정할 수 있습니다:

```python
import os

os.environ["BAICHUAN_API_KEY"] = "YOUR_API_KEY"
```


```python
text_1 = "今天天气不错"
text_2 = "今天阳光很好"

query_result = embeddings.embed_query(text_1)
query_result
```


```python
doc_result = embeddings.embed_documents([text_1, text_2])
doc_result
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
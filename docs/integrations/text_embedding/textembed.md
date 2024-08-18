---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/textembed.ipynb
description: TextEmbed는 다양한 문장 변환 모델을 지원하는 고속, 저지연 REST API로, 자연어 처리 응용 프로그램에 적합합니다.
---

# TextEmbed - 임베딩 추론 서버

TextEmbed는 벡터 임베딩을 제공하기 위해 설계된 고처리량, 저지연 REST API입니다. 다양한 문장 변환기 모델과 프레임워크를 지원하여 자연어 처리의 다양한 애플리케이션에 적합합니다.

## 특징

- **고처리량 및 저지연:** 많은 요청을 효율적으로 처리하도록 설계되었습니다.
- **유연한 모델 지원:** 다양한 문장 변환기 모델과 함께 작동합니다.
- **확장 가능:** 더 큰 시스템에 쉽게 통합되고 수요에 따라 확장됩니다.
- **배치 처리:** 더 나은 및 빠른 추론을 위한 배치 처리를 지원합니다.
- **OpenAI 호환 REST API 엔드포인트:** OpenAI 호환 REST API 엔드포인트를 제공합니다.
- **단일 명령 배포:** 효율적인 배포를 위해 단일 명령으로 여러 모델을 배포합니다.
- **임베딩 형식 지원:** 더 빠른 검색을 위한 이진, float16 및 float32 임베딩 형식을 지원합니다.

## 시작하기

### 전제 조건

Python 3.10 이상이 설치되어 있는지 확인하십시오. 필요한 종속성도 설치해야 합니다.

## PyPI를 통한 설치

1. **필요한 종속성 설치:**
   
   ```bash
   pip install -U textembed
   ```

2. **원하는 모델로 TextEmbed 서버 시작:**
   
   ```bash
   python -m textembed.server --models sentence-transformers/all-MiniLM-L12-v2 --workers 4 --api-key TextEmbed 
   ```


자세한 내용은 [문서](https://github.com/kevaldekivadiya2415/textembed/blob/main/docs/setup.md)를 참조하십시오.

### 가져오기

```python
<!--IMPORTS:[{"imported": "TextEmbedEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.textembed.TextEmbedEmbeddings.html", "title": "TextEmbed - Embedding Inference Server"}]-->
from langchain_community.embeddings import TextEmbedEmbeddings
```


```python
embeddings = TextEmbedEmbeddings(
    model="sentence-transformers/all-MiniLM-L12-v2",
    api_url="http://0.0.0.0:8000/v1",
    api_key="TextEmbed",
)
```


### 문서 임베드하기

```python
# Define a list of documents
documents = [
    "Data science involves extracting insights from data.",
    "Artificial intelligence is transforming various industries.",
    "Cloud computing provides scalable computing resources over the internet.",
    "Big data analytics helps in understanding large datasets.",
    "India has a diverse cultural heritage.",
]

# Define a query
query = "What is the cultural heritage of India?"
```


```python
# Embed all documents
document_embeddings = embeddings.embed_documents(documents)

# Embed the query
query_embedding = embeddings.embed_query(query)
```


```python
# Compute Similarity
import numpy as np

scores = np.array(document_embeddings) @ np.array(query_embedding).T
dict(zip(documents, scores))
```


```output
{'Data science involves extracting insights from data.': 0.05121298956322118,
 'Artificial intelligence is transforming various industries.': -0.0060612142358469345,
 'Cloud computing provides scalable computing resources over the internet.': -0.04877402795301714,
 'Big data analytics helps in understanding large datasets.': 0.016582168576929422,
 'India has a diverse cultural heritage.': 0.7408992963028144}
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
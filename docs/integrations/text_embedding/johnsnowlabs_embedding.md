---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/johnsnowlabs_embedding.ipynb
description: John Snow Labs는 AI 및 LLM 생태계를 제공하며, 20,000개 이상의 모델을 통해 헬스케어, 법률, 금융 분야의
  최첨단 AI를 지원합니다.
---

# John Snow Labs

> [John Snow Labs](https://nlp.johnsnowlabs.com/) NLP 및 LLM 생태계는 최첨단 AI를 대규모로 제공하는 소프트웨어 라이브러리, 책임 있는 AI, 코드 없는 AI 및 의료, 법률, 금융 등에서 20,000개 이상의 모델에 대한 접근을 포함합니다.
> 
> 모델은 [nlp.load](https://nlp.johnsnowlabs.com/docs/en/jsl/load_api)로 로드되며, 스파크 세션은 [nlp.start()](https://nlp.johnsnowlabs.com/docs/en/jsl/start-a-sparksession)로 시작됩니다.
24,000개 이상의 모든 모델은 [John Snow Labs Model Models Hub](https://nlp.johnsnowlabs.com/models)에서 확인할 수 있습니다.

## 설정

```python
%pip install --upgrade --quiet  johnsnowlabs
```


```python
# If you have a enterprise license, you can run this to install enterprise features
# from johnsnowlabs import nlp
# nlp.install()
```


## 예제

```python
<!--IMPORTS:[{"imported": "JohnSnowLabsEmbeddings", "source": "langchain_community.embeddings.johnsnowlabs", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.johnsnowlabs.JohnSnowLabsEmbeddings.html", "title": "John Snow Labs"}]-->
from langchain_community.embeddings.johnsnowlabs import JohnSnowLabsEmbeddings
```


Johnsnowlabs 임베딩 및 스파크 세션 초기화

```python
embedder = JohnSnowLabsEmbeddings("en.embed_sentence.biobert.clinical_base_cased")
```


분석하려는 예제 텍스트를 정의합니다. 이는 뉴스 기사, 소셜 미디어 게시물 또는 제품 리뷰와 같은 문서일 수 있습니다.

```python
texts = ["Cancer is caused by smoking", "Antibiotics aren't painkiller"]
```


텍스트에 대한 임베딩을 생성하고 인쇄합니다. JohnSnowLabsEmbeddings 클래스는 각 문서에 대한 임베딩을 생성하며, 이는 문서 내용의 수치적 표현입니다. 이러한 임베딩은 문서 유사성 비교 또는 텍스트 분류와 같은 다양한 자연어 처리 작업에 사용될 수 있습니다.

```python
embeddings = embedder.embed_documents(texts)
for i, embedding in enumerate(embeddings):
    print(f"Embedding for document {i+1}: {embedding}")
```


단일 텍스트 조각에 대한 임베딩을 생성하고 인쇄합니다. 검색 쿼리와 같은 단일 텍스트 조각에 대한 임베딩도 생성할 수 있습니다. 이는 주어진 쿼리와 유사한 문서를 찾고자 할 때 정보 검색과 같은 작업에 유용할 수 있습니다.

```python
query = "Cancer is caused by smoking"
query_embedding = embedder.embed_query(query)
print(f"Embedding for query: {query_embedding}")
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
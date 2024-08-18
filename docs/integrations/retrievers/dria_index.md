---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/dria_index.ipynb
description: Dria는 개발자를 위한 공개 RAG 모델 허브로, 데이터 검색 작업을 위한 Dria API 사용법을 보여줍니다.
---

# 드리아

> [드리아](https://dria.co/)는 개발자들이 기여하고 공유된 임베딩 호수를 활용할 수 있는 공공 RAG 모델의 허브입니다. 이 노트북은 데이터 검색 작업을 위한 `Dria API` 사용 방법을 보여줍니다.

# 설치

`dria` 패키지가 설치되어 있는지 확인하세요. pip를 사용하여 설치할 수 있습니다:

```python
%pip install --upgrade --quiet dria
```


# API 키 구성

접속을 위해 Dria API 키를 설정하세요.

```python
import os

os.environ["DRIA_API_KEY"] = "DRIA_API_KEY"
```


# 드리아 리트리버 초기화

`DriaRetriever`의 인스턴스를 생성하세요.

```python
<!--IMPORTS:[{"imported": "DriaRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.dria_index.DriaRetriever.html", "title": "Dria"}]-->
from langchain_community.retrievers import DriaRetriever

api_key = os.getenv("DRIA_API_KEY")
retriever = DriaRetriever(api_key=api_key)
```


# **지식 기반 생성**

[드리아의 지식 허브](https://dria.co/knowledge)에서 지식을 생성하세요.

```python
contract_id = retriever.create_knowledge_base(
    name="France's AI Development",
    embedding=DriaRetriever.models.jina_embeddings_v2_base_en.value,
    category="Artificial Intelligence",
    description="Explore the growth and contributions of France in the field of Artificial Intelligence.",
)
```


# 데이터 추가

드리아 지식 기반에 데이터를 로드하세요.

```python
texts = [
    "The first text to add to Dria.",
    "Another piece of information to store.",
    "More data to include in the Dria knowledge base.",
]

ids = retriever.add_texts(texts)
print("Data added with IDs:", ids)
```


# 데이터 검색

리트리버를 사용하여 쿼리에 따라 관련 문서를 찾으세요.

```python
query = "Find information about Dria."
result = retriever.invoke(query)
for doc in result:
    print(doc)
```


## 관련

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)
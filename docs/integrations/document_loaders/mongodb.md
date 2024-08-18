---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/mongodb.ipynb
description: MongoDB는 JSON과 유사한 문서를 지원하는 NoSQL 문서 지향 데이터베이스로, 동적 스키마를 제공합니다. Langchain
  문서 로더를 통해 MongoDB에서 문서를 불러올 수 있습니다.
---

# MongoDB

[MongoDB](https://www.mongodb.com/)는 동적 스키마를 가진 JSON과 유사한 문서를 지원하는 NoSQL 문서 지향 데이터베이스입니다.

## 개요

MongoDB 문서 로더는 MongoDB 데이터베이스에서 Langchain 문서의 목록을 반환합니다.

로더는 다음 매개변수를 필요로 합니다:

* MongoDB 연결 문자열
* MongoDB 데이터베이스 이름
* MongoDB 컬렉션 이름
* (선택 사항) 콘텐츠 필터 사전
* (선택 사항) 출력에 포함할 필드 이름 목록

출력 형식은 다음과 같습니다:

- pageContent= Mongo 문서
- metadata={'database': '[database_name]', 'collection': '[collection_name]'}

## 문서 로더 로드

```python
# add this import for running in jupyter notebook
import nest_asyncio

nest_asyncio.apply()
```


```python
<!--IMPORTS:[{"imported": "MongodbLoader", "source": "langchain_community.document_loaders.mongodb", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.mongodb.MongodbLoader.html", "title": "MongoDB"}]-->
from langchain_community.document_loaders.mongodb import MongodbLoader
```


```python
loader = MongodbLoader(
    connection_string="mongodb://localhost:27017/",
    db_name="sample_restaurants",
    collection_name="restaurants",
    filter_criteria={"borough": "Bronx", "cuisine": "Bakery"},
    field_names=["name", "address"],
)
```


```python
docs = loader.load()

len(docs)
```


```output
71
```


```python
docs[0]
```


```output
Document(page_content="Morris Park Bake Shop {'building': '1007', 'coord': [-73.856077, 40.848447], 'street': 'Morris Park Ave', 'zipcode': '10462'}", metadata={'database': 'sample_restaurants', 'collection': 'restaurants'})
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
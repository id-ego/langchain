---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/fauna.ipynb
description: Fauna는 문서 데이터베이스로, 쿼리를 통해 데이터를 조회하고 페이지네이션 기능을 제공합니다. 관련 문서 로더 가이드를 확인하세요.
---

# 파우나

> [파우나](https://fauna.com/)는 문서 데이터베이스입니다.

쿼리 `파우나` 문서

```python
%pip install --upgrade --quiet  fauna
```


## 쿼리 데이터 예시

```python
<!--IMPORTS:[{"imported": "FaunaLoader", "source": "langchain_community.document_loaders.fauna", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.fauna.FaunaLoader.html", "title": "Fauna"}]-->
from langchain_community.document_loaders.fauna import FaunaLoader

secret = "<enter-valid-fauna-secret>"
query = "Item.all()"  # Fauna query. Assumes that the collection is called "Item"
field = "text"  # The field that contains the page content. Assumes that the field is called "text"

loader = FaunaLoader(query, field, secret)
docs = loader.lazy_load()

for value in docs:
    print(value)
```


### 페이지네이션이 있는 쿼리
더 많은 데이터가 있는 경우 `after` 값을 얻습니다. 쿼리에서 `after` 문자열을 전달하여 커서 이후의 값을 얻을 수 있습니다.

자세한 내용은 [이 링크](https://fqlx-beta--fauna-docs.netlify.app/fqlx/beta/reference/schema_entities/set/static-paginate)를 참조하세요.

```python
query = """
Item.paginate("hs+DzoPOg ... aY1hOohozrV7A")
Item.all()
"""
loader = FaunaLoader(query, field, secret)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
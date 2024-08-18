---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/nucliadb.ipynb
description: NucliaDB를 사용하여 텍스트를 벡터화하고 인덱싱하며, 로컬 인스턴스 또는 Nuclia Cloud에서 지식 박스를 관리하는
  방법을 안내합니다.
---

# NucliaDB

로컬 NucliaDB 인스턴스를 사용하거나 [Nuclia Cloud](https://nuclia.cloud)를 사용할 수 있습니다.

로컬 인스턴스를 사용할 때는 Nuclia Understanding API 키가 필요하므로 텍스트가 적절하게 벡터화되고 인덱싱됩니다. [https://nuclia.cloud](https://nuclia.cloud)에서 무료 계정을 생성하여 키를 얻고, [NUA 키를 생성하세요](https://docs.nuclia.dev/docs/docs/using/understanding/intro).

```python
%pip install --upgrade --quiet  langchain langchain-community nuclia
```


## nuclia.cloud 사용법

```python
<!--IMPORTS:[{"imported": "NucliaDB", "source": "langchain_community.vectorstores.nucliadb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.nucliadb.NucliaDB.html", "title": "NucliaDB"}]-->
from langchain_community.vectorstores.nucliadb import NucliaDB

API_KEY = "YOUR_API_KEY"

ndb = NucliaDB(knowledge_box="YOUR_KB_ID", local=False, api_key=API_KEY)
```


## 로컬 인스턴스 사용법

참고: 기본적으로 `backend`는 `http://localhost:8080`으로 설정되어 있습니다.

```python
<!--IMPORTS:[{"imported": "NucliaDB", "source": "langchain_community.vectorstores.nucliadb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.nucliadb.NucliaDB.html", "title": "NucliaDB"}]-->
from langchain_community.vectorstores.nucliadb import NucliaDB

ndb = NucliaDB(knowledge_box="YOUR_KB_ID", local=True, backend="http://my-local-server")
```


## 지식 상자에 텍스트 추가 및 삭제

```python
ids = ndb.add_texts(["This is a new test", "This is a second test"])
```


```python
ndb.delete(ids=ids)
```


## 지식 상자에서 검색

```python
results = ndb.similarity_search("Who was inspired by Ada Lovelace?")
print(results[0].page_content)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
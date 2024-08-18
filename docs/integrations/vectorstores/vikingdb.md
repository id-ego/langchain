---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/vikingdb.ipynb
description: 이 문서는 VikingDB 벡터 데이터베이스의 기능을 사용하고, 문서를 수집하여 관리하는 방법을 설명합니다.
---

# 바이킹 DB

> [바이킹 DB](https://www.volcengine.com/docs/6459/1163946)는 심층 신경망 및 기타 머신 러닝(ML) 모델에 의해 생성된 대량의 임베딩 벡터를 저장, 인덱싱 및 관리하는 데이터베이스입니다.

이 노트북은 바이킹DB 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

실행하려면 [바이킹 DB 인스턴스가 실행 중이어야](https://www.volcengine.com/docs/6459/1165058) 합니다.

```python
!pip install --upgrade volcengine
```


VikingDBEmbeddings를 사용하려면 VikingDB API 키를 가져와야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "viking DB"}, {"imported": "VikingDB", "source": "langchain_community.vectorstores.vikingdb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vikingdb.VikingDB.html", "title": "viking DB"}, {"imported": "VikingDBConfig", "source": "langchain_community.vectorstores.vikingdb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vikingdb.VikingDBConfig.html", "title": "viking DB"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "viking DB"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "viking DB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.vikingdb import VikingDB, VikingDBConfig
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
```


```python
loader = TextLoader("./test.txt")
documents = loader.load()
text_splitter = RecursiveCharacterTextSplitter(chunk_size=10, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
db = VikingDB.from_documents(
    docs,
    embeddings,
    connection_args=VikingDBConfig(
        host="host", region="region", ak="ak", sk="sk", scheme="http"
    ),
    drop_old=True,
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
```


```python
docs[0].page_content
```


### 바이킹 DB 컬렉션으로 데이터 구분하기

같은 바이킹 DB 인스턴스 내에서 서로 관련 없는 다양한 문서를 서로 다른 컬렉션에 저장하여 맥락을 유지할 수 있습니다.

새 컬렉션을 만드는 방법은 다음과 같습니다.

```python
db = VikingDB.from_documents(
    docs,
    embeddings,
    connection_args=VikingDBConfig(
        host="host", region="region", ak="ak", sk="sk", scheme="http"
    ),
    collection_name="collection_1",
    drop_old=True,
)
```


저장된 컬렉션을 검색하는 방법은 다음과 같습니다.

```python
db = VikingDB.from_documents(
    embeddings,
    connection_args=VikingDBConfig(
        host="host", region="region", ak="ak", sk="sk", scheme="http"
    ),
    collection_name="collection_1",
)
```


검색 후에는 평소처럼 쿼리를 계속 진행할 수 있습니다.

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
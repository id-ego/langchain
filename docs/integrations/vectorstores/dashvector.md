---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/dashvector.ipynb
description: DashVector는 고차원 밀집 및 희소 벡터를 지원하는 완전 관리형 벡터DB 서비스로, 실시간 삽입 및 필터링 검색 기능을
  제공합니다.
---

# DashVector

> [DashVector](https://help.aliyun.com/document_detail/2510225.html)는 고차원 밀집 및 희소 벡터, 실시간 삽입 및 필터링된 검색을 지원하는 완전 관리형 벡터DB 서비스입니다. 자동으로 확장되도록 구축되었으며 다양한 애플리케이션 요구 사항에 적응할 수 있습니다.

이 노트북은 `DashVector` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

DashVector를 사용하려면 API 키가 필요합니다. [설치 지침](https://help.aliyun.com/document_detail/2510223.html)을 참조하세요.

## 설치

```python
%pip install --upgrade --quiet  langchain-community dashvector dashscope
```


`DashScopeEmbeddings`를 사용하려고 하므로 Dashscope API 키도 받아야 합니다.

```python
import getpass
import os

os.environ["DASHVECTOR_API_KEY"] = getpass.getpass("DashVector API Key:")
os.environ["DASHSCOPE_API_KEY"] = getpass.getpass("DashScope API Key:")
```


## 예제

```python
<!--IMPORTS:[{"imported": "DashScopeEmbeddings", "source": "langchain_community.embeddings.dashscope", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.dashscope.DashScopeEmbeddings.html", "title": "DashVector"}, {"imported": "DashVector", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.dashvector.DashVector.html", "title": "DashVector"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "DashVector"}]-->
from langchain_community.embeddings.dashscope import DashScopeEmbeddings
from langchain_community.vectorstores import DashVector
from langchain_text_splitters import CharacterTextSplitter
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DashVector"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = DashScopeEmbeddings()
```


문서에서 DashVector를 생성할 수 있습니다.

```python
dashvector = DashVector.from_documents(docs, embeddings)

query = "What did the president say about Ketanji Brown Jackson"
docs = dashvector.similarity_search(query)
print(docs)
```


메타 데이터와 ID가 포함된 텍스트를 추가하고 메타 필터로 검색할 수 있습니다.

```python
texts = ["foo", "bar", "baz"]
metadatas = [{"key": i} for i in range(len(texts))]
ids = ["0", "1", "2"]

dashvector.add_texts(texts, metadatas=metadatas, ids=ids)

docs = dashvector.similarity_search("foo", filter="key = 2")
print(docs)
```

```output
[Document(page_content='baz', metadata={'key': 2})]
```

### 운영 밴드 `partition` 매개변수

`partition` 매개변수는 기본값으로 설정되며, 존재하지 않는 `partition` 매개변수가 전달되면 `partition`이 자동으로 생성됩니다.

```python
texts = ["foo", "bar", "baz"]
metadatas = [{"key": i} for i in range(len(texts))]
ids = ["0", "1", "2"]
partition = "langchain"

# add texts
dashvector.add_texts(texts, metadatas=metadatas, ids=ids, partition=partition)

# similarity search
query = "What did the president say about Ketanji Brown Jackson"
docs = dashvector.similarity_search(query, partition=partition)

# delete
dashvector.delete(ids=ids, partition=partition)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
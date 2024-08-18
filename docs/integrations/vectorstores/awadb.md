---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/awadb.ipynb
description: AwaDB는 LLM 애플리케이션에 사용되는 임베딩 벡터의 검색 및 저장을 위한 AI 네이티브 데이터베이스입니다.
---

# AwaDB
> [AwaDB](https://github.com/awa-ai/awadb)는 LLM 애플리케이션에서 사용되는 임베딩 벡터의 검색 및 저장을 위한 AI 네이티브 데이터베이스입니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `AwaDB`와 관련된 기능을 사용하는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet  awadb
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "AwaDB"}, {"imported": "AwaDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.awadb.AwaDB.html", "title": "AwaDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "AwaDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import AwaDB
from langchain_text_splitters import CharacterTextSplitter
```


```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=100, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
```


```python
db = AwaDB.from_documents(docs)
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

## 점수를 통한 유사성 검색

반환된 거리 점수는 0-1 사이입니다. 0은 유사하지 않음을, 1은 가장 유사함을 나타냅니다.

```python
docs = db.similarity_search_with_score(query)
```


```python
print(docs[0])
```

```output
(Document(page_content='And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt'}), 0.561813814013747)
```

## 이전에 생성하고 추가한 테이블 복원

AwaDB는 추가된 문서 데이터를 자동으로 지속합니다.

이전에 생성하고 추가한 테이블을 복원할 수 있다면, 아래와 같이 간단히 수행할 수 있습니다:

```python
import awadb

awadb_client = awadb.Client()
ret = awadb_client.Load("langchain_awadb")
if ret:
    print("awadb load table success")
else:
    print("awadb load table failed")
```

awadb load table success

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
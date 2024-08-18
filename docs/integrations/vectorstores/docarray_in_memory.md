---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/docarray_in_memory.ipynb
description: DocArrayInMemorySearch는 메모리에 문서를 저장하는 인덱스로, 작은 데이터셋에 적합하며 데이터베이스 서버를
  실행할 필요가 없습니다.
---

# DocArray InMemorySearch

> [DocArrayInMemorySearch](https://docs.docarray.org/user_guide/storing/index_in_memory/)는 [Docarray](https://github.com/docarray/docarray)에서 제공하는 메모리 내 문서 인덱스입니다. 데이터베이스 서버를 실행하고 싶지 않은 작은 데이터셋에 적합한 훌륭한 시작점입니다.

이 노트북은 `DocArrayInMemorySearch`와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

아래 셀의 주석을 제거하여 docarray를 설치하고 OpenAI API 키를 설정하세요. 아직 설정하지 않았다면.

```python
%pip install --upgrade --quiet  langchain-community "docarray"
```


```python
# Get an OpenAI token: https://platform.openai.com/account/api-keys

# import os
# from getpass import getpass

# OPENAI_API_KEY = getpass()

# os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY
```


## DocArrayInMemorySearch 사용하기

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DocArray InMemorySearch"}, {"imported": "DocArrayInMemorySearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.docarray.in_memory.DocArrayInMemorySearch.html", "title": "DocArray InMemorySearch"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "DocArray InMemorySearch"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "DocArray InMemorySearch"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import DocArrayInMemorySearch
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

db = DocArrayInMemorySearch.from_documents(docs, embeddings)
```


### 유사성 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

### 점수가 있는 유사성 검색

반환된 거리 점수는 코사인 거리입니다. 따라서 점수가 낮을수록 좋습니다.

```python
docs = db.similarity_search_with_score(query)
```


```python
docs[0]
```


```output
(Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={}),
 0.8154190158347903)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
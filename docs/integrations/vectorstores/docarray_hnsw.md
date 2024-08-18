---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/docarray_hnsw.ipynb
description: DocArray HnswSearch는 소형 및 중형 데이터셋에 적합한 경량 문서 인덱스 구현체로, 벡터를 hnswlib에 저장하고
  기타 데이터를 SQLite에 저장합니다.
---

# DocArray HnswSearch

> [DocArrayHnswSearch](https://docs.docarray.org/user_guide/storing/index_hnswlib/)는 [Docarray](https://github.com/docarray/docarray)에서 제공하는 경량 문서 인덱스 구현으로, 완전히 로컬에서 실행되며 소규모에서 중규모 데이터셋에 가장 적합합니다. 벡터는 [hnswlib](https://github.com/nmslib/hnswlib)에서 디스크에 저장되고, 모든 다른 데이터는 [SQLite](https://www.sqlite.org/index.html)에 저장됩니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `DocArrayHnswSearch`와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

아래 셀의 주석을 제거하여 docarray를 설치하고 OpenAI API 키를 설정/가져오세요. 아직 하지 않았다면.

```python
%pip install --upgrade --quiet  "docarray[hnswlib]"
```


```python
# Get an OpenAI token: https://platform.openai.com/account/api-keys

# import os
# from getpass import getpass

# OPENAI_API_KEY = getpass()

# os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY
```


## DocArrayHnswSearch 사용하기

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DocArray HnswSearch"}, {"imported": "DocArrayHnswSearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.docarray.hnsw.DocArrayHnswSearch.html", "title": "DocArray HnswSearch"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "DocArray HnswSearch"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "DocArray HnswSearch"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import DocArrayHnswSearch
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

db = DocArrayHnswSearch.from_documents(
    docs, embeddings, work_dir="hnswlib_store/", n_dim=1536
)
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

반환된 거리 점수는 코사인 거리입니다. 따라서 낮은 점수가 더 좋습니다.

```python
docs = db.similarity_search_with_score(query)
```


```python
docs[0]
```


```output
(Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={}),
 0.36962226)
```


```python
import shutil

# delete the dir
shutil.rmtree("hnswlib_store")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
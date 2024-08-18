---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/bagel.ipynb
description: Bagel은 AI 데이터의 협업 플랫폼으로, 사용자들이 추론 데이터셋을 생성, 공유 및 관리할 수 있도록 지원합니다.
---

# 베이글

> [베이글](https://www.bagel.net/) (`AI를 위한 오픈 추론 플랫폼`)은 AI 데이터에 대한 GitHub와 같습니다.  
사용자가 추론 데이터셋을 생성, 공유 및 관리할 수 있는 협업 플랫폼입니다. 독립 개발자를 위한 개인 프로젝트, 기업의 내부 협업, 데이터 DAO를 위한 공개 기여를 지원할 수 있습니다.

### 설치 및 설정

```bash
pip install bagelML langchain-community
```


## 텍스트에서 VectorStore 생성

```python
<!--IMPORTS:[{"imported": "Bagel", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.bagel.Bagel.html", "title": "Bagel"}]-->
from langchain_community.vectorstores import Bagel

texts = ["hello bagel", "hello langchain", "I love salad", "my car", "a dog"]
# create cluster and add texts
cluster = Bagel.from_texts(cluster_name="testing", texts=texts)
```


```python
# similarity search
cluster.similarity_search("bagel", k=3)
```


```output
[Document(page_content='hello bagel', metadata={}),
 Document(page_content='my car', metadata={}),
 Document(page_content='I love salad', metadata={})]
```


```python
# the score is a distance metric, so lower is better
cluster.similarity_search_with_score("bagel", k=3)
```


```output
[(Document(page_content='hello bagel', metadata={}), 0.27392977476119995),
 (Document(page_content='my car', metadata={}), 1.4783176183700562),
 (Document(page_content='I love salad', metadata={}), 1.5342965126037598)]
```


```python
# delete the cluster
cluster.delete_cluster()
```


## 문서에서 VectorStore 생성

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Bagel"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Bagel"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)[:10]
```


```python
# create cluster with docs
cluster = Bagel.from_documents(cluster_name="testing_with_docs", documents=docs)
```


```python
# similarity search
query = "What did the president say about Ketanji Brown Jackson"
docs = cluster.similarity_search(query)
print(docs[0].page_content[:102])
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the
```


## 클러스터에서 모든 텍스트/문서 가져오기

```python
texts = ["hello bagel", "this is langchain"]
cluster = Bagel.from_texts(cluster_name="testing", texts=texts)
cluster_data = cluster.get()
```


```python
# all keys
cluster_data.keys()
```


```output
dict_keys(['ids', 'embeddings', 'metadatas', 'documents'])
```


```python
# all values and keys
cluster_data
```


```output
{'ids': ['578c6d24-3763-11ee-a8ab-b7b7b34f99ba',
  '578c6d25-3763-11ee-a8ab-b7b7b34f99ba',
  'fb2fc7d8-3762-11ee-a8ab-b7b7b34f99ba',
  'fb2fc7d9-3762-11ee-a8ab-b7b7b34f99ba',
  '6b40881a-3762-11ee-a8ab-b7b7b34f99ba',
  '6b40881b-3762-11ee-a8ab-b7b7b34f99ba',
  '581e691e-3762-11ee-a8ab-b7b7b34f99ba',
  '581e691f-3762-11ee-a8ab-b7b7b34f99ba'],
 'embeddings': None,
 'metadatas': [{}, {}, {}, {}, {}, {}, {}, {}],
 'documents': ['hello bagel',
  'this is langchain',
  'hello bagel',
  'this is langchain',
  'hello bagel',
  'this is langchain',
  'hello bagel',
  'this is langchain']}
```


```python
cluster.delete_cluster()
```


## 메타데이터로 클러스터 생성 및 메타데이터 사용하여 필터링

```python
texts = ["hello bagel", "this is langchain"]
metadatas = [{"source": "notion"}, {"source": "google"}]

cluster = Bagel.from_texts(cluster_name="testing", texts=texts, metadatas=metadatas)
cluster.similarity_search_with_score("hello bagel", where={"source": "notion"})
```


```output
[(Document(page_content='hello bagel', metadata={'source': 'notion'}), 0.0)]
```


```python
# delete the cluster
cluster.delete_cluster()
```


## 관련

- Vector store [개념 가이드](/docs/concepts/#vector-stores)
- Vector store [사용 방법 가이드](/docs/how_to/#vector-stores)
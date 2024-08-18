---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/semadb.ipynb
description: SemaDB는 AI 애플리케이션 구축을 위한 간편한 벡터 유사성 데이터베이스입니다. SemaDB Cloud를 통해 쉽게 시작할
  수 있습니다.
---

# SemaDB

> [SemaDB](https://www.semafind.com/products/semadb)는 [SemaFind](https://www.semafind.com)에서 제공하는 AI 애플리케이션 구축을 위한 간편한 벡터 유사성 데이터베이스입니다. 호스팅된 `SemaDB Cloud`는 시작하기 위한 간편한 개발자 경험을 제공합니다.

API의 전체 문서와 예제, 인터랙티브 플레이그라운드는 [RapidAPI](https://rapidapi.com/semafind-semadb/api/semadb)에서 확인할 수 있습니다.

이 노트북은 `SemaDB Cloud` 벡터 저장소의 사용법을 보여줍니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

## 문서 임베딩 로드

로컬에서 실행하기 위해 우리는 일반적으로 문장 임베딩에 사용되는 [Sentence Transformers](https://www.sbert.net/)를 사용하고 있습니다. LangChain이 제공하는 어떤 임베딩 모델도 사용할 수 있습니다.

```python
%pip install --upgrade --quiet  sentence_transformers
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "SemaDB"}]-->
from langchain_huggingface import HuggingFaceEmbeddings

embeddings = HuggingFaceEmbeddings()
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SemaDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SemaDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=400, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
print(len(docs))
```

```output
114
```


## SemaDB에 연결

SemaDB Cloud는 [RapidAPI 키](https://rapidapi.com/semafind-semadb/api/semadb)를 사용하여 인증합니다. 무료 RapidAPI 계정을 생성하여 키를 얻을 수 있습니다.

```python
import getpass
import os

os.environ["SEMADB_API_KEY"] = getpass.getpass("SemaDB API Key:")
```

```output
SemaDB API Key: ········
```


```python
<!--IMPORTS:[{"imported": "SemaDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.semadb.SemaDB.html", "title": "SemaDB"}, {"imported": "DistanceStrategy", "source": "langchain_community.vectorstores.utils", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.utils.DistanceStrategy.html", "title": "SemaDB"}]-->
from langchain_community.vectorstores import SemaDB
from langchain_community.vectorstores.utils import DistanceStrategy
```


SemaDB 벡터 저장소의 매개변수는 API를 직접 반영합니다:

- "mycollection": 이 벡터를 저장할 컬렉션 이름입니다.
- 768: 벡터의 차원입니다. 우리의 경우, 문장 변환기 임베딩은 768 차원 벡터를 생성합니다.
- API_KEY: 당신의 RapidAPI 키입니다.
- embeddings: 문서, 텍스트 및 쿼리의 임베딩이 생성되는 방식을 나타냅니다.
- DistanceStrategy: 사용되는 거리 메트릭입니다. COSINE이 사용될 경우 래퍼가 벡터를 자동으로 정규화합니다.

```python
db = SemaDB("mycollection", 768, embeddings, DistanceStrategy.COSINE)

# Create collection if running for the first time. If the collection
# already exists this will fail.
db.create_collection()
```


```output
True
```


SemaDB 벡터 저장소 래퍼는 나중에 수집하기 위해 문서 텍스트를 포인트 메타데이터로 추가합니다. 대량의 텍스트를 저장하는 것은 *권장되지 않습니다*. 대규모 컬렉션을 인덱싱하는 경우, 외부 ID와 같은 문서에 대한 참조를 저장하는 것을 권장합니다.

```python
db.add_documents(docs)[:2]
```


```output
['813c7ef3-9797-466b-8afa-587115592c6c',
 'fc392f7f-082b-4932-bfcc-06800db5e017']
```


## 유사성 검색

우리는 가장 유사한 문장을 검색하기 위해 기본 LangChain 유사성 검색 인터페이스를 사용합니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
print(docs[0].page_content)
```

```output
And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```


```python
docs = db.similarity_search_with_score(query)
docs[0]
```


```output
(Document(page_content='And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt', 'text': 'And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.'}),
 0.42369342)
```


## 정리

컬렉션을 삭제하여 모든 데이터를 제거할 수 있습니다.

```python
db.delete_collection()
```


```output
True
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
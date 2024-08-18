---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/tair.ipynb
description: Tair는 Alibaba Cloud에서 개발한 클라우드 네이티브 인메모리 데이터베이스 서비스로, Redis와 호환되며 실시간
  온라인 시나리오를 지원합니다.
---

# Tair

> [Tair](https://www.alibabacloud.com/help/en/tair/latest/what-is-tair)는 `Alibaba Cloud`에서 개발한 클라우드 네이티브 인메모리 데이터베이스 서비스입니다. 이는 풍부한 데이터 모델과 기업 수준의 기능을 제공하여 실시간 온라인 시나리오를 지원하며 오픈 소스 `Redis`와의 완전한 호환성을 유지합니다. `Tair`는 또한 새로운 비휘발성 메모리(NVM) 저장 매체를 기반으로 하는 지속 메모리 최적화 인스턴스를 도입합니다.

이 노트북은 `Tair` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

실행하려면 `Tair` 인스턴스가 실행 중이어야 합니다.

```python
<!--IMPORTS:[{"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Tair"}, {"imported": "Tair", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tair.Tair.html", "title": "Tair"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Tair"}]-->
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores import Tair
from langchain_text_splitters import CharacterTextSplitter
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Tair"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = FakeEmbeddings(size=128)
```


`TAIR_URL` 환경 변수를 사용하여 Tair에 연결합니다.  
```
export TAIR_URL="redis://{username}:{password}@{tair_address}:{tair_port}"
```


또는 키워드 인수 `tair_url`을 사용할 수 있습니다.

그런 다음 문서와 임베딩을 Tair에 저장합니다.

```python
tair_url = "redis://localhost:6379"

# drop first if index already exists
Tair.drop_index(tair_url=tair_url)

vector_store = Tair.from_documents(docs, embeddings, tair_url=tair_url)
```


유사한 문서를 쿼리합니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_store.similarity_search(query)
docs[0]
```


Tair 하이브리드 검색 인덱스 구축

```python
# drop first if index already exists
Tair.drop_index(tair_url=tair_url)

vector_store = Tair.from_documents(
    docs, embeddings, tair_url=tair_url, index_params={"lexical_algorithm": "bm25"}
)
```


Tair 하이브리드 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
# hybrid_ratio: 0.5 hybrid search, 0.9999 vector search, 0.0001 text search
kwargs = {"TEXT": query, "hybrid_ratio": 0.5}
docs = vector_store.similarity_search(query, **kwargs)
docs[0]
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
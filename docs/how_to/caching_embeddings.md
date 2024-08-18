---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/caching_embeddings.ipynb
description: 임베딩을 재계산하지 않도록 저장하거나 임시로 캐시할 수 있는 방법을 설명합니다. CacheBackedEmbeddings를 사용하여
  효율성을 높입니다.
---

# 캐싱

임베딩은 재계산할 필요 없이 저장되거나 임시로 캐시될 수 있습니다.

임베딩 캐싱은 `CacheBackedEmbeddings`를 사용하여 수행할 수 있습니다. 캐시 백업 임베더는 키-값 저장소에 임베딩을 캐시하는 임베더의 래퍼입니다. 텍스트는 해시되고 해시는 캐시의 키로 사용됩니다.

`CacheBackedEmbeddings`를 초기화하는 주요 지원 방법은 `from_bytes_store`입니다. 다음 매개변수를 사용합니다:

- underlying_embedder: 임베딩에 사용할 임베더.
- document_embedding_cache: 문서 임베딩을 캐시하기 위한 [`ByteStore`](/docs/integrations/stores/).
- batch_size: (선택 사항, 기본값은 `None`) 저장소 업데이트 간에 임베딩할 문서 수.
- namespace: (선택 사항, 기본값은 `""`) 문서 캐시에 사용할 네임스페이스. 이 네임스페이스는 다른 캐시와의 충돌을 피하는 데 사용됩니다. 예를 들어, 사용된 임베딩 모델의 이름으로 설정합니다.
- query_embedding_cache: (선택 사항, 기본값은 `None` 또는 캐시하지 않음) 쿼리 임베딩을 캐시하기 위한 [`ByteStore`](/docs/integrations/stores/), 또는 `document_embedding_cache`와 동일한 저장소를 사용하기 위해 `True`.

**주의**:

- 서로 다른 임베딩 모델을 사용하여 동일한 텍스트가 임베딩되는 충돌을 피하기 위해 `namespace` 매개변수를 설정해야 합니다.
- 기본적으로 `CacheBackedEmbeddings`는 쿼리 임베딩을 캐시하지 않습니다. 쿼리 캐싱을 활성화하려면 `query_embedding_cache`를 지정해야 합니다.

```python
<!--IMPORTS:[{"imported": "CacheBackedEmbeddings", "source": "langchain.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain.embeddings.cache.CacheBackedEmbeddings.html", "title": "Caching"}]-->
from langchain.embeddings import CacheBackedEmbeddings
```


## 벡터 저장소와 함께 사용하기

먼저, 임베딩을 저장하기 위해 로컬 파일 시스템을 사용하고 검색을 위해 FAISS 벡터 저장소를 사용하는 예제를 살펴보겠습니다.

```python
%pip install --upgrade --quiet  langchain-openai faiss-cpu
```


```python
<!--IMPORTS:[{"imported": "LocalFileStore", "source": "langchain.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain.storage.file_system.LocalFileStore.html", "title": "Caching"}, {"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Caching"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Caching"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Caching"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Caching"}]-->
from langchain.storage import LocalFileStore
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

underlying_embeddings = OpenAIEmbeddings()

store = LocalFileStore("./cache/")

cached_embedder = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings, store, namespace=underlying_embeddings.model
)
```


임베딩 전에 캐시는 비어 있습니다:

```python
list(store.yield_keys())
```


```output
[]
```


문서를 로드하고, 청크로 나누고, 각 청크를 임베딩하고 벡터 저장소에 로드합니다.

```python
raw_documents = TextLoader("state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
documents = text_splitter.split_documents(raw_documents)
```


벡터 저장소를 생성합니다:

```python
%%time
db = FAISS.from_documents(documents, cached_embedder)
```

```output
CPU times: user 218 ms, sys: 29.7 ms, total: 248 ms
Wall time: 1.02 s
```

벡터 저장소를 다시 생성하려고 하면, 임베딩을 다시 계산할 필요가 없으므로 훨씬 빨라질 것입니다.

```python
%%time
db2 = FAISS.from_documents(documents, cached_embedder)
```

```output
CPU times: user 15.7 ms, sys: 2.22 ms, total: 18 ms
Wall time: 17.2 ms
```

그리고 여기 생성된 일부 임베딩이 있습니다:

```python
list(store.yield_keys())[:5]
```


```output
['text-embedding-ada-00217a6727d-8916-54eb-b196-ec9c9d6ca472',
 'text-embedding-ada-0025fc0d904-bd80-52da-95c9-441015bfb438',
 'text-embedding-ada-002e4ad20ef-dfaa-5916-9459-f90c6d8e8159',
 'text-embedding-ada-002ed199159-c1cd-5597-9757-f80498e8f17b',
 'text-embedding-ada-0021297d37a-2bc1-5e19-bf13-6c950f075062']
```


# `ByteStore` 교체하기

다른 `ByteStore`를 사용하려면 `CacheBackedEmbeddings`를 생성할 때 그것을 사용하면 됩니다. 아래에서는 비영구적인 `InMemoryByteStore`를 사용하는 동등한 캐시된 임베딩 객체를 생성합니다:

```python
<!--IMPORTS:[{"imported": "CacheBackedEmbeddings", "source": "langchain.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain.embeddings.cache.CacheBackedEmbeddings.html", "title": "Caching"}, {"imported": "InMemoryByteStore", "source": "langchain.storage", "docs": "https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryByteStore.html", "title": "Caching"}]-->
from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import InMemoryByteStore

store = InMemoryByteStore()

cached_embedder = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings, store, namespace=underlying_embeddings.model
)
```
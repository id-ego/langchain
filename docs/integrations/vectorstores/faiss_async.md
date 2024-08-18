---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/faiss_async.ipynb
description: Faiss는 밀집 벡터의 효율적인 유사성 검색 및 클러스터링을 위한 라이브러리입니다. 비동기 기능을 활용하여 LangChain과
  통합됩니다.
---

# Faiss (비동기)

> [Facebook AI 유사성 검색 (Faiss)](https://engineering.fb.com/2017/03/29/data-infrastructure/faiss-a-library-for-efficient-similarity-search/)는 밀집 벡터의 효율적인 유사성 검색 및 클러스터링을 위한 라이브러리입니다. 이 라이브러리는 RAM에 맞지 않을 수 있는 크기의 벡터 집합에서 검색하는 알고리즘을 포함하고 있습니다. 또한 평가 및 매개변수 조정을 위한 지원 코드를 포함하고 있습니다.

[Faiss 문서](https://faiss.ai/)를 참조하세요.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `asyncio`를 사용하여 `FAISS` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다. LangChain은 동기 및 비동기 벡터 저장소 기능을 구현했습니다.

`synchronous` 버전은 [여기](/docs/integrations/vectorstores/faiss)에서 확인하세요.

```python
%pip install --upgrade --quiet  faiss-gpu # For CUDA 7.5+ Supported GPU's.
# OR
%pip install --upgrade --quiet  faiss-cpu # For CPU Installation
```


OpenAIEmbeddings를 사용하려면 OpenAI API 키를 가져와야 합니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Faiss (Async)"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Faiss (Async)"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Faiss (Async)"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Faiss (Async)"}]-->
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")

# Uncomment the following line if you need to initialize FAISS with no AVX2 optimization
# os.environ['FAISS_NO_AVX2'] = '1'

from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../../extras/modules/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

db = await FAISS.afrom_documents(docs, embeddings)

query = "What did the president say about Ketanji Brown Jackson"
docs = await db.asimilarity_search(query)

print(docs[0].page_content)
```


## 점수가 있는 유사성 검색
FAISS 특정 메서드가 몇 가지 있습니다. 그 중 하나는 `similarity_search_with_score`로, 문서뿐만 아니라 쿼리와의 거리 점수도 반환할 수 있습니다. 반환된 거리 점수는 L2 거리입니다. 따라서 점수가 낮을수록 좋습니다.

```python
docs_and_scores = await db.asimilarity_search_with_score(query)

docs_and_scores[0]
```


주어진 임베딩 벡터와 유사한 문서를 검색하는 것도 가능합니다. 이때 `similarity_search_by_vector`를 사용하며, 문자열 대신 임베딩 벡터를 매개변수로 받습니다.

```python
embedding_vector = await embeddings.aembed_query(query)
docs_and_scores = await db.asimilarity_search_by_vector(embedding_vector)
```


## 저장 및 로드
FAISS 인덱스를 저장하고 로드할 수도 있습니다. 이렇게 하면 사용할 때마다 인덱스를 재생성할 필요가 없습니다.

```python
db.save_local("faiss_index")

new_db = FAISS.load_local("faiss_index", embeddings, asynchronous=True)

docs = await new_db.asimilarity_search(query)

docs[0]
```


# 바이트로 직렬화 및 역직렬화

이 함수들을 사용하여 FAISS 인덱스를 피클링할 수 있습니다. 90MB의 임베딩 모델(예: sentence-transformers/all-MiniLM-L6-v2 또는 다른 모델)을 사용하는 경우 결과 피클 크기는 90MB를 초과할 것입니다. 모델의 크기도 전체 크기에 포함됩니다. 이를 극복하기 위해 아래의 함수를 사용하세요. 이 함수들은 FAISS 인덱스만 직렬화하며 크기는 훨씬 작아집니다. 이는 SQL과 같은 데이터베이스에 인덱스를 저장하려는 경우 유용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Faiss (Async)"}]-->
from langchain_huggingface import HuggingFaceEmbeddings

pkl = db.serialize_to_bytes()  # serializes the faiss index
embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
db = FAISS.deserialize_from_bytes(
    embeddings=embeddings, serialized=pkl, asynchronous=True
)  # Load the index
```


## 병합
두 개의 FAISS 벡터 저장소를 병합할 수도 있습니다.

```python
db1 = await FAISS.afrom_texts(["foo"], embeddings)
db2 = await FAISS.afrom_texts(["bar"], embeddings)
```


```python
db1.docstore._dict
```


```output
{'8164a453-9643-4959-87f7-9ba79f9e8fb0': Document(page_content='foo')}
```


```python
db2.docstore._dict
```


```output
{'4fbcf8a2-e80f-4f65-9308-2f4cb27cb6e7': Document(page_content='bar')}
```


```python
db1.merge_from(db2)
```


```python
db1.docstore._dict
```


```output
{'8164a453-9643-4959-87f7-9ba79f9e8fb0': Document(page_content='foo'),
 '4fbcf8a2-e80f-4f65-9308-2f4cb27cb6e7': Document(page_content='bar')}
```


## 필터링이 있는 유사성 검색
FAISS 벡터 저장소는 필터링도 지원할 수 있습니다. FAISS는 기본적으로 필터링을 지원하지 않기 때문에 수동으로 수행해야 합니다. 이는 먼저 `k`보다 더 많은 결과를 가져온 다음 필터링하는 방식으로 이루어집니다. 메타데이터를 기반으로 문서를 필터링할 수 있습니다. 필터링 전에 가져오고 싶은 문서 수를 설정하기 위해 검색 메서드를 호출할 때 `fetch_k` 매개변수를 설정할 수도 있습니다. 다음은 간단한 예입니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Faiss (Async)"}]-->
from langchain_core.documents import Document

list_of_documents = [
    Document(page_content="foo", metadata=dict(page=1)),
    Document(page_content="bar", metadata=dict(page=1)),
    Document(page_content="foo", metadata=dict(page=2)),
    Document(page_content="barbar", metadata=dict(page=2)),
    Document(page_content="foo", metadata=dict(page=3)),
    Document(page_content="bar burr", metadata=dict(page=3)),
    Document(page_content="foo", metadata=dict(page=4)),
    Document(page_content="bar bruh", metadata=dict(page=4)),
]
db = FAISS.from_documents(list_of_documents, embeddings)
results_with_scores = db.similarity_search_with_score("foo")
for doc, score in results_with_scores:
    print(f"Content: {doc.page_content}, Metadata: {doc.metadata}, Score: {score}")
```

```output
Content: foo, Metadata: {'page': 1}, Score: 5.159960813797904e-15
Content: foo, Metadata: {'page': 2}, Score: 5.159960813797904e-15
Content: foo, Metadata: {'page': 3}, Score: 5.159960813797904e-15
Content: foo, Metadata: {'page': 4}, Score: 5.159960813797904e-15
```

이제 동일한 쿼리 호출을 하지만 `page = 1`만 필터링합니다.

```python
results_with_scores = await db.asimilarity_search_with_score("foo", filter=dict(page=1))
for doc, score in results_with_scores:
    print(f"Content: {doc.page_content}, Metadata: {doc.metadata}, Score: {score}")
```

```output
Content: foo, Metadata: {'page': 1}, Score: 5.159960813797904e-15
Content: bar, Metadata: {'page': 1}, Score: 0.3131446838378906
```

`max_marginal_relevance_search`에서도 동일한 작업을 수행할 수 있습니다.

```python
results = await db.amax_marginal_relevance_search("foo", filter=dict(page=1))
for doc in results:
    print(f"Content: {doc.page_content}, Metadata: {doc.metadata}")
```

```output
Content: foo, Metadata: {'page': 1}
Content: bar, Metadata: {'page': 1}
```

다음은 `similarity_search`를 호출할 때 `fetch_k` 매개변수를 설정하는 방법의 예입니다. 일반적으로 `fetch_k` 매개변수는 `k` 매개변수보다 커야 합니다. 이는 `fetch_k` 매개변수가 필터링 전에 가져올 문서 수이기 때문입니다. `fetch_k`를 낮은 숫자로 설정하면 필터링할 충분한 문서를 얻지 못할 수 있습니다.

```python
results = await db.asimilarity_search("foo", filter=dict(page=1), k=1, fetch_k=4)
for doc in results:
    print(f"Content: {doc.page_content}, Metadata: {doc.metadata}")
```

```output
Content: foo, Metadata: {'page': 1}
```

## 삭제

ID를 삭제할 수도 있습니다. 삭제할 ID는 docstore의 ID여야 합니다.

```python
db.delete([db.index_to_docstore_id[0]])
```


```output
True
```


```python
# Is now missing
0 in db.index_to_docstore_id
```


```output
False
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
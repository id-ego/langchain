---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/time_weighted_vectorstore.ipynb
description: 시간 가중 벡터 저장소 검색기를 사용하는 방법에 대한 설명으로, 의미적 유사성과 시간 감쇠를 결합한 알고리즘을 다룹니다.
---

# 시간 가중 벡터 저장소 검색기 사용 방법

이 검색기는 의미론적 유사성과 시간 감소를 결합하여 사용합니다.

점수를 매기는 알고리즘은 다음과 같습니다:

```
semantic_similarity + (1.0 - decay_rate) ^ hours_passed
```


특히, `hours_passed`는 검색기에서 객체가 **마지막으로 접근된** 이후 경과된 시간을 의미하며, 생성된 이후의 시간이 아닙니다. 이는 자주 접근되는 객체가 "신선하게" 유지된다는 것을 의미합니다.

```python
<!--IMPORTS:[{"imported": "TimeWeightedVectorStoreRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.time_weighted_retriever.TimeWeightedVectorStoreRetriever.html", "title": "How to use a time-weighted vector store retriever"}, {"imported": "InMemoryDocstore", "source": "langchain_community.docstore", "docs": "https://api.python.langchain.com/en/latest/docstore/langchain_community.docstore.in_memory.InMemoryDocstore.html", "title": "How to use a time-weighted vector store retriever"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to use a time-weighted vector store retriever"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to use a time-weighted vector store retriever"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to use a time-weighted vector store retriever"}]-->
from datetime import datetime, timedelta

import faiss
from langchain.retrievers import TimeWeightedVectorStoreRetriever
from langchain_community.docstore import InMemoryDocstore
from langchain_community.vectorstores import FAISS
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
```


## 낮은 감소율

낮은 `decay rate`(이 경우, 극단적으로 0에 가깝게 설정할 것입니다)는 기억이 더 오랫동안 "기억"된다는 것을 의미합니다. `decay rate`가 0이면 기억이 결코 잊혀지지 않으며, 이는 이 검색기가 벡터 조회와 동등하다는 것을 의미합니다.

```python
# Define your embedding model
embeddings_model = OpenAIEmbeddings()
# Initialize the vectorstore as empty
embedding_size = 1536
index = faiss.IndexFlatL2(embedding_size)
vectorstore = FAISS(embeddings_model, index, InMemoryDocstore({}), {})
retriever = TimeWeightedVectorStoreRetriever(
    vectorstore=vectorstore, decay_rate=0.0000000000000000000000001, k=1
)
```


```python
yesterday = datetime.now() - timedelta(days=1)
retriever.add_documents(
    [Document(page_content="hello world", metadata={"last_accessed_at": yesterday})]
)
retriever.add_documents([Document(page_content="hello foo")])
```


```output
['c3dcf671-3c0a-4273-9334-c4a913076bfa']
```


```python
# "Hello World" is returned first because it is most salient, and the decay rate is close to 0., meaning it's still recent enough
retriever.get_relevant_documents("hello world")
```


```output
[Document(page_content='hello world', metadata={'last_accessed_at': datetime.datetime(2023, 12, 27, 15, 30, 18, 457125), 'created_at': datetime.datetime(2023, 12, 27, 15, 30, 8, 442662), 'buffer_idx': 0})]
```


## 높은 감소율

높은 `decay rate`(예: 여러 개의 9)에서는 `recency score`가 빠르게 0으로 떨어집니다! 이를 1로 설정하면 모든 객체의 `recency`가 0이 되어, 다시 한 번 벡터 조회와 동등하게 됩니다.

```python
# Define your embedding model
embeddings_model = OpenAIEmbeddings()
# Initialize the vectorstore as empty
embedding_size = 1536
index = faiss.IndexFlatL2(embedding_size)
vectorstore = FAISS(embeddings_model, index, InMemoryDocstore({}), {})
retriever = TimeWeightedVectorStoreRetriever(
    vectorstore=vectorstore, decay_rate=0.999, k=1
)
```


```python
yesterday = datetime.now() - timedelta(days=1)
retriever.add_documents(
    [Document(page_content="hello world", metadata={"last_accessed_at": yesterday})]
)
retriever.add_documents([Document(page_content="hello foo")])
```


```output
['eb1c4c86-01a8-40e3-8393-9a927295a950']
```


```python
# "Hello Foo" is returned first because "hello world" is mostly forgotten
retriever.get_relevant_documents("hello world")
```


```output
[Document(page_content='hello foo', metadata={'last_accessed_at': datetime.datetime(2023, 12, 27, 15, 30, 50, 57185), 'created_at': datetime.datetime(2023, 12, 27, 15, 30, 44, 720490), 'buffer_idx': 1})]
```


## 가상 시간

LangChain의 몇 가지 유틸리티를 사용하여 시간 요소를 모의할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "mock_now", "source": "langchain_core.utils", "docs": "https://api.python.langchain.com/en/latest/utils/langchain_core.utils.utils.mock_now.html", "title": "How to use a time-weighted vector store retriever"}]-->
import datetime

from langchain_core.utils import mock_now
```


```python
# Notice the last access time is that date time
with mock_now(datetime.datetime(2024, 2, 3, 10, 11)):
    print(retriever.get_relevant_documents("hello world"))
```

```output
[Document(page_content='hello world', metadata={'last_accessed_at': MockDateTime(2024, 2, 3, 10, 11), 'created_at': datetime.datetime(2023, 12, 27, 15, 30, 44, 532941), 'buffer_idx': 0})]
```
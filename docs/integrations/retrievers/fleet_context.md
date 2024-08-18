---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/fleet_context.ipynb
description: Fleet AI Context는 인기 있는 1200개 파이썬 라이브러리의 고품질 임베딩 데이터셋으로, 코드 생성 및 문서 검색
  시스템에 활용됩니다.
---

# Fleet AI Context

> [Fleet AI Context](https://www.fleet.so/context)는 가장 인기 있고 허용적인 1200개의 Python 라이브러리 및 그 문서의 고품질 임베딩 데이터셋입니다.
> 
> `Fleet AI` 팀은 세계에서 가장 중요한 데이터를 임베딩하는 임무를 수행하고 있습니다. 그들은 최신 지식을 바탕으로 코드 생성을 가능하게 하기 위해 상위 1200개의 Python 라이브러리를 임베딩하는 것으로 시작했습니다. 그들은 [LangChain docs](/docs/introduction) 및 [API reference](https://api.python.langchain.com/en/latest/api_reference.html)의 임베딩을 기꺼이 공유했습니다.

이 임베딩을 사용하여 문서 검색 시스템을 강화하고 궁극적으로 간단한 코드 생성 체인을 만드는 방법을 살펴보겠습니다!

```python
%pip install --upgrade --quiet  langchain fleet-context langchain-openai pandas faiss-cpu # faiss-gpu for CUDA supported GPU
```


```python
<!--IMPORTS:[{"imported": "MultiVectorRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_vector.MultiVectorRetriever.html", "title": "Fleet AI Context"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Fleet AI Context"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Fleet AI Context"}, {"imported": "BaseStore", "source": "langchain_core.stores", "docs": "https://api.python.langchain.com/en/latest/stores/langchain_core.stores.BaseStore.html", "title": "Fleet AI Context"}, {"imported": "VectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.base.VectorStore.html", "title": "Fleet AI Context"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Fleet AI Context"}]-->
from operator import itemgetter
from typing import Any, Optional, Type

import pandas as pd
from langchain.retrievers import MultiVectorRetriever
from langchain_community.vectorstores import FAISS
from langchain_core.documents import Document
from langchain_core.stores import BaseStore
from langchain_core.vectorstores import VectorStore
from langchain_openai import OpenAIEmbeddings


def load_fleet_retriever(
    df: pd.DataFrame,
    *,
    vectorstore_cls: Type[VectorStore] = FAISS,
    docstore: Optional[BaseStore] = None,
    **kwargs: Any,
):
    vectorstore = _populate_vectorstore(df, vectorstore_cls)
    if docstore is None:
        return vectorstore.as_retriever(**kwargs)
    else:
        _populate_docstore(df, docstore)
        return MultiVectorRetriever(
            vectorstore=vectorstore, docstore=docstore, id_key="parent", **kwargs
        )


def _populate_vectorstore(
    df: pd.DataFrame,
    vectorstore_cls: Type[VectorStore],
) -> VectorStore:
    if not hasattr(vectorstore_cls, "from_embeddings"):
        raise ValueError(
            f"Incompatible vector store class {vectorstore_cls}."
            "Must implement `from_embeddings` class method."
        )
    texts_embeddings = []
    metadatas = []
    for _, row in df.iterrows():
        texts_embeddings.append((row.metadata["text"], row["dense_embeddings"]))
        metadatas.append(row.metadata)
    return vectorstore_cls.from_embeddings(
        texts_embeddings,
        OpenAIEmbeddings(model="text-embedding-ada-002"),
        metadatas=metadatas,
    )


def _populate_docstore(df: pd.DataFrame, docstore: BaseStore) -> None:
    parent_docs = []
    df = df.copy()
    df["parent"] = df.metadata.apply(itemgetter("parent"))
    for parent_id, group in df.groupby("parent"):
        sorted_group = group.iloc[
            group.metadata.apply(itemgetter("section_index")).argsort()
        ]
        text = "".join(sorted_group.metadata.apply(itemgetter("text")))
        metadata = {
            k: sorted_group.iloc[0].metadata[k] for k in ("title", "type", "url")
        }
        text = metadata["title"] + "\n" + text
        metadata["id"] = parent_id
        parent_docs.append(Document(page_content=text, metadata=metadata))
    docstore.mset(((d.metadata["id"], d) for d in parent_docs))
```


## 검색기 청크

Fleet AI 팀은 임베딩 프로세스의 일환으로 긴 문서를 먼저 청크로 나눈 후 임베딩했습니다. 이는 벡터가 LangChain 문서의 전체 페이지가 아닌 페이지의 섹션에 해당함을 의미합니다. 기본적으로 이러한 임베딩에서 검색기를 시작할 때, 우리는 이러한 임베딩된 청크를 검색하게 됩니다.

우리는 Fleet Context의 `download_embeddings()`를 사용하여 Langchain의 문서 임베딩을 가져올 것입니다. 지원되는 모든 라이브러리의 문서는 https://fleet.so/context에서 확인할 수 있습니다.

```python
from context import download_embeddings

df = download_embeddings("langchain")
vecstore_retriever = load_fleet_retriever(df)
```


```python
vecstore_retriever.invoke("How does the multi vector retriever work")
```


## 기타 패키지

[이 Dropbox 링크](https://www.dropbox.com/scl/fo/54t2e7fogtixo58pnlyub/h?rlkey=tne16wkssgf01jor0p1iqg6p9&dl=0)에서 다른 임베딩을 다운로드하고 사용할 수 있습니다.

## 부모 문서 검색

Fleet AI에서 제공하는 임베딩에는 동일한 원본 문서 페이지에 해당하는 임베딩 청크를 나타내는 메타데이터가 포함되어 있습니다. 원한다면 이 정보를 사용하여 전체 부모 문서를 검색할 수 있으며, 단지 임베딩된 청크만 검색하지 않을 수 있습니다. 내부적으로 우리는 MultiVectorRetriever와 BaseStore 객체를 사용하여 관련 청크를 검색한 다음 이를 부모 문서에 매핑합니다.

```python
<!--IMPORTS:[{"imported": "InMemoryStore", "source": "langchain.storage", "docs": "https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryStore.html", "title": "Fleet AI Context"}]-->
from langchain.storage import InMemoryStore

parent_retriever = load_fleet_retriever(
    "https://www.dropbox.com/scl/fi/4rescpkrg9970s3huz47l/libraries_langchain_release.parquet?rlkey=283knw4wamezfwiidgpgptkep&dl=1",
    docstore=InMemoryStore(),
)
```


```python
parent_retriever.invoke("How does the multi vector retriever work")
```


## 체인에 넣기

간단한 체인에서 우리의 검색 시스템을 사용해 보겠습니다!

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Fleet AI Context"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Fleet AI Context"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Fleet AI Context"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Fleet AI Context"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are a great software engineer who is very familiar \
with Python. Given a user question or request about a new Python library called LangChain and \
parts of the LangChain documentation, answer the question or generate the requested code. \
Your answers must be accurate, should include code whenever possible, and should assume anything \
about LangChain which is note explicitly stated in the LangChain documentation. If the required \
information is not available, just say so.

LangChain Documentation
------------------

{context}""",
        ),
        ("human", "{question}"),
    ]
)

model = ChatOpenAI(model="gpt-3.5-turbo-16k")

chain = (
    {
        "question": RunnablePassthrough(),
        "context": parent_retriever
        | (lambda docs: "\n\n".join(d.page_content for d in docs)),
    }
    | prompt
    | model
    | StrOutputParser()
)
```


```python
for chunk in chain.invoke(
    "How do I create a FAISS vector store retriever that returns 10 documents per search query"
):
    print(chunk, end="", flush=True)
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
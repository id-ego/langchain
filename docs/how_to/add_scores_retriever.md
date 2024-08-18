---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/add_scores_retriever.ipynb
description: 문서 검색 결과에 점수를 추가하는 방법을 설명합니다. 벡터 저장소 및 고차원 LangChain 검색기를 활용한 구현 방법을
  다룹니다.
---

# 검색 결과에 점수 추가하는 방법

검색자는 기본적으로 검색 프로세스에 대한 정보(예: 쿼리에 대한 유사성 점수)를 포함하지 않는 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체의 시퀀스를 반환합니다. 여기에서는 문서의 `.metadata`에 검색 점수를 추가하는 방법을 보여줍니다:
1. [벡터 스토어 검색기](/docs/how_to/vectorstore_retriever)에서;
2. [SelfQueryRetriever](/docs/how_to/self_query) 또는 [MultiVectorRetriever](/docs/how_to/multi_vector)와 같은 고차원 LangChain 검색기에서.

(1)의 경우, 해당 벡터 스토어 주위에 짧은 래퍼 함수를 구현합니다. (2)의 경우, 해당 클래스의 메서드를 업데이트합니다.

## 벡터 스토어 생성

먼저 일부 데이터를 사용하여 벡터 스토어를 채웁니다. 우리는 [PineconeVectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_pinecone.vectorstores.PineconeVectorStore.html)를 사용할 것이지만, 이 가이드는 `.similarity_search_with_score` 메서드를 구현하는 모든 LangChain 벡터 스토어와 호환됩니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to add scores to retriever results"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to add scores to retriever results"}, {"imported": "PineconeVectorStore", "source": "langchain_pinecone", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_pinecone.vectorstores.PineconeVectorStore.html", "title": "How to add scores to retriever results"}]-->
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_pinecone import PineconeVectorStore

docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={"year": 1993, "rating": 7.7, "genre": "science fiction"},
    ),
    Document(
        page_content="Leo DiCaprio gets lost in a dream within a dream within a dream within a ...",
        metadata={"year": 2010, "director": "Christopher Nolan", "rating": 8.2},
    ),
    Document(
        page_content="A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea",
        metadata={"year": 2006, "director": "Satoshi Kon", "rating": 8.6},
    ),
    Document(
        page_content="A bunch of normal-sized women are supremely wholesome and some men pine after them",
        metadata={"year": 2019, "director": "Greta Gerwig", "rating": 8.3},
    ),
    Document(
        page_content="Toys come alive and have a blast doing so",
        metadata={"year": 1995, "genre": "animated"},
    ),
    Document(
        page_content="Three men walk into the Zone, three men walk out of the Zone",
        metadata={
            "year": 1979,
            "director": "Andrei Tarkovsky",
            "genre": "thriller",
            "rating": 9.9,
        },
    ),
]

vectorstore = PineconeVectorStore.from_documents(
    docs, index_name="sample", embedding=OpenAIEmbeddings()
)
```


## 검색기

벡터 스토어 검색기에서 점수를 얻기 위해, 기본 벡터 스토어의 `.similarity_search_with_score` 메서드를 점수를 관련 문서의 메타데이터에 패키징하는 짧은 함수로 래핑합니다.

우리는 이 함수에 `@chain` 데코레이터를 추가하여 일반적인 검색기와 유사하게 사용할 수 있는 [Runnable](/docs/concepts/#langchain-expression-language)를 생성합니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to add scores to retriever results"}, {"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to add scores to retriever results"}]-->
from typing import List

from langchain_core.documents import Document
from langchain_core.runnables import chain


@chain
def retriever(query: str) -> List[Document]:
    docs, scores = zip(*vectorstore.similarity_search_with_score(query))
    for doc, score in zip(docs, scores):
        doc.metadata["score"] = score

    return docs
```


```python
result = retriever.invoke("dinosaur")
result
```


```output
(Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'genre': 'science fiction', 'rating': 7.7, 'year': 1993.0, 'score': 0.84429127}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'genre': 'animated', 'year': 1995.0, 'score': 0.792038262}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'director': 'Andrei Tarkovsky', 'genre': 'thriller', 'rating': 9.9, 'year': 1979.0, 'score': 0.751571238}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'director': 'Satoshi Kon', 'rating': 8.6, 'year': 2006.0, 'score': 0.747471571}))
```


검색 단계에서의 유사성 점수가 위 문서의 메타데이터에 포함되어 있음을 주의하세요.

## SelfQueryRetriever

`SelfQueryRetriever`는 잠재적으로 구조화된 쿼리를 생성하기 위해 LLM을 사용합니다. 예를 들어, 일반적인 의미적 유사성 기반 선택 위에 검색을 위한 필터를 구성할 수 있습니다. 자세한 내용은 [이 가이드](/docs/how_to/self_query)를 참조하세요.

`SelfQueryRetriever`는 `vectorstore` 검색을 실행하는 짧은 (1 - 2줄) 메서드 `_get_docs_with_query`를 포함합니다. 우리는 `SelfQueryRetriever`를 서브클래싱하고 이 메서드를 재정의하여 유사성 점수를 전파할 수 있습니다.

먼저, [사용 방법 가이드](/docs/how_to/self_query)를 따라 필터링할 메타데이터를 설정해야 합니다:

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "How to add scores to retriever results"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "How to add scores to retriever results"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add scores to retriever results"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import ChatOpenAI

metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genre of the movie. One of ['science fiction', 'comedy', 'drama', 'thriller', 'romance', 'action', 'animated']",
        type="string",
    ),
    AttributeInfo(
        name="year",
        description="The year the movie was released",
        type="integer",
    ),
    AttributeInfo(
        name="director",
        description="The name of the movie director",
        type="string",
    ),
    AttributeInfo(
        name="rating", description="A 1-10 rating for the movie", type="float"
    ),
]
document_content_description = "Brief summary of a movie"
llm = ChatOpenAI(temperature=0)
```


그런 다음 기본 벡터 스토어의 `similarity_search_with_score` 메서드를 사용하도록 `_get_docs_with_query`를 재정의합니다:

```python
from typing import Any, Dict


class CustomSelfQueryRetriever(SelfQueryRetriever):
    def _get_docs_with_query(
        self, query: str, search_kwargs: Dict[str, Any]
    ) -> List[Document]:
        """Get docs, adding score information."""
        docs, scores = zip(
            *vectorstore.similarity_search_with_score(query, **search_kwargs)
        )
        for doc, score in zip(docs, scores):
            doc.metadata["score"] = score

        return docs
```


이 검색기를 호출하면 이제 문서 메타데이터에 유사성 점수가 포함됩니다. `SelfQueryRetriever`의 기본 구조화 쿼리 기능이 유지됨을 주의하세요.

```python
retriever = CustomSelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
)


result = retriever.invoke("dinosaur movie with rating less than 8")
result
```


```output
(Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'genre': 'science fiction', 'rating': 7.7, 'year': 1993.0, 'score': 0.84429127}),)
```


## MultiVectorRetriever

`MultiVectorRetriever`는 단일 문서와 여러 벡터를 연결할 수 있게 해줍니다. 이는 여러 응용 프로그램에서 유용할 수 있습니다. 예를 들어, 더 큰 문서의 작은 조각을 인덱싱하고 조각에서 검색을 수행하되, 검색기를 호출할 때 더 큰 "부모" 문서를 반환할 수 있습니다. `MultiVectorRetriever`의 서브클래스인 [ParentDocumentRetriever](/docs/how_to/parent_document_retriever/)는 이를 지원하기 위해 벡터 스토어를 채우기 위한 편리한 메서드를 포함합니다. 추가 응용 프로그램은 이 [사용 방법 가이드](/docs/how_to/multi_vector/)에 자세히 설명되어 있습니다.

이 검색기를 통해 유사성 점수를 전파하기 위해, 우리는 다시 `MultiVectorRetriever`를 서브클래싱하고 메서드를 재정의할 수 있습니다. 이번에는 `_get_relevant_documents`를 재정의합니다.

먼저, 일부 가짜 데이터를 준비합니다. 우리는 가짜 "전체 문서"를 생성하고 이를 문서 스토어에 저장합니다; 여기서는 간단한 [InMemoryStore](https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryBaseStore.html)를 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "InMemoryStore", "source": "langchain.storage", "docs": "https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryStore.html", "title": "How to add scores to retriever results"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to add scores to retriever results"}]-->
from langchain.storage import InMemoryStore
from langchain_text_splitters import RecursiveCharacterTextSplitter

# The storage layer for the parent documents
docstore = InMemoryStore()
fake_whole_documents = [
    ("fake_id_1", Document(page_content="fake whole document 1")),
    ("fake_id_2", Document(page_content="fake whole document 2")),
]
docstore.mset(fake_whole_documents)
```


다음으로, 벡터 스토어에 일부 가짜 "하위 문서"를 추가합니다. 우리는 이 하위 문서를 부모 문서에 연결하기 위해 메타데이터의 `"doc_id"` 키를 채울 수 있습니다.

```python
docs = [
    Document(
        page_content="A snippet from a larger document discussing cats.",
        metadata={"doc_id": "fake_id_1"},
    ),
    Document(
        page_content="A snippet from a larger document discussing discourse.",
        metadata={"doc_id": "fake_id_1"},
    ),
    Document(
        page_content="A snippet from a larger document discussing chocolate.",
        metadata={"doc_id": "fake_id_2"},
    ),
]

vectorstore.add_documents(docs)
```


```output
['62a85353-41ff-4346-bff7-be6c8ec2ed89',
 '5d4a0e83-4cc5-40f1-bc73-ed9cbad0ee15',
 '8c1d9a56-120f-45e4-ba70-a19cd19a38f4']
```


점수를 전파하기 위해, 우리는 `MultiVectorRetriever`를 서브클래싱하고 `_get_relevant_documents` 메서드를 재정의합니다. 여기에서 두 가지 변경을 합니다:

1. 위와 같이 기본 벡터 스토어의 `similarity_search_with_score` 메서드를 사용하여 해당 "하위 문서"의 메타데이터에 유사성 점수를 추가합니다;
2. 검색된 부모 문서의 메타데이터에 이러한 하위 문서의 목록을 포함합니다. 이는 검색에 의해 식별된 텍스트 조각과 해당 유사성 점수를 함께 표시합니다.

```python
<!--IMPORTS:[{"imported": "MultiVectorRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_vector.MultiVectorRetriever.html", "title": "How to add scores to retriever results"}, {"imported": "CallbackManagerForRetrieverRun", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManagerForRetrieverRun.html", "title": "How to add scores to retriever results"}]-->
from collections import defaultdict

from langchain.retrievers import MultiVectorRetriever
from langchain_core.callbacks import CallbackManagerForRetrieverRun


class CustomMultiVectorRetriever(MultiVectorRetriever):
    def _get_relevant_documents(
        self, query: str, *, run_manager: CallbackManagerForRetrieverRun
    ) -> List[Document]:
        """Get documents relevant to a query.
        Args:
            query: String to find relevant documents for
            run_manager: The callbacks handler to use
        Returns:
            List of relevant documents
        """
        results = self.vectorstore.similarity_search_with_score(
            query, **self.search_kwargs
        )

        # Map doc_ids to list of sub-documents, adding scores to metadata
        id_to_doc = defaultdict(list)
        for doc, score in results:
            doc_id = doc.metadata.get("doc_id")
            if doc_id:
                doc.metadata["score"] = score
                id_to_doc[doc_id].append(doc)

        # Fetch documents corresponding to doc_ids, retaining sub_docs in metadata
        docs = []
        for _id, sub_docs in id_to_doc.items():
            docstore_docs = self.docstore.mget([_id])
            if docstore_docs:
                if doc := docstore_docs[0]:
                    doc.metadata["sub_docs"] = sub_docs
                    docs.append(doc)

        return docs
```


이 검색기를 호출하면, 올바른 부모 문서를 식별하고 유사성 점수를 가진 하위 문서의 관련 조각을 포함하는 것을 볼 수 있습니다.

```python
retriever = CustomMultiVectorRetriever(vectorstore=vectorstore, docstore=docstore)

retriever.invoke("cat")
```


```output
[Document(page_content='fake whole document 1', metadata={'sub_docs': [Document(page_content='A snippet from a larger document discussing cats.', metadata={'doc_id': 'fake_id_1', 'score': 0.831276655})]})]
```
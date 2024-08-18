---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/multi_vector.ipynb
description: 문서당 여러 벡터를 저장하고 검색하는 방법을 다루며, LangChain의 MultiVectorRetriever를 활용한 다양한
  벡터 생성 기법을 설명합니다.
---

# 여러 벡터를 사용하여 문서 검색하는 방법

문서당 여러 벡터를 저장하는 것은 종종 유용할 수 있습니다. 이는 여러 사용 사례에서 유익합니다. 예를 들어, 문서의 여러 청크를 임베드하고 이러한 임베딩을 부모 문서와 연결하여 청크에 대한 검색 결과가 더 큰 문서를 반환할 수 있습니다.

LangChain은 이 프로세스를 단순화하는 기본 [MultiVectorRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_vector.MultiVectorRetriever.html)를 구현합니다. 문서당 여러 벡터를 생성하는 방법에서 많은 복잡성이 발생합니다. 이 노트북에서는 이러한 벡터를 생성하고 `MultiVectorRetriever`를 사용하는 몇 가지 일반적인 방법을 다룹니다.

문서당 여러 벡터를 생성하는 방법에는 다음이 포함됩니다:

- 작은 청크: 문서를 더 작은 청크로 나누고 이를 임베드합니다(이는 [ParentDocumentRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.parent_document_retriever.ParentDocumentRetriever.html)입니다).
- 요약: 각 문서에 대한 요약을 생성하고 이를 문서와 함께(또는 대신) 임베드합니다.
- 가설 질문: 각 문서에 적합한 가설 질문을 생성하고 이를 문서와 함께(또는 대신) 임베드합니다.

이 방법은 임베딩을 수동으로 추가하는 또 다른 방법을 가능하게 합니다. 이는 문서가 검색되도록 이끌어야 하는 질문이나 쿼리를 명시적으로 추가할 수 있기 때문에 유용하며, 더 많은 제어를 제공합니다.

아래에서는 예제를 살펴보겠습니다. 먼저 몇 개의 문서를 인스턴스화합니다. 우리는 [OpenAI](https://python.langchain.com/v0.2/docs/integrations/text_embedding/openai/) 임베딩을 사용하여 (메모리 내) [Chroma](/docs/integrations/providers/chroma/) 벡터 저장소에 인덱싱할 것입니다. 그러나 어떤 LangChain 벡터 저장소나 임베딩 모델도 충분합니다.

```python
%pip install --upgrade --quiet  langchain-chroma langchain langchain-openai > /dev/null
```


```python
<!--IMPORTS:[{"imported": "InMemoryByteStore", "source": "langchain.storage", "docs": "https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryByteStore.html", "title": "How to retrieve using multiple vectors per document"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to retrieve using multiple vectors per document"}, {"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "How to retrieve using multiple vectors per document"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to retrieve using multiple vectors per document"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to retrieve using multiple vectors per document"}]-->
from langchain.storage import InMemoryByteStore
from langchain_chroma import Chroma
from langchain_community.document_loaders import TextLoader
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

loaders = [
    TextLoader("paul_graham_essay.txt"),
    TextLoader("state_of_the_union.txt"),
]
docs = []
for loader in loaders:
    docs.extend(loader.load())
text_splitter = RecursiveCharacterTextSplitter(chunk_size=10000)
docs = text_splitter.split_documents(docs)

# The vectorstore to use to index the child chunks
vectorstore = Chroma(
    collection_name="full_documents", embedding_function=OpenAIEmbeddings()
)
```


## 작은 청크

종종 더 큰 정보 청크를 검색하는 것이 유용할 수 있지만, 더 작은 청크를 임베드하는 것이 좋습니다. 이는 임베딩이 의미론적 의미를 가능한 한 가깝게 포착할 수 있도록 하면서 가능한 한 많은 컨텍스트를 하류로 전달할 수 있게 합니다. 이는 [ParentDocumentRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.parent_document_retriever.ParentDocumentRetriever.html)가 수행하는 작업입니다. 여기서는 내부에서 어떤 일이 일어나고 있는지 보여줍니다.

우리는 (하위) 문서의 임베딩을 인덱싱하는 벡터 저장소와 "부모" 문서를 보관하고 식별자와 연결하는 문서 저장소를 구분합니다.

```python
<!--IMPORTS:[{"imported": "MultiVectorRetriever", "source": "langchain.retrievers.multi_vector", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_vector.MultiVectorRetriever.html", "title": "How to retrieve using multiple vectors per document"}]-->
import uuid

from langchain.retrievers.multi_vector import MultiVectorRetriever

# The storage layer for the parent documents
store = InMemoryByteStore()
id_key = "doc_id"

# The retriever (empty to start)
retriever = MultiVectorRetriever(
    vectorstore=vectorstore,
    byte_store=store,
    id_key=id_key,
)

doc_ids = [str(uuid.uuid4()) for _ in docs]
```


다음으로 원본 문서를 나누어 "하위" 문서를 생성합니다. 해당 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체의 `metadata`에 문서 식별자를 저장합니다.

```python
# The splitter to use to create smaller chunks
child_text_splitter = RecursiveCharacterTextSplitter(chunk_size=400)

sub_docs = []
for i, doc in enumerate(docs):
    _id = doc_ids[i]
    _sub_docs = child_text_splitter.split_documents([doc])
    for _doc in _sub_docs:
        _doc.metadata[id_key] = _id
    sub_docs.extend(_sub_docs)
```


마지막으로 벡터 저장소와 문서 저장소에 문서를 인덱싱합니다:

```python
retriever.vectorstore.add_documents(sub_docs)
retriever.docstore.mset(list(zip(doc_ids, docs)))
```


벡터 저장소만으로는 작은 청크를 검색합니다:

```python
retriever.vectorstore.similarity_search("justice breyer")[0]
```


```output
Document(page_content='Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court.', metadata={'doc_id': '064eca46-a4c4-4789-8e3b-583f9597e54f', 'source': 'state_of_the_union.txt'})
```


반면에 리트리버는 더 큰 부모 문서를 반환합니다:

```python
len(retriever.invoke("justice breyer")[0].page_content)
```


```output
9875
```


리트리버가 벡터 데이터베이스에서 수행하는 기본 검색 유형은 유사성 검색입니다. LangChain 벡터 저장소는 [최대 한계 관련성](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html#langchain_core.vectorstores.VectorStore.max_marginal_relevance_search)을 통한 검색도 지원합니다. 이는 리트리버의 `search_type` 매개변수를 통해 제어할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SearchType", "source": "langchain.retrievers.multi_vector", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_vector.SearchType.html", "title": "How to retrieve using multiple vectors per document"}]-->
from langchain.retrievers.multi_vector import SearchType

retriever.search_type = SearchType.mmr

len(retriever.invoke("justice breyer")[0].page_content)
```


```output
9875
```


## 문서에 요약을 연결하여 검색하기

요약은 청크가 무엇에 대한 것인지 더 정확하게 증류할 수 있어, 더 나은 검색 결과를 이끌어낼 수 있습니다. 여기서는 요약을 생성하는 방법과 이를 임베드하는 방법을 보여줍니다.

우리는 입력 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체를 받아 LLM을 사용하여 요약을 생성하는 간단한 [체인](/docs/how_to/sequence)을 구성합니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to retrieve using multiple vectors per document"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to retrieve using multiple vectors per document"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to retrieve using multiple vectors per document"}]-->
import uuid

from langchain_core.documents import Document
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

chain = (
    {"doc": lambda x: x.page_content}
    | ChatPromptTemplate.from_template("Summarize the following document:\n\n{doc}")
    | llm
    | StrOutputParser()
)
```


우리는 [배치](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable) 체인을 문서에 걸쳐 사용할 수 있습니다:

```python
summaries = chain.batch(docs, {"max_concurrency": 5})
```


그런 다음 이전과 같이 `MultiVectorRetriever`를 초기화하여 요약을 벡터 저장소에 인덱싱하고 원본 문서는 문서 저장소에 유지합니다:

```python
# The vectorstore to use to index the child chunks
vectorstore = Chroma(collection_name="summaries", embedding_function=OpenAIEmbeddings())
# The storage layer for the parent documents
store = InMemoryByteStore()
id_key = "doc_id"
# The retriever (empty to start)
retriever = MultiVectorRetriever(
    vectorstore=vectorstore,
    byte_store=store,
    id_key=id_key,
)
doc_ids = [str(uuid.uuid4()) for _ in docs]

summary_docs = [
    Document(page_content=s, metadata={id_key: doc_ids[i]})
    for i, s in enumerate(summaries)
]

retriever.vectorstore.add_documents(summary_docs)
retriever.docstore.mset(list(zip(doc_ids, docs)))
```


```python
# # We can also add the original chunks to the vectorstore if we so want
# for i, doc in enumerate(docs):
#     doc.metadata[id_key] = doc_ids[i]
# retriever.vectorstore.add_documents(docs)
```


벡터 저장소를 쿼리하면 요약이 반환됩니다:

```python
sub_docs = retriever.vectorstore.similarity_search("justice breyer")

sub_docs[0]
```


```output
Document(page_content="President Biden recently nominated Judge Ketanji Brown Jackson to serve on the United States Supreme Court, emphasizing her qualifications and broad support. The President also outlined a plan to secure the border, fix the immigration system, protect women's rights, support LGBTQ+ Americans, and advance mental health services. He highlighted the importance of bipartisan unity in passing legislation, such as the Violence Against Women Act. The President also addressed supporting veterans, particularly those impacted by exposure to burn pits, and announced plans to expand benefits for veterans with respiratory cancers. Additionally, he proposed a plan to end cancer as we know it through the Cancer Moonshot initiative. President Biden expressed optimism about the future of America and emphasized the strength of the American people in overcoming challenges.", metadata={'doc_id': '84015b1b-980e-400a-94d8-cf95d7e079bd'})
```


반면에 리트리버는 더 큰 원본 문서를 반환합니다:

```python
retrieved_docs = retriever.invoke("justice breyer")

len(retrieved_docs[0].page_content)
```


```output
9194
```


## 가설 쿼리

LLM은 특정 문서에 대해 질문할 수 있는 가설 질문 목록을 생성하는 데에도 사용될 수 있으며, 이는 [RAG](/docs/tutorials/rag) 애플리케이션의 관련 쿼리와 의미론적 유사성을 가질 수 있습니다. 이러한 질문은 임베드되어 문서와 연결되어 검색을 개선할 수 있습니다.

아래에서는 [with_structured_output](/docs/how_to/structured_output/) 메서드를 사용하여 LLM 출력을 문자열 목록으로 구조화합니다.

```python
from typing import List

from langchain_core.pydantic_v1 import BaseModel, Field


class HypotheticalQuestions(BaseModel):
    """Generate hypothetical questions."""

    questions: List[str] = Field(..., description="List of questions")


chain = (
    {"doc": lambda x: x.page_content}
    # Only asking for 3 hypothetical questions, but this could be adjusted
    | ChatPromptTemplate.from_template(
        "Generate a list of exactly 3 hypothetical questions that the below document could be used to answer:\n\n{doc}"
    )
    | ChatOpenAI(max_retries=0, model="gpt-4o").with_structured_output(
        HypotheticalQuestions
    )
    | (lambda x: x.questions)
)
```


단일 문서에서 체인을 호출하면 질문 목록을 출력하는 것을 보여줍니다:

```python
chain.invoke(docs[0])
```


```output
["What impact did the IBM 1401 have on the author's early programming experiences?",
 "How did the transition from using the IBM 1401 to microcomputers influence the author's programming journey?",
 "What role did Lisp play in shaping the author's understanding and approach to AI?"]
```


그런 다음 모든 문서에 대해 체인을 배치하고 이전과 같이 벡터 저장소와 문서 저장소를 조립할 수 있습니다:

```python
# Batch chain over documents to generate hypothetical questions
hypothetical_questions = chain.batch(docs, {"max_concurrency": 5})


# The vectorstore to use to index the child chunks
vectorstore = Chroma(
    collection_name="hypo-questions", embedding_function=OpenAIEmbeddings()
)
# The storage layer for the parent documents
store = InMemoryByteStore()
id_key = "doc_id"
# The retriever (empty to start)
retriever = MultiVectorRetriever(
    vectorstore=vectorstore,
    byte_store=store,
    id_key=id_key,
)
doc_ids = [str(uuid.uuid4()) for _ in docs]


# Generate Document objects from hypothetical questions
question_docs = []
for i, question_list in enumerate(hypothetical_questions):
    question_docs.extend(
        [Document(page_content=s, metadata={id_key: doc_ids[i]}) for s in question_list]
    )


retriever.vectorstore.add_documents(question_docs)
retriever.docstore.mset(list(zip(doc_ids, docs)))
```


기본 벡터 저장소를 쿼리하면 입력 쿼리와 의미론적으로 유사한 가설 질문을 검색합니다:

```python
sub_docs = retriever.vectorstore.similarity_search("justice breyer")

sub_docs
```


```output
[Document(page_content='What might be the potential benefits of nominating Circuit Court of Appeals Judge Ketanji Brown Jackson to the United States Supreme Court?', metadata={'doc_id': '43292b74-d1b8-4200-8a8b-ea0cb57fbcdb'}),
 Document(page_content='How might the Bipartisan Infrastructure Law impact the economic competition between the U.S. and China?', metadata={'doc_id': '66174780-d00c-4166-9791-f0069846e734'}),
 Document(page_content='What factors led to the creation of Y Combinator?', metadata={'doc_id': '72003c4e-4cc9-4f09-a787-0b541a65b38c'}),
 Document(page_content='How did the ability to publish essays online change the landscape for writers and thinkers?', metadata={'doc_id': 'e8d2c648-f245-4bcc-b8d3-14e64a164b64'})]
```


리트리버를 호출하면 해당 문서를 반환합니다:

```python
retrieved_docs = retriever.invoke("justice breyer")
len(retrieved_docs[0].page_content)
```


```output
9194
```
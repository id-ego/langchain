---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/query_analysis.ipynb
description: 쿼리 분석 시스템 구축에 대한 가이드를 제공하며, 검색 엔진 생성 및 쿼리 분석 기법을 활용한 문제 해결 방법을 설명합니다.
sidebar_position: 0
---

# 쿼리 분석 시스템 구축

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [문서 로더](/docs/concepts/#document-loaders)
- [채팅 모델](/docs/concepts/#chat-models)
- [임베딩](/docs/concepts/#embedding-models)
- [벡터 저장소](/docs/concepts/#vector-stores)
- [검색](/docs/concepts/#retrieval)

:::

이 페이지에서는 기본적인 엔드 투 엔드 예제를 통해 쿼리 분석을 사용하는 방법을 보여줍니다. 여기서는 간단한 검색 엔진을 만들고, 원시 사용자 질문을 검색에 전달할 때 발생하는 실패 모드를 보여준 다음, 쿼리 분석이 그 문제를 해결하는 데 어떻게 도움이 되는지에 대한 예제를 다룰 것입니다. 쿼리 분석 기술은 매우 다양하며, 이 엔드 투 엔드 예제에서는 모든 기술을 보여주지 않습니다.

이 예제의 목적을 위해 LangChain YouTube 비디오에 대한 검색을 수행할 것입니다.

## 설정
#### 의존성 설치

```python
# %pip install -qU langchain langchain-community langchain-openai youtube-transcript-api pytube langchain-chroma
```


#### 환경 변수 설정

이 예제에서는 OpenAI를 사용할 것입니다:

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Optional, uncomment to trace runs with LangSmith. Sign up here: https://smith.langchain.com.
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


### 문서 로드

`YouTubeLoader`를 사용하여 몇 개의 LangChain 비디오의 전사를 로드할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "YoutubeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.youtube.YoutubeLoader.html", "title": "Build a Query Analysis System"}]-->
from langchain_community.document_loaders import YoutubeLoader

urls = [
    "https://www.youtube.com/watch?v=HAn9vnJy6S4",
    "https://www.youtube.com/watch?v=dA1cHGACXCo",
    "https://www.youtube.com/watch?v=ZcEMLz27sL4",
    "https://www.youtube.com/watch?v=hvAPnpSfSGo",
    "https://www.youtube.com/watch?v=EhlPDL4QrWY",
    "https://www.youtube.com/watch?v=mmBo8nlu2j0",
    "https://www.youtube.com/watch?v=rQdibOsL1ps",
    "https://www.youtube.com/watch?v=28lC4fqukoc",
    "https://www.youtube.com/watch?v=es-9MgxB-uc",
    "https://www.youtube.com/watch?v=wLRHwKuKvOE",
    "https://www.youtube.com/watch?v=ObIltMaRJvY",
    "https://www.youtube.com/watch?v=DjuXACWYkkU",
    "https://www.youtube.com/watch?v=o7C9ld6Ln-M",
]
docs = []
for url in urls:
    docs.extend(YoutubeLoader.from_youtube_url(url, add_video_info=True).load())
```


```python
import datetime

# Add some additional metadata: what year the video was published
for doc in docs:
    doc.metadata["publish_year"] = int(
        datetime.datetime.strptime(
            doc.metadata["publish_date"], "%Y-%m-%d %H:%M:%S"
        ).strftime("%Y")
    )
```


로드한 비디오의 제목은 다음과 같습니다:

```python
[doc.metadata["title"] for doc in docs]
```


```output
['OpenGPTs',
 'Building a web RAG chatbot: using LangChain, Exa (prev. Metaphor), LangSmith, and Hosted Langserve',
 'Streaming Events: Introducing a new `stream_events` method',
 'LangGraph: Multi-Agent Workflows',
 'Build and Deploy a RAG app with Pinecone Serverless',
 'Auto-Prompt Builder (with Hosted LangServe)',
 'Build a Full Stack RAG App With TypeScript',
 'Getting Started with Multi-Modal LLMs',
 'SQL Research Assistant',
 'Skeleton-of-Thought: Building a New Template from Scratch',
 'Benchmarking RAG over LangChain Docs',
 'Building a Research Assistant from Scratch',
 'LangServe and LangChain Templates Webinar']
```


각 비디오와 관련된 메타데이터는 다음과 같습니다. 각 문서에는 제목, 조회수, 게시 날짜 및 길이가 포함되어 있습니다:

```python
docs[0].metadata
```


```output
{'source': 'HAn9vnJy6S4',
 'title': 'OpenGPTs',
 'description': 'Unknown',
 'view_count': 7210,
 'thumbnail_url': 'https://i.ytimg.com/vi/HAn9vnJy6S4/hq720.jpg',
 'publish_date': '2024-01-31 00:00:00',
 'length': 1530,
 'author': 'LangChain',
 'publish_year': 2024}
```


문서 내용의 샘플은 다음과 같습니다:

```python
docs[0].page_content[:500]
```


```output
"hello today I want to talk about open gpts open gpts is a project that we built here at linkchain uh that replicates the GPT store in a few ways so it creates uh end user-facing friendly interface to create different Bots and these Bots can have access to different tools and they can uh be given files to retrieve things over and basically it's a way to create a variety of bots and expose the configuration of these Bots to end users it's all open source um it can be used with open AI it can be us"
```


### 문서 인덱싱

검색을 수행할 때마다 쿼리할 수 있는 문서 인덱스를 생성해야 합니다. 우리는 벡터 저장소를 사용하여 문서를 인덱싱하고, 검색을 더 간결하고 정확하게 만들기 위해 먼저 문서를 청크로 나눌 것입니다:

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Build a Query Analysis System"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Build a Query Analysis System"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build a Query Analysis System"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(chunk_size=2000)
chunked_docs = text_splitter.split_documents(docs)
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_documents(
    chunked_docs,
    embeddings,
)
```


## 쿼리 분석 없는 검색

사용자 질문에 대해 유사성 검색을 직접 수행하여 질문과 관련된 청크를 찾을 수 있습니다:

```python
search_results = vectorstore.similarity_search("how do I build a RAG agent")
print(search_results[0].metadata["title"])
print(search_results[0].page_content[:500])
```

```output
Build and Deploy a RAG app with Pinecone Serverless
hi this is Lance from the Lang chain team and today we're going to be building and deploying a rag app using pine con serval list from scratch so we're going to kind of walk through all the code required to do this and I'll use these slides as kind of a guide to kind of lay the the ground work um so first what is rag so under capoy has this pretty nice visualization that shows LMS as a kernel of a new kind of operating system and of course one of the core components of our operating system is th
```

이것은 꽤 잘 작동합니다! 우리의 첫 번째 결과는 질문과 매우 관련이 있습니다.

특정 기간의 결과를 검색하고 싶다면 어떻게 해야 할까요?

```python
search_results = vectorstore.similarity_search("videos on RAG published in 2023")
print(search_results[0].metadata["title"])
print(search_results[0].metadata["publish_date"])
print(search_results[0].page_content[:500])
```

```output
OpenGPTs
2024-01-31
hardcoded that it will always do a retrieval step here the assistant decides whether to do a retrieval step or not sometimes this is good sometimes this is bad sometimes it you don't need to do a retrieval step when I said hi it didn't need to call it tool um but other times you know the the llm might mess up and not realize that it needs to do a retrieval step and so the rag bot will always do a retrieval step so it's more focused there because this is also a simpler architecture so it's always
```

우리의 첫 번째 결과는 2024년의 것이며 (2023년 비디오를 요청했음에도 불구하고), 입력과는 그다지 관련이 없습니다. 문서 내용에 대해서만 검색하고 있기 때문에, 결과를 문서 속성에 따라 필터링할 방법이 없습니다.

이것은 발생할 수 있는 하나의 실패 모드에 불과합니다. 이제 기본적인 형태의 쿼리 분석이 이를 어떻게 수정할 수 있는지 살펴보겠습니다!

## 쿼리 분석

쿼리 분석을 사용하여 검색 결과를 개선할 수 있습니다. 여기에는 날짜 필터가 포함된 **쿼리 스키마**를 정의하고, 사용자 질문을 구조화된 쿼리로 변환하는 함수 호출 모델을 사용하는 것이 포함됩니다.

### 쿼리 스키마
이 경우 게시 날짜에 대한 명시적인 최소 및 최대 속성을 설정하여 필터링할 수 있도록 합니다.

```python
from typing import Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Search(BaseModel):
    """Search over a database of tutorial videos about a software library."""

    query: str = Field(
        ...,
        description="Similarity search query applied to video transcripts.",
    )
    publish_year: Optional[int] = Field(None, description="Year video was published")
```


### 쿼리 생성

사용자 질문을 구조화된 쿼리로 변환하기 위해 OpenAI의 도구 호출 API를 사용할 것입니다. 구체적으로, 우리는 새로운 [ChatModel.with_structured_output()](/docs/how_to/structured_output) 생성자를 사용하여 스키마를 모델에 전달하고 출력을 파싱하는 작업을 처리할 것입니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Query Analysis System"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Build a Query Analysis System"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Build a Query Analysis System"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

system = """You are an expert at converting user questions into database queries. \
You have access to a database of tutorial videos about a software library for building LLM-powered applications. \
Given a question, return a list of database queries optimized to retrieve the most relevant results.

If there are acronyms or words you are not familiar with, do not try to rephrase them."""
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm = llm.with_structured_output(Search)
query_analyzer = {"question": RunnablePassthrough()} | prompt | structured_llm
```

```output
/Users/bagatur/langchain/libs/core/langchain_core/_api/beta_decorator.py:86: LangChainBetaWarning: The function `with_structured_output` is in beta. It is actively being worked on, so the API may change.
  warn_beta(
```

이제 우리가 이전에 검색한 질문에 대해 분석기가 생성한 쿼리를 살펴보겠습니다:

```python
query_analyzer.invoke("how do I build a RAG agent")
```


```output
Search(query='build RAG agent', publish_year=None)
```


```python
query_analyzer.invoke("videos on RAG published in 2023")
```


```output
Search(query='RAG', publish_year=2023)
```


## 쿼리 분석을 통한 검색

우리의 쿼리 분석은 꽤 괜찮아 보입니다. 이제 생성된 쿼리를 사용하여 실제로 검색을 수행해 보겠습니다.

**참고:** 우리의 예제에서는 `tool_choice="Search"`를 지정했습니다. 이것은 LLM이 하나의 도구만 호출하도록 강제하며, 따라서 항상 최적화된 쿼리를 하나만 조회할 수 있습니다. 이는 항상 그런 것은 아니며 - 최적화된 쿼리가 없거나 여러 개가 반환되는 상황을 처리하는 방법에 대한 다른 가이드를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Build a Query Analysis System"}]-->
from typing import List

from langchain_core.documents import Document
```


```python
def retrieval(search: Search) -> List[Document]:
    if search.publish_year is not None:
        # This is syntax specific to Chroma,
        # the vector database we are using.
        _filter = {"publish_year": {"$eq": search.publish_year}}
    else:
        _filter = None
    return vectorstore.similarity_search(search.query, filter=_filter)
```


```python
retrieval_chain = query_analyzer | retrieval
```


이제 이전의 문제 있는 입력에 대해 이 체인을 실행할 수 있으며, 그 결과 해당 연도의 결과만 반환되는 것을 확인할 수 있습니다!

```python
results = retrieval_chain.invoke("RAG tutorial published in 2023")
```


```python
[(doc.metadata["title"], doc.metadata["publish_date"]) for doc in results]
```


```output
[('Getting Started with Multi-Modal LLMs', '2023-12-20 00:00:00'),
 ('LangServe and LangChain Templates Webinar', '2023-11-02 00:00:00'),
 ('Getting Started with Multi-Modal LLMs', '2023-12-20 00:00:00'),
 ('Building a Research Assistant from Scratch', '2023-11-16 00:00:00')]
```
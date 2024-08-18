---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/rag.ipynb
description: RAG 앱 구축에 대한 튜토리얼로, 질문-답변 챗봇을 만들고 LangSmith를 활용하여 애플리케이션을 이해하는 방법을 설명합니다.
---

# 검색 증강 생성(RAG) 앱 구축하기

LLM이 가능하게 하는 가장 강력한 응용 프로그램 중 하나는 정교한 질문-답변(Q&A) 챗봇입니다. 이러한 응용 프로그램은 특정 소스 정보에 대한 질문에 답할 수 있습니다. 이러한 응용 프로그램은 검색 증강 생성(Retrieval Augmented Generation, RAG)이라는 기술을 사용합니다.

이 튜토리얼에서는 텍스트 데이터 소스에 대한 간단한 Q&A 응용 프로그램을 구축하는 방법을 보여줍니다. 그 과정에서 일반적인 Q&A 아키텍처를 살펴보고 더 고급 Q&A 기술을 위한 추가 리소스를 강조할 것입니다. 또한 LangSmith가 어떻게 우리의 응용 프로그램을 추적하고 이해하는 데 도움을 줄 수 있는지도 살펴보겠습니다. 우리의 응용 프로그램이 복잡해짐에 따라 LangSmith는 점점 더 유용해질 것입니다.

기본 검색에 이미 익숙하다면, [다양한 검색 기술에 대한 고급 개요](/docs/concepts/#retrieval)에도 관심이 있을 수 있습니다.

## RAG란 무엇인가?

RAG는 LLM 지식을 추가 데이터로 보강하는 기술입니다.

LLM은 광범위한 주제에 대해 추론할 수 있지만, 그 지식은 특정 시점까지 훈련된 공개 데이터로 제한됩니다. 모델의 컷오프 날짜 이후의 개인 데이터나 데이터를 추론할 수 있는 AI 응용 프로그램을 구축하려면, 모델이 필요로 하는 특정 정보로 모델의 지식을 보강해야 합니다. 적절한 정보를 가져와 모델 프롬프트에 삽입하는 과정을 검색 증강 생성(RAG)이라고 합니다.

LangChain에는 Q&A 응용 프로그램과 일반적으로 RAG 응용 프로그램을 구축하는 데 도움이 되는 여러 구성 요소가 있습니다.

**참고**: 여기서는 비구조화된 데이터에 대한 Q&A에 중점을 둡니다. 구조화된 데이터에 대한 RAG에 관심이 있다면, [SQL 데이터에 대한 질문/답변 튜토리얼](/docs/tutorials/sql_qa)을 확인하세요.

## 개념
전형적인 RAG 응용 프로그램은 두 가지 주요 구성 요소가 있습니다:

**인덱싱**: 소스에서 데이터를 수집하고 인덱싱하는 파이프라인. *이는 일반적으로 오프라인에서 발생합니다.*

**검색 및 생성**: 실제 RAG 체인으로, 실행 시간에 사용자 쿼리를 받아 인덱스에서 관련 데이터를 검색한 다음 이를 모델에 전달합니다.

원시 데이터에서 답변까지의 가장 일반적인 전체 시퀀스는 다음과 같습니다:

### 인덱싱
1. **로드**: 먼저 데이터를 로드해야 합니다. 이는 [문서 로더](/docs/concepts/#document-loaders)를 사용하여 수행됩니다.
2. **분할**: [텍스트 분할기](/docs/concepts/#text-splitters)는 큰 `문서`를 더 작은 조각으로 나눕니다. 이는 데이터 인덱싱과 모델에 전달하는 데 유용합니다. 큰 조각은 검색하기 어렵고 모델의 유한한 컨텍스트 창에 맞지 않기 때문입니다.
3. **저장**: 나눈 조각을 저장하고 인덱싱할 장소가 필요합니다. 이는 종종 [벡터 저장소](/docs/concepts/#vector-stores)와 [임베딩](/docs/concepts/#embedding-models) 모델을 사용하여 수행됩니다.

![index_diagram](../../static/img/rag_indexing.png)

### 검색 및 생성
4. **검색**: 사용자 입력이 주어지면, 관련 조각이 [검색기](/docs/concepts/#retrievers) 를 사용하여 저장소에서 검색됩니다.
5. **생성**: [챗 모델](/docs/concepts/#chat-models) / [LLM](/docs/concepts/#llms)은 질문과 검색된 데이터를 포함한 프롬프트를 사용하여 답변을 생성합니다.

![retrieval_diagram](../../static/img/rag_retrieval_generation.png)

## 설정

### 주피터 노트북

이 가이드(및 문서의 다른 대부분의 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며, 독자가 주피터 노트북을 사용한다고 가정합니다. 주피터 노트북은 LLM 시스템과 작업하는 방법을 배우기에 완벽합니다. 종종 예상치 못한 출력, API 다운 등 문제가 발생할 수 있으며, 인터랙티브 환경에서 가이드를 진행하는 것은 이를 더 잘 이해하는 좋은 방법입니다.

이 튜토리얼과 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행될 수 있습니다. 설치 방법에 대한 지침은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

이 튜토리얼은 다음의 langchain 종속성을 필요로 합니다:

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import CodeBlock from "@theme/CodeBlock";

<Tabs>
  <TabItem value="pip" label="Pip" default>
    <CodeBlock language="bash">pip install langchain langchain_community langchain_chroma</CodeBlock>
  </TabItem>
  <TabItem value="conda" label="Conda">
    <CodeBlock language="bash">conda install langchain langchain_community langchain_chroma -c conda-forge</CodeBlock>
  </TabItem>
</Tabs>

자세한 내용은 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축한 많은 응용 프로그램은 여러 단계와 여러 번의 LLM 호출을 포함합니다. 이러한 응용 프로그램이 점점 더 복잡해짐에 따라, 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 위한 가장 좋은 방법은 [LangSmith](https://smith.langchain.com)입니다.

위 링크에서 가입한 후, 추적 로그를 시작하기 위해 환경 변수를 설정해야 합니다:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```


또는 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 미리보기

이 가이드에서는 웹사이트의 콘텐츠에 대한 질문에 답하는 앱을 구축할 것입니다. 우리가 사용할 특정 웹사이트는 Lilian Weng의 [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) 블로그 게시물로, 이 게시물의 내용에 대한 질문을 할 수 있습니다.

우리는 약 20줄의 코드로 간단한 인덱싱 파이프라인과 RAG 체인을 생성할 수 있습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
import bs4
from langchain import hub
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Load, chunk and index the contents of the blog.
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(
        parse_only=bs4.SoupStrainer(
            class_=("post-content", "post-title", "post-header")
        )
    ),
)
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())

# Retrieve and generate using the relevant snippets of the blog.
retriever = vectorstore.as_retriever()
prompt = hub.pull("rlm/rag-prompt")


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

rag_chain.invoke("What is Task Decomposition?")
```


```output
'Task Decomposition is a process where a complex task is broken down into smaller, simpler steps or subtasks. This technique is utilized to enhance model performance on complex tasks by making them more manageable. It can be done by using language models with simple prompting, task-specific instructions, or with human inputs.'
```


```python
# cleanup
vectorstore.delete_collection()
```


[LangSmith 추적](https://smith.langchain.com/public/1c6ca97e-445b-4d00-84b4-c7befcbc59fe/r)를 확인하세요.

## 자세한 단계별 설명

위 코드를 단계별로 살펴보며 무슨 일이 일어나고 있는지 정말로 이해해 봅시다.

## 1. 인덱싱: 로드 {#indexing-load}

먼저 블로그 게시물 내용을 로드해야 합니다. 이를 위해 [문서 로더](/docs/concepts#document-loaders)를 사용할 수 있으며, 이는 소스에서 데이터를 로드하고 [문서](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 목록을 반환하는 객체입니다. `문서`는 일부 `page_content`(str) 및 `metadata`(dict)를 가진 객체입니다.

이 경우, `urllib`를 사용하여 웹 URL에서 HTML을 로드하고 `BeautifulSoup`를 사용하여 이를 텍스트로 파싱하는 [WebBaseLoader](/docs/integrations/document_loaders/web_base)를 사용할 것입니다. `bs_kwargs`를 통해 `BeautifulSoup` 파서에 매개변수를 전달하여 HTML -> 텍스트 파싱을 사용자 정의할 수 있습니다(자세한 내용은 [BeautifulSoup 문서](https://beautiful-soup-4.readthedocs.io/en/latest/#beautifulsoup)를 참조하세요). 이 경우 "post-content", "post-title" 또는 "post-header" 클래스를 가진 HTML 태그만 관련이 있으므로 나머지는 모두 제거할 것입니다.

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
import bs4
from langchain_community.document_loaders import WebBaseLoader

# Only keep post title, headers, and content from the full HTML.
bs4_strainer = bs4.SoupStrainer(class_=("post-title", "post-header", "post-content"))
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs={"parse_only": bs4_strainer},
)
docs = loader.load()

len(docs[0].page_content)
```


```output
43131
```


```python
print(docs[0].page_content[:500])
```

```output


      LLM Powered Autonomous Agents
    
Date: June 23, 2023  |  Estimated Reading Time: 31 min  |  Author: Lilian Weng


Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.
Agent System Overview#
In
```


### 더 깊이 들어가기

`DocumentLoader`: 소스에서 데이터를 목록 형태로 로드하는 객체입니다.

- [문서](/docs/how_to#document-loaders): `DocumentLoaders` 사용에 대한 자세한 문서입니다.
- [통합](/docs/integrations/document_loaders/): 선택할 수 있는 160개 이상의 통합.
- [인터페이스](https://api.python.langchain.com/en/latest/document_loaders/langchain_core.document_loaders.base.BaseLoader.html): 기본 인터페이스에 대한 API 참조입니다.

## 2. 인덱싱: 분할 {#indexing-split}

로드된 문서는 42,000자 이상입니다. 이는 많은 모델의 컨텍스트 창에 맞지 않습니다. 전체 게시물을 컨텍스트 창에 맞출 수 있는 모델조차도 매우 긴 입력에서 정보를 찾는 데 어려움을 겪을 수 있습니다.

이를 처리하기 위해 `문서`를 임베딩 및 벡터 저장을 위해 조각으로 나눌 것입니다. 이는 실행 시간에 블로그 게시물의 가장 관련성이 높은 부분만 검색하는 데 도움이 될 것입니다.

이 경우, 문서를 1000자 조각으로 나누고 조각 간 200자의 겹침을 두겠습니다. 겹침은 중요한 맥락과 관련된 진술을 분리할 가능성을 완화하는 데 도움이 됩니다. 우리는 [RecursiveCharacterTextSplitter](/docs/how_to/recursive_text_splitter)를 사용하여, 일반적인 구분 기호인 줄 바꿈을 사용하여 문서를 재귀적으로 나누어 각 조각이 적절한 크기가 되도록 합니다. 이는 일반적인 텍스트 사용 사례에 권장되는 텍스트 분할기입니다.

`add_start_index=True`로 설정하여 각 분할된 문서가 초기 문서 내에서 시작하는 문자 인덱스를 메타데이터 속성 "start_index"로 보존합니다.

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000, chunk_overlap=200, add_start_index=True
)
all_splits = text_splitter.split_documents(docs)

len(all_splits)
```


```output
66
```


```python
len(all_splits[0].page_content)
```


```output
969
```


```python
all_splits[10].metadata
```


```output
{'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/',
 'start_index': 7056}
```


### 더 깊이 들어가기

`TextSplitter`: `문서` 목록을 더 작은 조각으로 나누는 객체입니다. `DocumentTransformer`의 하위 클래스입니다.

- 다양한 방법으로 텍스트를 분할하는 방법에 대한 자세한 내용을 보려면 [사용 방법 문서](/docs/how_to#text-splitters)를 읽어보세요.
- [코드 (py 또는 js)](/docs/integrations/document_loaders/source_code)
- [과학 논문](/docs/integrations/document_loaders/grobid)
- [인터페이스](https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TextSplitter.html): 기본 인터페이스에 대한 API 참조입니다.

`DocumentTransformer`: `문서` 객체 목록에 대한 변환을 수행하는 객체입니다.

- [문서](/docs/how_to#text-splitters): `DocumentTransformers` 사용에 대한 자세한 문서입니다.
- [통합](/docs/integrations/document_transformers/)
- [인터페이스](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.transformers.BaseDocumentTransformer.html): 기본 인터페이스에 대한 API 참조입니다.

## 3. 인덱싱: 저장 {#indexing-store}

이제 66개의 텍스트 조각을 인덱싱하여 실행 시간에 검색할 수 있도록 해야 합니다. 이를 수행하는 가장 일반적인 방법은 각 문서 분할의 내용을 임베딩하고 이러한 임베딩을 벡터 데이터베이스(또는 벡터 저장소)에 삽입하는 것입니다. 분할을 검색하고 싶을 때, 텍스트 검색 쿼리를 가져와 임베딩하고, 쿼리 임베딩과 가장 유사한 저장된 분할을 식별하기 위해 어떤 형태의 "유사성" 검색을 수행합니다. 가장 간단한 유사성 측정은 코사인 유사성입니다. 각 임베딩 쌍(고차원 벡터) 간의 각도 코사인을 측정합니다.

우리는 [Chroma](/docs/integrations/vectorstores/chroma) 벡터 저장소와 [OpenAIEmbeddings](/docs/integrations/text_embedding/openai) 모델을 사용하여 모든 문서 분할을 단일 명령으로 임베딩하고 저장할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(documents=all_splits, embedding=OpenAIEmbeddings())
```


### 더 깊이 들어가기

`Embeddings`: 텍스트를 임베딩으로 변환하는 데 사용되는 텍스트 임베딩 모델의 래퍼입니다.

- [문서](/docs/how_to/embed_text): 임베딩 사용에 대한 자세한 문서입니다.
- [통합](/docs/integrations/text_embedding/): 선택할 수 있는 30개 이상의 통합.
- [인터페이스](https://api.python.langchain.com/en/latest/embeddings/langchain_core.embeddings.Embeddings.html): 기본 인터페이스에 대한 API 참조입니다.

`VectorStore`: 임베딩을 저장하고 쿼리하는 데 사용되는 벡터 데이터베이스의 래퍼입니다.

- [문서](/docs/how_to/vectorstores): 벡터 저장소 사용에 대한 자세한 문서입니다.
- [통합](/docs/integrations/vectorstores/): 선택할 수 있는 40개 이상의 통합.
- [인터페이스](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html): 기본 인터페이스에 대한 API 참조입니다.

이로써 파이프라인의 **인덱싱** 부분이 완료되었습니다. 이 시점에서 우리는 블로그 게시물의 조각화된 내용을 쿼리할 수 있는 벡터 저장소를 가지고 있습니다. 사용자 질문이 주어지면, 우리는 이상적으로 질문에 대한 답변을 제공하는 블로그 게시물의 스니펫을 반환할 수 있어야 합니다.

## 4. 검색 및 생성: 검색 {#retrieval-and-generation-retrieve}

이제 실제 응용 프로그램 논리를 작성해 보겠습니다. 우리는 사용자 질문을 받아 그 질문과 관련된 문서를 검색하고, 검색된 문서와 초기 질문을 모델에 전달하여 답변을 반환하는 간단한 응용 프로그램을 만들고자 합니다.

먼저 문서 검색을 위한 논리를 정의해야 합니다. LangChain은 문자열 쿼리를 기반으로 관련 `문서`를 반환할 수 있는 인덱스를 래핑하는 [검색기](/docs/concepts#retrievers/) 인터페이스를 정의합니다.

가장 일반적인 유형의 `검색기`는 [VectorStoreRetriever](/docs/how_to/vectorstore_retriever)로, 벡터 저장소의 유사성 검색 기능을 사용하여 검색을 용이하게 합니다. 어떤 `VectorStore`도 `VectorStore.as_retriever()`를 사용하여 쉽게 `검색기`로 변환할 수 있습니다:

```python
retriever = vectorstore.as_retriever(search_type="similarity", search_kwargs={"k": 6})

retrieved_docs = retriever.invoke("What are the approaches to Task Decomposition?")

len(retrieved_docs)
```


```output
6
```


```python
print(retrieved_docs[0].page_content)
```

```output
Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.
Task decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.
```

### 더 깊이 들어가기

벡터 저장소는 검색에 일반적으로 사용되지만, 검색을 수행하는 다른 방법도 있습니다.

`Retriever`: 텍스트 쿼리를 기반으로 `Document`를 반환하는 객체입니다.

- [Docs](/docs/how_to#retrievers): 인터페이스 및 내장 검색 기술에 대한 추가 문서입니다. 그 중 일부는 다음과 같습니다:
  - `MultiQueryRetriever`는 [입력 질문의 변형을 생성합니다](/docs/how_to/MultiQueryRetriever) 검색 적중률을 개선하기 위해.
  - `MultiVectorRetriever`는 [임베딩의 변형을 생성합니다](/docs/how_to/multi_vector) 검색 적중률을 개선하기 위해.
  - `Max marginal relevance`는 [관련성과 다양성](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf)을 선택하여 중복된 컨텍스트를 전달하지 않도록 합니다.
  - 문서는 [Self Query Retriever](/docs/how_to/self_query)와 같은 메타데이터 필터를 사용하여 벡터 저장소 검색 중에 필터링할 수 있습니다.
- [Integrations](/docs/integrations/retrievers/): 검색 서비스와의 통합.
- [Interface](https://api.python.langchain.com/en/latest/retrievers/langchain_core.retrievers.BaseRetriever.html): 기본 인터페이스에 대한 API 참조.

## 5. 검색 및 생성: 생성 {#retrieval-and-generation-generate}

질문을 받고 관련 문서를 검색하고 프롬프트를 구성하여 모델에 전달하고 출력을 분석하는 체인으로 모두 결합해 보겠습니다.

gpt-4o-mini OpenAI 채팅 모델을 사용할 것이지만, LangChain `LLM` 또는 `ChatModel`을 대체할 수 있습니다.

<ChatModelTabs
customVarName="llm"
anthropicParams={`"model="claude-3-sonnet-20240229", temperature=0.2, max_tokens=1024"`}
/>

LangChain 프롬프트 허브에 체크된 RAG 프롬프트를 사용할 것입니다 ([여기](https://smith.langchain.com/hub/rlm/rag-prompt)).

```python
from langchain import hub

prompt = hub.pull("rlm/rag-prompt")

example_messages = prompt.invoke(
    {"context": "filler context", "question": "filler question"}
).to_messages()

example_messages
```


```output
[HumanMessage(content="You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.\nQuestion: filler question \nContext: filler context \nAnswer:")]
```


```python
print(example_messages[0].content)
```

```output
You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.
Question: filler question 
Context: filler context 
Answer:
```

체인을 정의하기 위해 [LCEL Runnable](/docs/concepts#langchain-expression-language-lcel) 프로토콜을 사용할 것이며, 이를 통해

- 구성 요소와 기능을 투명하게 연결할 수 있습니다.
- LangSmith에서 체인을 자동으로 추적할 수 있습니다.
- 즉시 스트리밍, 비동기 및 배치 호출을 얻을 수 있습니다.

구현은 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

for chunk in rag_chain.stream("What is Task Decomposition?"):
    print(chunk, end="", flush=True)
```

```output
Task Decomposition is a process where a complex task is broken down into smaller, more manageable steps or parts. This is often done using techniques like "Chain of Thought" or "Tree of Thoughts", which instruct a model to "think step by step" and transform large tasks into multiple simple tasks. Task decomposition can be prompted in a model, guided by task-specific instructions, or influenced by human inputs.
```

LCEL을 분석하여 무슨 일이 일어나고 있는지 이해해 보겠습니다.

첫째: 이러한 각 구성 요소(`retriever`, `prompt`, `llm` 등)는 [Runnable](/docs/concepts#langchain-expression-language-lcel)의 인스턴스입니다. 이는 동기 및 비동기 `.invoke`, `.stream` 또는 `.batch`와 같은 동일한 메서드를 구현하므로 서로 연결하기가 더 쉽습니다. 이들은 `|` 연산자를 통해 [RunnableSequence](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableSequence.html)로 연결될 수 있습니다-- 또 다른 Runnable입니다.

LangChain은 `|` 연산자를 만나면 특정 객체를 자동으로 런너블로 변환합니다. 여기서 `format_docs`는 [RunnableLambda](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html)로 변환되고, `"context"`와 `"question"`이 포함된 dict는 [RunnableParallel](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html)로 변환됩니다. 세부 사항은 각 객체가 Runnable이라는 더 큰 점보다 덜 중요합니다.

입력 질문이 위의 런너블을 통해 어떻게 흐르는지 추적해 보겠습니다.

위에서 보았듯이, `prompt`에 대한 입력은 `"context"`와 `"question"` 키가 있는 dict로 예상됩니다. 따라서 이 체인의 첫 번째 요소는 입력 질문으로부터 이 두 가지를 계산할 런너블을 구축합니다:
- `retriever | format_docs`는 질문을 리트리버를 통해 전달하여 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체를 생성한 다음 `format_docs`로 전달하여 문자열을 생성합니다;
- `RunnablePassthrough()`는 입력 질문을 변경하지 않고 그대로 전달합니다.

즉, 만약 당신이 다음을 구성했다면
```python
chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
)
```

그렇다면 `chain.invoke(question)`은 추론을 위해 준비된 형식화된 프롬프트를 생성할 것입니다. (참고: LCEL로 개발할 때는 이렇게 하위 체인으로 테스트하는 것이 실용적일 수 있습니다.)

체인의 마지막 단계는 추론을 실행하는 `llm`과 LLM의 출력 메시지에서 문자열 내용을 추출하는 `StrOutputParser()`입니다.

이 체인의 개별 단계를 [LangSmith trace](https://smith.langchain.com/public/1799e8db-8a6d-4eb2-84d5-46e8d7d5a99b/r)를 통해 분석할 수 있습니다.

### 내장 체인

원하는 경우 LangChain은 위의 LCEL을 구현하는 편리한 함수를 포함합니다. 우리는 두 가지 함수를 구성합니다:

- [create_stuff_documents_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html)는 검색된 컨텍스트가 프롬프트와 LLM에 어떻게 공급되는지를 지정합니다. 이 경우 우리는 "stuff"를 프롬프트에 포함할 것입니다 -- 즉, 요약이나 다른 처리를 하지 않고 모든 검색된 컨텍스트를 포함합니다. 이는 위의 `rag_chain`을 대체하며, 입력 키는 `context`와 `input`입니다 -- 검색된 컨텍스트와 쿼리를 사용하여 답변을 생성합니다.
- [create_retrieval_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html)는 검색 단계를 추가하고 검색된 컨텍스트를 체인을 통해 전파하여 최종 답변과 함께 제공합니다. 입력 키는 `input`이며, 출력에는 `input`, `context`, `answer`가 포함됩니다.

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate

system_prompt = (
    "You are an assistant for question-answering tasks. "
    "Use the following pieces of retrieved context to answer "
    "the question. If you don't know the answer, say that you "
    "don't know. Use three sentences maximum and keep the "
    "answer concise."
    "\n\n"
    "{context}"
)

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
    ]
)


question_answer_chain = create_stuff_documents_chain(llm, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)

response = rag_chain.invoke({"input": "What is Task Decomposition?"})
print(response["answer"])
```

```output
Task Decomposition is a process in which complex tasks are broken down into smaller and simpler steps. Techniques like Chain of Thought (CoT) and Tree of Thoughts are used to enhance model performance on these tasks. The CoT method instructs the model to think step by step, decomposing hard tasks into manageable ones, while Tree of Thoughts extends CoT by exploring multiple reasoning possibilities at each step, creating a tree structure of thoughts.
```

#### 출처 반환
Q&A 애플리케이션에서는 답변을 생성하는 데 사용된 출처를 사용자에게 보여주는 것이 중요합니다. LangChain의 내장 `create_retrieval_chain`은 검색된 출처 문서를 `"context"` 키를 통해 출력으로 전파합니다:

```python
for document in response["context"]:
    print(document)
    print()
```

```output
page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}

page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 1585}

page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 2192}

page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}

page_content='Resources:\n1. Internet access for searches and information gathering.\n2. Long Term memory management.\n3. GPT-3.5 powered Agents for delegation of simple tasks.\n4. File output.\n\nPerformance Evaluation:\n1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.\n2. Constructively self-criticize your big-picture behavior constantly.\n3. Reflect on past decisions and strategies to refine your approach.\n4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}

page_content='Resources:\n1. Internet access for searches and information gathering.\n2. Long Term memory management.\n3. GPT-3.5 powered Agents for delegation of simple tasks.\n4. File output.\n\nPerformance Evaluation:\n1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.\n2. Constructively self-criticize your big-picture behavior constantly.\n3. Reflect on past decisions and strategies to refine your approach.\n4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 29630}
```

### 더 깊이 들어가기

#### 모델 선택

`ChatModel`: LLM 지원 채팅 모델입니다. 메시지 시퀀스를 입력받아 메시지를 반환합니다.

- [Docs](/docs/how_to#chat-models)
- [Integrations](/docs/integrations/chat/): 선택할 수 있는 25개 이상의 통합.
- [Interface](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.BaseChatModel.html): 기본 인터페이스에 대한 API 참조.

`LLM`: 텍스트 입력-텍스트 출력 LLM입니다. 문자열을 입력받아 문자열을 반환합니다.

- [Docs](/docs/how_to#llms)
- [Integrations](/docs/integrations/llms): 선택할 수 있는 75개 이상의 통합.
- [Interface](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.llms.BaseLLM.html): 기본 인터페이스에 대한 API 참조.

로컬에서 실행되는 모델을 사용한 RAG에 대한 가이드는 [여기](/docs/tutorials/local_rag)에서 확인하세요.

#### 프롬프트 사용자 정의

위에서 보여준 것처럼, 우리는 프롬프트 허브에서 프롬프트(예: [이 RAG 프롬프트](https://smith.langchain.com/hub/rlm/rag-prompt))를 로드할 수 있습니다. 프롬프트는 쉽게 사용자 정의할 수도 있습니다:

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Build a Retrieval Augmented Generation (RAG) App"}]-->
from langchain_core.prompts import PromptTemplate

template = """Use the following pieces of context to answer the question at the end.
If you don't know the answer, just say that you don't know, don't try to make up an answer.
Use three sentences maximum and keep the answer as concise as possible.
Always say "thanks for asking!" at the end of the answer.

{context}

Question: {question}

Helpful Answer:"""
custom_rag_prompt = PromptTemplate.from_template(template)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | custom_rag_prompt
    | llm
    | StrOutputParser()
)

rag_chain.invoke("What is Task Decomposition?")
```


```output
'Task decomposition is the process of breaking down a complex task into smaller, more manageable parts. Techniques like Chain of Thought (CoT) and Tree of Thoughts allow an agent to "think step by step" and explore multiple reasoning possibilities, respectively. This process can be executed by a Language Model with simple prompts, task-specific instructions, or human inputs. Thanks for asking!'
```


[LangSmith trace](https://smith.langchain.com/public/da23c4d8-3b33-47fd-84df-a3a582eedf84/r)를 확인하세요.

## 다음 단계

우리는 데이터에 대한 기본 Q&A 앱을 구축하는 단계를 다루었습니다:

- [Document Loader](/docs/concepts#document-loaders)를 사용하여 데이터 로드
- 모델이 더 쉽게 사용할 수 있도록 [Text Splitter](/docs/concepts#text-splitters)로 인덱스된 데이터 청크화
- [Embedding the data](/docs/concepts#embedding-models) 및 [vectorstore](/docs/how_to/vectorstores)에 데이터 저장
- 들어오는 질문에 대한 응답으로 이전에 저장된 청크 검색
- 검색된 청크를 컨텍스트로 사용하여 답변 생성

위의 각 섹션에서 탐색할 수 있는 많은 기능, 통합 및 확장이 있습니다. 위에서 언급한 **더 깊이 들어가기** 소스 외에도 좋은 다음 단계는 다음과 같습니다:

- [Return sources](/docs/how_to/qa_sources): 출처 문서를 반환하는 방법 배우기
- [Streaming](/docs/how_to/streaming): 출력 및 중간 단계를 스트리밍하는 방법 배우기
- [Add chat history](/docs/how_to/message_history): 앱에 채팅 기록 추가하는 방법 배우기
- [Retrieval conceptual guide](/docs/concepts/#retrieval): 특정 검색 기술에 대한 고급 개요
- [Build a local RAG application](/docs/tutorials/local_rag): 위와 유사한 앱을 로컬 구성 요소를 사용하여 만들기
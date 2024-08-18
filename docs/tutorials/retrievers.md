---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/retrievers.ipynb
description: 이 튜토리얼은 LangChain의 벡터 저장소 및 검색기 추상화를 소개하며, 데이터 검색 및 LLM 워크플로우 통합을 지원합니다.
---

# 벡터 저장소 및 검색기

이 튜토리얼은 LangChain의 벡터 저장소 및 검색기 추상화에 대해 익숙해지도록 도와줍니다. 이러한 추상화는 LLM 워크플로우와 통합하기 위해 (벡터) 데이터베이스 및 기타 소스에서 데이터를 검색하는 것을 지원하도록 설계되었습니다. 이는 검색 보강 생성(RAG)의 경우와 같이 모델 추론의 일환으로 추론할 데이터를 가져오는 애플리케이션에 중요합니다(자세한 내용은 우리의 RAG 튜토리얼을 [여기](/docs/tutorials/rag)에서 확인하세요).

## 개념

이 가이드는 텍스트 데이터 검색에 중점을 둡니다. 다음 개념을 다룰 것입니다:

- 문서;
- 벡터 저장소;
- 검색기.

## 설정

### 주피터 노트북

이 튜토리얼 및 기타 튜토리얼은 주피터 노트북에서 가장 편리하게 실행됩니다. 설치 방법에 대한 지침은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

이 튜토리얼은 `langchain`, `langchain-chroma`, 및 `langchain-openai` 패키지가 필요합니다:

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import CodeBlock from "@theme/CodeBlock";

<Tabs>
  <TabItem value="pip" label="Pip" default>
    <CodeBlock language="bash">pip install langchain langchain-chroma langchain-openai</CodeBlock>
  </TabItem>
  <TabItem value="conda" label="Conda">
    <CodeBlock language="bash">conda install langchain langchain-chroma langchain-openai -c conda-forge</CodeBlock>
  </TabItem>
</Tabs>

자세한 내용은 우리의 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 LLM 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)를 사용하는 것입니다.

위 링크에서 가입한 후, 트레이스를 기록하기 위해 환경 변수를 설정하세요:

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


## 문서

LangChain은 텍스트 단위와 관련 메타데이터를 나타내기 위해 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 추상화를 구현합니다. 두 가지 속성이 있습니다:

- `page_content`: 내용을 나타내는 문자열;
- `metadata`: 임의의 메타데이터를 포함하는 딕셔너리.

`metadata` 속성은 문서의 출처, 다른 문서와의 관계 및 기타 정보를 캡처할 수 있습니다. 개별 `Document` 객체는 종종 더 큰 문서의 일부를 나타냅니다.

샘플 문서를 생성해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Vector stores and retrievers"}]-->
from langchain_core.documents import Document

documents = [
    Document(
        page_content="Dogs are great companions, known for their loyalty and friendliness.",
        metadata={"source": "mammal-pets-doc"},
    ),
    Document(
        page_content="Cats are independent pets that often enjoy their own space.",
        metadata={"source": "mammal-pets-doc"},
    ),
    Document(
        page_content="Goldfish are popular pets for beginners, requiring relatively simple care.",
        metadata={"source": "fish-pets-doc"},
    ),
    Document(
        page_content="Parrots are intelligent birds capable of mimicking human speech.",
        metadata={"source": "bird-pets-doc"},
    ),
    Document(
        page_content="Rabbits are social animals that need plenty of space to hop around.",
        metadata={"source": "mammal-pets-doc"},
    ),
]
```


여기에서는 세 가지 서로 다른 "출처"를 나타내는 메타데이터를 포함한 다섯 개의 문서를 생성했습니다.

## 벡터 저장소

벡터 검색은 비구조화된 데이터(예: 비구조화된 텍스트)를 저장하고 검색하는 일반적인 방법입니다. 아이디어는 텍스트와 연관된 숫자 벡터를 저장하는 것입니다. 쿼리가 주어지면, 이를 동일한 차원의 벡터로 [임베드](/docs/concepts#embedding-models)하고 벡터 유사성 메트릭을 사용하여 저장소에서 관련 데이터를 식별할 수 있습니다.

LangChain [VectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html) 객체는 텍스트 및 `Document` 객체를 저장소에 추가하고 다양한 유사성 메트릭을 사용하여 쿼리하는 메서드를 포함합니다. 이들은 종종 텍스트 데이터가 숫자 벡터로 변환되는 방식을 결정하는 [임베딩](/docs/how_to/embed_text) 모델로 초기화됩니다.

LangChain은 다양한 벡터 저장소 기술과의 [통합](/docs/integrations/vectorstores) 모음을 포함합니다. 일부 벡터 저장소는 제공업체(예: 다양한 클라우드 제공업체)에 의해 호스팅되며 사용을 위해 특정 자격 증명이 필요합니다. 일부(예: [Postgres](/docs/integrations/vectorstores/pgvector))는 로컬 또는 제3자를 통해 실행할 수 있는 별도의 인프라에서 실행됩니다. 다른 저장소는 경량 작업을 위해 인메모리로 실행할 수 있습니다. 여기에서는 인메모리 구현을 포함하는 [Chroma](/docs/integrations/vectorstores/chroma)를 사용하여 LangChain VectorStores의 사용을 보여줍니다.

벡터 저장소를 인스턴스화하려면 일반적으로 텍스트가 숫자 벡터로 변환되는 방식을 지정하기 위해 [임베딩](/docs/how_to/embed_text) 모델을 제공해야 합니다. 여기에서는 [OpenAI 임베딩](/docs/integrations/text_embedding/openai/)을 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Vector stores and retrievers"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Vector stores and retrievers"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(
    documents,
    embedding=OpenAIEmbeddings(),
)
```


여기서 `.from_documents`를 호출하면 문서가 벡터 저장소에 추가됩니다. [VectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html)에는 객체가 인스턴스화된 후에도 호출할 수 있는 문서를 추가하는 메서드가 구현되어 있습니다. 대부분의 구현은 클라이언트, 인덱스 이름 또는 기타 정보를 제공하여 기존 벡터 저장소에 연결할 수 있도록 허용합니다. 특정 [통합](/docs/integrations/vectorstores)에 대한 문서를 참조하여 자세한 내용을 확인하세요.

문서가 포함된 `VectorStore`를 인스턴스화한 후에는 이를 쿼리할 수 있습니다. [VectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html)에는 다음과 같은 쿼리 메서드가 포함되어 있습니다:
- 동기 및 비동기;
- 문자열 쿼리 및 벡터로;
- 유사성 점수를 반환할지 여부;
- 유사성 및 [최대 한계 관련성](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html#langchain_core.vectorstores.VectorStore.max_marginal_relevance_search) (쿼리의 유사성과 검색된 결과의 다양성을 균형 있게 조정하기 위해).

메서드는 일반적으로 출력에 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) 객체 목록을 포함합니다.

### 예시

문서 반환 문자열 쿼리에 대한 유사성 기반:

```python
vectorstore.similarity_search("cat")
```


```output
[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'})]
```


비동기 쿼리:

```python
await vectorstore.asimilarity_search("cat")
```


```output
[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'})]
```


점수 반환:

```python
# Note that providers implement different scores; Chroma here
# returns a distance metric that should vary inversely with
# similarity.

vectorstore.similarity_search_with_score("cat")
```


```output
[(Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
  0.3751849830150604),
 (Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
  0.48316916823387146),
 (Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
  0.49601367115974426),
 (Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'}),
  0.4972994923591614)]
```


임베디드 쿼리에 대한 유사성 기반 문서 반환:

```python
embedding = OpenAIEmbeddings().embed_query("cat")

vectorstore.similarity_search_by_vector(embedding)
```


```output
[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'})]
```


자세히 알아보기:

- [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html)
- [사용 방법 가이드](/docs/how_to/vectorstores)
- [통합별 문서](/docs/integrations/vectorstores)

## 검색기

LangChain `VectorStore` 객체는 [Runnable](https://api.python.langchain.com/en/latest/core_api_reference.html#module-langchain_core.runnables)을 서브클래스화하지 않으므로 LangChain 표현 언어 [체인](/docs/concepts/#langchain-expression-language-lcel)에 즉시 통합될 수 없습니다.

LangChain [검색기](https://api.python.langchain.com/en/latest/core_api_reference.html#module-langchain_core.retrievers)는 Runnables이므로 표준 메서드 집합(예: 동기 및 비동기 `invoke` 및 `batch` 작업)을 구현하며 LCEL 체인에 통합되도록 설계되었습니다.

우리는 `Retriever`를 서브클래스화하지 않고도 간단한 버전을 스스로 만들 수 있습니다. 문서를 검색하는 데 사용할 방법을 선택하면 쉽게 실행 가능한 객체를 만들 수 있습니다. 아래에서는 `similarity_search` 메서드를 중심으로 하나를 구축할 것입니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Vector stores and retrievers"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "Vector stores and retrievers"}]-->
from typing import List

from langchain_core.documents import Document
from langchain_core.runnables import RunnableLambda

retriever = RunnableLambda(vectorstore.similarity_search).bind(k=1)  # select top result

retriever.batch(["cat", "shark"])
```


```output
[[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'})],
 [Document(page_content='Goldfish are popular pets for beginners, requiring relatively simple care.', metadata={'source': 'fish-pets-doc'})]]
```


벡터 저장소는 검색기를 생성하는 `as_retriever` 메서드를 구현하며, 특히 [VectorStoreRetriever](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStoreRetriever.html)입니다. 이러한 검색기는 기본 벡터 저장소에서 호출할 메서드를 식별하는 특정 `search_type` 및 `search_kwargs` 속성을 포함합니다. 예를 들어, 다음과 같이 위의 내용을 복제할 수 있습니다:

```python
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 1},
)

retriever.batch(["cat", "shark"])
```


```output
[[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'})],
 [Document(page_content='Goldfish are popular pets for beginners, requiring relatively simple care.', metadata={'source': 'fish-pets-doc'})]]
```


`VectorStoreRetriever`는 `"similarity"`(기본값), `"mmr"`(위에서 설명한 최대 한계 관련성), 및 `"similarity_score_threshold"`의 검색 유형을 지원합니다. 후자는 유사성 점수에 따라 검색기가 출력하는 문서를 임계값으로 설정하는 데 사용할 수 있습니다.

검색기는 검색 보강 생성(RAG) 애플리케이션과 같은 더 복잡한 애플리케이션에 쉽게 통합될 수 있으며, 이는 주어진 질문과 검색된 컨텍스트를 결합하여 LLM에 대한 프롬프트를 생성합니다. 아래는 최소한의 예를 보여줍니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Vector stores and retrievers"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Vector stores and retrievers"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

message = """
Answer this question using the provided context only.

{question}

Context:
{context}
"""

prompt = ChatPromptTemplate.from_messages([("human", message)])

rag_chain = {"context": retriever, "question": RunnablePassthrough()} | prompt | llm
```


```python
response = rag_chain.invoke("tell me about cats")

print(response.content)
```

```output
Cats are independent pets that often enjoy their own space.
```

## 자세히 알아보기:

검색 전략은 풍부하고 복잡할 수 있습니다. 예를 들어:

- 쿼리에서 [하드 규칙 및 필터를 유추할 수 있습니다](/docs/how_to/self_query/) (예: "2020년 이후에 발표된 문서 사용");
- 검색된 컨텍스트와 어떤 식으로든 [연결된 문서](/docs/how_to/parent_document_retriever/)를 반환할 수 있습니다 (예: 문서 분류를 통해);
- 각 컨텍스트 단위에 대해 [여러 임베딩](/docs/how_to/multi_vector)을 생성할 수 있습니다;
- 여러 검색기에서 [결과를 앙상블](/docs/how_to/ensemble_retriever)할 수 있습니다;
- 문서에 가중치를 부여할 수 있습니다. 예를 들어, [최근 문서](/docs/how_to/time_weighted_vectorstore/)에 더 높은 가중치를 부여할 수 있습니다.

사용 방법 가이드의 [검색기](/docs/how_to#retrievers) 섹션에서는 이러한 및 기타 내장 검색 전략을 다룹니다.

또한 [BaseRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain_core.retrievers.BaseRetriever.html) 클래스를 확장하여 사용자 정의 검색기를 구현하는 것도 간단합니다. 우리의 사용 방법 가이드를 [여기](/docs/how_to/custom_retriever)에서 확인하세요.
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/qa_per_user.ipynb
description: 사용자별 검색 체인을 구성하는 방법을 안내하며, 여러 사용자의 데이터를 안전하게 관리하는 방법을 설명합니다.
---

# 사용자별 검색 수행 방법

이 가이드는 검색 체인의 런타임 속성을 구성하는 방법을 보여줍니다. 예제 애플리케이션은 사용자를 기반으로 검색자가 사용할 수 있는 문서를 제한하는 것입니다.

검색 애플리케이션을 구축할 때, 여러 사용자를 염두에 두고 구축해야 하는 경우가 많습니다. 이는 한 사용자뿐만 아니라 여러 다른 사용자를 위해 데이터를 저장해야 하며, 그들이 서로의 데이터를 볼 수 없어야 함을 의미합니다. 따라서 검색 체인을 구성하여 특정 정보만 검색할 수 있어야 합니다. 일반적으로 두 단계가 포함됩니다.

**1단계: 사용 중인 검색자가 여러 사용자를 지원하는지 확인하기**

현재 LangChain에는 이를 위한 통합 플래그나 필터가 없습니다. 오히려 각 벡터 저장소와 검색자는 각자의 것을 가질 수 있으며, 서로 다른 이름(네임스페이스, 다중 임대 등)으로 불릴 수 있습니다. 벡터 저장소의 경우, 이는 일반적으로 `similarity_search` 중에 전달되는 키워드 인수로 노출됩니다. 문서나 소스 코드를 읽어 사용 중인 검색자가 여러 사용자를 지원하는지, 그리고 지원하는 경우 어떻게 사용하는지 확인하십시오.

참고: 지원하지 않거나 문서화되지 않은 검색자에 대해 여러 사용자에 대한 문서 및/또는 지원을 추가하는 것은 LangChain에 기여하는 훌륭한 방법입니다.

**2단계: 해당 매개변수를 체인을 위한 구성 가능한 필드로 추가하기**

이렇게 하면 체인을 쉽게 호출하고 런타임에 관련 플래그를 구성할 수 있습니다. 구성에 대한 자세한 내용은 [이 문서](/docs/how_to/configure)를 참조하십시오.

이제 런타임에서 구성 가능한 필드로 이 체인을 호출할 수 있습니다.

## 코드 예제

코드에서 이것이 어떻게 보이는지 구체적인 예를 살펴보겠습니다. 이 예제에서는 Pinecone을 사용할 것입니다.

Pinecone을 구성하려면 다음 환경 변수를 설정하십시오:

- `PINECONE_API_KEY`: 귀하의 Pinecone API 키

```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to do per-user retrieval"}, {"imported": "PineconeVectorStore", "source": "langchain_pinecone", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_pinecone.vectorstores.PineconeVectorStore.html", "title": "How to do per-user retrieval"}]-->
from langchain_openai import OpenAIEmbeddings
from langchain_pinecone import PineconeVectorStore

embeddings = OpenAIEmbeddings()
vectorstore = PineconeVectorStore(index_name="test-example", embedding=embeddings)

vectorstore.add_texts(["i worked at kensho"], namespace="harrison")
vectorstore.add_texts(["i worked at facebook"], namespace="ankush")
```


```output
['ce15571e-4e2f-44c9-98df-7e83f6f63095']
```


`namespace`에 대한 pinecone kwarg는 문서를 분리하는 데 사용할 수 있습니다.

```python
# This will only get documents for Ankush
vectorstore.as_retriever(search_kwargs={"namespace": "ankush"}).get_relevant_documents(
    "where did i work?"
)
```


```output
[Document(page_content='i worked at facebook')]
```


```python
# This will only get documents for Harrison
vectorstore.as_retriever(
    search_kwargs={"namespace": "harrison"}
).get_relevant_documents("where did i work?")
```


```output
[Document(page_content='i worked at kensho')]
```


이제 질문-답변을 수행하는 데 사용할 체인을 생성할 수 있습니다.

먼저 LLM을 선택합시다.
import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

이것은 기본 질문-답변 체인 설정입니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to do per-user retrieval"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to do per-user retrieval"}, {"imported": "ConfigurableField", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html", "title": "How to do per-user retrieval"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to do per-user retrieval"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import (
    ConfigurableField,
    RunnablePassthrough,
)

template = """Answer the question based only on the following context:
{context}
Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

retriever = vectorstore.as_retriever()
```


여기서 우리는 검색자를 구성 가능한 필드로 표시합니다. 모든 벡터 저장소 검색자는 `search_kwargs`를 필드로 가집니다. 이는 벡터 저장소 특정 필드가 포함된 사전입니다.

이렇게 하면 체인을 호출할 때 `search_kwargs`에 대한 값을 전달할 수 있습니다.

```python
configurable_retriever = retriever.configurable_fields(
    search_kwargs=ConfigurableField(
        id="search_kwargs",
        name="Search Kwargs",
        description="The search kwargs to use",
    )
)
```


이제 구성 가능한 검색자를 사용하여 체인을 생성할 수 있습니다.

```python
chain = (
    {"context": configurable_retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```


이제 구성 가능한 옵션으로 체인을 호출할 수 있습니다. `search_kwargs`는 구성 가능한 필드의 ID입니다. 값은 Pinecone에 사용할 검색 kwargs입니다.

```python
chain.invoke(
    "where did the user work?",
    config={"configurable": {"search_kwargs": {"namespace": "harrison"}}},
)
```


```output
'The user worked at Kensho.'
```


```python
chain.invoke(
    "where did the user work?",
    config={"configurable": {"search_kwargs": {"namespace": "ankush"}}},
)
```


```output
'The user worked at Facebook.'
```


다중 사용자에 대한 더 많은 벡터 저장소 구현에 대해서는 [Milvus](/docs/integrations/vectorstores/milvus)와 같은 특정 페이지를 참조하십시오.
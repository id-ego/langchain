---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/parallel.ipynb
description: 이 문서는 `RunnableParallel`을 사용하여 병렬로 실행하는 방법과 이를 통해 연산을 최적화하는 방법에 대해 설명합니다.
keywords:
- RunnableParallel
- RunnableMap
- LCEL
sidebar_position: 1
---

# 병렬로 실행 가능한 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [Runnable 연결하기](/docs/how_to/sequence)

:::

[`RunnableParallel`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html) 원시 타입은 본질적으로 값이 실행 가능한 것(또는 실행 가능하도록 강제할 수 있는 것, 예: 함수)인 딕셔너리입니다. 이 값들은 모두 병렬로 실행되며, 각 값은 `RunnableParallel`의 전체 입력으로 호출됩니다. 최종 반환 값은 각 값의 결과를 적절한 키 아래에 포함하는 딕셔너리입니다.

## `RunnableParallels`로 포맷팅하기

`RunnableParallels`는 작업을 병렬화하는 데 유용하지만, 한 Runnable의 출력을 다음 Runnable의 입력 형식에 맞게 조작하는 데에도 유용합니다. 이를 사용하여 체인을 분할하거나 포크하여 여러 구성 요소가 입력을 병렬로 처리할 수 있습니다. 이후 다른 구성 요소가 결과를 결합하거나 병합하여 최종 응답을 합성할 수 있습니다. 이러한 유형의 체인은 다음과 같은 계산 그래프를 생성합니다:

```text
     Input
      / \
     /   \
 Branch1 Branch2
     \   /
      \ /
      Combine
```


아래에서 프롬프트에 대한 입력은 `"context"`와 `"question"` 키가 있는 맵으로 예상됩니다. 사용자 입력은 단지 질문입니다. 따라서 우리는 리트리버를 사용하여 컨텍스트를 가져오고 사용자 입력을 `"question"` 키 아래에 전달해야 합니다.

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to invoke runnables in parallel"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to invoke runnables in parallel"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to invoke runnables in parallel"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to invoke runnables in parallel"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to invoke runnables in parallel"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to invoke runnables in parallel"}]-->
from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

vectorstore = FAISS.from_texts(
    ["harrison worked at kensho"], embedding=OpenAIEmbeddings()
)
retriever = vectorstore.as_retriever()
template = """Answer the question based only on the following context:
{context}

Question: {question}
"""

# The prompt expects input with keys for "context" and "question"
prompt = ChatPromptTemplate.from_template(template)

model = ChatOpenAI()

retrieval_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)

retrieval_chain.invoke("where did harrison work?")
```


```output
'Harrison worked at Kensho.'
```


::: {.callout-tip}
RunnableParallel을 다른 Runnable과 조합할 때 우리의 딕셔너리를 RunnableParallel 클래스에 감쌀 필요가 없다는 점에 유의하세요 — 타입 변환은 자동으로 처리됩니다. 체인의 맥락에서, 이들은 동등합니다:
:::

```
{"context": retriever, "question": RunnablePassthrough()}
```


```
RunnableParallel({"context": retriever, "question": RunnablePassthrough()})
```


```
RunnableParallel(context=retriever, question=RunnablePassthrough())
```


자세한 내용은 [강제 변환에 대한 섹션](/docs/how_to/sequence/#coercion)을 참조하세요.

## itemgetter를 약어로 사용하기

Python의 `itemgetter`를 사용하여 `RunnableParallel`과 결합할 때 맵에서 데이터를 추출하는 약어로 사용할 수 있다는 점에 유의하세요. itemgetter에 대한 자세한 정보는 [Python 문서](https://docs.python.org/3/library/operator.html#operator.itemgetter)에서 확인할 수 있습니다.

아래 예제에서는 itemgetter를 사용하여 맵에서 특정 키를 추출합니다:

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to invoke runnables in parallel"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to invoke runnables in parallel"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to invoke runnables in parallel"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to invoke runnables in parallel"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to invoke runnables in parallel"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to invoke runnables in parallel"}]-->
from operator import itemgetter

from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

vectorstore = FAISS.from_texts(
    ["harrison worked at kensho"], embedding=OpenAIEmbeddings()
)
retriever = vectorstore.as_retriever()

template = """Answer the question based only on the following context:
{context}

Question: {question}

Answer in the following language: {language}
"""
prompt = ChatPromptTemplate.from_template(template)

chain = (
    {
        "context": itemgetter("question") | retriever,
        "question": itemgetter("question"),
        "language": itemgetter("language"),
    }
    | prompt
    | model
    | StrOutputParser()
)

chain.invoke({"question": "where did harrison work", "language": "italian"})
```


```output
'Harrison ha lavorato a Kensho.'
```


## 단계 병렬화

RunnableParallels는 여러 Runnable을 병렬로 실행하고 이러한 Runnable의 출력을 맵으로 반환하는 것을 쉽게 만듭니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to invoke runnables in parallel"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "How to invoke runnables in parallel"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to invoke runnables in parallel"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableParallel
from langchain_openai import ChatOpenAI

model = ChatOpenAI()
joke_chain = ChatPromptTemplate.from_template("tell me a joke about {topic}") | model
poem_chain = (
    ChatPromptTemplate.from_template("write a 2-line poem about {topic}") | model
)

map_chain = RunnableParallel(joke=joke_chain, poem=poem_chain)

map_chain.invoke({"topic": "bear"})
```


```output
{'joke': AIMessage(content="Why don't bears like fast food? Because they can't catch it!", response_metadata={'token_usage': {'completion_tokens': 15, 'prompt_tokens': 13, 'total_tokens': 28}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_d9767fc5b9', 'finish_reason': 'stop', 'logprobs': None}, id='run-fe024170-c251-4b7a-bfd4-64a3737c67f2-0'),
 'poem': AIMessage(content='In the quiet of the forest, the bear roams free\nMajestic and wild, a sight to see.', response_metadata={'token_usage': {'completion_tokens': 24, 'prompt_tokens': 15, 'total_tokens': 39}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-2707913e-a743-4101-b6ec-840df4568a76-0')}
```


## 병렬성

RunnableParallel은 맵의 각 Runnable이 병렬로 실행되기 때문에 독립적인 프로세스를 병렬로 실행하는 데에도 유용합니다. 예를 들어, 이전의 `joke_chain`, `poem_chain` 및 `map_chain`은 모두 약간 비슷한 실행 시간을 가지며, `map_chain`은 다른 두 개를 모두 실행합니다.

```python
%%timeit

joke_chain.invoke({"topic": "bear"})
```

```output
610 ms ± 64 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```


```python
%%timeit

poem_chain.invoke({"topic": "bear"})
```

```output
599 ms ± 73.3 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```


```python
%%timeit

map_chain.invoke({"topic": "bear"})
```

```output
643 ms ± 77.8 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```


## 다음 단계

이제 `RunnableParallel`을 사용하여 체인 단계를 포맷하고 병렬화하는 몇 가지 방법을 알게 되었습니다.

더 배우려면 이 섹션의 다른 실행 가능성에 대한 가이드를 참조하세요.
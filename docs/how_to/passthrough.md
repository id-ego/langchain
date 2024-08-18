---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/passthrough.ipynb
description: 여러 단계로 구성된 체인에서 이전 단계의 데이터를 다음 단계로 전달하는 방법을 설명합니다. `RunnablePassthrough`
  클래스를 사용합니다.
keywords:
- RunnablePassthrough
- LCEL
sidebar_position: 5
---

# 다음 단계로 인수를 전달하는 방법

:::info 필수 조건

이 가이드는 다음 개념에 대한 이해를 가정합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [체이닝 실행 가능 객체](/docs/how_to/sequence/)
- [실행 가능 객체를 병렬로 호출하기](/docs/how_to/parallel/)
- [사용자 정의 함수](/docs/how_to/functions/)

:::

여러 단계로 구성된 체인을 작성할 때, 때때로 이전 단계에서 데이터를 변경하지 않고 다음 단계의 입력으로 사용하고 싶을 수 있습니다. [`RunnablePassthrough`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html) 클래스는 이를 가능하게 하며, 일반적으로 [RunnableParallel](/docs/how_to/parallel/)과 함께 사용되어 구성된 체인에서 데이터를 다음 단계로 전달합니다.

아래 예제를 참조하세요:

```python
%pip install -qU langchain langchain-openai

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "How to pass through arguments from one step to the next"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to pass through arguments from one step to the next"}]-->
from langchain_core.runnables import RunnableParallel, RunnablePassthrough

runnable = RunnableParallel(
    passed=RunnablePassthrough(),
    modified=lambda x: x["num"] + 1,
)

runnable.invoke({"num": 1})
```


```output
{'passed': {'num': 1}, 'modified': 2}
```


위에서 볼 수 있듯이, `passed` 키는 `RunnablePassthrough()`로 호출되어 `{'num': 1}`을 단순히 전달했습니다.

우리는 또한 `modified`라는 두 번째 키를 맵에 설정했습니다. 이는 람다를 사용하여 num에 1을 더한 단일 값을 설정하며, 그 결과 `modified` 키는 값이 `2`가 됩니다.

## 검색 예제

아래 예제에서는 체인에서 `RunnablePassthrough`와 `RunnableParallel`을 함께 사용하여 프롬프트에 대한 입력을 적절하게 형식화하는 보다 실제적인 사용 사례를 볼 수 있습니다:

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to pass through arguments from one step to the next"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to pass through arguments from one step to the next"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to pass through arguments from one step to the next"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to pass through arguments from one step to the next"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to pass through arguments from one step to the next"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to pass through arguments from one step to the next"}]-->
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


여기서 프롬프트에 대한 입력은 "context"와 "question" 키가 있는 맵으로 예상됩니다. 사용자 입력은 단지 질문입니다. 따라서 우리는 리트리버를 사용하여 컨텍스트를 가져오고 사용자 입력을 "question" 키 아래에 전달해야 합니다. `RunnablePassthrough`는 사용자의 질문을 프롬프트와 모델에 전달할 수 있게 해줍니다.

## 다음 단계

이제 체인을 통해 데이터를 전달하는 방법을 배웠으므로 체인을 통해 흐르는 데이터를 형식화하는 데 도움이 됩니다.

자세한 내용을 보려면 이 섹션의 실행 가능 객체에 대한 다른 가이드를 참조하세요.
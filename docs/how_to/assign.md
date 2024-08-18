---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/assign.ipynb
description: 체인의 상태에 값을 추가하는 방법에 대한 가이드로, LangChain 표현 언어 및 다양한 실행 가능한 기능을 활용하는 방법을
  설명합니다.
keywords:
- RunnablePassthrough
- assign
- LCEL
sidebar_position: 6
---

# 체인의 상태에 값을 추가하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [런너블 연결하기](/docs/how_to/sequence/)
- [런너블을 병렬로 호출하기](/docs/how_to/parallel/)
- [사용자 정의 함수](/docs/how_to/functions/)
- [데이터 전달하기](/docs/how_to/passthrough)

:::

체인의 단계에서 데이터를 [전달하는](https://docs/how_to/passthrough) 또 다른 방법은 주어진 키 아래에 새 값을 할당하면서 체인 상태의 현재 값을 변경하지 않는 것입니다. [`RunnablePassthrough.assign()`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html#langchain_core.runnables.passthrough.RunnablePassthrough.assign) 정적 메서드는 입력 값을 받아 할당 함수에 전달된 추가 인수를 추가합니다.

이는 나중 단계의 입력으로 사용할 사전을 추가적으로 생성하는 일반적인 [LangChain 표현 언어](/docs/concepts/#langchain-expression-language) 패턴에서 유용합니다.

예를 들어 보겠습니다:

```python
%pip install --upgrade --quiet langchain langchain-openai

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "How to add values to a chain's state"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add values to a chain's state"}]-->
from langchain_core.runnables import RunnableParallel, RunnablePassthrough

runnable = RunnableParallel(
    extra=RunnablePassthrough.assign(mult=lambda x: x["num"] * 3),
    modified=lambda x: x["num"] + 1,
)

runnable.invoke({"num": 1})
```


```output
{'extra': {'num': 1, 'mult': 3}, 'modified': 2}
```


여기서 무슨 일이 일어나고 있는지 살펴보겠습니다.

- 체인에 대한 입력은 `{"num": 1}`입니다. 이는 `RunnableParallel`에 전달되어 해당 입력으로 병렬로 런너블을 호출합니다.
- `extra` 키 아래의 값이 호출됩니다. `RunnablePassthrough.assign()`은 입력 사전의 원래 키(`{"num": 1}`)를 유지하고 `mult`라는 새 키를 할당합니다. 값은 `lambda x: x["num"] * 3)`으로, 이는 `3`입니다. 따라서 결과는 `{"num": 1, "mult": 3}`입니다.
- `{"num": 1, "mult": 3}`이 `RunnableParallel` 호출로 반환되며, `extra` 키의 값으로 설정됩니다.
- 동시에 `modified` 키가 호출됩니다. 결과는 `2`입니다. 이는 람다가 입력에서 `"num"`이라는 키를 추출하고 1을 추가하기 때문입니다.

따라서 결과는 `{'extra': {'num': 1, 'mult': 3}, 'modified': 2}`입니다.

## 스트리밍

이 방법의 편리한 기능 중 하나는 값이 사용 가능해지자마자 즉시 전달될 수 있다는 것입니다. 이를 보여주기 위해, 우리는 `RunnablePassthrough.assign()`을 사용하여 검색 체인에서 소스 문서를 즉시 반환할 것입니다:

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to add values to a chain's state"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to add values to a chain's state"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add values to a chain's state"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add values to a chain's state"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add values to a chain's state"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to add values to a chain's state"}]-->
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

generation_chain = prompt | model | StrOutputParser()

retrieval_chain = {
    "context": retriever,
    "question": RunnablePassthrough(),
} | RunnablePassthrough.assign(output=generation_chain)

stream = retrieval_chain.stream("where did harrison work?")

for chunk in stream:
    print(chunk)
```

```output
{'question': 'where did harrison work?'}
{'context': [Document(page_content='harrison worked at kensho')]}
{'output': ''}
{'output': 'H'}
{'output': 'arrison'}
{'output': ' worked'}
{'output': ' at'}
{'output': ' Kens'}
{'output': 'ho'}
{'output': '.'}
{'output': ''}
```

첫 번째 청크에는 원래의 `"question"`이 포함되어 있습니다. 이는 즉시 사용 가능하기 때문입니다. 두 번째 청크에는 `"context"`가 포함되어 있습니다. 이는 검색기가 두 번째로 완료되기 때문입니다. 마지막으로, `generation_chain`의 출력은 사용 가능해지자마자 청크로 스트리밍됩니다.

## 다음 단계

이제 체인을 통해 데이터를 전달하여 체인에서 흐르는 데이터를 형식화하는 방법을 배웠습니다.

더 알아보려면 이 섹션의 런너블에 대한 다른 가이드를 참조하세요.
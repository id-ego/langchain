---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/dynamic_chain.ipynb
description: 체인 입력에 따라 런타임에 동적으로 체인을 구성하는 방법을 설명합니다. RunnableLambda의 유용한 속성을 활용합니다.
---

# 동적(자기 생성) 체인 만드는 방법

:::info 전제 조건

이 가이드는 다음에 대한 이해를 가정합니다:
- [LangChain 표현 언어(LCEL)](/docs/concepts/#langchain-expression-language)
- [모든 함수를 실행 가능하게 만드는 방법](/docs/how_to/functions)

:::

때때로 우리는 체인 입력에 따라 런타임에 체인의 일부를 구성하고 싶습니다([라우팅](/docs/how_to/routing/)이 가장 일반적인 예입니다). 우리는 RunnableLambda의 매우 유용한 속성을 사용하여 이렇게 동적 체인을 만들 수 있습니다. 즉, RunnableLambda가 Runnable을 반환하면, 그 Runnable이 자체적으로 호출됩니다. 예를 들어 보겠습니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
/>

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to create a dynamic (self-constructing) chain"}]-->
# | echo: false

from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-sonnet-20240229")
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to create a dynamic (self-constructing) chain"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to create a dynamic (self-constructing) chain"}, {"imported": "Runnable", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html", "title": "How to create a dynamic (self-constructing) chain"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to create a dynamic (self-constructing) chain"}, {"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to create a dynamic (self-constructing) chain"}]-->
from operator import itemgetter

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable, RunnablePassthrough, chain

contextualize_instructions = """Convert the latest user question into a standalone question given the chat history. Don't answer the question, return the question and nothing else (no descriptive text)."""
contextualize_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", contextualize_instructions),
        ("placeholder", "{chat_history}"),
        ("human", "{question}"),
    ]
)
contextualize_question = contextualize_prompt | llm | StrOutputParser()

qa_instructions = (
    """Answer the user question given the following context:\n\n{context}."""
)
qa_prompt = ChatPromptTemplate.from_messages(
    [("system", qa_instructions), ("human", "{question}")]
)


@chain
def contextualize_if_needed(input_: dict) -> Runnable:
    if input_.get("chat_history"):
        # NOTE: This is returning another Runnable, not an actual output.
        return contextualize_question
    else:
        return RunnablePassthrough() | itemgetter("question")


@chain
def fake_retriever(input_: dict) -> str:
    return "egypt's population in 2024 is about 111 million"


full_chain = (
    RunnablePassthrough.assign(question=contextualize_if_needed).assign(
        context=fake_retriever
    )
    | qa_prompt
    | llm
    | StrOutputParser()
)

full_chain.invoke(
    {
        "question": "what about egypt",
        "chat_history": [
            ("human", "what's the population of indonesia"),
            ("ai", "about 276 million"),
        ],
    }
)
```


```output
"According to the context provided, Egypt's population in 2024 is estimated to be about 111 million."
```


여기서 핵심은 `contextualize_if_needed`가 실제 출력이 아닌 또 다른 Runnable을 반환한다는 것입니다. 이 반환된 Runnable은 전체 체인이 실행될 때 자체적으로 실행됩니다.

추적을 살펴보면, 우리가 chat_history를 전달했기 때문에 전체 체인의 일부로 contextualize_question 체인을 실행했음을 알 수 있습니다: https://smith.langchain.com/public/9e0ae34c-4082-4f3f-beed-34a2a2f4c991/r

반환된 Runnable의 스트리밍, 배치 처리 등의 기능이 모두 보존된다는 점에 유의하세요.

```python
for chunk in contextualize_if_needed.stream(
    {
        "question": "what about egypt",
        "chat_history": [
            ("human", "what's the population of indonesia"),
            ("ai", "about 276 million"),
        ],
    }
):
    print(chunk)
```

```output
What
 is
 the
 population
 of
 Egypt
?
```
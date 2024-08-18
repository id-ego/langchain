---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/constitutional_chain.ipynb
description: ConstitutionalChain은 LLM이 원칙에 따라 생성물을 비판하고 수정할 수 있도록 하는 구조화된 출력 기능을 활용합니다.
title: Migrating from ConstitutionalChain
---

[ConstitutionalChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.constitutional_ai.base.ConstitutionalChain.html)은 LLM이 [원칙](https://api.python.langchain.com/en/latest/chains/langchain.chains.constitutional_ai.models.ConstitutionalPrinciple.html)에 기반하여 생성물을 비판하고 수정할 수 있도록 허용합니다. 이 원칙은 비판 및 수정 요청의 조합으로 구성됩니다. 예를 들어, 원칙에는 유해한 콘텐츠를 식별하라는 요청과 콘텐츠를 다시 작성하라는 요청이 포함될 수 있습니다.

`ConstitutionalChain`에서는 이러한 비판 요청과 관련된 수정을 LLM 프롬프트로 형식화하고 문자열 응답에서 파싱하였습니다. 이는 채팅 모델의 [구조화된 출력](/docs/how_to/structured_output/) 기능을 통해 보다 자연스럽게 달성됩니다. 이 목적을 위해 [LangGraph](https://langchain-ai.github.io/langgraph/)에서 간단한 체인을 구성할 수 있습니다. 이 접근 방식의 몇 가지 장점은 다음과 같습니다:

- 이 목적을 위해 미세 조정된 채팅 모델의 도구 호출 기능 활용;
- 문자열 LLM 응답에서 표현을 추출할 때의 파싱 오류 감소;
- [메시지 역할](/docs/concepts/#messages)로 지침 위임 (예: 채팅 모델은 추가 프롬프트 없이 `ToolMessage`가 무엇을 나타내는지 이해할 수 있음);
- 개별 토큰 및 체인 단계의 스트리밍 지원.

```python
%pip install --upgrade --quiet langchain-openai
```


```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


## Legacy

<details open>

```python
<!--IMPORTS:[{"imported": "ConstitutionalChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.constitutional_ai.base.ConstitutionalChain.html", "title": "# Legacy"}, {"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "# Legacy"}, {"imported": "ConstitutionalPrinciple", "source": "langchain.chains.constitutional_ai.models", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.constitutional_ai.models.ConstitutionalPrinciple.html", "title": "# Legacy"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Legacy"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "# Legacy"}]-->
from langchain.chains import ConstitutionalChain, LLMChain
from langchain.chains.constitutional_ai.models import ConstitutionalPrinciple
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

llm = OpenAI()

qa_prompt = PromptTemplate(
    template="Q: {question} A:",
    input_variables=["question"],
)
qa_chain = LLMChain(llm=llm, prompt=qa_prompt)

constitutional_chain = ConstitutionalChain.from_llm(
    llm=llm,
    chain=qa_chain,
    constitutional_principles=[
        ConstitutionalPrinciple(
            critique_request="Tell if this answer is good.",
            revision_request="Give a better answer.",
        )
    ],
    return_intermediate_steps=True,
)

result = constitutional_chain.invoke("What is the meaning of life?")
```


```python
result
```


```output
{'question': 'What is the meaning of life?',
 'output': 'The meaning of life is a deeply personal and ever-evolving concept. It is a journey of self-discovery and growth, and can be different for each individual. Some may find meaning in relationships, others in achieving their goals, and some may never find a concrete answer. Ultimately, the meaning of life is what we make of it.',
 'initial_output': ' The meaning of life is a subjective concept that can vary from person to person. Some may believe that the purpose of life is to find happiness and fulfillment, while others may see it as a journey of self-discovery and personal growth. Ultimately, the meaning of life is something that each individual must determine for themselves.',
 'critiques_and_revisions': [('This answer is good in that it recognizes and acknowledges the subjective nature of the question and provides a valid and thoughtful response. However, it could have also mentioned that the meaning of life is a complex and deeply personal concept that can also change and evolve over time for each individual. Critique Needed.',
   'The meaning of life is a deeply personal and ever-evolving concept. It is a journey of self-discovery and growth, and can be different for each individual. Some may find meaning in relationships, others in achieving their goals, and some may never find a concrete answer. Ultimately, the meaning of life is what we make of it.')]}
```


위에서는 다음과 같은 중간 단계를 반환했습니다:

- 원래 질문;
- 초기 출력;
- 비판 및 수정;
- 최종 출력 (수정과 일치).

</details>

## LangGraph

<details open>

아래에서는 [.with_structured_output](/docs/how_to/structured_output/) 메서드를 사용하여 동시에 (1) 비판이 필요한지에 대한 판단과 (2) 비판을 생성합니다. 모든 프롬프트를 명확성과 사용자 정의 용이성을 위해 표면화합니다.

이 구현을 통해 중간 단계를 스트리밍할 수 있으므로 실행 중 모니터링하고 필요시 개입할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ConstitutionalPrinciple", "source": "langchain.chains.constitutional_ai.models", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.constitutional_ai.models.ConstitutionalPrinciple.html", "title": "# Legacy"}, {"imported": "CRITIQUE_PROMPT", "source": "langchain.chains.constitutional_ai.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.CRITIQUE_PROMPT.html", "title": "# Legacy"}, {"imported": "REVISION_PROMPT", "source": "langchain.chains.constitutional_ai.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.REVISION_PROMPT.html", "title": "# Legacy"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from typing import List, Optional, Tuple

from langchain.chains.constitutional_ai.models import ConstitutionalPrinciple
from langchain.chains.constitutional_ai.prompts import (
    CRITIQUE_PROMPT,
    REVISION_PROMPT,
)
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langgraph.graph import END, START, StateGraph
from typing_extensions import Annotated, TypedDict

llm = ChatOpenAI(model="gpt-4o-mini")


class Critique(TypedDict):
    """Generate a critique, if needed."""

    critique_needed: Annotated[bool, ..., "Whether or not a critique is needed."]
    critique: Annotated[str, ..., "If needed, the critique."]


critique_prompt = ChatPromptTemplate.from_template(
    "Critique this response according to the critique request. "
    "If no critique is needed, specify that.\n\n"
    "Query: {query}\n\n"
    "Response: {response}\n\n"
    "Critique request: {critique_request}"
)

revision_prompt = ChatPromptTemplate.from_template(
    "Revise this response according to the critique and reivsion request.\n\n"
    "Query: {query}\n\n"
    "Response: {response}\n\n"
    "Critique request: {critique_request}\n\n"
    "Critique: {critique}\n\n"
    "If the critique does not identify anything worth changing, ignore the "
    "revision request and return 'No revisions needed'. If the critique "
    "does identify something worth changing, revise the response based on "
    "the revision request.\n\n"
    "Revision Request: {revision_request}"
)

chain = llm | StrOutputParser()
critique_chain = critique_prompt | llm.with_structured_output(Critique)
revision_chain = revision_prompt | llm | StrOutputParser()


class State(TypedDict):
    query: str
    constitutional_principles: List[ConstitutionalPrinciple]
    initial_response: str
    critiques_and_revisions: List[Tuple[str, str]]
    response: str


async def generate_response(state: State):
    """Generate initial response."""
    response = await chain.ainvoke(state["query"])
    return {"response": response, "initial_response": response}


async def critique_and_revise(state: State):
    """Critique and revise response according to principles."""
    critiques_and_revisions = []
    response = state["initial_response"]
    for principle in state["constitutional_principles"]:
        critique = await critique_chain.ainvoke(
            {
                "query": state["query"],
                "response": response,
                "critique_request": principle.critique_request,
            }
        )
        if critique["critique_needed"]:
            revision = await revision_chain.ainvoke(
                {
                    "query": state["query"],
                    "response": response,
                    "critique_request": principle.critique_request,
                    "critique": critique["critique"],
                    "revision_request": principle.revision_request,
                }
            )
            response = revision
            critiques_and_revisions.append((critique["critique"], revision))
        else:
            critiques_and_revisions.append((critique["critique"], ""))
    return {
        "critiques_and_revisions": critiques_and_revisions,
        "response": response,
    }


graph = StateGraph(State)
graph.add_node("generate_response", generate_response)
graph.add_node("critique_and_revise", critique_and_revise)

graph.add_edge(START, "generate_response")
graph.add_edge("generate_response", "critique_and_revise")
graph.add_edge("critique_and_revise", END)
app = graph.compile()
```


```python
constitutional_principles = [
    ConstitutionalPrinciple(
        critique_request="Tell if this answer is good.",
        revision_request="Give a better answer.",
    )
]

query = "What is the meaning of life? Answer in 10 words or fewer."

async for step in app.astream(
    {"query": query, "constitutional_principles": constitutional_principles},
    stream_mode="values",
):
    subset = ["initial_response", "critiques_and_revisions", "response"]
    print({k: v for k, v in step.items() if k in subset})
```

```output
{}
{'initial_response': 'Finding purpose, connection, and joy in our experiences and relationships.', 'response': 'Finding purpose, connection, and joy in our experiences and relationships.'}
{'initial_response': 'Finding purpose, connection, and joy in our experiences and relationships.', 'critiques_and_revisions': [("The response exceeds the 10-word limit, providing a more elaborate answer than requested. A concise response, such as 'To seek purpose and joy in life,' would better align with the query.", 'To seek purpose and joy in life.')], 'response': 'To seek purpose and joy in life.'}
```

</details>

## Next steps

구조화된 출력을 생성하기 위한 가이드는 [여기](/docs/how_to/structured_output/)에서 확인하세요.

LangGraph로 구축하는 자세한 내용은 [LangGraph 문서](https://langchain-ai.github.io/langgraph/)를 확인하세요.
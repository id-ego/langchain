---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/multi_prompt_chain.ipynb
description: 이 문서는 `MultiPromptChain`과 `LangGraph`의 차이점을 비교하며, 각자의 기능과 장점을 설명합니다.
title: Migrating from MultiPromptChain
---

[`MultiPromptChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.router.multi_prompt.MultiPromptChain.html)는 입력 쿼리를 여러 LLMChain 중 하나로 라우팅합니다. 즉, 입력 쿼리를 기반으로 LLM을 사용하여 프롬프트 목록에서 선택하고, 쿼리를 프롬프트 형식으로 변환하여 응답을 생성합니다.

`MultiPromptChain`은 메시지 역할 및 [도구 호출](/docs/concepts/#functiontool-calling)과 같은 일반 [채팅 모델](/docs/concepts/#chat-models) 기능을 지원하지 않습니다.

[LangGraph](https://langchain-ai.github.io/langgraph/) 구현은 이 문제에 대해 여러 가지 장점을 제공합니다:

- `system` 및 기타 역할이 포함된 채팅 프롬프트 템플릿 지원;
- 라우팅 단계에서 도구 호출 사용 지원;
- 개별 단계 및 출력 토큰의 스트리밍 지원.

이제 이를 나란히 살펴보겠습니다. 이 가이드를 위해 우리는 `langchain-openai >= 0.1.20`을 사용할 것입니다.

```python
%pip install -qU langchain-core langchain-openai
```


```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


## 레거시

<details open>

```python
<!--IMPORTS:[{"imported": "MultiPromptChain", "source": "langchain.chains.router.multi_prompt", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.router.multi_prompt.MultiPromptChain.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain.chains.router.multi_prompt import MultiPromptChain
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o-mini")

prompt_1_template = """
You are an expert on animals. Please answer the below query:

{input}
"""

prompt_2_template = """
You are an expert on vegetables. Please answer the below query:

{input}
"""

prompt_infos = [
    {
        "name": "animals",
        "description": "prompt for an animal expert",
        "prompt_template": prompt_1_template,
    },
    {
        "name": "vegetables",
        "description": "prompt for a vegetable expert",
        "prompt_template": prompt_2_template,
    },
]

chain = MultiPromptChain.from_prompts(llm, prompt_infos)
```


```python
chain.invoke({"input": "What color are carrots?"})
```


```output
{'input': 'What color are carrots?',
 'text': 'Carrots are most commonly orange, but they can also be found in a variety of other colors including purple, yellow, white, and red. The orange variety is the most popular and widely recognized.'}
```


[LangSmith 추적](https://smith.langchain.com/public/e935238b-0b63-4984-abc8-873b2170a32d/r)에서 쿼리를 라우팅하기 위한 프롬프트와 최종 선택된 프롬프트를 포함한 이 과정의 두 단계를 볼 수 있습니다.

</details>

## LangGraph

<details open>

```python
pip install -qU langgraph
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from operator import itemgetter
from typing import Literal

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableConfig
from langchain_openai import ChatOpenAI
from langgraph.graph import END, START, StateGraph
from typing_extensions import TypedDict

llm = ChatOpenAI(model="gpt-4o-mini")

# Define the prompts we will route to
prompt_1 = ChatPromptTemplate.from_messages(
    [
        ("system", "You are an expert on animals."),
        ("human", "{input}"),
    ]
)
prompt_2 = ChatPromptTemplate.from_messages(
    [
        ("system", "You are an expert on vegetables."),
        ("human", "{input}"),
    ]
)

# Construct the chains we will route to. These format the input query
# into the respective prompt, run it through a chat model, and cast
# the result to a string.
chain_1 = prompt_1 | llm | StrOutputParser()
chain_2 = prompt_2 | llm | StrOutputParser()


# Next: define the chain that selects which branch to route to.
# Here we will take advantage of tool-calling features to force
# the output to select one of two desired branches.
route_system = "Route the user's query to either the animal or vegetable expert."
route_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", route_system),
        ("human", "{input}"),
    ]
)


# Define schema for output:
class RouteQuery(TypedDict):
    """Route query to destination expert."""

    destination: Literal["animal", "vegetable"]


route_chain = route_prompt | llm.with_structured_output(RouteQuery)


# For LangGraph, we will define the state of the graph to hold the query,
# destination, and final answer.
class State(TypedDict):
    query: str
    destination: RouteQuery
    answer: str


# We define functions for each node, including routing the query:
async def route_query(state: State, config: RunnableConfig):
    destination = await route_chain.ainvoke(state["query"], config)
    return {"destination": destination}


# And one node for each prompt
async def prompt_1(state: State, config: RunnableConfig):
    return {"answer": await chain_1.ainvoke(state["query"], config)}


async def prompt_2(state: State, config: RunnableConfig):
    return {"answer": await chain_2.ainvoke(state["query"], config)}


# We then define logic that selects the prompt based on the classification
def select_node(state: State) -> Literal["prompt_1", "prompt_2"]:
    if state["destination"] == "animal":
        return "prompt_1"
    else:
        return "prompt_2"


# Finally, assemble the multi-prompt chain. This is a sequence of two steps:
# 1) Select "animal" or "vegetable" via the route_chain, and collect the answer
# alongside the input query.
# 2) Route the input query to chain_1 or chain_2, based on the
# selection.
graph = StateGraph(State)
graph.add_node("route_query", route_query)
graph.add_node("prompt_1", prompt_1)
graph.add_node("prompt_2", prompt_2)

graph.add_edge(START, "route_query")
graph.add_conditional_edges("route_query", select_node)
graph.add_edge("prompt_1", END)
graph.add_edge("prompt_2", END)
app = graph.compile()
```


```python
from IPython.display import Image

Image(app.get_graph().draw_mermaid_png())
```


![](/img/167f4f7c1b53d416d949714d03c01ce8.jpg)

체인을 다음과 같이 호출할 수 있습니다:

```python
state = await app.ainvoke({"query": "what color are carrots"})
print(state["destination"])
print(state["answer"])
```

```output
{'destination': 'vegetable'}
Carrots are most commonly orange, but they can also come in a variety of other colors, including purple, red, yellow, and white. The different colors often indicate varying flavors and nutritional profiles. For example, purple carrots contain anthocyanins, while orange carrots are rich in beta-carotene, which is converted to vitamin A in the body.
```

[LangSmith 추적](https://smith.langchain.com/public/1017a9d2-2d2a-4954-a5fd-5689632b4c5f/r)에서 쿼리를 라우팅한 도구 호출과 응답 생성을 위해 선택된 프롬프트를 볼 수 있습니다.

</details>

## 개요:

- 내부적으로 `MultiPromptChain`은 LLM에 JSON 형식의 텍스트 생성을 지시하여 쿼리를 라우팅하고, 의도된 목적지를 파싱합니다. 문자열 프롬프트 템플릿의 레지스트리를 입력으로 사용합니다.
- 위에서 하위 수준의 원시를 통해 구현된 LangGraph 구현은 도구 호출을 사용하여 임의의 체인으로 라우팅합니다. 이 예제에서 체인에는 채팅 모델 템플릿과 채팅 모델이 포함됩니다.

## 다음 단계

프롬프트 템플릿, LLM 및 출력 파서로 빌드하는 방법에 대한 자세한 내용은 [이 튜토리얼](/docs/tutorials/llm_chain)을 참조하십시오.

LangGraph로 빌드하는 방법에 대한 자세한 내용은 [LangGraph 문서](https://langchain-ai.github.io/langgraph/)를 확인하십시오.
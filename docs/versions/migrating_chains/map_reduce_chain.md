---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/map_reduce_chain.ipynb
description: MapReduceDocumentsChain은 긴 텍스트를 요약하기 위해 문서를 분할하고, 각 문서를 처리한 후 결과를 통합하는
  전략입니다.
title: Migrating from MapReduceDocumentsChain
---

[MapReduceDocumentsChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.map_reduce.MapReduceDocumentsChain.html) 는 (잠재적으로 긴) 텍스트에 대한 맵-리듀스 전략을 구현합니다. 전략은 다음과 같습니다:

- 텍스트를 더 작은 문서로 나누기;
- 더 작은 문서에 프로세스 매핑하기;
- 프로세스의 결과를 최종 결과로 축소 또는 통합하기.

맵 단계는 일반적으로 입력 문서에 대해 병렬화됩니다.

이 맥락에서 적용되는 일반적인 프로세스는 요약이며, 여기서 맵 단계는 개별 문서를 요약하고, 리듀스 단계는 요약의 요약을 생성합니다.

리듀스 단계에서 `MapReduceDocumentsChain`은 요약의 재귀적 "축소"를 지원합니다: 입력은 토큰 제한에 따라 분할되고, 분할의 요약이 생성됩니다. 이 단계는 요약의 총 길이가 원하는 제한 내에 있을 때까지 반복되며, 임의 길이의 텍스트 요약이 가능합니다. 이는 작은 컨텍스트 윈도우를 가진 모델에 특히 유용합니다.

LangGraph는 [map-reduce](https://langchain-ai.github.io/langgraph/how-tos/map-reduce/) 워크플로우를 지원하며, 이 문제에 대해 여러 가지 이점을 제공합니다:

- LangGraph는 개별 단계(예: 연속 요약)를 스트리밍할 수 있어 실행 제어를 더 높일 수 있습니다;
- LangGraph의 [체크포인팅](https://langchain-ai.github.io/langgraph/how-tos/persistence/)은 오류 복구를 지원하며, 인간이 개입하는 워크플로우로 확장되고, 대화형 애플리케이션에 더 쉽게 통합됩니다.
- LangGraph 구현은 아래에서 볼 수 있듯이 확장하기가 더 쉽습니다.

아래에서는 `MapReduceDocumentsChain`과 해당 LangGraph 구현을 살펴보겠습니다. 먼저 간단한 예제를 통해 설명하고, 두 번째로 재귀적 리듀스 단계를 시연하기 위해 긴 예제 텍스트를 사용합니다.

먼저 채팅 모델을 로드해 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


## 기본 예제 (짧은 문서)

설명을 위해 간단한 문서를 생성해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "# Basic example (short documents)"}]-->
from langchain_core.documents import Document

documents = [
    Document(page_content="Apples are red", metadata={"title": "apple_book"}),
    Document(page_content="Blueberries are blue", metadata={"title": "blueberry_book"}),
    Document(page_content="Bananas are yelow", metadata={"title": "banana_book"}),
]
```


### 레거시

<details open>

아래에서는 `MapReduceDocumentsChain`을 사용한 구현을 보여줍니다. 우리는 맵 및 리듀스 단계에 대한 프롬프트 템플릿을 정의하고, 이러한 단계에 대한 개별 체인을 인스턴스화한 다음, 마지막으로 `MapReduceDocumentsChain`을 인스턴스화합니다:

```python
<!--IMPORTS:[{"imported": "MapReduceDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.map_reduce.MapReduceDocumentsChain.html", "title": "# Basic example (short documents)"}, {"imported": "ReduceDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.reduce.ReduceDocumentsChain.html", "title": "# Basic example (short documents)"}, {"imported": "StuffDocumentsChain", "source": "langchain.chains.combine_documents.stuff", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.StuffDocumentsChain.html", "title": "# Basic example (short documents)"}, {"imported": "LLMChain", "source": "langchain.chains.llm", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "# Basic example (short documents)"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Basic example (short documents)"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "# Basic example (short documents)"}]-->
from langchain.chains import MapReduceDocumentsChain, ReduceDocumentsChain
from langchain.chains.combine_documents.stuff import StuffDocumentsChain
from langchain.chains.llm import LLMChain
from langchain_core.prompts import ChatPromptTemplate
from langchain_text_splitters import CharacterTextSplitter

# Map
map_template = "Write a concise summary of the following: {docs}."
map_prompt = ChatPromptTemplate([("human", map_template)])
map_chain = LLMChain(llm=llm, prompt=map_prompt)


# Reduce
reduce_template = """
The following is a set of summaries:
{docs}
Take these and distill it into a final, consolidated summary
of the main themes.
"""
reduce_prompt = ChatPromptTemplate([("human", reduce_template)])
reduce_chain = LLMChain(llm=llm, prompt=reduce_prompt)


# Takes a list of documents, combines them into a single string, and passes this to an LLMChain
combine_documents_chain = StuffDocumentsChain(
    llm_chain=reduce_chain, document_variable_name="docs"
)

# Combines and iteratively reduces the mapped documents
reduce_documents_chain = ReduceDocumentsChain(
    # This is final chain that is called.
    combine_documents_chain=combine_documents_chain,
    # If documents exceed context for `StuffDocumentsChain`
    collapse_documents_chain=combine_documents_chain,
    # The maximum number of tokens to group documents into.
    token_max=1000,
)

# Combining documents by mapping a chain over them, then combining results
map_reduce_chain = MapReduceDocumentsChain(
    # Map chain
    llm_chain=map_chain,
    # Reduce chain
    reduce_documents_chain=reduce_documents_chain,
    # The variable name in the llm_chain to put the documents in
    document_variable_name="docs",
    # Return the results of the map steps in the output
    return_intermediate_steps=False,
)
```


```python
result = map_reduce_chain.invoke(documents)

print(result["output_text"])
```

```output
Fruits come in a variety of colors, with apples being red, blueberries being blue, and bananas being yellow.
```

[LangSmith trace](https://smith.langchain.com/public/8d88a2c0-5d26-41f6-9176-d06549b17aa6/r)에서 우리는 네 개의 LLM 호출을 관찰합니다: 세 개의 입력 문서를 각각 요약하는 하나와 요약을 요약하는 하나입니다.

</details>


### LangGraph

아래에서는 위와 동일한 프롬프트 템플릿을 사용한 LangGraph 구현을 보여줍니다. 그래프에는 요약을 생성하는 노드가 포함되어 있으며, 이는 입력 문서 목록에 매핑됩니다. 이 노드는 최종 요약을 생성하는 두 번째 노드로 흐릅니다.

<details open>

우리는 `langgraph`를 설치해야 합니다:

```python
pip install -qU langgraph
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "# Basic example (short documents)"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Basic example (short documents)"}]-->
import operator
from typing import Annotated, List, TypedDict

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langgraph.constants import Send
from langgraph.graph import END, START, StateGraph

map_template = "Write a concise summary of the following: {context}."

reduce_template = """
The following is a set of summaries:
{docs}
Take these and distill it into a final, consolidated summary
of the main themes.
"""

map_prompt = ChatPromptTemplate([("human", map_template)])
reduce_prompt = ChatPromptTemplate([("human", reduce_template)])

map_chain = map_prompt | llm | StrOutputParser()
reduce_chain = reduce_prompt | llm | StrOutputParser()

# Graph components: define the components that will make up the graph


# This will be the overall state of the main graph.
# It will contain the input document contents, corresponding
# summaries, and a final summary.
class OverallState(TypedDict):
    # Notice here we use the operator.add
    # This is because we want combine all the summaries we generate
    # from individual nodes back into one list - this is essentially
    # the "reduce" part
    contents: List[str]
    summaries: Annotated[list, operator.add]
    final_summary: str


# This will be the state of the node that we will "map" all
# documents to in order to generate summaries
class SummaryState(TypedDict):
    content: str


# Here we generate a summary, given a document
async def generate_summary(state: SummaryState):
    response = await map_chain.ainvoke(state["content"])
    return {"summaries": [response]}


# Here we define the logic to map out over the documents
# We will use this an edge in the graph
def map_summaries(state: OverallState):
    # We will return a list of `Send` objects
    # Each `Send` object consists of the name of a node in the graph
    # as well as the state to send to that node
    return [
        Send("generate_summary", {"content": content}) for content in state["contents"]
    ]


# Here we will generate the final summary
async def generate_final_summary(state: OverallState):
    response = await reduce_chain.ainvoke(state["summaries"])
    return {"final_summary": response}


# Construct the graph: here we put everything together to construct our graph
graph = StateGraph(OverallState)
graph.add_node("generate_summary", generate_summary)
graph.add_node("generate_final_summary", generate_final_summary)
graph.add_conditional_edges(START, map_summaries, ["generate_summary"])
graph.add_edge("generate_summary", "generate_final_summary")
graph.add_edge("generate_final_summary", END)
app = graph.compile()
```


```python
from IPython.display import Image

Image(app.get_graph().draw_mermaid_png())
```


![](/img/f3f56d7b90c0634330fd3afafc7525ea.jpg)

스트리밍 모드에서 그래프를 호출하면 단계 모니터링 및 실행 중 조치를 취할 수 있습니다.

```python
# Call the graph:
async for step in app.astream({"contents": [doc.page_content for doc in documents]}):
    print(step)
```

```output
{'generate_summary': {'summaries': ['Apples are typically red in color.']}}
{'generate_summary': {'summaries': ['Bananas are yellow in color.']}}
{'generate_summary': {'summaries': ['Blueberries are a type of fruit that are blue in color.']}}
{'generate_final_summary': {'final_summary': 'The main themes are the colors of different fruits: apples are red, blueberries are blue, and bananas are yellow.'}}
```

[LangSmith trace](https://smith.langchain.com/public/8ecbe9fd-eb02-4c6e-90ae-659952c9360a/r)에서 우리는 이전과 동일한 네 개의 LLM 호출을 복구합니다.

</details>


## 긴 문서 요약하기

맵-리듀스 흐름은 텍스트가 LLM의 컨텍스트 윈도우에 비해 길 때 특히 유용합니다. `MapReduceDocumentsChain`은 요약의 재귀적 "축소"를 지원합니다: 입력은 토큰 제한에 따라 분할되고, 분할의 요약이 생성됩니다. 이 단계는 요약의 총 길이가 원하는 제한 내에 있을 때까지 반복되며, 임의 길이의 텍스트 요약이 가능합니다.

이 "축소" 단계는 `MapReduceDocumentsChain` 내에서 `while` 루프로 구현됩니다. 우리는 Lilian Weng의 [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) 블로그 게시물( [RAG 튜토리얼](/docs/tutorials/rag) 및 기타 문서에 소개됨)에서 이 단계를 긴 텍스트로 시연할 수 있습니다.

먼저 게시물을 로드하고 더 작은 "하위 문서"로 분할합니다:

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "# Basic example (short documents)"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "# Basic example (short documents)"}]-->
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import CharacterTextSplitter

loader = WebBaseLoader("https://lilianweng.github.io/posts/2023-06-23-agent/")
documents = loader.load()

text_splitter = CharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=1000, chunk_overlap=0
)
split_docs = text_splitter.split_documents(documents)
print(f"Generated {len(split_docs)} documents.")
```

```output
USER_AGENT environment variable not set, consider setting it to identify your requests.
Created a chunk of size 1003, which is longer than the specified 1000
``````output
Generated 14 documents.
```

### 레거시

<details open>
우리는 이전과 같이 `MapReduceDocumentsChain`을 호출할 수 있습니다:

```python
result = map_reduce_chain.invoke(split_docs)

print(result["output_text"])
```

```output
The article discusses the use of Large Language Models (LLMs) to power autonomous agents in various tasks, showcasing their capabilities in problem-solving beyond generating written content. Key components such as planning, memory optimization, and tool use are explored, with proof-of-concept demos like AutoGPT and GPT-Engineer demonstrating the potential of LLM-powered agents. Challenges include limitations in historical information retention and natural language interface reliability, while the potential of LLMs in enhancing reasoning, problem-solving, and planning proficiency for autonomous agents is highlighted. Overall, the article emphasizes the versatility and power of LLMs in creating intelligent agents for tasks like scientific discovery and experiment design.
```

위의 호출에 대한 [LangSmith trace](https://smith.langchain.com/public/d8b3311d-2220-487a-8eaf-104ef90678dd/r)를 고려해 보십시오. `ReduceDocumentsChain`을 인스턴스화할 때, 우리는 1,000 토큰의 `token_max`를 설정합니다. 이로 인해 총 17개의 LLM 호출이 발생합니다:

- 14개의 호출은 텍스트 분할기에서 생성된 14개의 하위 문서를 요약하는 것입니다.
- 이는 약 1,000 - 2,000 토큰에 해당하는 요약을 생성했습니다. 우리는 `token_max`를 1,000으로 설정했기 때문에, 이러한 요약을 요약(또는 "축소")하기 위해 두 번 더 호출이 필요합니다.
- 마지막 호출은 두 개의 "축소된" 요약의 최종 요약을 생성하는 것입니다.

</details>


### LangGraph

<details open>
우리는 LangGraph에서 원래의 맵-리듀스 구현을 확장하여 동일한 재귀적 축소 단계를 구현할 수 있습니다. 우리는 다음과 같은 변경을 합니다:

- 축소된 요약을 저장하기 위해 상태에 `collapsed_summaries` 키를 추가합니다;
- 최종 요약 노드를 업데이트하여 축소된 요약을 요약합니다;
- 문서 목록을 토큰 길이에 따라 분할하고(여기서는 1,000 토큰) 각 분할의 요약을 생성하여 결과를 `collapsed_summaries`에 저장하는 `collapse_summaries` 노드를 추가합니다.

우리는 `collapse_summaries`에서 자기 자신으로의 조건부 엣지를 추가하여 루프를 형성합니다: 축소된 요약의 총 길이가 `token_max`를 초과하면, 노드를 다시 실행합니다.

```python
<!--IMPORTS:[{"imported": "acollapse_docs", "source": "langchain.chains.combine_documents.reduce", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.reduce.acollapse_docs.html", "title": "# Basic example (short documents)"}, {"imported": "split_list_of_docs", "source": "langchain.chains.combine_documents.reduce", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.reduce.split_list_of_docs.html", "title": "# Basic example (short documents)"}]-->
from typing import Literal

from langchain.chains.combine_documents.reduce import (
    acollapse_docs,
    split_list_of_docs,
)


def length_function(documents: List[Document]) -> int:
    """Get number of tokens for input contents."""
    return sum(llm.get_num_tokens(doc.page_content) for doc in documents)


token_max = 1000


class OverallState(TypedDict):
    contents: List[str]
    summaries: Annotated[list, operator.add]
    collapsed_summaries: List[Document]  # add key for collapsed summaries
    final_summary: str


# Add node to store summaries for collapsing
def collect_summaries(state: OverallState):
    return {
        "collapsed_summaries": [Document(summary) for summary in state["summaries"]]
    }


# Modify final summary to read off collapsed summaries
async def generate_final_summary(state: OverallState):
    response = await reduce_chain.ainvoke(state["collapsed_summaries"])
    return {"final_summary": response}


graph = StateGraph(OverallState)
graph.add_node("generate_summary", generate_summary)  # same as before
graph.add_node("collect_summaries", collect_summaries)
graph.add_node("generate_final_summary", generate_final_summary)


# Add node to collapse summaries
async def collapse_summaries(state: OverallState):
    doc_lists = split_list_of_docs(
        state["collapsed_summaries"], length_function, token_max
    )
    results = []
    for doc_list in doc_lists:
        results.append(await acollapse_docs(doc_list, reduce_chain.ainvoke))

    return {"collapsed_summaries": results}


graph.add_node("collapse_summaries", collapse_summaries)


def should_collapse(
    state: OverallState,
) -> Literal["collapse_summaries", "generate_final_summary"]:
    num_tokens = length_function(state["collapsed_summaries"])
    if num_tokens > token_max:
        return "collapse_summaries"
    else:
        return "generate_final_summary"


graph.add_conditional_edges(START, map_summaries, ["generate_summary"])
graph.add_edge("generate_summary", "collect_summaries")
graph.add_conditional_edges("collect_summaries", should_collapse)
graph.add_conditional_edges("collapse_summaries", should_collapse)
graph.add_edge("generate_final_summary", END)
app = graph.compile()
```


LangGraph는 그래프 구조를 플로팅하여 기능을 시각화하는 데 도움을 줍니다:

```python
from IPython.display import Image

Image(app.get_graph().draw_mermaid_png())
```


![](/img/5e012481506abca60d4dc12b1116bcaa.jpg)

이전과 같이 그래프를 스트리밍하여 단계의 순서를 관찰할 수 있습니다. 아래에서는 단순히 단계의 이름을 출력합니다.

그래프에 루프가 있기 때문에, 실행 시 [recursion_limit](https://langchain-ai.github.io/langgraph/reference/errors/#langgraph.errors.GraphRecursionError)를 지정하는 것이 유용할 수 있습니다. 이는 [ReduceDocumentsChain.token_max](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.reduce.ReduceDocumentsChain.html#langchain.chains.combine_documents.reduce.ReduceDocumentsChain.token_max)와 유사하여 지정된 제한이 초과될 때 특정 오류를 발생시킵니다.

```python
async for step in app.astream(
    {"contents": [doc.page_content for doc in split_docs]},
    {"recursion_limit": 10},
):
    print(list(step.keys()))
```

```output
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['generate_summary']
['collect_summaries']
['collapse_summaries']
['generate_final_summary']
```


```python
print(step)
```

```output
{'generate_final_summary': {'final_summary': 'The summaries discuss the use of Large Language Models (LLMs) to power autonomous agents in various tasks such as problem-solving, planning, and tool use. Key components like planning, memory, and task decomposition are highlighted, along with challenges such as inefficient planning and hallucination. Techniques like Algorithm Distillation and Maximum Inner Product Search are explored for optimization, while frameworks like ReAct and Reflexion show improvements in knowledge-intensive tasks. The importance of accurate interpretation of user input and well-structured code for functional autonomy is emphasized, along with the potential of LLMs in prompting, reasoning, and emergent social behavior in simulation environments. Challenges in real-world scenarios and the use of LLMs with expert-designed tools for tasks like organic synthesis and drug discovery are also discussed.'}}
```

해당 [LangSmith trace](https://smith.langchain.com/public/9d7b1d50-e1d6-44c9-9ab2-eabef621c883/r)에서 우리는 이전과 동일한 17개의 LLM 호출을 볼 수 있으며, 이번에는 각 노드 아래에 그룹화되어 있습니다.

</details>


## 다음 단계

LangGraph로 구축하는 방법에 대한 자세한 내용은 [LangGraph 문서](https://langchain-ai.github.io/langgraph/)를 확인하고, LangGraph의 맵-리듀스 세부 사항에 대한 [이 가이드](https://langchain-ai.github.io/langgraph/how-tos/map-reduce/)를 참조하십시오.

LLM 기반 요약 전략에 대한 [이 튜토리얼](/docs/tutorials/summarization/)을 확인하십시오.
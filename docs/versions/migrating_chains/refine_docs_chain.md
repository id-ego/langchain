---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/refine_docs_chain.ipynb
description: RefineDocumentsChain은 긴 텍스트를 분석하기 위한 전략으로, 문서를 나누고 요약을 통해 결과를 개선하는 과정을
  포함합니다.
title: Migrating from RefineDocumentsChain
---

[RefineDocumentsChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.refine.RefineDocumentsChain.html)은 긴 텍스트를 분석하기 위한 전략을 구현합니다. 전략은 다음과 같습니다:

- 텍스트를 더 작은 문서로 나누기;
- 첫 번째 문서에 프로세스 적용하기;
- 다음 문서를 기반으로 결과를 정제하거나 업데이트하기;
- 완료될 때까지 문서의 순서를 반복하기.

이 맥락에서 적용되는 일반적인 프로세스는 요약으로, 긴 텍스트의 조각을 진행하면서 실행 중인 요약을 수정합니다. 이는 주어진 LLM의 컨텍스트 창에 비해 큰 텍스트에 특히 유용합니다.

[LangGraph](https://langchain-ai.github.io/langgraph/) 구현은 이 문제에 대해 여러 가지 장점을 제공합니다:

- `RefineDocumentsChain`이 클래스 내부의 `for` 루프를 통해 요약을 정제하는 반면, LangGraph 구현은 필요에 따라 실행을 모니터링하거나 조정할 수 있도록 단계별로 진행할 수 있습니다.
- LangGraph 구현은 실행 단계와 개별 토큰의 스트리밍을 지원합니다.
- 모듈형 구성 요소로 조립되어 있기 때문에 [도구 호출](/docs/concepts/#functiontool-calling) 또는 기타 동작을 통합하는 등의 확장이나 수정이 간단합니다.

아래에서는 설명을 위해 간단한 예제를 통해 `RefineDocumentsChain`과 해당 LangGraph 구현을 살펴보겠습니다.

먼저 채팅 모델을 로드해 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


## 예제

문서의 시퀀스를 요약하는 예제를 살펴보겠습니다. 설명을 위해 간단한 문서를 먼저 생성합니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "# Example"}]-->
from langchain_core.documents import Document

documents = [
    Document(page_content="Apples are red", metadata={"title": "apple_book"}),
    Document(page_content="Blueberries are blue", metadata={"title": "blueberry_book"}),
    Document(page_content="Bananas are yelow", metadata={"title": "banana_book"}),
]
```


### 레거시

<details open>


아래에서는 `RefineDocumentsChain`을 사용한 구현을 보여줍니다. 초기 요약 및 후속 정제를 위한 프롬프트 템플릿을 정의하고, 이 두 가지 목적을 위해 별도의 [LLMChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html) 객체를 인스턴스화하며, 이러한 구성 요소로 `RefineDocumentsChain`을 인스턴스화합니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "# Example"}, {"imported": "RefineDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.refine.RefineDocumentsChain.html", "title": "# Example"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Example"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Example"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Example"}]-->
from langchain.chains import LLMChain, RefineDocumentsChain
from langchain_core.prompts import ChatPromptTemplate, PromptTemplate
from langchain_openai import ChatOpenAI

# This controls how each document will be formatted. Specifically,
# it will be passed to `format_document` - see that function for more
# details.
document_prompt = PromptTemplate(
    input_variables=["page_content"], template="{page_content}"
)
document_variable_name = "context"
# The prompt here should take as an input variable the
# `document_variable_name`
summarize_prompt = ChatPromptTemplate(
    [
        ("human", "Write a concise summary of the following: {context}"),
    ]
)
initial_llm_chain = LLMChain(llm=llm, prompt=summarize_prompt)
initial_response_name = "existing_answer"
# The prompt here should take as an input variable the
# `document_variable_name` as well as `initial_response_name`
refine_template = """
Produce a final summary.

Existing summary up to this point:
{existing_answer}

New context:
------------
{context}
------------

Given the new context, refine the original summary.
"""
refine_prompt = ChatPromptTemplate([("human", refine_template)])
refine_llm_chain = LLMChain(llm=llm, prompt=refine_prompt)
chain = RefineDocumentsChain(
    initial_llm_chain=initial_llm_chain,
    refine_llm_chain=refine_llm_chain,
    document_prompt=document_prompt,
    document_variable_name=document_variable_name,
    initial_response_name=initial_response_name,
)
```


이제 체인을 호출할 수 있습니다:

```python
result = chain.invoke(documents)
result["output_text"]
```


```output
'Apples are typically red in color, blueberries are blue, and bananas are yellow.'
```


[LangSmith trace](https://smith.langchain.com/public/8ec51479-9420-412f-bb21-cb8c9f59dfde/r)는 초기 요약을 위한 하나의 LLM 호출과 그 요약을 업데이트하는 두 개의 호출로 구성됩니다. 최종 문서의 내용을 사용하여 요약을 업데이트할 때 프로세스가 완료됩니다.

</details>


### LangGraph

<details open>


아래에서는 이 프로세스의 LangGraph 구현을 보여줍니다:

- 이전과 동일한 두 개의 템플릿을 사용합니다.
- 첫 번째 문서를 추출하고 이를 프롬프트로 포맷하여 LLM으로 추론을 실행하는 초기 요약을 위한 간단한 체인을 생성합니다.
- 초기 요약을 정제하는 각 후속 문서에서 작동하는 두 번째 `refine_summary_chain`을 생성합니다.

`langgraph`를 설치해야 합니다:

```python
pip install -qU langgraph
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "# Example"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Example"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "# Example"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Example"}]-->
import operator
from typing import List, Literal, TypedDict

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableConfig
from langchain_openai import ChatOpenAI
from langgraph.constants import Send
from langgraph.graph import END, START, StateGraph

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

# Initial summary
summarize_prompt = ChatPromptTemplate(
    [
        ("human", "Write a concise summary of the following: {context}"),
    ]
)
initial_summary_chain = summarize_prompt | llm | StrOutputParser()

# Refining the summary with new docs
refine_template = """
Produce a final summary.

Existing summary up to this point:
{existing_answer}

New context:
------------
{context}
------------

Given the new context, refine the original summary.
"""
refine_prompt = ChatPromptTemplate([("human", refine_template)])

refine_summary_chain = refine_prompt | llm | StrOutputParser()


# For LangGraph, we will define the state of the graph to hold the query,
# destination, and final answer.
class State(TypedDict):
    contents: List[str]
    index: int
    summary: str


# We define functions for each node, including a node that generates
# the initial summary:
async def generate_initial_summary(state: State, config: RunnableConfig):
    summary = await initial_summary_chain.ainvoke(
        state["contents"][0],
        config,
    )
    return {"summary": summary, "index": 1}


# And a node that refines the summary based on the next document
async def refine_summary(state: State, config: RunnableConfig):
    content = state["contents"][state["index"]]
    summary = await refine_summary_chain.ainvoke(
        {"existing_answer": state["summary"], "context": content},
        config,
    )

    return {"summary": summary, "index": state["index"] + 1}


# Here we implement logic to either exit the application or refine
# the summary.
def should_refine(state: State) -> Literal["refine_summary", END]:
    if state["index"] >= len(state["contents"]):
        return END
    else:
        return "refine_summary"


graph = StateGraph(State)
graph.add_node("generate_initial_summary", generate_initial_summary)
graph.add_node("refine_summary", refine_summary)

graph.add_edge(START, "generate_initial_summary")
graph.add_conditional_edges("generate_initial_summary", should_refine)
graph.add_conditional_edges("refine_summary", should_refine)
app = graph.compile()
```


```python
from IPython.display import Image

Image(app.get_graph().draw_mermaid_png())
```


![](/img/25f912b8bd6c29a6818aa760ebf47b27.jpg)

다음과 같이 실행을 단계별로 진행하며 요약이 정제되는 과정을 출력할 수 있습니다:

```python
async for step in app.astream(
    {"contents": [doc.page_content for doc in documents]},
    stream_mode="values",
):
    if summary := step.get("summary"):
        print(summary)
```

```output
Apples are typically red in color.
Apples are typically red in color, while blueberries are blue.
Apples are typically red in color, blueberries are blue, and bananas are yellow.
```

[LangSmith trace](https://smith.langchain.com/public/d6656f49-4fa1-44b9-b6d3-10af921037fa/r)에서도 세 개의 LLM 호출을 다시 확인할 수 있으며, 이전과 동일한 기능을 수행합니다.

중간 단계에서 애플리케이션으로부터 토큰을 스트리밍할 수 있다는 점에 유의하세요:

```python
async for event in app.astream_events(
    {"contents": [doc.page_content for doc in documents]}, version="v2"
):
    kind = event["event"]
    if kind == "on_chat_model_stream":
        content = event["data"]["chunk"].content
        if content:
            print(content, end="|")
    elif kind == "on_chat_model_end":
        print("\n\n")
```

```output
Ap|ples| are| characterized| by| their| red| color|.|


Ap|ples| are| characterized| by| their| red| color|,| while| blueberries| are| known| for| their| blue| hue|.|


Ap|ples| are| characterized| by| their| red| color|,| blueberries| are| known| for| their| blue| hue|,| and| bananas| are| recognized| for| their| yellow| color|.|
```

</details>


## 다음 단계

LLM 기반 요약 전략에 대한 [이 튜토리얼](/docs/tutorials/summarization/)을 참조하세요.

LangGraph로 빌드하는 방법에 대한 자세한 내용은 [LangGraph 문서](https://langchain-ai.github.io/langgraph/)를 확인하세요.
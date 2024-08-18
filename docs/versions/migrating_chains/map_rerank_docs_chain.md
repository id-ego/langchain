---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/map_rerank_docs_chain.ipynb
description: 이 문서는 MapRerankDocumentsChain의 전략과 LangGraph 구현을 통해 긴 텍스트 분석 및 질문-답변
  프로세스를 설명합니다.
title: Migrating from MapRerankDocumentsChain
---

[MapRerankDocumentsChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.map_rerank.MapRerankDocumentsChain.html)은 긴 텍스트를 분석하기 위한 전략을 구현합니다. 전략은 다음과 같습니다:

- 텍스트를 더 작은 문서로 나누기;
- 문서 집합에 프로세스를 매핑하고, 이 프로세스에는 점수 생성이 포함됨;
- 점수에 따라 결과를 순위 매기고 최대값을 반환.

이 시나리오에서 일반적인 프로세스는 문서의 맥락 조각을 사용한 질문-답변입니다. 모델이 답변과 함께 점수를 생성하도록 강제하는 것은 관련 맥락에 의해 생성된 답변을 선택하는 데 도움이 됩니다.

[LangGraph](https://langchain-ai.github.io/langgraph/) 구현은 이 문제에 대해 [도구 호출](/docs/concepts/#functiontool-calling) 및 기타 기능을 통합할 수 있게 해줍니다. 아래에서는 `MapRerankDocumentsChain`과 이에 해당하는 LangGraph 구현을 간단한 예제를 통해 설명하겠습니다.

## 예제

문서 집합을 분석하는 예제를 살펴보겠습니다. 설명을 위해 간단한 문서를 먼저 생성합니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "# Example"}]-->
from langchain_core.documents import Document

documents = [
    Document(page_content="Alice has blue eyes", metadata={"title": "book_chapter_2"}),
    Document(page_content="Bob has brown eyes", metadata={"title": "book_chapter_1"}),
    Document(
        page_content="Charlie has green eyes", metadata={"title": "book_chapter_3"}
    ),
]
```


### 레거시

<details open>

아래에서는 `MapRerankDocumentsChain`을 사용한 구현을 보여줍니다. 질문-답변 작업을 위한 프롬프트 템플릿을 정의하고, 이를 위해 [LLMChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html) 객체를 인스턴스화합니다. 문서가 프롬프트에 어떻게 포맷되는지 정의하고, 다양한 프롬프트의 키 간 일관성을 보장합니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "# Example"}, {"imported": "MapRerankDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.map_rerank.MapRerankDocumentsChain.html", "title": "# Example"}, {"imported": "RegexParser", "source": "langchain.output_parsers.regex", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain.output_parsers.regex.RegexParser.html", "title": "# Example"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Example"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "# Example"}]-->
from langchain.chains import LLMChain, MapRerankDocumentsChain
from langchain.output_parsers.regex import RegexParser
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

document_variable_name = "context"
llm = OpenAI()
# The prompt here should take as an input variable the
# `document_variable_name`
# The actual prompt will need to be a lot more complex, this is just
# an example.
prompt_template = (
    "What color are Bob's eyes? "
    "Output both your answer and a score (1-10) of how confident "
    "you are in the format: <Answer>\nScore: <Score>.\n\n"
    "Provide no other commentary.\n\n"
    "Context: {context}"
)
output_parser = RegexParser(
    regex=r"(.*?)\nScore: (.*)",
    output_keys=["answer", "score"],
)
prompt = PromptTemplate(
    template=prompt_template,
    input_variables=["context"],
    output_parser=output_parser,
)
llm_chain = LLMChain(llm=llm, prompt=prompt)
chain = MapRerankDocumentsChain(
    llm_chain=llm_chain,
    document_variable_name=document_variable_name,
    rank_key="score",
    answer_key="answer",
)
```


```python
response = chain.invoke(documents)
response["output_text"]
```

```output
/langchain/libs/langchain/langchain/chains/llm.py:369: UserWarning: The apply_and_parse method is deprecated, instead pass an output parser directly to LLMChain.
  warnings.warn(
```


```output
'Brown'
```


위 실행에 대한 [LangSmith trace](https://smith.langchain.com/public/7a071bd1-0283-4b90-898c-6e4a2b5a0593/r)를 검사하면, 각 문서에 대해 하나씩 총 세 번의 LLM 호출이 있었고, 점수 매기기 메커니즘이 환각을 완화했음을 알 수 있습니다.

</details>

### LangGraph

<details open>

아래에서는 이 프로세스의 LangGraph 구현을 보여줍니다. 우리의 템플릿은 단순화되어 있으며, 포맷팅 지침을 채팅 모델의 도구 호출 기능에 위임합니다 [.with_structured_output](/docs/how_to/structured_output/) 메서드를 통해.

여기서는 기본 [map-reduce](https://langchain-ai.github.io/langgraph/how-tos/map-reduce/) 워크플로우를 따라 LLM 호출을 병렬로 실행합니다.

`langgraph`를 설치해야 합니다:

```python
pip install -qU langgraph
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Example"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Example"}]-->
import operator
from typing import Annotated, List, TypedDict

from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langgraph.constants import Send
from langgraph.graph import END, START, StateGraph


class AnswerWithScore(TypedDict):
    answer: str
    score: Annotated[int, ..., "Score from 1-10."]


llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

prompt_template = "What color are Bob's eyes?\n\n" "Context: {context}"
prompt = ChatPromptTemplate.from_template(prompt_template)

# The below chain formats context from a document into a prompt, then
# generates a response structured according to the AnswerWithScore schema.
map_chain = prompt | llm.with_structured_output(AnswerWithScore)

# Below we define the components that will make up the graph


# This will be the overall state of the graph.
# It will contain the input document contents, corresponding
# answers with scores, and a final answer.
class State(TypedDict):
    contents: List[str]
    answers_with_scores: Annotated[list, operator.add]
    answer: str


# This will be the state of the node that we will "map" all
# documents to in order to generate answers with scores
class MapState(TypedDict):
    content: str


# Here we define the logic to map out over the documents
# We will use this an edge in the graph
def map_analyses(state: State):
    # We will return a list of `Send` objects
    # Each `Send` object consists of the name of a node in the graph
    # as well as the state to send to that node
    return [
        Send("generate_analysis", {"content": content}) for content in state["contents"]
    ]


# Here we generate an answer with score, given a document
async def generate_analysis(state: MapState):
    response = await map_chain.ainvoke(state["content"])
    return {"answers_with_scores": [response]}


# Here we will select the top answer
def pick_top_ranked(state: State):
    ranked_answers = sorted(
        state["answers_with_scores"], key=lambda x: -int(x["score"])
    )
    return {"answer": ranked_answers[0]}


# Construct the graph: here we put everything together to construct our graph
graph = StateGraph(State)
graph.add_node("generate_analysis", generate_analysis)
graph.add_node("pick_top_ranked", pick_top_ranked)
graph.add_conditional_edges(START, map_analyses, ["generate_analysis"])
graph.add_edge("generate_analysis", "pick_top_ranked")
graph.add_edge("pick_top_ranked", END)
app = graph.compile()
```


```python
from IPython.display import Image

Image(app.get_graph().draw_mermaid_png())
```


![](/img/8e2154549da7bbbf4d5bc287a2ce627e.jpg)

```python
result = await app.ainvoke({"contents": [doc.page_content for doc in documents]})
result["answer"]
```


```output
{'answer': 'Bob has brown eyes.', 'score': 10}
```


위 실행에 대한 [LangSmith trace](https://smith.langchain.com/public/b64bf9aa-7558-4c1b-be5c-ba8924069039/r)를 검사하면, 이전과 같이 세 번의 LLM 호출이 있었음을 알 수 있습니다. 모델의 도구 호출 기능을 사용함으로써 파싱 단계를 제거할 수 있었습니다.

</details>

## 다음 단계

질문-답변 작업에 대한 RAG에 대한 더 많은 정보는 이 [사용 가이드](/docs/how_to/#qa-with-rag)를 참조하세요.

LangGraph로 구축하는 방법에 대한 자세한 내용은 [LangGraph 문서](https://langchain-ai.github.io/langgraph/)를 확인하고, LangGraph의 map-reduce 세부 사항에 대한 [이 가이드](https://langchain-ai.github.io/langgraph/how-tos/map-reduce/)를 참조하세요.
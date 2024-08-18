---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/llm_router_chain.ipynb
description: '`LLMRouterChain`은 입력 쿼리를 여러 목적지 중 하나로 라우팅하며, LLM을 사용해 적절한 체인을 선택합니다.'
title: Migrating from LLMRouterChain
---

[`LLMRouterChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.router.llm_router.LLMRouterChain.html)는 입력 쿼리를 여러 목적지 중 하나로 라우팅합니다. 즉, 입력 쿼리를 기반으로 LLM을 사용하여 목적지 체인 목록에서 선택하고, 선택된 체인에 입력을 전달합니다.

`LLMRouterChain`은 메시지 역할 및 [도구 호출](/docs/concepts/#functiontool-calling)과 같은 일반적인 [채팅 모델](/docs/concepts/#chat-models) 기능을 지원하지 않습니다. 내부적으로 `LLMRouterChain`은 LLM에게 JSON 형식의 텍스트를 생성하도록 지시하여 쿼리를 라우팅하고, 의도된 목적지를 파싱합니다.

`LLMRouterChain`을 사용하는 [MultiPromptChain](/docs/versions/migrating_chains/multi_prompt_chain)의 예를 고려해 보십시오. 아래는 (예시) 기본 프롬프트입니다:

```python
from langchain.chains.router.multi_prompt import MULTI_PROMPT_ROUTER_TEMPLATE

destinations = """
animals: prompt for animal expert
vegetables: prompt for a vegetable expert
"""

router_template = MULTI_PROMPT_ROUTER_TEMPLATE.format(destinations=destinations)

print(router_template.replace("`", "'"))  # for rendering purposes
```

```output
Given a raw text input to a language model select the model prompt best suited for the input. You will be given the names of the available prompts and a description of what the prompt is best suited for. You may also revise the original input if you think that revising it will ultimately lead to a better response from the language model.

<< FORMATTING >>
Return a markdown code snippet with a JSON object formatted to look like:
'''json
{{
    "destination": string \ name of the prompt to use or "DEFAULT"
    "next_inputs": string \ a potentially modified version of the original input
}}
'''

REMEMBER: "destination" MUST be one of the candidate prompt names specified below OR it can be "DEFAULT" if the input is not well suited for any of the candidate prompts.
REMEMBER: "next_inputs" can just be the original input if you don't think any modifications are needed.

<< CANDIDATE PROMPTS >>

animals: prompt for animal expert
vegetables: prompt for a vegetable expert


<< INPUT >>
{input}

<< OUTPUT (must include '''json at the start of the response) >>
<< OUTPUT (must end with ''') >>
```

대부분의 동작은 단일 자연어 프롬프트를 통해 결정됩니다. [도구 호출](/docs/how_to/tool_calling/) 기능을 지원하는 채팅 모델은 이 작업에 여러 가지 장점을 제공합니다:

- `system` 및 기타 역할이 포함된 메시지를 포함한 채팅 프롬프트 템플릿 지원;
- 도구 호출 모델은 구조화된 출력을 생성하도록 미세 조정됨;
- 스트리밍 및 비동기 작업과 같은 실행 가능한 메서드 지원.

이제 도구 호출을 사용하는 LCEL 구현과 나란히 `LLMRouterChain`을 살펴보겠습니다. 이 가이드를 위해 `langchain-openai >= 0.1.20`을 사용할 것입니다:

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
<!--IMPORTS:[{"imported": "LLMRouterChain", "source": "langchain.chains.router.llm_router", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.router.llm_router.LLMRouterChain.html", "title": "# Legacy"}, {"imported": "RouterOutputParser", "source": "langchain.chains.router.llm_router", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.router.llm_router.RouterOutputParser.html", "title": "# Legacy"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain.chains.router.llm_router import LLMRouterChain, RouterOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o-mini")

router_prompt = PromptTemplate(
    # Note: here we use the prompt template from above. Generally this would need
    # to be customized.
    template=router_template,
    input_variables=["input"],
    output_parser=RouterOutputParser(),
)

chain = LLMRouterChain.from_llm(llm, router_prompt)
```


```python
result = chain.invoke({"input": "What color are carrots?"})

print(result["destination"])
```

```output
vegetables
```

</details>

## LCEL

<details open>

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from operator import itemgetter
from typing import Literal

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI
from typing_extensions import TypedDict

llm = ChatOpenAI(model="gpt-4o-mini")

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


# Instead of writing formatting instructions into the prompt, we
# leverage .with_structured_output to coerce the output into a simple
# schema.
chain = route_prompt | llm.with_structured_output(RouteQuery)
```


```python
result = chain.invoke({"input": "What color are carrots?"})

print(result["destination"])
```

```output
vegetable
```

</details>

## 다음 단계

프롬프트 템플릿, LLM 및 출력 파서를 사용하여 구축하는 방법에 대한 자세한 내용은 [이 튜토리얼](/docs/tutorials/llm_chain)을 참조하십시오.

더 많은 배경 정보는 [LCEL 개념 문서](/docs/concepts/#langchain-expression-language-lcel)를 확인하십시오.
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_prompting.ipynb
description: 이 가이드는 LLM 및 채팅 모델에 대한 애드혹 도구 호출 기능 추가 방법을 설명합니다. 도구 호출을 위한 대체 방법을 제공합니다.
sidebar_position: 3
---

# LLM 및 채팅 모델에 애드혹 도구 호출 기능 추가하는 방법

:::caution

일부 모델은 도구 호출을 위해 미세 조정되어 있으며 도구 호출을 위한 전용 API를 제공합니다. 일반적으로 이러한 모델은 미세 조정되지 않은 모델보다 도구 호출에 더 능숙하며, 도구 호출이 필요한 사용 사례에 권장됩니다. 자세한 내용은 [채팅 모델을 사용하여 도구 호출하는 방법](/docs/how_to/tool_calling) 가이드를 참조하십시오.

:::

:::info 필수 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [LangChain Tools](/docs/concepts/#tools)
- [함수/도구 호출](https://python.langchain.com/v0.2/docs/concepts/#functiontool-calling)
- [채팅 모델](/docs/concepts/#chat-models)
- [LLMs](/docs/concepts/#llms)

:::

이 가이드에서는 채팅 모델에 **애드혹** 도구 호출 지원을 추가하는 방법을 살펴보겠습니다. 이는 [도구 호출](/docs/how_to/tool_calling)을 기본적으로 지원하지 않는 모델을 사용할 경우 도구를 호출하는 대체 방법입니다.

모델이 적절한 도구를 호출하도록 유도하는 프롬프트를 작성하여 이를 수행할 것입니다. 다음은 논리의 다이어그램입니다:

![chain](../../static/img/tool_chain.svg)

## 설정

다음 패키지를 설치해야 합니다:

```python
%pip install --upgrade --quiet langchain langchain-community
```


LangSmith를 사용하려면 아래의 주석을 제거하십시오:

```python
import getpass
import os
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


이 사용 방법 가이드를 위해 주어진 모델 중 하나를 선택할 수 있습니다. 이 모델들 중 대부분은 이미 [네이티브 도구 호출을 지원](/docs/integrations/chat/)하므로, 여기서 보여주는 프롬프트 전략을 사용하는 것은 의미가 없으며, 대신 [채팅 모델을 사용하여 도구 호출하는 방법](/docs/how_to/tool_calling) 가이드를 따라야 합니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs openaiParams={`model="gpt-4"`} />

아이디어를 설명하기 위해, 도구 호출에 대한 네이티브 지원이 **없는** `phi3`를 Ollama를 통해 사용할 것입니다. `Ollama`를 사용하려면 [이 지침](/docs/integrations/chat/ollama/)을 따르십시오.

```python
<!--IMPORTS:[{"imported": "Ollama", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.ollama.Ollama.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}]-->
from langchain_community.llms import Ollama

model = Ollama(model="phi3")
```


## 도구 생성

먼저, `add` 및 `multiply` 도구를 생성하겠습니다. 사용자 정의 도구 생성에 대한 자세한 내용은 [이 가이드](/docs/how_to/custom_tools)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}]-->
from langchain_core.tools import tool


@tool
def multiply(x: float, y: float) -> float:
    """Multiply two numbers together."""
    return x * y


@tool
def add(x: int, y: int) -> int:
    "Add two numbers."
    return x + y


tools = [multiply, add]

# Let's inspect the tools
for t in tools:
    print("--")
    print(t.name)
    print(t.description)
    print(t.args)
```

```output
--
multiply
Multiply two numbers together.
{'x': {'title': 'X', 'type': 'number'}, 'y': {'title': 'Y', 'type': 'number'}}
--
add
Add two numbers.
{'x': {'title': 'X', 'type': 'integer'}, 'y': {'title': 'Y', 'type': 'integer'}}
```


```python
multiply.invoke({"x": 4, "y": 5})
```


```output
20.0
```


## 프롬프트 작성

모델이 액세스할 수 있는 도구, 해당 도구의 인수 및 모델의 원하는 출력 형식을 지정하는 프롬프트를 작성해야 합니다. 이 경우, 모델에게 `{"name": "...", "arguments": {...}}` 형식의 JSON 블롭을 출력하도록 지시할 것입니다.

```python
<!--IMPORTS:[{"imported": "JsonOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}, {"imported": "render_text_description", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.render.render_text_description.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}]-->
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import render_text_description

rendered_tools = render_text_description(tools)
print(rendered_tools)
```

```output
multiply(x: float, y: float) -> float - Multiply two numbers together.
add(x: int, y: int) -> int - Add two numbers.
```


```python
system_prompt = f"""\
You are an assistant that has access to the following set of tools. 
Here are the names and descriptions for each tool:

{rendered_tools}

Given the user input, return the name and input of the tool to use. 
Return your response as a JSON blob with 'name' and 'arguments' keys.

The `arguments` should be a dictionary, with keys corresponding 
to the argument names and the values corresponding to the requested values.
"""

prompt = ChatPromptTemplate.from_messages(
    [("system", system_prompt), ("user", "{input}")]
)
```


```python
chain = prompt | model
message = chain.invoke({"input": "what's 3 plus 1132"})

# Let's take a look at the output from the model
# if the model is an LLM (not a chat model), the output will be a string.
if isinstance(message, str):
    print(message)
else:  # Otherwise it's a chat model
    print(message.content)
```

```output
{
    "name": "add",
    "arguments": {
        "x": 3,
        "y": 1132
    }
}
```


## 출력 파서 추가

모델의 출력을 JSON으로 파싱하기 위해 `JsonOutputParser`를 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "JsonOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}]-->
from langchain_core.output_parsers import JsonOutputParser

chain = prompt | model | JsonOutputParser()
chain.invoke({"input": "what's thirteen times 4"})
```


```output
{'name': 'multiply', 'arguments': {'x': 13.0, 'y': 4.0}}
```


:::important

🎉 놀라워요! 🎉 이제 모델에게 도구를 호출하도록 **요청**하는 방법을 지시했습니다.

이제 도구를 실제로 실행할 수 있는 로직을 만들어 보겠습니다!
:::

## 도구 호출 🏃

모델이 도구를 호출하도록 요청할 수 있게 되었으므로, 실제로 도구를 호출할 수 있는 함수를 작성해야 합니다.

이 함수는 이름에 따라 적절한 도구를 선택하고, 모델이 선택한 인수를 전달합니다.

```python
<!--IMPORTS:[{"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}]-->
from typing import Any, Dict, Optional, TypedDict

from langchain_core.runnables import RunnableConfig


class ToolCallRequest(TypedDict):
    """A typed dict that shows the inputs into the invoke_tool function."""

    name: str
    arguments: Dict[str, Any]


def invoke_tool(
    tool_call_request: ToolCallRequest, config: Optional[RunnableConfig] = None
):
    """A function that we can use the perform a tool invocation.

    Args:
        tool_call_request: a dict that contains the keys name and arguments.
            The name must match the name of a tool that exists.
            The arguments are the arguments to that tool.
        config: This is configuration information that LangChain uses that contains
            things like callbacks, metadata, etc.See LCEL documentation about RunnableConfig.

    Returns:
        output from the requested tool
    """
    tool_name_to_tool = {tool.name: tool for tool in tools}
    name = tool_call_request["name"]
    requested_tool = tool_name_to_tool[name]
    return requested_tool.invoke(tool_call_request["arguments"], config=config)
```


이제 이를 테스트해 보겠습니다 🧪!

```python
invoke_tool({"name": "multiply", "arguments": {"x": 3, "y": 5}})
```


```output
15.0
```


## 함께 모으기

더하기 및 곱하기 기능을 갖춘 계산기를 생성하는 체인으로 함께 모아 보겠습니다.

```python
chain = prompt | model | JsonOutputParser() | invoke_tool
chain.invoke({"input": "what's thirteen times 4.14137281"})
```


```output
53.83784653
```


## 도구 입력 반환

도구 출력뿐만 아니라 도구 입력도 반환하는 것이 유용할 수 있습니다. 우리는 `RunnablePassthrough.assign`을 사용하여 도구 출력을 쉽게 반환할 수 있습니다. 이는 RunnablePassrthrough 구성 요소에 대한 입력(사전으로 가정됨)을 가져와서 현재 입력에 있는 모든 것을 전달하면서 키를 추가합니다:

```python
<!--IMPORTS:[{"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add ad-hoc tool calling capability to LLMs and Chat Models"}]-->
from langchain_core.runnables import RunnablePassthrough

chain = (
    prompt | model | JsonOutputParser() | RunnablePassthrough.assign(output=invoke_tool)
)
chain.invoke({"input": "what's thirteen times 4.14137281"})
```


```output
{'name': 'multiply',
 'arguments': {'x': 13, 'y': 4.14137281},
 'output': 53.83784653}
```


## 다음은 무엇인가요?

이 사용 방법 가이드는 모델이 모든 필수 도구 정보를 올바르게 출력할 때의 "행복한 경로"를 보여줍니다.

실제로 더 복잡한 도구를 사용하는 경우, 특히 도구 호출을 위해 미세 조정되지 않은 모델이나 덜 능력 있는 모델을 사용할 경우 모델에서 오류가 발생하기 시작할 것입니다.

모델의 출력을 개선하기 위한 전략을 추가할 준비가 필요합니다; 예를 들어,

1. 몇 가지 샷 예제를 제공하십시오.
2. 오류 처리를 추가하십시오 (예: 예외를 포착하고 이를 LLM에 피드백하여 이전 출력을 수정하도록 요청).
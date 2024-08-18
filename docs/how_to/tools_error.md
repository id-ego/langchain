---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_error.ipynb
description: 도구 오류 처리 방법에 대한 가이드로, LLM을 사용한 도구 호출 시 발생할 수 있는 오류를 관리하는 전략을 설명합니다.
---

# 도구 오류 처리 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [랑체인 도구](/docs/concepts/#tools)
- [모델을 사용하여 도구 호출하기](/docs/how_to/tool_calling)

:::

LLM으로 도구를 호출하는 것은 순수한 프롬프트보다 일반적으로 더 신뢰할 수 있지만 완벽하지는 않습니다. 모델이 존재하지 않는 도구를 호출하려 하거나 요청된 스키마와 일치하는 인수를 반환하지 못할 수 있습니다. 스키마를 간단하게 유지하고, 한 번에 전달하는 도구의 수를 줄이며, 좋은 이름과 설명을 갖는 것과 같은 전략은 이러한 위험을 완화하는 데 도움이 될 수 있지만 완벽하지는 않습니다.

이 가이드는 이러한 실패 모드를 완화하기 위해 체인에 오류 처리를 구축하는 몇 가지 방법을 다룹니다.

## 설정

다음 패키지를 설치해야 합니다:

```python
%pip install --upgrade --quiet langchain-core langchain-openai
```


[LangSmith](https://docs.smith.langchain.com/)에서 실행을 추적하려면 다음 환경 변수를 주석 해제하고 설정하세요:

```python
import getpass
import os

# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 체인

다음과 같은 (더미) 도구 및 도구 호출 체인이 있다고 가정해 보겠습니다. 모델을 혼란스럽게 만들기 위해 의도적으로 도구를 복잡하게 만들겠습니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm"/>

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to handle tool errors"}]-->
# Define tool
from langchain_core.tools import tool


@tool
def complex_tool(int_arg: int, float_arg: float, dict_arg: dict) -> int:
    """Do something complex with a complex tool."""
    return int_arg * float_arg


llm_with_tools = llm.bind_tools(
    [complex_tool],
)

# Define chain
chain = llm_with_tools | (lambda msg: msg.tool_calls[0]["args"]) | complex_tool
```


상당히 명확한 입력으로 이 체인을 호출하려고 할 때, 모델이 도구를 올바르게 호출하지 못하는 것을 볼 수 있습니다 (모델이 `dict_arg` 인수를 잊어버립니다).

```python
chain.invoke(
    "use complex tool. the args are 5, 2.1, empty dictionary. don't forget dict_arg"
)
```


```output
---------------------------------------------------------------------------
``````output
ValidationError                           Traceback (most recent call last)
``````output
Cell In[6], line 1
----> 1 chain.invoke(
      2     "use complex tool. the args are 5, 2.1, empty dictionary. don't forget dict_arg"
      3 )
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/langchain_core/runnables/base.py:2572, in RunnableSequence.invoke(self, input, config, **kwargs)
   2570             input = step.invoke(input, config, **kwargs)
   2571         else:
-> 2572             input = step.invoke(input, config)
   2573 # finish the root run
   2574 except BaseException as e:
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/langchain_core/tools.py:380, in BaseTool.invoke(self, input, config, **kwargs)
    373 def invoke(
    374     self,
    375     input: Union[str, Dict],
    376     config: Optional[RunnableConfig] = None,
    377     **kwargs: Any,
    378 ) -> Any:
    379     config = ensure_config(config)
--> 380     return self.run(
    381         input,
    382         callbacks=config.get("callbacks"),
    383         tags=config.get("tags"),
    384         metadata=config.get("metadata"),
    385         run_name=config.get("run_name"),
    386         run_id=config.pop("run_id", None),
    387         config=config,
    388         **kwargs,
    389     )
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/langchain_core/tools.py:537, in BaseTool.run(self, tool_input, verbose, start_color, color, callbacks, tags, metadata, run_name, run_id, config, **kwargs)
    535 except ValidationError as e:
    536     if not self.handle_validation_error:
--> 537         raise e
    538     elif isinstance(self.handle_validation_error, bool):
    539         observation = "Tool input validation error"
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/langchain_core/tools.py:526, in BaseTool.run(self, tool_input, verbose, start_color, color, callbacks, tags, metadata, run_name, run_id, config, **kwargs)
    524 context = copy_context()
    525 context.run(_set_config_context, child_config)
--> 526 parsed_input = self._parse_input(tool_input)
    527 tool_args, tool_kwargs = self._to_args_and_kwargs(parsed_input)
    528 observation = (
    529     context.run(
    530         self._run, *tool_args, run_manager=run_manager, **tool_kwargs
   (...)
    533     else context.run(self._run, *tool_args, **tool_kwargs)
    534 )
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/langchain_core/tools.py:424, in BaseTool._parse_input(self, tool_input)
    422 else:
    423     if input_args is not None:
--> 424         result = input_args.parse_obj(tool_input)
    425         return {
    426             k: getattr(result, k)
    427             for k, v in result.dict().items()
    428             if k in tool_input
    429         }
    430 return tool_input
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/pydantic/main.py:526, in pydantic.main.BaseModel.parse_obj()
``````output
File ~/.pyenv/versions/3.10.5/lib/python3.10/site-packages/pydantic/main.py:341, in pydantic.main.BaseModel.__init__()
``````output
ValidationError: 1 validation error for complex_toolSchema
dict_arg
  field required (type=value_error.missing)
```


## 시도/예외 도구 호출

오류를 보다 우아하게 처리하는 가장 간단한 방법은 도구 호출 단계를 try/except로 감싸고 오류에 대한 유용한 메시지를 반환하는 것입니다:

```python
<!--IMPORTS:[{"imported": "Runnable", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html", "title": "How to handle tool errors"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to handle tool errors"}]-->
from typing import Any

from langchain_core.runnables import Runnable, RunnableConfig


def try_except_tool(tool_args: dict, config: RunnableConfig) -> Runnable:
    try:
        complex_tool.invoke(tool_args, config=config)
    except Exception as e:
        return f"Calling tool with arguments:\n\n{tool_args}\n\nraised the following error:\n\n{type(e)}: {e}"


chain = llm_with_tools | (lambda msg: msg.tool_calls[0]["args"]) | try_except_tool

print(
    chain.invoke(
        "use complex tool. the args are 5, 2.1, empty dictionary. don't forget dict_arg"
    )
)
```

```output
Calling tool with arguments:

{'int_arg': 5, 'float_arg': 2.1}

raised the following error:

<class 'pydantic.error_wrappers.ValidationError'>: 1 validation error for complex_toolSchema
dict_arg
  field required (type=value_error.missing)
```


## 대체

도구 호출 오류가 발생할 경우 더 나은 모델로 대체할 수도 있습니다. 이 경우 `gpt-3.5-turbo` 대신 `gpt-4-1106-preview`를 사용하는 동일한 체인으로 대체하겠습니다.

```python
chain = llm_with_tools | (lambda msg: msg.tool_calls[0]["args"]) | complex_tool

better_model = ChatOpenAI(model="gpt-4-1106-preview", temperature=0).bind_tools(
    [complex_tool], tool_choice="complex_tool"
)

better_chain = better_model | (lambda msg: msg.tool_calls[0]["args"]) | complex_tool

chain_with_fallback = chain.with_fallbacks([better_chain])

chain_with_fallback.invoke(
    "use complex tool. the args are 5, 2.1, empty dictionary. don't forget dict_arg"
)
```


```output
10.5
```


이 체인 실행에 대한 [LangSmith 추적](https://smith.langchain.com/public/00e91fc2-e1a4-4b0f-a82e-e6b3119d196c/r)을 살펴보면, 첫 번째 체인 호출이 예상대로 실패하고 대체가 성공하는 것을 볼 수 있습니다.

## 예외와 함께 재시도

한 걸음 더 나아가, 예외가 전달된 상태에서 체인을 자동으로 재실행하여 모델이 자신의 동작을 수정할 수 있도록 시도할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to handle tool errors"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to handle tool errors"}, {"imported": "ToolCall", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolCall.html", "title": "How to handle tool errors"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to handle tool errors"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to handle tool errors"}]-->
from langchain_core.messages import AIMessage, HumanMessage, ToolCall, ToolMessage
from langchain_core.prompts import ChatPromptTemplate


class CustomToolException(Exception):
    """Custom LangChain tool exception."""

    def __init__(self, tool_call: ToolCall, exception: Exception) -> None:
        super().__init__()
        self.tool_call = tool_call
        self.exception = exception


def tool_custom_exception(msg: AIMessage, config: RunnableConfig) -> Runnable:
    try:
        return complex_tool.invoke(msg.tool_calls[0]["args"], config=config)
    except Exception as e:
        raise CustomToolException(msg.tool_calls[0], e)


def exception_to_messages(inputs: dict) -> dict:
    exception = inputs.pop("exception")

    # Add historical messages to the original input, so the model knows that it made a mistake with the last tool call.
    messages = [
        AIMessage(content="", tool_calls=[exception.tool_call]),
        ToolMessage(
            tool_call_id=exception.tool_call["id"], content=str(exception.exception)
        ),
        HumanMessage(
            content="The last tool call raised an exception. Try calling the tool again with corrected arguments. Do not repeat mistakes."
        ),
    ]
    inputs["last_output"] = messages
    return inputs


# We add a last_output MessagesPlaceholder to our prompt which if not passed in doesn't
# affect the prompt at all, but gives us the option to insert an arbitrary list of Messages
# into the prompt if needed. We'll use this on retries to insert the error message.
prompt = ChatPromptTemplate.from_messages(
    [("human", "{input}"), ("placeholder", "{last_output}")]
)
chain = prompt | llm_with_tools | tool_custom_exception

# If the initial chain call fails, we rerun it withe the exception passed in as a message.
self_correcting_chain = chain.with_fallbacks(
    [exception_to_messages | chain], exception_key="exception"
)
```


```python
self_correcting_chain.invoke(
    {
        "input": "use complex tool. the args are 5, 2.1, empty dictionary. don't forget dict_arg"
    }
)
```


```output
10.5
```


그리고 우리의 체인이 성공했습니다! [LangSmith 추적](https://smith.langchain.com/public/c11e804c-e14f-4059-bd09-64766f999c14/r)을 살펴보면, 초기 체인은 여전히 실패하고, 재시도할 때만 체인이 성공하는 것을 알 수 있습니다.

## 다음 단계

이제 도구 호출 오류를 처리하는 몇 가지 전략을 보았습니다. 다음으로 도구 사용에 대해 더 알아볼 수 있습니다:

- 도구를 사용한 [소수 샷 프롬프트](/docs/how_to/tools_few_shot/)
- [도구 호출 스트리밍](/docs/how_to/tool_streaming/)
- 도구에 [런타임 값 전달하기](/docs/how_to/tool_runtime)

또한 도구 호출의 좀 더 구체적인 사용 사례를 확인할 수 있습니다:

- 모델에서 [구조화된 출력](/docs/how_to/structured_output/) 얻기
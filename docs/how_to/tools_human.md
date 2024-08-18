---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_human.ipynb
description: 모델이 도구를 독립적으로 실행하는 것을 신뢰하지 않을 때, 도구 호출 전에 인간의 승인을 요구하는 방법을 안내합니다.
---

# 도구에 대한 인간 개입 추가 방법

모델이 독립적으로 실행하는 것을 신뢰하지 않는 특정 도구가 있습니다. 이러한 상황에서 우리가 할 수 있는 한 가지는 도구가 호출되기 전에 인간의 승인을 요구하는 것입니다.

:::info

이 사용 설명서는 주피터 노트북이나 터미널에서 코드 실행을 위한 인간 개입을 추가하는 간단한 방법을 보여줍니다.

프로덕션 애플리케이션을 구축하려면 애플리케이션 상태를 적절하게 추적하기 위해 더 많은 작업이 필요합니다.

이러한 기능을 지원하기 위해 `langgraph` 사용을 권장합니다. 자세한 내용은 이 [가이드](https://langchain-ai.github.io/langgraph/how-tos/human-in-the-loop/)를 참조하십시오.
:::

## 설정

다음 패키지를 설치해야 합니다:

```python
%pip install --upgrade --quiet langchain
```


그리고 이 환경 변수를 설정합니다:

```python
import getpass
import os

# If you'd like to use LangSmith, uncomment the below:
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 체인

간단한 (더미) 도구와 도구 호출 체인을 만들어 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm"/>


```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to add a human-in-the-loop for tools"}, {"imported": "Runnable", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html", "title": "How to add a human-in-the-loop for tools"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add a human-in-the-loop for tools"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to add a human-in-the-loop for tools"}]-->
from typing import Dict, List

from langchain_core.messages import AIMessage
from langchain_core.runnables import Runnable, RunnablePassthrough
from langchain_core.tools import tool


@tool
def count_emails(last_n_days: int) -> int:
    """Multiply two integers together."""
    return last_n_days * 2


@tool
def send_email(message: str, recipient: str) -> str:
    "Add two integers."
    return f"Successfully sent email to {recipient}."


tools = [count_emails, send_email]
llm_with_tools = llm.bind_tools(tools)


def call_tools(msg: AIMessage) -> List[Dict]:
    """Simple sequential tool calling helper."""
    tool_map = {tool.name: tool for tool in tools}
    tool_calls = msg.tool_calls.copy()
    for tool_call in tool_calls:
        tool_call["output"] = tool_map[tool_call["name"]].invoke(tool_call["args"])
    return tool_calls


chain = llm_with_tools | call_tools
chain.invoke("how many emails did i get in the last 5 days?")
```


```output
[{'name': 'count_emails',
  'args': {'last_n_days': 5},
  'id': 'toolu_01QYZdJ4yPiqsdeENWHqioFW',
  'output': 10}]
```


## 인간 승인 추가

체인에 사람에게 호출 요청을 승인하거나 거부하도록 요청하는 단계를 추가하겠습니다.

거부 시, 이 단계는 예외를 발생시켜 나머지 체인의 실행을 중단합니다.

```python
import json


class NotApproved(Exception):
    """Custom exception."""


def human_approval(msg: AIMessage) -> AIMessage:
    """Responsible for passing through its input or raising an exception.

    Args:
        msg: output from the chat model

    Returns:
        msg: original output from the msg
    """
    tool_strs = "\n\n".join(
        json.dumps(tool_call, indent=2) for tool_call in msg.tool_calls
    )
    input_msg = (
        f"Do you approve of the following tool invocations\n\n{tool_strs}\n\n"
        "Anything except 'Y'/'Yes' (case-insensitive) will be treated as a no.\n >>>"
    )
    resp = input(input_msg)
    if resp.lower() not in ("yes", "y"):
        raise NotApproved(f"Tool invocations not approved:\n\n{tool_strs}")
    return msg
```


```python
chain = llm_with_tools | human_approval | call_tools
chain.invoke("how many emails did i get in the last 5 days?")
```

```output
Do you approve of the following tool invocations

{
  "name": "count_emails",
  "args": {
    "last_n_days": 5
  },
  "id": "toolu_01WbD8XeMoQaRFtsZezfsHor"
}

Anything except 'Y'/'Yes' (case-insensitive) will be treated as a no.
 >>> yes
```


```output
[{'name': 'count_emails',
  'args': {'last_n_days': 5},
  'id': 'toolu_01WbD8XeMoQaRFtsZezfsHor',
  'output': 10}]
```


```python
try:
    chain.invoke("Send sally@gmail.com an email saying 'What's up homie'")
except NotApproved as e:
    print()
    print(e)
```

```output
Do you approve of the following tool invocations

{
  "name": "send_email",
  "args": {
    "recipient": "sally@gmail.com",
    "message": "What's up homie"
  },
  "id": "toolu_014XccHFzBiVcc9GV1harV9U"
}

Anything except 'Y'/'Yes' (case-insensitive) will be treated as a no.
 >>> no
``````output

Tool invocations not approved:

{
  "name": "send_email",
  "args": {
    "recipient": "sally@gmail.com",
    "message": "What's up homie"
  },
  "id": "toolu_014XccHFzBiVcc9GV1harV9U"
}
```
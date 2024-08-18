---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/cohere.ipynb
description: 이 문서는 Cohere 채팅 모델을 시작하는 방법과 Langchain에서의 사용법을 안내합니다. API 키 설정 및 활용 방법을
  포함합니다.
sidebar_label: Cohere
---

# Cohere

이 노트북은 [Cohere 채팅 모델](https://cohere.com/chat) 시작하는 방법을 다룹니다.

모든 속성과 메서드에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.cohere.ChatCohere.html)에서 확인할 수 있습니다.

## 설정

통합은 `langchain-cohere` 패키지에 있습니다. 우리는 다음과 같이 설치할 수 있습니다:

```bash
pip install -U langchain-cohere
```


또한 [Cohere API 키](https://cohere.com/)를 얻고 `COHERE_API_KEY` 환경 변수를 설정해야 합니다:

```python
import getpass
import os

os.environ["COHERE_API_KEY"] = getpass.getpass()
```


최고 수준의 가시성을 위해 [LangSmith](https://smith.langchain.com/)를 설정하는 것도 도움이 됩니다(필수는 아님).

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 사용법

ChatCohere는 모든 [ChatModel](/docs/how_to#chat-models) 기능을 지원합니다:

```python
<!--IMPORTS:[{"imported": "ChatCohere", "source": "langchain_cohere", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_cohere.chat_models.ChatCohere.html", "title": "Cohere"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Cohere"}]-->
from langchain_cohere import ChatCohere
from langchain_core.messages import HumanMessage
```


```python
chat = ChatCohere()
```


```python
messages = [HumanMessage(content="1"), HumanMessage(content="2 3")]
chat.invoke(messages)
```


```output
AIMessage(content='4 && 5 \n6 || 7 \n\nWould you like to play a game of odds and evens?', additional_kwargs={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '2076b614-52b3-4082-a259-cc92cd3d9fea', 'token_count': {'prompt_tokens': 68, 'response_tokens': 23, 'total_tokens': 91, 'billed_tokens': 77}}, response_metadata={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '2076b614-52b3-4082-a259-cc92cd3d9fea', 'token_count': {'prompt_tokens': 68, 'response_tokens': 23, 'total_tokens': 91, 'billed_tokens': 77}}, id='run-3475e0c8-c89b-4937-9300-e07d652455e1-0')
```


```python
await chat.ainvoke(messages)
```


```output
AIMessage(content='4 && 5', additional_kwargs={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': 'f0708a92-f874-46ee-9b93-334d616ad92e', 'token_count': {'prompt_tokens': 68, 'response_tokens': 3, 'total_tokens': 71, 'billed_tokens': 57}}, response_metadata={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': 'f0708a92-f874-46ee-9b93-334d616ad92e', 'token_count': {'prompt_tokens': 68, 'response_tokens': 3, 'total_tokens': 71, 'billed_tokens': 57}}, id='run-1635e63e-2994-4e7f-986e-152ddfc95777-0')
```


```python
for chunk in chat.stream(messages):
    print(chunk.content, end="", flush=True)
```

```output
4 && 5
```


```python
chat.batch([messages])
```


```output
[AIMessage(content='4 && 5', additional_kwargs={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '6770ca86-f6c3-4ba3-a285-c4772160612f', 'token_count': {'prompt_tokens': 68, 'response_tokens': 3, 'total_tokens': 71, 'billed_tokens': 57}}, response_metadata={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '6770ca86-f6c3-4ba3-a285-c4772160612f', 'token_count': {'prompt_tokens': 68, 'response_tokens': 3, 'total_tokens': 71, 'billed_tokens': 57}}, id='run-8d6fade2-1b39-4e31-ab23-4be622dd0027-0')]
```


## 체인 구성

프롬프트 템플릿과 쉽게 결합하여 사용자 입력을 쉽게 구조화할 수 있습니다. 우리는 [LCEL](/docs/concepts#langchain-expression-language-lcel)을 사용하여 이를 수행할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Cohere"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("Tell me a joke about {topic}")
chain = prompt | chat
```


```python
chain.invoke({"topic": "bears"})
```


```output
AIMessage(content='What color socks do bears wear?\n\nThey don’t wear socks, they have bear feet. \n\nHope you laughed! If not, maybe this will help: laughter is the best medicine, and a good sense of humor is infectious!', additional_kwargs={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '6edccf44-9bc8-4139-b30e-13b368f3563c', 'token_count': {'prompt_tokens': 68, 'response_tokens': 51, 'total_tokens': 119, 'billed_tokens': 108}}, response_metadata={'documents': None, 'citations': None, 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '6edccf44-9bc8-4139-b30e-13b368f3563c', 'token_count': {'prompt_tokens': 68, 'response_tokens': 51, 'total_tokens': 119, 'billed_tokens': 108}}, id='run-ef7f9789-0d4d-43bf-a4f7-f2a0e27a5320-0')
```


## 도구 호출

Cohere는 도구 호출 기능을 지원합니다!

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Cohere"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "Cohere"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "Cohere"}]-->
from langchain_core.messages import (
    HumanMessage,
    ToolMessage,
)
from langchain_core.tools import tool
```


```python
@tool
def magic_function(number: int) -> int:
    """Applies a magic operation to an integer
    Args:
        number: Number to have magic operation performed on
    """
    return number + 10


def invoke_tools(tool_calls, messages):
    for tool_call in tool_calls:
        selected_tool = {"magic_function": magic_function}[tool_call["name"].lower()]
        tool_output = selected_tool.invoke(tool_call["args"])
        messages.append(ToolMessage(tool_output, tool_call_id=tool_call["id"]))
    return messages


tools = [magic_function]
```


```python
llm_with_tools = chat.bind_tools(tools=tools)
messages = [HumanMessage(content="What is the value of magic_function(2)?")]
```


```python
res = llm_with_tools.invoke(messages)
while res.tool_calls:
    messages.append(res)
    messages = invoke_tools(res.tool_calls, messages)
    res = llm_with_tools.invoke(messages)

res
```


```output
AIMessage(content='The value of magic_function(2) is 12.', additional_kwargs={'documents': [{'id': 'magic_function:0:2:0', 'output': '12', 'tool_name': 'magic_function'}], 'citations': [ChatCitation(start=34, end=36, text='12', document_ids=['magic_function:0:2:0'])], 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '96a55791-0c58-4e2e-bc2a-8550e137c46d', 'token_count': {'input_tokens': 998, 'output_tokens': 59}}, response_metadata={'documents': [{'id': 'magic_function:0:2:0', 'output': '12', 'tool_name': 'magic_function'}], 'citations': [ChatCitation(start=34, end=36, text='12', document_ids=['magic_function:0:2:0'])], 'search_results': None, 'search_queries': None, 'is_search_required': None, 'generation_id': '96a55791-0c58-4e2e-bc2a-8550e137c46d', 'token_count': {'input_tokens': 998, 'output_tokens': 59}}, id='run-f318a9cf-55c8-44f4-91d1-27cf46c6a465-0')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
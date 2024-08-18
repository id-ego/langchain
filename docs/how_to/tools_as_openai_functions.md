---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_as_openai_functions.ipynb
description: 이 문서는 LangChain 도구를 OpenAI 함수로 변환하는 방법을 설명합니다. 자동 바인딩 및 업데이트된 OpenAI
  API 사용법도 포함되어 있습니다.
---

# OpenAI 함수로 도구 변환하는 방법

이 노트북은 LangChain 도구를 OpenAI 함수로 사용하는 방법에 대해 설명합니다.

```python
%pip install -qU langchain-community langchain-openai
```


```python
<!--IMPORTS:[{"imported": "MoveFileTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.file_management.move.MoveFileTool.html", "title": "How to convert tools to OpenAI Functions"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to convert tools to OpenAI Functions"}, {"imported": "convert_to_openai_function", "source": "langchain_core.utils.function_calling", "docs": "https://api.python.langchain.com/en/latest/utils/langchain_core.utils.function_calling.convert_to_openai_function.html", "title": "How to convert tools to OpenAI Functions"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to convert tools to OpenAI Functions"}]-->
from langchain_community.tools import MoveFileTool
from langchain_core.messages import HumanMessage
from langchain_core.utils.function_calling import convert_to_openai_function
from langchain_openai import ChatOpenAI
```


```python
model = ChatOpenAI(model="gpt-3.5-turbo")
```


```python
tools = [MoveFileTool()]
functions = [convert_to_openai_function(t) for t in tools]
```


```python
functions[0]
```


```output
{'name': 'move_file',
 'description': 'Move or rename a file from one location to another',
 'parameters': {'type': 'object',
  'properties': {'source_path': {'description': 'Path of the file to move',
    'type': 'string'},
   'destination_path': {'description': 'New path for the moved file',
    'type': 'string'}},
  'required': ['source_path', 'destination_path']}}
```


```python
message = model.invoke(
    [HumanMessage(content="move file foo to bar")], functions=functions
)
```


```python
message
```


```output
AIMessage(content='', additional_kwargs={'function_call': {'arguments': '{\n  "source_path": "foo",\n  "destination_path": "bar"\n}', 'name': 'move_file'}})
```


```python
message.additional_kwargs["function_call"]
```


```output
{'name': 'move_file',
 'arguments': '{\n  "source_path": "foo",\n  "destination_path": "bar"\n}'}
```


OpenAI 채팅 모델을 사용하면 `bind_functions`로 함수와 같은 객체를 자동으로 바인딩하고 변환할 수 있습니다.

```python
model_with_functions = model.bind_functions(tools)
model_with_functions.invoke([HumanMessage(content="move file foo to bar")])
```


```output
AIMessage(content='', additional_kwargs={'function_call': {'arguments': '{\n  "source_path": "foo",\n  "destination_path": "bar"\n}', 'name': 'move_file'}})
```


또는 `functions`와 `function_call` 대신 `tools`와 `tool_choice`를 사용하는 업데이트된 OpenAI API를 사용할 수 있습니다. `ChatOpenAI.bind_tools`를 사용하여:

```python
model_with_tools = model.bind_tools(tools)
model_with_tools.invoke([HumanMessage(content="move file foo to bar")])
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_btkY3xV71cEVAOHnNa5qwo44', 'function': {'arguments': '{\n  "source_path": "foo",\n  "destination_path": "bar"\n}', 'name': 'move_file'}, 'type': 'function'}]})
```
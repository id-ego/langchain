---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_model_specific.ipynb
description: 모델 특정 도구를 바인딩하는 방법에 대한 설명으로, OpenAI의 도구 스키마 포맷과 예제를 제공합니다.
---

# 모델 특정 도구 바인딩 방법

제공자는 도구 스키마 형식을 위해 서로 다른 규칙을 채택합니다. 예를 들어, OpenAI는 다음과 같은 형식을 사용합니다:

- `type`: 도구의 유형. 작성 시점에서 항상 `"function"`입니다.
- `function`: 도구 매개변수를 포함하는 객체입니다.
- `function.name`: 출력할 스키마의 이름입니다.
- `function.description`: 출력할 스키마에 대한 높은 수준의 설명입니다.
- `function.parameters`: 추출하려는 스키마의 중첩 세부정보로, [JSON 스키마](https://json-schema.org/) 사전 형식으로 작성됩니다.

원하는 경우 이 모델 특정 형식을 모델에 직접 바인딩할 수 있습니다. 다음은 예시입니다:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to bind model-specific tools"}]-->
from langchain_openai import ChatOpenAI

model = ChatOpenAI()

model_with_tools = model.bind(
    tools=[
        {
            "type": "function",
            "function": {
                "name": "multiply",
                "description": "Multiply two integers together.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "a": {"type": "number", "description": "First integer"},
                        "b": {"type": "number", "description": "Second integer"},
                    },
                    "required": ["a", "b"],
                },
            },
        }
    ]
)

model_with_tools.invoke("Whats 119 times 8?")
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_mn4ELw1NbuE0DFYhIeK0GrPe', 'function': {'arguments': '{"a":119,"b":8}', 'name': 'multiply'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 62, 'total_tokens': 79}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-353e8a9a-7125-4f94-8c68-4f3da4c21120-0', tool_calls=[{'name': 'multiply', 'args': {'a': 119, 'b': 8}, 'id': 'call_mn4ELw1NbuE0DFYhIeK0GrPe'}])
```


이는 `bind_tools()` 메서드와 기능적으로 동등합니다.
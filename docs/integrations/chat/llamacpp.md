---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/llamacpp.ipynb
description: Llama.cpp는 Python 바인딩을 제공하며, 텍스트 완성을 위한 고급 API와 OpenAI 호환 웹 서버를 지원합니다.
---

# Llama.cpp

> [llama.cpp python](https://github.com/abetlen/llama-cpp-python) 라이브러리는 `@ggerganov`의 [llama.cpp](https://github.com/ggerganov/llama.cpp)에 대한 간단한 Python 바인딩입니다.
> 
> 이 패키지는 다음을 제공합니다:
> 
> - ctypes 인터페이스를 통한 C API에 대한 저수준 접근.
> - 텍스트 완성을 위한 고수준 Python API
>   - `OpenAI`와 유사한 API
>   - `LangChain` 호환성
>   - `LlamaIndex` 호환성
> - OpenAI 호환 웹 서버
>   - 로컬 Copilot 대체
>   - 함수 호출 지원
>   - 비전 API 지원
>   - 여러 모델

## 개요

### 통합 세부정보
| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 |
| :--- | :--- | :---: | :---: |  :---: |
| [ChatLlamaCpp](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.llamacpp.ChatLlamaCpp.html) | [langchain-community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | 이미지 입력 | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | 

## 설정

시작하고 아래에 표시된 **모든** 기능을 사용하려면 도구 호출에 맞게 미세 조정된 모델을 사용하는 것이 좋습니다.

우리는 NousResearch의 [
Hermes-2-Pro-Llama-3-8B-GGUF](https://huggingface.co/NousResearch/Hermes-2-Pro-Llama-3-8B-GGUF)를 사용할 것입니다. 

> Hermes 2 Pro는 Nous Hermes 2의 업그레이드된 버전으로, OpenHermes 2.5 데이터셋의 업데이트되고 정리된 버전과 내부에서 개발된 새로 도입된 함수 호출 및 JSON 모드 데이터셋으로 구성됩니다. 이 새로운 Hermes 버전은 뛰어난 일반 작업 및 대화 능력을 유지하면서 함수 호출에서도 뛰어납니다.

로컬 모델에 대한 가이드를 참조하여 더 깊이 알아보세요:

* [LLM을 로컬에서 실행하기](https://python.langchain.com/v0.1/docs/guides/development/local_llms/)
* [RAG와 함께 로컬 모델 사용하기](https://python.langchain.com/v0.1/docs/use_cases/question_answering/local_retrieval_qa/)

### 설치

LangChain LlamaCpp 통합은 `langchain-community` 및 `llama-cpp-python` 패키지에 있습니다:

```python
%pip install -qU langchain-community llama-cpp-python
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
# Path to your model weights
local_model = "local/path/to/Hermes-2-Pro-Llama-3-8B-Q8_0.gguf"
```


```python
<!--IMPORTS:[{"imported": "ChatLlamaCpp", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.llamacpp.ChatLlamaCpp.html", "title": "Llama.cpp"}]-->
import multiprocessing

from langchain_community.chat_models import ChatLlamaCpp

llm = ChatLlamaCpp(
    temperature=0.5,
    model_path=local_model,
    n_ctx=10000,
    n_gpu_layers=8,
    n_batch=300,  # Should be between 1 and n_ctx, consider the amount of VRAM in your GPU.
    max_tokens=512,
    n_threads=multiprocessing.cpu_count() - 1,
    repeat_penalty=1.5,
    top_p=0.5,
    verbose=True,
)
```


## 호출

```python
messages = [
    (
        "system",
        "You are a helpful assistant that translates English to French. Translate the user sentence.",
    ),
    ("human", "I love programming."),
]

ai_msg = llm.invoke(messages)
ai_msg
```


```python
print(ai_msg.content)
```

```output
J'aime programmer. (In France, "programming" is often used in its original sense of scheduling or organizing events.) 

If you meant computer-programming: 
Je suis amoureux de la programmation informatique.

(You might also say simply 'programmation', which would be understood as both meanings - depending on context).
```

## 체이닝

우리는 프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Llama.cpp"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant that translates {input_language} to {output_language}.",
        ),
        ("human", "{input}"),
    ]
)

chain = prompt | llm
chain.invoke(
    {
        "input_language": "English",
        "output_language": "German",
        "input": "I love programming.",
    }
)
```


## 도구 호출

첫째, 이는 OpenAI 함수 호출과 대부분 동일하게 작동합니다.

OpenAI는 도구와 그 인수를 설명하고 모델이 호출할 도구와 해당 도구의 입력을 포함하는 JSON 객체를 반환하도록 하는 [도구 호출](https://platform.openai.com/docs/guides/function-calling) API를 가지고 있습니다. 도구 호출은 도구를 사용하는 체인 및 에이전트를 구축하고 모델에서 구조화된 출력을 얻는 데 매우 유용합니다.

`ChatLlamaCpp.bind_tools`를 사용하면 Pydantic 클래스, dict 스키마, LangChain 도구 또는 심지어 함수를 도구로 모델에 쉽게 전달할 수 있습니다. 내부적으로 이러한 것은 OpenAI 도구 스키마로 변환되며, 이는 다음과 같습니다:
```
{
    "name": "...",
    "description": "...",
    "parameters": {...}  # JSONSchema
}
```

모든 모델 호출에 전달됩니다.

그러나 함수/도구를 자동으로 트리거할 수는 없으며, '도구 선택' 매개변수를 지정하여 강제로 호출해야 합니다. 이 매개변수는 일반적으로 아래와 같이 형식화됩니다.

`{"type": "function", "function": {"name": <<tool_name>>}}.`

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "Llama.cpp"}]-->
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_core.tools import tool


class WeatherInput(BaseModel):
    location: str = Field(description="The city and state, e.g. San Francisco, CA")
    unit: str = Field(enum=["celsius", "fahrenheit"])


@tool("get_current_weather", args_schema=WeatherInput)
def get_weather(location: str, unit: str):
    """Get the current weather in a given location"""
    return f"Now the weather in {location} is 22 {unit}"


llm_with_tools = llm.bind_tools(
    tools=[get_weather],
    tool_choice={"type": "function", "function": {"name": "get_current_weather"}},
)
```


```python
ai_msg = llm_with_tools.invoke(
    "what is the weather like in HCMC in celsius",
)
```


```python
ai_msg.tool_calls
```


```output
[{'name': 'get_current_weather',
  'args': {'location': 'Ho Chi Minh City', 'unit': 'celsius'},
  'id': 'call__0_get_current_weather_cmpl-394d9943-0a1f-425b-8139-d2826c1431f2'}]
```


```python
class MagicFunctionInput(BaseModel):
    magic_function_input: int = Field(description="The input value for magic function")


@tool("get_magic_function", args_schema=MagicFunctionInput)
def magic_function(magic_function_input: int):
    """Get the value of magic function for an input."""
    return magic_function_input + 2


llm_with_tools = llm.bind_tools(
    tools=[magic_function],
    tool_choice={"type": "function", "function": {"name": "get_magic_function"}},
)

ai_msg = llm_with_tools.invoke(
    "What is magic function of 3?",
)

ai_msg
```


```python
ai_msg.tool_calls
```


```output
[{'name': 'get_magic_function',
  'args': {'magic_function_input': 3},
  'id': 'call__0_get_magic_function_cmpl-cd83a994-b820-4428-957c-48076c68335a'}]
```


# 구조화된 출력

```python
<!--IMPORTS:[{"imported": "convert_to_openai_tool", "source": "langchain_core.utils.function_calling", "docs": "https://api.python.langchain.com/en/latest/utils/langchain_core.utils.function_calling.convert_to_openai_tool.html", "title": "Llama.cpp"}]-->
from langchain_core.pydantic_v1 import BaseModel
from langchain_core.utils.function_calling import convert_to_openai_tool


class Joke(BaseModel):
    """A setup to a joke and the punchline."""

    setup: str
    punchline: str


dict_schema = convert_to_openai_tool(Joke)
structured_llm = llm.with_structured_output(dict_schema)
result = structured_llm.invoke("Tell me a joke about birds")
result
```


```python
result
```


```output
{'setup': '- Why did the chicken cross the playground?',
 'punchline': '\n\n- To get to its gilded cage on the other side!'}
```


# 스트리밍

```python
for chunk in llm.stream("what is 25x5"):
    print(chunk.content, end="\n", flush=True)
```


## API 참조

ChatLlamaCpp의 모든 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.llamacpp.ChatLlamaCpp.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
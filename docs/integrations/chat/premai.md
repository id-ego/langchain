---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/premai.ipynb
description: PremAI는 생성 AI로 구동되는 애플리케이션을 간편하게 개발할 수 있는 올인원 플랫폼입니다. LangChain과의 통합
  방법을 소개합니다.
sidebar_label: PremAI
---

# ChatPremAI

[PremAI](https://premai.io/)는 생성 AI로 구동되는 강력하고 생산 준비가 완료된 애플리케이션의 생성 과정을 단순화하는 올인원 플랫폼입니다. 개발 프로세스를 간소화함으로써 PremAI는 사용자 경험을 향상하고 애플리케이션의 전반적인 성장을 촉진하는 데 집중할 수 있도록 합니다. 플랫폼 사용을 빠르게 시작하려면 [여기](https://docs.premai.io/quick-start)를 클릭하세요.

이 예제는 `ChatPremAI`를 사용하여 다양한 채팅 모델과 상호작용하는 방법을 설명합니다.

### 설치 및 설정

먼저 `langchain`과 `premai-sdk`를 설치합니다. 다음 명령어를 입력하여 설치할 수 있습니다:

```bash
pip install premai langchain
```


더 진행하기 전에, PremAI에 계정을 만들고 이미 프로젝트를 생성했는지 확인하세요. 그렇지 않다면, PremAI 플랫폼을 시작하는 방법에 대한 [빠른 시작](https://docs.premai.io/introduction) 가이드를 참조하세요. 첫 번째 프로젝트를 생성하고 API 키를 가져오세요.

```python
<!--IMPORTS:[{"imported": "ChatPremAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.premai.ChatPremAI.html", "title": "ChatPremAI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatPremAI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatPremAI"}]-->
from langchain_community.chat_models import ChatPremAI
from langchain_core.messages import HumanMessage, SystemMessage
```


### LangChain에서 PremAI 클라이언트 설정

필요한 모듈을 가져온 후, 클라이언트를 설정합시다. 현재 `project_id`가 `8`이라고 가정하겠습니다. 하지만 반드시 자신의 project-id를 사용해야 하며, 그렇지 않으면 오류가 발생합니다.

prem과 함께 langchain을 사용하려면, 모델 이름이나 채팅 클라이언트와 함께 매개변수를 설정할 필요가 없습니다. 기본적으로 [LaunchPad](https://docs.premai.io/get-started/launchpad)에서 사용된 모델 이름과 매개변수를 사용합니다. 

> 주의: 클라이언트를 설정할 때 `model`이나 `temperature`, `max_tokens`와 같은 다른 매개변수를 변경하면 LaunchPad에서 사용된 기존 기본 구성을 덮어쓰게 됩니다.   

```python
import getpass
import os

# First step is to set up the env variable.
# you can also pass the API key while instantiating the model but this
# comes under a best practices to set it as env variable.

if os.environ.get("PREMAI_API_KEY") is None:
    os.environ["PREMAI_API_KEY"] = getpass.getpass("PremAI API Key:")
```


```python
# By default it will use the model which was deployed through the platform
# in my case it will is "gpt-4o"

chat = ChatPremAI(project_id=1234, model_name="gpt-4o")
```


### 채팅 완성

`ChatPremAI`는 두 가지 방법을 지원합니다: `invoke` (이는 `generate`와 동일) 및 `stream`. 

첫 번째 방법은 정적인 결과를 제공합니다. 반면 두 번째 방법은 토큰을 하나씩 스트리밍합니다. 채팅과 같은 완성을 생성하는 방법은 다음과 같습니다. 

```python
human_message = HumanMessage(content="Who are you?")

response = chat.invoke([human_message])
print(response.content)
```

```output
I am an AI language model created by OpenAI, designed to assist with answering questions and providing information based on the context provided. How can I help you today?
```

위의 내용이 흥미롭지 않나요? 저는 기본 LaunchPad 시스템 프롬프트를 `항상 해적처럼 들리게` 설정했습니다. 필요하다면 기본 시스템 프롬프트를 덮어쓸 수도 있습니다. 방법은 다음과 같습니다. 

```python
system_message = SystemMessage(content="You are a friendly assistant.")
human_message = HumanMessage(content="Who are you?")

chat.invoke([system_message, human_message])
```


```output
AIMessage(content="I'm your friendly assistant! How can I help you today?", response_metadata={'document_chunks': [{'repository_id': 1985, 'document_id': 1306, 'chunk_id': 173899, 'document_name': '[D] Difference between sparse and dense informati…', 'similarity_score': 0.3209080100059509, 'content': "with the difference or anywhere\nwhere I can read about it?\n\n\n      17                  9\n\n\n      u/ScotiabankCanada        •  Promoted\n\n\n                       Accelerate your study permit process\n                       with Scotiabank's Student GIC\n                       Program. We're here to help you tur…\n\n\n                       startright.scotiabank.com         Learn More\n\n\n                            Add a Comment\n\n\nSort by:   Best\n\n\n      DinosParkour      • 1y ago\n\n\n     Dense Retrieval (DR) m"}]}, id='run-510bbd0e-3f8f-4095-9b1f-c2d29fd89719-0')
```


여기에서 시스템 프롬프트를 다음과 같이 제공할 수 있습니다:

```python
chat.invoke([system_message, human_message], temperature=0.7, max_tokens=10, top_p=0.95)
```

```output
/home/anindya/prem/langchain/libs/community/langchain_community/chat_models/premai.py:355: UserWarning: WARNING: Parameter top_p is not supported in kwargs.
  warnings.warn(f"WARNING: Parameter {key} is not supported in kwargs.")
```


```output
AIMessage(content="Hello! I'm your friendly assistant. How can I", response_metadata={'document_chunks': [{'repository_id': 1985, 'document_id': 1306, 'chunk_id': 173899, 'document_name': '[D] Difference between sparse and dense informati…', 'similarity_score': 0.3209080100059509, 'content': "with the difference or anywhere\nwhere I can read about it?\n\n\n      17                  9\n\n\n      u/ScotiabankCanada        •  Promoted\n\n\n                       Accelerate your study permit process\n                       with Scotiabank's Student GIC\n                       Program. We're here to help you tur…\n\n\n                       startright.scotiabank.com         Learn More\n\n\n                            Add a Comment\n\n\nSort by:   Best\n\n\n      DinosParkour      • 1y ago\n\n\n     Dense Retrieval (DR) m"}]}, id='run-c4b06b98-4161-4cca-8495-fd2fc98fa8f8-0')
```


> 여기에서 시스템 프롬프트를 설정하면, 플랫폼에서 애플리케이션을 배포할 때 고정된 시스템 프롬프트를 덮어쓰게 됩니다. 

### Prem 리포지토리와 함께하는 네이티브 RAG 지원

Prem 리포지토리는 사용자가 문서(.txt, .pdf 등)를 업로드하고 이러한 리포지토리를 LLM에 연결할 수 있게 해줍니다. Prem 리포지토리는 네이티브 RAG로 생각할 수 있으며, 각 리포지토리는 벡터 데이터베이스로 간주될 수 있습니다. 여러 리포지토리를 연결할 수 있습니다. 리포지토리에 대한 자세한 내용은 [여기](https://docs.premai.io/get-started/repositories)에서 확인하세요.

리포지토리는 langchain premai에서도 지원됩니다. 방법은 다음과 같습니다. 

```python
query = "Which models are used for dense retrieval"
repository_ids = [
    1985,
]
repositories = dict(ids=repository_ids, similarity_threshold=0.3, limit=3)
```


먼저 몇 개의 리포지토리 ID로 리포지토리를 정의합니다. ID가 유효한 리포지토리 ID인지 확인하세요. 리포지토리 ID를 얻는 방법에 대한 자세한 내용은 [여기](https://docs.premai.io/get-started/repositories)에서 확인하세요. 

> 주의: `repositories` 인수를 호출할 때 `model_name`과 유사하게, LaunchPad에서 연결된 리포지토리를 덮어쓸 수 있습니다. 

이제 리포지토리를 채팅 객체와 연결하여 RAG 기반 생성을 호출합니다. 

```python
import json

response = chat.invoke(query, max_tokens=100, repositories=repositories)

print(response.content)
print(json.dumps(response.response_metadata, indent=4))
```

```output
Dense retrieval models typically include:

1. **BERT-based Models**: Such as DPR (Dense Passage Retrieval) which uses BERT for encoding queries and passages.
2. **ColBERT**: A model that combines BERT with late interaction mechanisms.
3. **ANCE (Approximate Nearest Neighbor Negative Contrastive Estimation)**: Uses BERT and focuses on efficient retrieval.
4. **TCT-ColBERT**: A variant of ColBERT that uses a two-tower
{
    "document_chunks": [
        {
            "repository_id": 1985,
            "document_id": 1306,
            "chunk_id": 173899,
            "document_name": "[D] Difference between sparse and dense informati\u2026",
            "similarity_score": 0.3209080100059509,
            "content": "with the difference or anywhere\nwhere I can read about it?\n\n\n      17                  9\n\n\n      u/ScotiabankCanada        \u2022  Promoted\n\n\n                       Accelerate your study permit process\n                       with Scotiabank's Student GIC\n                       Program. We're here to help you tur\u2026\n\n\n                       startright.scotiabank.com         Learn More\n\n\n                            Add a Comment\n\n\nSort by:   Best\n\n\n      DinosParkour      \u2022 1y ago\n\n\n     Dense Retrieval (DR) m"
        }
    ]
}
```

> 이상적으로, Retrieval Augmented Generations를 얻기 위해 여기에서 리포지토리 ID를 연결할 필요는 없습니다. Prem 플랫폼에서 리포지토리를 연결한 경우에도 동일한 결과를 얻을 수 있습니다. 

### Prem 템플릿

프롬프트 템플릿을 작성하는 것은 매우 복잡할 수 있습니다. 프롬프트 템플릿은 길고 관리하기 어려우며, 애플리케이션 전반에 걸쳐 개선하고 일관성을 유지하기 위해 지속적으로 조정해야 합니다. 

**Prem**을 사용하면 프롬프트 작성 및 관리가 매우 쉬워집니다. [launchpad](https://docs.premai.io/get-started/launchpad) 내의 ***Templates*** 탭은 필요한 만큼의 프롬프트를 작성하고 SDK 내에서 사용하여 애플리케이션을 실행하는 데 도움을 줍니다. 프롬프트 템플릿에 대한 자세한 내용은 [여기](https://docs.premai.io/get-started/prem-templates)에서 확인하세요. 

LangChain과 함께 Prem 템플릿을 네이티브로 사용하려면, `HumanMessage`에 ID를 전달해야 합니다. 이 ID는 프롬프트 템플릿의 변수 이름이어야 합니다. `HumanMessage`의 `content`는 해당 변수의 값이어야 합니다. 

예를 들어, 프롬프트 템플릿이 다음과 같다면:

```text
Say hello to my name and say a feel-good quote
from my age. My name is: {name} and age is {age}
```


이제 `human_messages`는 다음과 같아야 합니다:

```python
human_messages = [
    HumanMessage(content="Shawn", id="name"),
    HumanMessage(content="22", id="age"),
]
```


이 `human_messages`를 ChatPremAI 클라이언트에 전달하세요. 주의: Prem 템플릿으로 생성을 호출하려면 추가 `template_id`를 전달하는 것을 잊지 마세요. `template_id`에 대해 잘 모른다면, [우리 문서](https://docs.premai.io/get-started/prem-templates)에서 자세히 알아볼 수 있습니다. 예시는 다음과 같습니다:

```python
template_id = "78069ce8-xxxxx-xxxxx-xxxx-xxx"
response = chat.invoke([human_messages], template_id=template_id)
print(response.content)
```


Prem 템플릿 기능은 스트리밍에서도 사용할 수 있습니다. 

### 스트리밍

이 섹션에서는 langchain과 PremAI를 사용하여 토큰을 스트리밍하는 방법을 살펴보겠습니다. 방법은 다음과 같습니다. 

```python
import sys

for chunk in chat.stream("hello how are you"):
    sys.stdout.write(chunk.content)
    sys.stdout.flush()
```

```output
It looks like your message got cut off. If you need information about Dense Retrieval (DR) or any other topic, please provide more details or clarify your question.
```

위와 유사하게, 시스템 프롬프트와 생성 매개변수를 덮어쓰려면 다음을 추가해야 합니다:

```python
import sys

# For some experimental reasons if you want to override the system prompt then you
# can pass that here too. However it is not recommended to override system prompt
# of an already deployed model.

for chunk in chat.stream(
    "hello how are you",
    system_prompt="act like a dog",
    temperature=0.7,
    max_tokens=200,
):
    sys.stdout.write(chunk.content)
    sys.stdout.flush()
```

```output
Woof! 🐾 How can I help you today? Want to play fetch or maybe go for a walk 🐶🦴
```

### 도구/함수 호출

LangChain PremAI는 도구/함수 호출을 지원합니다. 도구/함수 호출은 모델이 주어진 프롬프트에 응답하여 사용자 정의 스키마에 맞는 출력을 생성할 수 있게 해줍니다. 

- 도구 호출에 대한 모든 내용은 [우리 문서](https://docs.premai.io/get-started/function-calling)에서 자세히 알아볼 수 있습니다.
- langchain 도구 호출에 대한 자세한 내용은 [문서의 이 부분](https://python.langchain.com/v0.1/docs/modules/model_io/chat/function_calling)에서 확인하세요.

**주의:**
현재 버전의 LangChain ChatPremAI는 스트리밍 지원과 함께 함수/도구 호출을 지원하지 않습니다. 스트리밍 지원과 함수 호출은 곧 제공될 예정입니다. 

#### 모델에 도구 전달하기

도구를 전달하고 LLM이 호출해야 할 도구를 선택할 수 있도록 하려면 도구 스키마를 전달해야 합니다. 도구 스키마는 함수 정의와 함수가 수행하는 작업, 각 인수에 대한 설명 등을 포함한 적절한 docstring입니다. 아래는 몇 가지 간단한 산술 함수와 그 스키마입니다. 

**주의:** 함수/도구 스키마를 정의할 때 함수 인수에 대한 정보를 추가하는 것을 잊지 마세요. 그렇지 않으면 오류가 발생합니다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "ChatPremAI"}]-->
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_core.tools import tool


# Define the schema for function arguments
class OperationInput(BaseModel):
    a: int = Field(description="First number")
    b: int = Field(description="Second number")


# Now define the function where schema for argument will be OperationInput
@tool("add", args_schema=OperationInput, return_direct=True)
def add(a: int, b: int) -> int:
    """Adds a and b.

    Args:
        a: first int
        b: second int
    """
    return a + b


@tool("multiply", args_schema=OperationInput, return_direct=True)
def multiply(a: int, b: int) -> int:
    """Multiplies a and b.

    Args:
        a: first int
        b: second int
    """
    return a * b
```


#### LLM과 도구 스키마 바인딩

이제 `bind_tools` 메서드를 사용하여 위의 함수를 "도구"로 변환하고 모델과 바인딩합니다. 이는 모델을 호출할 때마다 이러한 도구 정보를 전달한다는 것을 의미합니다. 

```python
tools = [add, multiply]
llm_with_tools = chat.bind_tools(tools)
```


이후, 도구와 바인딩된 모델로부터 응답을 받습니다. 

```python
query = "What is 3 * 12? Also, what is 11 + 49?"

messages = [HumanMessage(query)]
ai_msg = llm_with_tools.invoke(messages)
```


보시다시피, 채팅 모델이 도구와 바인딩되면 주어진 프롬프트에 따라 올바른 도구 세트를 호출하고 순차적으로 실행합니다. 

```python
ai_msg.tool_calls
```


```output
[{'name': 'multiply',
  'args': {'a': 3, 'b': 12},
  'id': 'call_A9FL20u12lz6TpOLaiS6rFa8'},
 {'name': 'add',
  'args': {'a': 11, 'b': 49},
  'id': 'call_MPKYGLHbf39csJIyb5BZ9xIk'}]
```


위에 표시된 메시지를 LLM에 추가하여 컨텍스트로 작용하게 하고, LLM이 호출한 모든 함수에 대해 인식하게 만듭니다. 

```python
messages.append(ai_msg)
```


도구 호출은 두 단계로 이루어집니다:

1. 첫 번째 호출에서 LLM이 선택한 모든 도구를 수집하여 더 정확하고 환각 없는 결과를 제공하기 위한 추가 컨텍스트로 사용합니다. 
2. 두 번째 호출에서는 LLM이 결정한 도구 세트를 파싱하고 실행합니다 (우리의 경우 정의한 함수와 LLM이 추출한 인수로). 이 결과를 LLM에 전달합니다.

```python
<!--IMPORTS:[{"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "ChatPremAI"}]-->
from langchain_core.messages import ToolMessage

for tool_call in ai_msg.tool_calls:
    selected_tool = {"add": add, "multiply": multiply}[tool_call["name"].lower()]
    tool_output = selected_tool.invoke(tool_call["args"])
    messages.append(ToolMessage(tool_output, tool_call_id=tool_call["id"]))
```


마지막으로, 도구와 바인딩된 LLM을 함수 응답이 추가된 컨텍스트로 호출합니다. 

```python
response = llm_with_tools.invoke(messages)
print(response.content)
```

```output
The final answers are:

- 3 * 12 = 36
- 11 + 49 = 60
```

### 도구 스키마 정의: Pydantic 클래스

위에서는 `tool` 데코레이터를 사용하여 스키마를 정의하는 방법을 보여주었지만, Pydantic을 사용하여 스키마를 동등하게 정의할 수 있습니다. Pydantic은 도구 입력이 더 복잡할 때 유용합니다:

```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers.openai_tools", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "ChatPremAI"}]-->
from langchain_core.output_parsers.openai_tools import PydanticToolsParser


class add(BaseModel):
    """Add two integers together."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


class multiply(BaseModel):
    """Multiply two integers together."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


tools = [add, multiply]
```


이제 이를 채팅 모델에 바인딩하고 직접 결과를 얻을 수 있습니다:

```python
chain = llm_with_tools | PydanticToolsParser(tools=[multiply, add])
chain.invoke(query)
```


```output
[multiply(a=3, b=12), add(a=11, b=49)]
```


이제 위와 같이 이를 파싱하고 이 함수를 실행한 후 LLM을 다시 호출하여 결과를 얻습니다.

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
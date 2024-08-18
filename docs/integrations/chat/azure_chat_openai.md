---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/azure_chat_openai.ipynb
description: 이 가이드는 Azure OpenAI의 채팅 모델을 시작하는 데 도움을 주며, 기능 및 구성에 대한 자세한 문서는 API 참조에서
  확인할 수 있습니다.
sidebar_label: Azure OpenAI
---

# AzureChatOpenAI

이 가이드는 AzureOpenAI [채팅 모델](/docs/concepts/#chat-models) 사용을 시작하는 데 도움을 줍니다. AzureChatOpenAI의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.azure.AzureChatOpenAI.html)에서 확인할 수 있습니다.

Azure OpenAI에는 여러 채팅 모델이 있습니다. 최신 모델 및 비용, 컨텍스트 창, 지원되는 입력 유형에 대한 정보는 [Azure 문서](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models)에서 찾을 수 있습니다.

:::info Azure OpenAI vs OpenAI

Azure OpenAI는 [Microsoft Azure 플랫폼](https://azure.microsoft.com/en-us/products/ai-services/openai-service)에서 호스팅되는 OpenAI 모델을 의미합니다. OpenAI는 자체 모델 API도 제공합니다. OpenAI 서비스에 직접 액세스하려면 [ChatOpenAI 통합](/docs/integrations/chat/openai/)를 사용하세요.

:::

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/azure) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [AzureChatOpenAI](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.azure.AzureChatOpenAI.html) | [langchain-openai](https://api.python.langchain.com/en/latest/openai_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-openai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-openai?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | 

## 설정

AzureOpenAI 모델에 액세스하려면 Azure 계정을 만들고 Azure OpenAI 모델의 배포를 생성한 다음 배포의 이름과 엔드포인트를 가져오고 Azure OpenAI API 키를 얻고 `langchain-openai` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Azure 문서](https://learn.microsoft.com/en-us/azure/ai-services/openai/chatgpt-quickstart?tabs=command-line%2Cpython-new&pivots=programming-language-python)로 이동하여 배포를 생성하고 API 키를 생성하세요. 이 작업을 완료한 후 AZURE_OPENAI_API_KEY 및 AZURE_OPENAI_ENDPOINT 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["AZURE_OPENAI_API_KEY"] = getpass.getpass("Enter your AzureOpenAI API key: ")
os.environ["AZURE_OPENAI_ENDPOINT"] = "https://YOUR-ENDPOINT.openai.azure.com/"
```


모델 호출의 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain AzureOpenAI 통합은 `langchain-openai` 패키지에 포함되어 있습니다:

```python
%pip install -qU langchain-openai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완료를 생성할 수 있습니다.
- `azure_deployment`를 배포의 이름으로 바꾸세요,
- 최신 지원되는 `api_version`은 여기에서 확인할 수 있습니다: https://learn.microsoft.com/en-us/azure/ai-services/openai/reference.

```python
<!--IMPORTS:[{"imported": "AzureChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.azure.AzureChatOpenAI.html", "title": "AzureChatOpenAI"}]-->
from langchain_openai import AzureChatOpenAI

llm = AzureChatOpenAI(
    azure_deployment="gpt-35-turbo",  # or your deployment
    api_version="2023-06-01-preview",  # or your api version
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
    # other params...
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


```output
AIMessage(content="J'adore la programmation.", response_metadata={'token_usage': {'completion_tokens': 8, 'prompt_tokens': 31, 'total_tokens': 39}, 'model_name': 'gpt-35-turbo', 'system_fingerprint': None, 'prompt_filter_results': [{'prompt_index': 0, 'content_filter_results': {'hate': {'filtered': False, 'severity': 'safe'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': False, 'severity': 'safe'}}}], 'finish_reason': 'stop', 'logprobs': None, 'content_filter_results': {'hate': {'filtered': False, 'severity': 'safe'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': False, 'severity': 'safe'}}}, id='run-bea4b46c-e3e1-4495-9d3a-698370ad963d-0', usage_metadata={'input_tokens': 31, 'output_tokens': 8, 'total_tokens': 39})
```


```python
print(ai_msg.content)
```

```output
J'adore la programmation.
```

## 체이닝

모델을 프롬프트 템플릿과 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "AzureChatOpenAI"}]-->
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


```output
AIMessage(content='Ich liebe das Programmieren.', response_metadata={'token_usage': {'completion_tokens': 6, 'prompt_tokens': 26, 'total_tokens': 32}, 'model_name': 'gpt-35-turbo', 'system_fingerprint': None, 'prompt_filter_results': [{'prompt_index': 0, 'content_filter_results': {'hate': {'filtered': False, 'severity': 'safe'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': False, 'severity': 'safe'}}}], 'finish_reason': 'stop', 'logprobs': None, 'content_filter_results': {'hate': {'filtered': False, 'severity': 'safe'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': False, 'severity': 'safe'}}}, id='run-cbc44038-09d3-40d4-9da2-c5910ee636ca-0', usage_metadata={'input_tokens': 26, 'output_tokens': 6, 'total_tokens': 32})
```


## 모델 버전 지정

Azure OpenAI 응답에는 응답을 생성하는 데 사용된 모델의 이름인 `model_name` 응답 메타데이터 속성이 포함되어 있습니다. 그러나 기본 OpenAI 응답과 달리 Azure에서 배포에 설정된 모델의 특정 버전은 포함되어 있지 않습니다. 예를 들어 `gpt-35-turbo-0125`와 `gpt-35-turbo-0301`을 구분하지 않습니다. 이로 인해 응답을 생성하는 데 사용된 모델의 버전을 알기 어려워지며, 결과적으로 `OpenAICallbackHandler`와 함께 잘못된 총 비용 계산으로 이어질 수 있습니다.

이 문제를 해결하려면 `AzureChatOpenAI` 클래스에 `model_version` 매개변수를 전달하여 llm 출력의 모델 이름에 추가할 수 있습니다. 이렇게 하면 모델의 다양한 버전을 쉽게 구분할 수 있습니다.

```python
%pip install -qU langchain-community
```


```python
<!--IMPORTS:[{"imported": "get_openai_callback", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_openai_callback.html", "title": "AzureChatOpenAI"}]-->
from langchain_community.callbacks import get_openai_callback

with get_openai_callback() as cb:
    llm.invoke(messages)
    print(
        f"Total Cost (USD): ${format(cb.total_cost, '.6f')}"
    )  # without specifying the model version, flat-rate 0.002 USD per 1k input and output tokens is used
```

```output
Total Cost (USD): $0.000063
```


```python
llm_0301 = AzureChatOpenAI(
    azure_deployment="gpt-35-turbo",  # or your deployment
    api_version="2023-06-01-preview",  # or your api version
    model_version="0301",
)
with get_openai_callback() as cb:
    llm_0301.invoke(messages)
    print(f"Total Cost (USD): ${format(cb.total_cost, '.6f')}")
```

```output
Total Cost (USD): $0.000074
```

## API 참조

AzureChatOpenAI의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.azure.AzureChatOpenAI.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
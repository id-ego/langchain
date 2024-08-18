---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/oci_generative_ai.ipynb
description: 이 문서는 OCIGenAI 채팅 모델을 시작하는 방법과 API 참조에 대한 정보를 제공합니다. OCI 생성 AI 서비스의 기능을
  탐색하세요.
sidebar_label: OCIGenAI
---

# ChatOCIGenAI

이 노트북은 OCIGenAI [채팅 모델](/docs/concepts/#chat-models)을 시작하는 데 필요한 간단한 개요를 제공합니다. 모든 ChatOCIGenAI 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.oci_generative_ai.ChatOCIGenAI.html)에서 확인할 수 있습니다.

Oracle Cloud Infrastructure (OCI) Generative AI는 다양한 사용 사례를 포괄하는 최첨단의 사용자 정의 가능한 대형 언어 모델(LLM) 세트를 제공하는 완전 관리형 서비스로, 단일 API를 통해 제공됩니다. OCI Generative AI 서비스를 사용하면 즉시 사용할 수 있는 사전 훈련된 모델에 접근하거나, 전용 AI 클러스터에서 자신의 데이터에 기반하여 세밀하게 조정된 사용자 정의 모델을 생성하고 호스팅할 수 있습니다. 서비스 및 API에 대한 자세한 문서는 **[여기](https://docs.oracle.com/en-us/iaas/Content/generative-ai/home.htm)** 및 **[여기](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai/20231130/)**에서 확인할 수 있습니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/oci_generative_ai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatOCIGenAI](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.oci_generative_ai.ChatOCIGenAI.html) | [langchain-community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-oci-generative-ai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-oci-generative-ai?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling/) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | 

## 설정

OCIGenAI 모델에 접근하려면 `oci` 및 `langchain-community` 패키지를 설치해야 합니다.

### 자격 증명

이 통합에 대해 지원되는 자격 증명 및 인증 방법은 다른 OCI 서비스와 동일하며 **[표준 SDK 인증](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdk_authentication_methods.htm)** 방법을 따릅니다. 구체적으로 API 키, 세션 토큰, 인스턴스 주체 및 리소스 주체가 있습니다.

API 키는 위의 예제에서 사용되는 기본 인증 방법입니다. 다음 예제는 다른 인증 방법(세션 토큰)을 사용하는 방법을 보여줍니다.

### 설치

LangChain OCIGenAI 통합은 `langchain-community` 패키지에 있으며 `oci` 패키지도 설치해야 합니다:

```python
%pip install -qU langchain-community oci
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatOCIGenAI", "source": "langchain_community.chat_models.oci_generative_ai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.oci_generative_ai.ChatOCIGenAI.html", "title": "ChatOCIGenAI"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "ChatOCIGenAI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatOCIGenAI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatOCIGenAI"}]-->
from langchain_community.chat_models.oci_generative_ai import ChatOCIGenAI
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage

chat = ChatOCIGenAI(
    model_id="cohere.command-r-16k",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0.7, "max_tokens": 500},
)
```


## 호출

```python
messages = [
    SystemMessage(content="your are an AI assistant."),
    AIMessage(content="Hi there human!"),
    HumanMessage(content="tell me a joke."),
]
response = chat.invoke(messages)
```


```python
print(response.content)
```


## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatOCIGenAI"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("Tell me a joke about {topic}")
chain = prompt | chat

response = chain.invoke({"topic": "dogs"})
print(response.content)
```


## API 참조

모든 ChatOCIGenAI 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.oci_generative_ai.ChatOCIGenAI.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
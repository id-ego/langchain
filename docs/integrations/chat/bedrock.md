---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/bedrock.ipynb
description: AWS Bedrock을 사용하여 고성능 AI 모델을 쉽게 실험하고 사용자 데이터로 맞춤화하여 생성 AI 애플리케이션을 구축하는
  방법을 안내합니다.
sidebar_label: AWS Bedrock
---

# ChatBedrock

이 문서는 AWS Bedrock [채팅 모델](/docs/concepts/#chat-models) 사용을 시작하는 데 도움을 줄 것입니다. Amazon Bedrock은 AI21 Labs, Anthropic, Cohere, Meta, Stability AI 및 Amazon과 같은 선도적인 AI 회사의 고성능 기초 모델(FM)을 단일 API를 통해 제공하는 완전 관리형 서비스로, 보안, 개인 정보 보호 및 책임 있는 AI로 생성 AI 애플리케이션을 구축하는 데 필요한 광범위한 기능을 제공합니다. Amazon Bedrock을 사용하면 사용 사례에 맞는 최고 FM을 쉽게 실험하고 평가하며, 미세 조정 및 검색 증강 생성(RAG)과 같은 기술을 사용하여 데이터를 통해 개인적으로 사용자 정의하고, 기업 시스템 및 데이터 소스를 사용하여 작업을 실행하는 에이전트를 구축할 수 있습니다. Amazon Bedrock은 서버리스이므로 인프라를 관리할 필요가 없으며, 이미 익숙한 AWS 서비스를 사용하여 생성 AI 기능을 애플리케이션에 안전하게 통합하고 배포할 수 있습니다.

Bedrock을 통해 접근할 수 있는 모델에 대한 자세한 정보는 [AWS 문서](https://docs.aws.amazon.com/bedrock/latest/userguide/models-features.html)를 참조하세요.

모든 ChatBedrock 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_aws.chat_models.bedrock.ChatBedrock.html)를 참조하세요.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/bedrock) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatBedrock](https://api.python.langchain.com/en/latest/chat_models/langchain_aws.chat_models.bedrock.ChatBedrock.html) | [langchain-aws](https://api.python.langchain.com/en/latest/aws_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-aws?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-aws?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [로그확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | 

## 설정

Bedrock 모델에 접근하려면 AWS 계정을 생성하고, Bedrock API 서비스를 설정하고, 액세스 키 ID 및 비밀 키를 얻고, `langchain-aws` 통합 패키지를 설치해야 합니다.

### 자격 증명

[AWS 문서](https://docs.aws.amazon.com/bedrock/latest/userguide/setting-up.html)로 이동하여 AWS에 가입하고 자격 증명을 설정하세요. 또한 계정에 대한 모델 액세스를 활성화해야 하며, 이는 [이 지침](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)을 따라 수행할 수 있습니다.

모델 호출에 대한 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Bedrock 통합은 `langchain-aws` 패키지에 있습니다:

```python
%pip install -qU langchain-aws
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
from langchain_aws import ChatBedrock

llm = ChatBedrock(
    model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    model_kwargs=dict(temperature=0),
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
AIMessage(content="Voici la traduction en français :\n\nJ'aime la programmation.", additional_kwargs={'usage': {'prompt_tokens': 29, 'completion_tokens': 21, 'total_tokens': 50}, 'stop_reason': 'end_turn', 'model_id': 'anthropic.claude-3-sonnet-20240229-v1:0'}, response_metadata={'usage': {'prompt_tokens': 29, 'completion_tokens': 21, 'total_tokens': 50}, 'stop_reason': 'end_turn', 'model_id': 'anthropic.claude-3-sonnet-20240229-v1:0'}, id='run-fdb07dc3-ff72-430d-b22b-e7824b15c766-0', usage_metadata={'input_tokens': 29, 'output_tokens': 21, 'total_tokens': 50})
```


```python
print(ai_msg.content)
```

```output
Voici la traduction en français :

J'aime la programmation.
```

## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatBedrock"}]-->
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
AIMessage(content='Ich liebe Programmieren.', additional_kwargs={'usage': {'prompt_tokens': 23, 'completion_tokens': 11, 'total_tokens': 34}, 'stop_reason': 'end_turn', 'model_id': 'anthropic.claude-3-sonnet-20240229-v1:0'}, response_metadata={'usage': {'prompt_tokens': 23, 'completion_tokens': 11, 'total_tokens': 34}, 'stop_reason': 'end_turn', 'model_id': 'anthropic.claude-3-sonnet-20240229-v1:0'}, id='run-5ad005ce-9f31-4670-baa0-9373d418698a-0', usage_metadata={'input_tokens': 23, 'output_tokens': 11, 'total_tokens': 34})
```


## ***베타***: Bedrock 대화 API

AWS는 최근 Bedrock 모델을 위한 통합 대화 인터페이스를 제공하는 Bedrock 대화 API를 출시했습니다. 이 API는 아직 사용자 정의 모델을 지원하지 않습니다. 지원되는 모든 [모델 목록은 여기에서 확인할 수 있습니다](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html). 신뢰성을 개선하기 위해 ChatBedrock 통합은 기존 Bedrock API와 기능이 동등해지는 즉시 Bedrock 대화 API를 사용하도록 전환할 것입니다. 그때까지는 사용자 정의 모델을 사용할 필요가 없는 사용자들을 위해 별도의 [ChatBedrockConverse](https://api.python.langchain.com/en/latest/chat_models/langchain_aws.chat_models.bedrock_converse.ChatBedrockConverse.html#langchain_aws.chat_models.bedrock_converse.ChatBedrockConverse) 통합이 베타로 출시되었습니다.

다음과 같이 사용할 수 있습니다:

```python
from langchain_aws import ChatBedrockConverse

llm = ChatBedrockConverse(
    model="anthropic.claude-3-sonnet-20240229-v1:0",
    temperature=0,
    max_tokens=None,
    # other params...
)

llm.invoke(messages)
```

```output
/Users/bagatur/langchain/libs/core/langchain_core/_api/beta_decorator.py:87: LangChainBetaWarning: The class `ChatBedrockConverse` is in beta. It is actively being worked on, so the API may change.
  warn_beta(
```


```output
AIMessage(content="Voici la traduction en français :\n\nJ'aime la programmation.", response_metadata={'ResponseMetadata': {'RequestId': '122fb1c8-c3c5-4b06-941e-c95d210bfbc7', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Mon, 01 Jul 2024 21:48:25 GMT', 'content-type': 'application/json', 'content-length': '243', 'connection': 'keep-alive', 'x-amzn-requestid': '122fb1c8-c3c5-4b06-941e-c95d210bfbc7'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': 830}}, id='run-0e3df22f-fcd8-4fbb-a4fb-565227e7e430-0', usage_metadata={'input_tokens': 29, 'output_tokens': 21, 'total_tokens': 50})
```


## API 참조

모든 ChatBedrock 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_aws.chat_models.bedrock.ChatBedrock.html

모든 ChatBedrockConverse 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_aws.chat_models.bedrock_converse.ChatBedrockConverse.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
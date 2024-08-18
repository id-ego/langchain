---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/google_vertex_ai_palm.ipynb
description: VertexAI의 채팅 모델 시작을 위한 개요와 API 참조 링크를 제공하며, Google Cloud의 다양한 모델을 소개합니다.
sidebar_label: Google Cloud Vertex AI
---

# ChatVertexAI

이 페이지는 VertexAI [채팅 모델](/docs/concepts/#chat-models) 시작을 위한 간단한 개요를 제공합니다. ChatVertexAI의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_google_vertexai.chat_models.ChatVertexAI.html)로 이동하세요.

ChatVertexAI는 `gemini-1.5-pro`, `gemini-1.5-flash` 등과 같은 Google Cloud에서 제공하는 모든 기본 모델을 노출합니다. 사용 가능한 모델의 전체 및 최신 목록은 [VertexAI 문서](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/overview)를 방문하세요.

:::info Google Cloud VertexAI vs Google PaLM

Google Cloud VertexAI 통합은 [Google PaLM 통합](/docs/integrations/chat/google_generative_ai/)과 별개입니다. Google은 GCP를 통해 PaLM의 엔터프라이즈 버전을 제공하기로 선택했으며, 이를 통해 제공되는 모델을 지원합니다.

:::

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/google_vertex_ai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatVertexAI](https://api.python.langchain.com/en/latest/chat_models/langchain_google_vertexai.chat_models.ChatVertexAI.html) | [langchain-google-vertexai](https://api.python.langchain.com/en/latest/google_vertexai_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-google-vertexai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-google-vertexai?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | 

## 설정

VertexAI 모델에 접근하려면 Google Cloud Platform 계정을 생성하고, 자격 증명을 설정하고, `langchain-google-vertexai` 통합 패키지를 설치해야 합니다.

### 자격 증명

통합을 사용하려면 다음이 필요합니다:
- 환경에 대한 자격 증명이 구성되어 있어야 합니다 (gcloud, 작업 부하 ID 등...)
- 서비스 계정 JSON 파일의 경로를 GOOGLE_APPLICATION_CREDENTIALS 환경 변수로 저장해야 합니다.

이 코드베이스는 먼저 위에서 언급한 애플리케이션 자격 증명 변수를 찾고, 그 다음 시스템 수준 인증을 찾는 `google.auth` 라이브러리를 사용합니다.

자세한 정보는 다음을 참조하세요:
- https://cloud.google.com/docs/authentication/application-default-credentials#GAC
- https://googleapis.dev/python/google-auth/latest/reference/google.auth.html#module-google.auth

모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain VertexAI 통합은 `langchain-google-vertexai` 패키지에 포함되어 있습니다:

```python
%pip install -qU langchain-google-vertexai
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
from langchain_google_vertexai import ChatVertexAI

llm = ChatVertexAI(
    model="gemini-1.5-flash-001",
    temperature=0,
    max_tokens=None,
    max_retries=6,
    stop=None,
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
AIMessage(content="J'adore programmer. \n", response_metadata={'is_blocked': False, 'safety_ratings': [{'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}], 'usage_metadata': {'prompt_token_count': 20, 'candidates_token_count': 7, 'total_token_count': 27}}, id='run-7032733c-d05c-4f0c-a17a-6c575fdd1ae0-0', usage_metadata={'input_tokens': 20, 'output_tokens': 7, 'total_tokens': 27})
```


```python
print(ai_msg.content)
```

```output
J'adore programmer.
```

## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatVertexAI"}]-->
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
AIMessage(content='Ich liebe Programmieren. \n', response_metadata={'is_blocked': False, 'safety_ratings': [{'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}], 'usage_metadata': {'prompt_token_count': 15, 'candidates_token_count': 8, 'total_token_count': 23}}, id='run-c71955fd-8dc1-422b-88a7-853accf4811b-0', usage_metadata={'input_tokens': 15, 'output_tokens': 8, 'total_tokens': 23})
```


## API 참조

모든 ChatVertexAI 기능 및 구성에 대한 자세한 문서는 멀티모달 입력을 전송하고 안전 설정을 구성하는 방법과 같은 내용을 포함하여 API 참조로 이동하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_google_vertexai.chat_models.ChatVertexAI.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
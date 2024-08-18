---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/groq.ipynb
description: ChatGroq는 Groq 채팅 모델을 시작하는 데 도움이 되며, API 참조 및 모델 목록에 대한 링크를 제공합니다.
sidebar_label: Groq
---

# ChatGroq

이 문서는 Groq [채팅 모델](../../concepts.mdx#chat-models) 시작하는 데 도움이 됩니다. 모든 ChatGroq 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_groq.chat_models.ChatGroq.html)에서 확인할 수 있습니다. 모든 Groq 모델 목록은 이 [링크](https://console.groq.com/docs/models)에서 확인하세요.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/groq) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatGroq](https://api.python.langchain.com/en/latest/chat_models/langchain_groq.chat_models.ChatGroq.html) | [langchain-groq](https://api.python.langchain.com/en/latest/groq_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-groq?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-groq?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](../../how_to/tool_calling.md) | [구조화된 출력](../../how_to/structured_output.md) | JSON 모드 | [이미지 입력](../../how_to/multimodal_inputs.md) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](../../how_to/chat_streaming.md) | 네이티브 비동기 | [토큰 사용](../../how_to/chat_token_usage_tracking.md) | [로그 확률](../../how_to/logprobs.md) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | 

## 설정

Groq 모델에 접근하려면 Groq 계정을 생성하고 API 키를 얻고 `langchain-groq` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Groq 콘솔](https://console.groq.com/keys)로 이동하여 Groq에 가입하고 API 키를 생성하세요. 이 작업이 완료되면 GROQ_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["GROQ_API_KEY"] = getpass.getpass("Enter your Groq API key: ")
```


모델 호출에 대한 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Groq 통합은 `langchain-groq` 패키지에 있습니다:

```python
%pip install -qU langchain-groq
```

```output

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m24.0[0m[39;49m -> [0m[32;49m24.1.2[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatGroq", "source": "langchain_groq", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_groq.chat_models.ChatGroq.html", "title": "ChatGroq"}]-->
from langchain_groq import ChatGroq

llm = ChatGroq(
    model="mixtral-8x7b-32768",
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
AIMessage(content='I enjoy programming. (The French translation is: "J\'aime programmer.")\n\nNote: I chose to translate "I love programming" as "J\'aime programmer" instead of "Je suis amoureux de programmer" because the latter has a romantic connotation that is not present in the original English sentence.', response_metadata={'token_usage': {'completion_tokens': 73, 'prompt_tokens': 31, 'total_tokens': 104, 'completion_time': 0.1140625, 'prompt_time': 0.003352463, 'queue_time': None, 'total_time': 0.117414963}, 'model_name': 'mixtral-8x7b-32768', 'system_fingerprint': 'fp_c5f20b5bb1', 'finish_reason': 'stop', 'logprobs': None}, id='run-64433c19-eadf-42fc-801e-3071e3c40160-0', usage_metadata={'input_tokens': 31, 'output_tokens': 73, 'total_tokens': 104})
```


```python
print(ai_msg.content)
```

```output
I enjoy programming. (The French translation is: "J'aime programmer.")

Note: I chose to translate "I love programming" as "J'aime programmer" instead of "Je suis amoureux de programmer" because the latter has a romantic connotation that is not present in the original English sentence.
```

## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](../../how_to/sequence.md)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatGroq"}]-->
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
AIMessage(content='That\'s great! I can help you translate English phrases related to programming into German.\n\n"I love programming" can be translated as "Ich liebe Programmieren" in German.\n\nHere are some more programming-related phrases translated into German:\n\n* "Programming language" = "Programmiersprache"\n* "Code" = "Code"\n* "Variable" = "Variable"\n* "Function" = "Funktion"\n* "Array" = "Array"\n* "Object-oriented programming" = "Objektorientierte Programmierung"\n* "Algorithm" = "Algorithmus"\n* "Data structure" = "Datenstruktur"\n* "Debugging" = "Fehlersuche"\n* "Compile" = "Kompilieren"\n* "Link" = "Verknüpfen"\n* "Run" = "Ausführen"\n* "Test" = "Testen"\n* "Deploy" = "Bereitstellen"\n* "Version control" = "Versionskontrolle"\n* "Open source" = "Open Source"\n* "Software development" = "Softwareentwicklung"\n* "Agile methodology" = "Agile Methodik"\n* "DevOps" = "DevOps"\n* "Cloud computing" = "Cloud Computing"\n\nI hope this helps! Let me know if you have any other questions or if you need further translations.', response_metadata={'token_usage': {'completion_tokens': 331, 'prompt_tokens': 25, 'total_tokens': 356, 'completion_time': 0.520006542, 'prompt_time': 0.00250165, 'queue_time': None, 'total_time': 0.522508192}, 'model_name': 'mixtral-8x7b-32768', 'system_fingerprint': 'fp_c5f20b5bb1', 'finish_reason': 'stop', 'logprobs': None}, id='run-74207fb7-85d3-417d-b2b9-621116b75d41-0', usage_metadata={'input_tokens': 25, 'output_tokens': 331, 'total_tokens': 356})
```


## API 참조

모든 ChatGroq 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_groq.chat_models.ChatGroq.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
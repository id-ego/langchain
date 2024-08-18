---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/yi.ipynb
description: ChatYI는 Yi 채팅 모델을 시작하는 데 도움이 되는 문서로, 01.AI의 최신 AI 기술과 다양한 기능을 소개합니다.
---

# ChatYI

이 문서는 Yi [채팅 모델](/docs/concepts/#chat-models) 시작하는 데 도움을 줄 것입니다. ChatYi의 모든 기능과 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/lanchain_community.chat_models.yi.ChatYi.html)에서 확인하세요.

[01.AI](https://www.lingyiwanwu.com/en)는 Dr. Kai-Fu Lee가 설립한 AI 2.0의 최전선에 있는 글로벌 기업입니다. 그들은 6B에서 수백억 개의 매개변수에 이르는 Yi 시리즈를 포함한 최첨단 대형 언어 모델을 제공합니다. 01.AI는 또한 다중 모드 모델, 오픈 API 플랫폼 및 Yi-34B/9B/6B와 Yi-VL과 같은 오픈 소스 옵션을 제공합니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatYi](https://api.python.langchain.com/en/latest/chat_models/lanchain_community.chat_models.yi.ChatYi.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | 

## 설정

ChatYi 모델에 접근하려면 01.AI 계정을 만들고, API 키를 얻고, `langchain_community` 통합 패키지를 설치해야 합니다.

### 자격 증명

[01.AI](https://platform.01.ai)로 가서 01.AI에 가입하고 API 키를 생성하세요. 이 작업을 완료한 후 `YI_API_KEY` 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["YI_API_KEY"] = getpass.getpass("Enter your Yi API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain **ModuleName** 통합은 `langchain_community` 패키지에 있습니다:

```python
%pip install -qU langchain_community
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

- TODO: 관련 매개변수로 모델 인스턴스화 업데이트.

```python
<!--IMPORTS:[{"imported": "ChatYi", "source": "langchain_community.chat_models.yi", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yi.ChatYi.html", "title": "ChatYI"}]-->
from langchain_community.chat_models.yi import ChatYi

llm = ChatYi(
    model="yi-large",
    temperature=0,
    timeout=60,
    yi_api_base="https://api.01.ai/v1/chat/completions",
    # other params...
)
```


## 호출

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatYI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatYI"}]-->
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="You are an AI assistant specializing in technology trends."),
    HumanMessage(
        content="What are the potential applications of large language models in healthcare?"
    ),
]

ai_msg = llm.invoke(messages)
ai_msg
```


```output
AIMessage(content="Large Language Models (LLMs) have the potential to significantly impact healthcare by enhancing various aspects of patient care, research, and administrative processes. Here are some potential applications:\n\n1. **Clinical Documentation and Reporting**: LLMs can assist in generating patient reports and documentation by understanding and summarizing clinical notes, making the process more efficient and reducing the administrative burden on healthcare professionals.\n\n2. **Medical Coding and Billing**: These models can help in automating the coding process for medical billing by accurately translating clinical notes into standardized codes, reducing errors and improving billing efficiency.\n\n3. **Clinical Decision Support**: LLMs can analyze patient data and medical literature to provide evidence-based recommendations to healthcare providers, aiding in diagnosis and treatment planning.\n\n4. **Patient Education and Communication**: By simplifying medical jargon, LLMs can help in educating patients about their conditions, treatment options, and preventive care, improving patient engagement and health literacy.\n\n5. **Natural Language Processing (NLP) for EHRs**: LLMs can enhance NLP capabilities in Electronic Health Records (EHRs) systems, enabling better extraction of information from unstructured data, such as clinical notes, to support data-driven decision-making.\n\n6. **Drug Discovery and Development**: LLMs can analyze biomedical literature and clinical trial data to identify new drug candidates, predict drug interactions, and support the development of personalized medicine.\n\n7. **Telemedicine and Virtual Health Assistants**: Integrated into telemedicine platforms, LLMs can provide preliminary assessments and triage, offering patients basic health advice and determining the urgency of their needs, thus optimizing the utilization of healthcare resources.\n\n8. **Research and Literature Review**: LLMs can expedite the process of reviewing medical literature by quickly identifying relevant studies and summarizing findings, accelerating research and evidence-based practice.\n\n9. **Personalized Medicine**: By analyzing a patient's genetic information and medical history, LLMs can help in tailoring treatment plans and medication dosages, contributing to the advancement of personalized medicine.\n\n10. **Quality Improvement and Risk Assessment**: LLMs can analyze healthcare data to identify patterns that may indicate areas for quality improvement or potential risks, such as hospital-acquired infections or adverse drug events.\n\n11. **Mental Health Support**: LLMs can provide mental health support by offering coping strategies, mindfulness exercises, and preliminary assessments, serving as a complement to professional mental health services.\n\n12. **Continuing Medical Education (CME)**: LLMs can personalize CME by recommending educational content based on a healthcare provider's practice area, patient demographics, and emerging medical literature, ensuring that professionals stay updated with the latest advancements.\n\nWhile the applications of LLMs in healthcare are promising, it's crucial to address challenges such as data privacy, model bias, and the need for regulatory approval to ensure that these technologies are implemented safely and ethically.", response_metadata={'token_usage': {'completion_tokens': 656, 'prompt_tokens': 40, 'total_tokens': 696}, 'model': 'yi-large'}, id='run-870850bd-e4bf-4265-8730-1736409c0acf-0')
```


## 체이닝

다음과 같이 프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatYI"}]-->
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
AIMessage(content='Ich liebe das Programmieren.', response_metadata={'token_usage': {'completion_tokens': 8, 'prompt_tokens': 33, 'total_tokens': 41}, 'model': 'yi-large'}, id='run-daa3bc58-8289-4d72-a24e-80622fa90d6d-0')
```


## API 참조

ChatYi의 모든 기능과 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yi.ChatYi.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
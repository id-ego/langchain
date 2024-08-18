---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/cohere.ipynb
description: Cohere는 기업의 인간-기계 상호작용을 개선하는 자연어 처리 모델을 제공하는 캐나다 스타트업입니다.
---

# Cohere

:::caution
현재 [텍스트 완성 모델](/docs/concepts/#llms)로서 Cohere 모델 사용에 대한 문서 페이지에 있습니다. 많은 인기 있는 Cohere 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)입니다.

대신 [이 페이지](/docs/integrations/chat/cohere/)를 찾고 있을 수 있습니다.
:::

> [Cohere](https://cohere.ai/about)는 기업이 인간-기계 상호작용을 개선하는 데 도움을 주는 자연어 처리 모델을 제공하는 캐나다 스타트업입니다.

모든 속성과 메서드에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/llms/langchain_community.llms.cohere.Cohere.html)에서 확인하세요.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/llms/cohere/) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [Cohere](https://api.python.langchain.com/en/latest/llms/langchain_community.llms.cohere.Cohere.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

## 설정

통합은 `langchain-community` 패키지에 있습니다. `cohere` 패키지 자체도 설치해야 합니다. 다음과 같이 설치할 수 있습니다:

### 자격 증명

[Cohere API 키](https://cohere.com/)를 받아야 하며 `COHERE_API_KEY` 환경 변수를 설정해야 합니다:

```python
import getpass
import os

if "COHERE_API_KEY" not in os.environ:
    os.environ["COHERE_API_KEY"] = getpass.getpass()
```


### 설치

```python
pip install -U langchain-community langchain-cohere
```


최고 수준의 가시성을 위해 [LangSmith](https://smith.langchain.com/)를 설정하는 것도 도움이 됩니다(필수는 아님).

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 호출

Cohere는 모든 [LLM](/docs/how_to#llms) 기능을 지원합니다:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Cohere"}]-->
from langchain_cohere import Cohere
from langchain_core.messages import HumanMessage
```


```python
model = Cohere(max_tokens=256, temperature=0.75)
```


```python
message = "Knock knock"
model.invoke(message)
```


```output
" Who's there?"
```


```python
await model.ainvoke(message)
```


```output
" Who's there?"
```


```python
for chunk in model.stream(message):
    print(chunk, end="", flush=True)
```

```output
 Who's there?
```


```python
model.batch([message])
```


```output
[" Who's there?"]
```


## 체이닝

프롬프트 템플릿과 쉽게 결합하여 사용자 입력을 쉽게 구조화할 수 있습니다. [LCEL](/docs/concepts#langchain-expression-language-lcel)을 사용하여 이를 수행할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Cohere"}]-->
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate.from_template("Tell me a joke about {topic}")
chain = prompt | model
```


```python
chain.invoke({"topic": "bears"})
```


```output
' Why did the teddy bear cross the road?\nBecause he had bear crossings.\n\nWould you like to hear another joke? '
```


## API 참조

모든 `Cohere` llm 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/llms/langchain_community.llms.cohere.Cohere.html

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
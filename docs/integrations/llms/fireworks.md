---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/fireworks.ipynb
description: Fireworks 모델을 사용하여 LangChain과 상호작용하는 방법을 설명하는 문서입니다. 생성 AI를 통한 제품 개발을
  가속화합니다.
---

# 불꽃놀이

:::caution
현재 [텍스트 완성 모델](/docs/concepts/#llms)로서 불꽃놀이 모델 사용에 대한 문서 페이지에 있습니다. 많은 인기 있는 불꽃놀이 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)입니다.

대신 [이 페이지](/docs/integrations/chat/fireworks/)를 찾고 있을 수 있습니다.
:::

> [불꽃놀이](https://app.fireworks.ai/)는 혁신적인 AI 실험 및 생산 플랫폼을 통해 생성 AI에서 제품 개발을 가속화합니다.

이 예제에서는 LangChain을 사용하여 `Fireworks` 모델과 상호작용하는 방법을 설명합니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.1/docs/integrations/llms/fireworks/) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [Fireworks](https://api.python.langchain.com/en/latest/llms/langchain_fireworks.llms.Fireworks.html#langchain_fireworks.llms.Fireworks) | [langchain_fireworks](https://api.python.langchain.com/en/latest/fireworks_api_reference.html) | ❌ | ❌ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_fireworks?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_fireworks?style=flat-square&label=%20) |

## 설정

### 자격 증명

[Fireworks AI](http://fireworks.ai)에 로그인하여 모델에 접근할 API 키를 얻고, 이를 `FIREWORKS_API_KEY` 환경 변수로 설정하세요.
3. 모델 ID를 사용하여 모델을 설정하세요. 모델이 설정되지 않은 경우 기본 모델은 fireworks-llama-v2-7b-chat입니다. [fireworks.ai](https://fireworks.ai)에서 최신 모델 목록을 확인하세요.

```python
import getpass
import os

if "FIREWORKS_API_KEY" not in os.environ:
    os.environ["FIREWORKS_API_KEY"] = getpass.getpass("Fireworks API Key:")
```


### 설치

나머지 노트북이 작동하려면 `langchain_fireworks` 파이썬 패키지를 설치해야 합니다.

```python
%pip install -qU langchain-fireworks
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

```python
<!--IMPORTS:[{"imported": "Fireworks", "source": "langchain_fireworks", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_fireworks.llms.Fireworks.html", "title": "Fireworks"}]-->
from langchain_fireworks import Fireworks

# Initialize a Fireworks model
llm = Fireworks(
    model="accounts/fireworks/models/mixtral-8x7b-instruct",
    base_url="https://api.fireworks.ai/inference/v1/completions",
)
```


## 호출

문자열 프롬프트로 모델을 직접 호출하여 완성을 얻을 수 있습니다.

```python
output = llm.invoke("Who's the best quarterback in the NFL?")
print(output)
```

```output
 If Manningville Station, Lions rookie EJ Manuel's
```

### 여러 프롬프트로 호출하기

```python
# Calling multiple prompts
output = llm.generate(
    [
        "Who's the best cricket player in 2016?",
        "Who's the best basketball player in the league?",
    ]
)
print(output.generations)
```

```output
[[Generation(text=" We're not just asking, we've done some research. We'")], [Generation(text=' The conversation is dominated by Kobe Bryant, Dwyane Wade,')]]
```

### 추가 매개변수로 호출하기

```python
# Setting additional parameters: temperature, max_tokens, top_p
llm = Fireworks(
    model="accounts/fireworks/models/mixtral-8x7b-instruct",
    temperature=0.7,
    max_tokens=15,
    top_p=1.0,
)
print(llm.invoke("What's the weather like in Kansas City in December?"))
```

```output

December is a cold month in Kansas City, with temperatures of
```

## 체이닝

LangChain 표현 언어를 사용하여 비채팅 모델로 간단한 체인을 만들 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Fireworks"}, {"imported": "Fireworks", "source": "langchain_fireworks", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_fireworks.llms.Fireworks.html", "title": "Fireworks"}]-->
from langchain_core.prompts import PromptTemplate
from langchain_fireworks import Fireworks

llm = Fireworks(
    model="accounts/fireworks/models/mixtral-8x7b-instruct",
    temperature=0.7,
    max_tokens=15,
    top_p=1.0,
)
prompt = PromptTemplate.from_template("Tell me a joke about {topic}?")
chain = prompt | llm

print(chain.invoke({"topic": "bears"}))
```

```output
 What do you call a bear with no teeth? A gummy bear!
```

## 스트리밍

원하는 경우 출력을 스트리밍할 수 있습니다.

```python
for token in chain.stream({"topic": "bears"}):
    print(token, end="", flush=True)
```

```output
 Why do bears hate shoes so much? They like to run around in their
```

## API 참조

모든 `Fireworks` LLM 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/llms/langchain_fireworks.llms.Fireworks.html#langchain_fireworks.llms.Fireworks

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
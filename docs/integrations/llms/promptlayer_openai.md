---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/promptlayer_openai.ipynb
description: '`PromptLayer`는 GPT 프롬프트 엔지니어링을 추적, 관리 및 공유할 수 있는 플랫폼으로, OpenAI API 요청을
  기록합니다.'
---

# PromptLayer OpenAI

`PromptLayer`는 GPT 프롬프트 엔지니어링을 추적, 관리 및 공유할 수 있는 첫 번째 플랫폼입니다. `PromptLayer`는 코드와 `OpenAI`의 파이썬 라이브러리 사이의 미들웨어 역할을 합니다.

`PromptLayer`는 모든 `OpenAI API` 요청을 기록하여 `PromptLayer` 대시보드에서 요청 기록을 검색하고 탐색할 수 있게 합니다.

이 예제는 [PromptLayer](https://www.promptlayer.com)에 연결하여 OpenAI 요청을 기록하는 방법을 보여줍니다.

또 다른 예제는 [여기](/docs/integrations/providers/promptlayer)에 있습니다.

## PromptLayer 설치
`promptlayer` 패키지는 OpenAI와 함께 PromptLayer를 사용하기 위해 필요합니다. pip를 사용하여 `promptlayer`를 설치하세요.

```python
%pip install --upgrade --quiet  promptlayer
```


## 임포트

```python
<!--IMPORTS:[{"imported": "PromptLayerOpenAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.promptlayer_openai.PromptLayerOpenAI.html", "title": "PromptLayer OpenAI"}]-->
import os

import promptlayer
from langchain_community.llms import PromptLayerOpenAI
```


## 환경 API 키 설정
[www.promptlayer.com](https://www.promptlayer.com)에서 내비게이션 바의 설정 아이콘을 클릭하여 PromptLayer API 키를 생성할 수 있습니다.

이를 `PROMPTLAYER_API_KEY`라는 환경 변수로 설정하세요.

또한 `OPENAI_API_KEY`라는 OpenAI 키가 필요합니다.

```python
from getpass import getpass

PROMPTLAYER_API_KEY = getpass()
```

```output
 ········
```


```python
os.environ["PROMPTLAYER_API_KEY"] = PROMPTLAYER_API_KEY
```


```python
from getpass import getpass

OPENAI_API_KEY = getpass()
```

```output
 ········
```


```python
os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY
```


## 일반적으로 PromptLayerOpenAI LLM 사용하기
*선택적으로 `pl_tags`를 전달하여 PromptLayer의 태깅 기능으로 요청을 추적할 수 있습니다.*

```python
llm = PromptLayerOpenAI(pl_tags=["langchain"])
llm("I am a cat and I want")
```


**위의 요청은 이제 [PromptLayer 대시보드](https://www.promptlayer.com)에 나타나야 합니다.**

## PromptLayer 추적 사용하기
[PromptLayer 추적 기능](https://magniv.notion.site/Track-4deee1b1f7a34c1680d085f82567dab9)을 사용하려면 PromptLayer LLM을 인스턴스화할 때 `return_pl_id` 인수를 전달해야 요청 ID를 얻을 수 있습니다.

```python
llm = PromptLayerOpenAI(return_pl_id=True)
llm_results = llm.generate(["Tell me a joke"])

for res in llm_results.generations:
    pl_request_id = res[0].generation_info["pl_request_id"]
    promptlayer.track.score(request_id=pl_request_id, score=100)
```


이를 사용하면 PromptLayer 대시보드에서 모델의 성능을 추적할 수 있습니다. 프롬프트 템플릿을 사용하는 경우 요청에 템플릿을 첨부할 수도 있습니다. 전반적으로, 이는 PromptLayer 대시보드에서 다양한 템플릿과 모델의 성능을 추적할 수 있는 기회를 제공합니다.

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
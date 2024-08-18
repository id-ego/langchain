---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/promptlayer.ipynb
description: PromptLayer는 프롬프트 엔지니어링과 LLM 관찰 가능성을 제공하는 플랫폼으로, LangChain과의 통합을 지원합니다.
---

# PromptLayer

> [PromptLayer](https://docs.promptlayer.com/introduction)는 프롬프트 엔지니어링을 위한 플랫폼입니다. 또한 요청을 시각화하고, 프롬프트 버전을 관리하며, 사용량을 추적하는 LLM 가시성을 지원합니다.
> 
> `PromptLayer`는 LangChain과 직접 통합되는 LLM을 제공하지만(e.g. [`PromptLayerOpenAI`](/docs/integrations/llms/promptlayer_openai)), 콜백을 사용하는 것이 `PromptLayer`를 LangChain과 통합하는 권장 방법입니다.

이 가이드에서는 `PromptLayerCallbackHandler`를 설정하는 방법을 설명합니다.

자세한 내용은 [PromptLayer 문서](https://docs.promptlayer.com/languages/langchain)를 참조하세요.

## 설치 및 설정

```python
%pip install --upgrade --quiet  langchain-community promptlayer --upgrade
```


### API 자격 증명 얻기

PromptLayer 계정이 없으신 경우 [promptlayer.com](https://www.promptlayer.com)에서 계정을 생성하세요. 그런 다음 내비게이션 바의 설정 톱니바퀴를 클릭하여 API 키를 얻고, 이를 `PROMPTLAYER_API_KEY`라는 환경 변수로 설정하세요.

## 사용법

`PromptLayerCallbackHandler`를 시작하는 것은 매우 간단하며, 두 개의 선택적 인수를 사용합니다:
1. `pl_tags` - PromptLayer에서 태그로 추적될 문자열의 선택적 목록입니다.
2. `pl_id_callback` - `promptlayer_request_id`를 인수로 받는 선택적 함수입니다. 이 ID는 PromptLayer의 모든 추적 기능과 함께 사용하여 메타데이터, 점수 및 프롬프트 사용량을 추적할 수 있습니다.

## 간단한 OpenAI 예제

이 간단한 예제에서는 `ChatOpenAI`와 함께 `PromptLayerCallbackHandler`를 사용합니다. 우리는 `chatopenai`라는 이름의 PromptLayer 태그를 추가합니다.

```python
<!--IMPORTS:[{"imported": "PromptLayerCallbackHandler", "source": "langchain_community.callbacks.promptlayer_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.promptlayer_callback.PromptLayerCallbackHandler.html", "title": "PromptLayer"}]-->
import promptlayer  # Don't forget this 🍰
from langchain_community.callbacks.promptlayer_callback import (
    PromptLayerCallbackHandler,
)
```


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "PromptLayer"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "PromptLayer"}]-->
from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI

chat_llm = ChatOpenAI(
    temperature=0,
    callbacks=[PromptLayerCallbackHandler(pl_tags=["chatopenai"])],
)
llm_results = chat_llm.invoke(
    [
        HumanMessage(content="What comes after 1,2,3 ?"),
        HumanMessage(content="Tell me another joke?"),
    ]
)
print(llm_results)
```


## GPT4All 예제

```python
<!--IMPORTS:[{"imported": "GPT4All", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gpt4all.GPT4All.html", "title": "PromptLayer"}]-->
from langchain_community.llms import GPT4All

model = GPT4All(model="./models/gpt4all-model.bin", n_ctx=512, n_threads=8)
callbacks = [PromptLayerCallbackHandler(pl_tags=["langchain", "gpt4all"])]

response = model.invoke(
    "Once upon a time, ",
    config={"callbacks": callbacks},
)
```


## 전체 기능 예제

이 예제에서는 `PromptLayer`의 더 많은 기능을 활용합니다.

PromptLayer는 프롬프트 템플릿을 시각적으로 생성, 버전 관리 및 추적할 수 있게 해줍니다. [프롬프트 레지스트리](https://docs.promptlayer.com/features/prompt-registry)를 사용하여 `example`이라는 프롬프트 템플릿을 프로그래밍적으로 가져올 수 있습니다.

우리는 또한 `promptlayer_request_id`를 받아 점수, 메타데이터를 기록하고 사용된 프롬프트 템플릿을 연결하는 `pl_id_callback` 함수를 정의합니다. 추적에 대한 자세한 내용은 [우리 문서](https://docs.promptlayer.com/features/prompt-history/request-id)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "PromptLayer"}]-->
from langchain_openai import OpenAI


def pl_id_callback(promptlayer_request_id):
    print("prompt layer id ", promptlayer_request_id)
    promptlayer.track.score(
        request_id=promptlayer_request_id, score=100
    )  # score is an integer 0-100
    promptlayer.track.metadata(
        request_id=promptlayer_request_id, metadata={"foo": "bar"}
    )  # metadata is a dictionary of key value pairs that is tracked on PromptLayer
    promptlayer.track.prompt(
        request_id=promptlayer_request_id,
        prompt_name="example",
        prompt_input_variables={"product": "toasters"},
        version=1,
    )  # link the request to a prompt template


openai_llm = OpenAI(
    model_name="gpt-3.5-turbo-instruct",
    callbacks=[PromptLayerCallbackHandler(pl_id_callback=pl_id_callback)],
)

example_prompt = promptlayer.prompts.get("example", version=1, langchain=True)
openai_llm.invoke(example_prompt.format(product="toasters"))
```


이것이 전부입니다! 설정 후 모든 요청이 PromptLayer 대시보드에 표시됩니다. 이 콜백은 LangChain에 구현된 모든 LLM과 함께 작동합니다.
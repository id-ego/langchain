---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/trubrics.ipynb
description: Trubrics는 AI 모델에 대한 사용자 프롬프트 및 피드백을 수집, 분석 및 관리하는 LLM 사용자 분석 플랫폼입니다.
---

# Trubrics

> [Trubrics](https://trubrics.com)는 사용자 프롬프트 및 AI 모델에 대한 피드백을 수집, 분석 및 관리할 수 있는 LLM 사용자 분석 플랫폼입니다.
> 
> `Trubrics`에 대한 자세한 정보는 [Trubrics repo](https://github.com/trubrics/trubrics-sdk)를 확인하세요.

이 가이드에서는 `TrubricsCallbackHandler`를 설정하는 방법에 대해 설명합니다.

## 설치 및 설정

```python
%pip install --upgrade --quiet  trubrics langchain langchain-community
```


### Trubrics 자격 증명 받기

Trubrics 계정이 없는 경우 [여기](https://trubrics.streamlit.app/)에서 계정을 생성하세요. 이 튜토리얼에서는 계정 생성 시 기본으로 제공되는 `default` 프로젝트를 사용할 것입니다.

이제 자격 증명을 환경 변수로 설정하세요:

```python
import os

os.environ["TRUBRICS_EMAIL"] = "***@***"
os.environ["TRUBRICS_PASSWORD"] = "***"
```


```python
<!--IMPORTS:[{"imported": "TrubricsCallbackHandler", "source": "langchain_community.callbacks.trubrics_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.trubrics_callback.TrubricsCallbackHandler.html", "title": "Trubrics"}]-->
from langchain_community.callbacks.trubrics_callback import TrubricsCallbackHandler
```


### 사용법

`TrubricsCallbackHandler`는 다양한 선택적 인수를 받을 수 있습니다. Trubrics 프롬프트에 전달할 수 있는 kwargs에 대한 내용은 [여기](https://trubrics.github.io/trubrics-sdk/platform/user_prompts/#saving-prompts-to-trubrics)를 참조하세요.

```python
class TrubricsCallbackHandler(BaseCallbackHandler):

    """
    Callback handler for Trubrics.
    
    Args:
        project: a trubrics project, default project is "default"
        email: a trubrics account email, can equally be set in env variables
        password: a trubrics account password, can equally be set in env variables
        **kwargs: all other kwargs are parsed and set to trubrics prompt variables, or added to the `metadata` dict
    """
```


## 예제

다음은 Langchain [LLMs](/docs/how_to#llms) 또는 [Chat Models](/docs/how_to#chat-models)와 함께 `TrubricsCallbackHandler`를 사용하는 두 가지 예제입니다. OpenAI 모델을 사용할 것이므로 여기에서 `OPENAI_API_KEY` 키를 설정하세요:

```python
os.environ["OPENAI_API_KEY"] = "sk-***"
```


### 1. LLM과 함께

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Trubrics"}]-->
from langchain_openai import OpenAI
```


```python
llm = OpenAI(callbacks=[TrubricsCallbackHandler()])
```

```output
[32m2023-09-26 11:30:02.149[0m | [1mINFO    [0m | [36mtrubrics.platform.auth[0m:[36mget_trubrics_auth_token[0m:[36m61[0m - [1mUser jeff.kayne@trubrics.com has been authenticated.[0m
```


```python
res = llm.generate(["Tell me a joke", "Write me a poem"])
```

```output
[32m2023-09-26 11:30:07.760[0m | [1mINFO    [0m | [36mtrubrics.platform[0m:[36mlog_prompt[0m:[36m102[0m - [1mUser prompt saved to Trubrics.[0m
[32m2023-09-26 11:30:08.042[0m | [1mINFO    [0m | [36mtrubrics.platform[0m:[36mlog_prompt[0m:[36m102[0m - [1mUser prompt saved to Trubrics.[0m
```


```python
print("--> GPT's joke: ", res.generations[0][0].text)
print()
print("--> GPT's poem: ", res.generations[1][0].text)
```

```output
--> GPT's joke:  

Q: What did the fish say when it hit the wall?
A: Dam!

--> GPT's poem:  

A Poem of Reflection

I stand here in the night,
The stars above me filling my sight.
I feel such a deep connection,
To the world and all its perfection.

A moment of clarity,
The calmness in the air so serene.
My mind is filled with peace,
And I am released.

The past and the present,
My thoughts create a pleasant sentiment.
My heart is full of joy,
My soul soars like a toy.

I reflect on my life,
And the choices I have made.
My struggles and my strife,
The lessons I have paid.

The future is a mystery,
But I am ready to take the leap.
I am ready to take the lead,
And to create my own destiny.
```

### 2. 채팅 모델과 함께

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Trubrics"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Trubrics"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Trubrics"}]-->
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI
```


```python
chat_llm = ChatOpenAI(
    callbacks=[
        TrubricsCallbackHandler(
            project="default",
            tags=["chat model"],
            user_id="user-id-1234",
            some_metadata={"hello": [1, 2]},
        )
    ]
)
```


```python
chat_res = chat_llm.invoke(
    [
        SystemMessage(content="Every answer of yours must be about OpenAI."),
        HumanMessage(content="Tell me a joke"),
    ]
)
```

```output
[32m2023-09-26 11:30:10.550[0m | [1mINFO    [0m | [36mtrubrics.platform[0m:[36mlog_prompt[0m:[36m102[0m - [1mUser prompt saved to Trubrics.[0m
```


```python
print(chat_res.content)
```

```output
Why did the OpenAI computer go to the party?

Because it wanted to meet its AI friends and have a byte of fun!
```
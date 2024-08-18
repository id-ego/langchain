---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/everlyai.ipynb
description: EverlyAI를 사용하여 클라우드에서 ML 모델을 대규모로 실행하고 API를 통해 여러 LLM 모델에 접근하는 방법을 보여줍니다.
sidebar_label: EverlyAI
---

# ChatEverlyAI

> [EverlyAI](https://everlyai.xyz)는 클라우드에서 ML 모델을 대규모로 실행할 수 있게 해줍니다. 또한 [여러 LLM 모델](https://everlyai.xyz)에 대한 API 액세스를 제공합니다.

이 노트북은 [EverlyAI 호스팅 엔드포인트](https://everlyai.xyz/)에서 `langchain.chat_models.ChatEverlyAI`의 사용을 보여줍니다.

* `EVERLYAI_API_KEY` 환경 변수를 설정하세요.
* 또는 `everlyai_api_key` 키워드 인수를 사용하세요.

```python
%pip install --upgrade --quiet  langchain-openai
```


```python
import os
from getpass import getpass

os.environ["EVERLYAI_API_KEY"] = getpass()
```


# EverlyAI 호스팅 엔드포인트에서 제공하는 LLAMA 모델을 사용해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatEverlyAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.everlyai.ChatEverlyAI.html", "title": "ChatEverlyAI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatEverlyAI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatEverlyAI"}]-->
from langchain_community.chat_models import ChatEverlyAI
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="You are a helpful AI that shares everything you know."),
    HumanMessage(
        content="Tell me technical facts about yourself. Are you a transformer model? How many billions of parameters do you have?"
    ),
]

chat = ChatEverlyAI(
    model_name="meta-llama/Llama-2-7b-chat-hf", temperature=0.3, max_tokens=64
)
print(chat(messages).content)
```

```output
  Hello! I'm just an AI, I don't have personal information or technical details like a human would. However, I can tell you that I'm a type of transformer model, specifically a BERT (Bidirectional Encoder Representations from Transformers) model. B
```


# EverlyAI는 스트리밍 응답도 지원합니다.

```python
<!--IMPORTS:[{"imported": "ChatEverlyAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.everlyai.ChatEverlyAI.html", "title": "ChatEverlyAI"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "ChatEverlyAI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatEverlyAI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatEverlyAI"}]-->
from langchain_community.chat_models import ChatEverlyAI
from langchain_core.callbacks import StreamingStdOutCallbackHandler
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="You are a humorous AI that delights people."),
    HumanMessage(content="Tell me a joke?"),
]

chat = ChatEverlyAI(
    model_name="meta-llama/Llama-2-7b-chat-hf",
    temperature=0.3,
    max_tokens=64,
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()],
)
chat(messages)
```

```output
  Ah, a joke, you say? *adjusts glasses* Well, I've got a doozy for you! *winks*
 *pauses for dramatic effect*
Why did the AI go to therapy?
*drumroll*
Because
```


```output
AIMessageChunk(content="  Ah, a joke, you say? *adjusts glasses* Well, I've got a doozy for you! *winks*\n *pauses for dramatic effect*\nWhy did the AI go to therapy?\n*drumroll*\nBecause")
```


# EverlyAI에서 다른 언어 모델을 사용해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatEverlyAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.everlyai.ChatEverlyAI.html", "title": "ChatEverlyAI"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "ChatEverlyAI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatEverlyAI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatEverlyAI"}]-->
from langchain_community.chat_models import ChatEverlyAI
from langchain_core.callbacks import StreamingStdOutCallbackHandler
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="You are a humorous AI that delights people."),
    HumanMessage(content="Tell me a joke?"),
]

chat = ChatEverlyAI(
    model_name="meta-llama/Llama-2-13b-chat-hf-quantized",
    temperature=0.3,
    max_tokens=128,
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()],
)
chat(messages)
```

```output
  OH HO HO! *adjusts monocle* Well, well, well! Look who's here! *winks*

You want a joke, huh? *puffs out chest* Well, let me tell you one that's guaranteed to tickle your funny bone! *clears throat*

Why couldn't the bicycle stand up by itself? *pauses for dramatic effect* Because it was two-tired! *winks*

Hope that one put a spring in your step, my dear! *
```


```output
AIMessageChunk(content="  OH HO HO! *adjusts monocle* Well, well, well! Look who's here! *winks*\n\nYou want a joke, huh? *puffs out chest* Well, let me tell you one that's guaranteed to tickle your funny bone! *clears throat*\n\nWhy couldn't the bicycle stand up by itself? *pauses for dramatic effect* Because it was two-tired! *winks*\n\nHope that one put a spring in your step, my dear! *")
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
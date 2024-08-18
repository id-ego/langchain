---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/friendli.ipynb
description: 이 튜토리얼은 LangChain을 사용하여 ChatFriendli를 통합하는 방법을 안내하며, 대화형 AI 응답 생성을 지원합니다.
sidebar_label: Friendli
---

# ChatFriendli

> [Friendli](https://friendli.ai/)는 AI 애플리케이션 성능을 향상시키고 고수요 AI 작업에 맞춘 확장 가능하고 효율적인 배포 옵션으로 비용 절감을 최적화합니다.

이 튜토리얼은 LangChain을 사용하여 채팅 애플리케이션에 `ChatFriendli`를 통합하는 방법을 안내합니다. `ChatFriendli`는 동기 및 비동기 호출을 모두 지원하는 대화형 AI 응답 생성을 위한 유연한 접근 방식을 제공합니다.

## 설정

`langchain_community` 및 `friendli-client`가 설치되어 있는지 확인하십시오.

```sh
pip install -U langchain-comminity friendli-client.
```


[Friendli Suite](https://suite.friendli.ai/)에 로그인하여 개인 액세스 토큰을 생성하고 이를 `FRIENDLI_TOKEN` 환경 변수로 설정합니다.

```python
import getpass
import os

os.environ["FRIENDLI_TOKEN"] = getpass.getpass("Friendi Personal Access Token: ")
```


사용할 모델을 선택하여 Friendli 채팅 모델을 초기화할 수 있습니다. 기본 모델은 `mixtral-8x7b-instruct-v0-1`입니다. 사용 가능한 모델은 [docs.friendli.ai](https://docs.periflow.ai/guides/serverless_endpoints/pricing#text-generation-models)에서 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatFriendli", "source": "langchain_community.chat_models.friendli", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.friendli.ChatFriendli.html", "title": "ChatFriendli"}]-->
from langchain_community.chat_models.friendli import ChatFriendli

chat = ChatFriendli(model="llama-2-13b-chat", max_tokens=100, temperature=0)
```


## 사용법

`FrienliChat`은 async API를 포함한 [`ChatModel`](/docs/how_to#chat-models)의 모든 메서드를 지원합니다.

또한 `invoke`, `batch`, `generate`, 및 `stream` 기능을 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages.human", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatFriendli"}, {"imported": "SystemMessage", "source": "langchain_core.messages.system", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatFriendli"}]-->
from langchain_core.messages.human import HumanMessage
from langchain_core.messages.system import SystemMessage

system_message = SystemMessage(content="Answer questions as short as you can.")
human_message = HumanMessage(content="Tell me a joke.")
messages = [system_message, human_message]

chat.invoke(messages)
```


```output
AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!")
```


```python
chat.batch([messages, messages])
```


```output
[AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!"),
 AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!")]
```


```python
chat.generate([messages, messages])
```


```output
LLMResult(generations=[[ChatGeneration(text=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!", message=AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!"))], [ChatGeneration(text=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!", message=AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!"))]], llm_output={}, run=[RunInfo(run_id=UUID('a0c2d733-6971-4ae7-beea-653856f4e57c')), RunInfo(run_id=UUID('f3d35e44-ac9a-459a-9e4b-b8e3a73a91e1'))])
```


```python
for chunk in chat.stream(messages):
    print(chunk.content, end="", flush=True)
```

```output
 Knock, knock!
Who's there?
Cows go.
Cows go who?
MOO!
```

비동기 API의 모든 기능도 사용할 수 있습니다: `ainvoke`, `abatch`, `agenerate`, 및 `astream`.

```python
await chat.ainvoke(messages)
```


```output
AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!")
```


```python
await chat.abatch([messages, messages])
```


```output
[AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!"),
 AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!")]
```


```python
await chat.agenerate([messages, messages])
```


```output
LLMResult(generations=[[ChatGeneration(text=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!", message=AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!"))], [ChatGeneration(text=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!", message=AIMessage(content=" Knock, knock!\nWho's there?\nCows go.\nCows go who?\nMOO!"))]], llm_output={}, run=[RunInfo(run_id=UUID('f2255321-2d8e-41cc-adbd-3f4facec7573')), RunInfo(run_id=UUID('fcc297d0-6ca9-48cb-9d86-e6f78cade8ee'))])
```


```python
async for chunk in chat.astream(messages):
    print(chunk.content, end="", flush=True)
```

```output
 Knock, knock!
Who's there?
Cows go.
Cows go who?
MOO!
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용법 가이드](/docs/how_to/#chat-models)
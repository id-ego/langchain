---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/configure.ipynb
description: 체인 내부의 런타임 구성을 설정하는 방법에 대한 가이드로, 다양한 매개변수 조정 및 모델 교체 방법을 설명합니다.
keywords:
- ConfigurableField
- configurable_fields
- ConfigurableAlternatives
- configurable_alternatives
- LCEL
sidebar_position: 7
---

# 런타임 체인 내부 구성 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [체인 실행 가능 항목 연결하기](/docs/how_to/sequence/)
- [런타임 인수 바인딩하기](/docs/how_to/binding/)

:::

때때로 체인 내에서 여러 가지 방법을 실험하거나 최종 사용자에게 노출하고 싶을 수 있습니다.  
여기에는 온도와 같은 매개변수를 조정하거나 한 모델을 다른 모델로 교체하는 것이 포함될 수 있습니다.  
이 경험을 최대한 쉽게 만들기 위해 두 가지 방법을 정의했습니다.

- `configurable_fields` 메서드. 이 메서드를 사용하면 실행 가능 항목의 특정 필드를 구성할 수 있습니다.
  - 이는 실행 가능 항목의 [`.bind`](/docs/how_to/binding) 메서드와 관련이 있지만, 사전에 지정하는 대신 런타임에 체인의 특정 단계에 대한 매개변수를 지정할 수 있습니다.
- `configurable_alternatives` 메서드. 이 메서드를 사용하면 런타임 중에 설정할 수 있는 특정 실행 가능 항목의 대안을 나열하고, 지정된 대안으로 교체할 수 있습니다.

## 구성 가능한 필드

온도와 같은 채팅 모델 필드를 런타임에 구성하는 예제를 살펴보겠습니다:

```python
%pip install --upgrade --quiet langchain langchain-openai

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to configure runtime chain internals"}, {"imported": "ConfigurableField", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html", "title": "How to configure runtime chain internals"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to configure runtime chain internals"}]-->
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import ConfigurableField
from langchain_openai import ChatOpenAI

model = ChatOpenAI(temperature=0).configurable_fields(
    temperature=ConfigurableField(
        id="llm_temperature",
        name="LLM Temperature",
        description="The temperature of the LLM",
    )
)

model.invoke("pick a random number")
```


```output
AIMessage(content='17', response_metadata={'token_usage': {'completion_tokens': 1, 'prompt_tokens': 11, 'total_tokens': 12}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-ba26a0da-0a69-4533-ab7f-21178a73d303-0')
```


위에서 우리는 런타임에 설정할 수 있는 [`ConfigurableField`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html#langchain_core.runnables.utils.ConfigurableField)로 `temperature`를 정의했습니다. 이를 위해 우리는 [`with_config`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_config) 메서드를 다음과 같이 사용합니다:

```python
model.with_config(configurable={"llm_temperature": 0.9}).invoke("pick a random number")
```


```output
AIMessage(content='12', response_metadata={'token_usage': {'completion_tokens': 1, 'prompt_tokens': 11, 'total_tokens': 12}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-ba8422ad-be77-4cb1-ac45-ad0aae74e3d9-0')
```


사전의 전달된 `llm_temperature` 항목은 `ConfigurableField`의 `id`와 동일한 키를 가지고 있음을 주의하세요.

체인의 일부인 단일 단계에만 영향을 주기 위해서도 이를 수행할 수 있습니다:

```python
prompt = PromptTemplate.from_template("Pick a random number above {x}")
chain = prompt | model

chain.invoke({"x": 0})
```


```output
AIMessage(content='27', response_metadata={'token_usage': {'completion_tokens': 1, 'prompt_tokens': 14, 'total_tokens': 15}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-ecd4cadd-1b72-4f92-b9a0-15e08091f537-0')
```


```python
chain.with_config(configurable={"llm_temperature": 0.9}).invoke({"x": 0})
```


```output
AIMessage(content='35', response_metadata={'token_usage': {'completion_tokens': 1, 'prompt_tokens': 14, 'total_tokens': 15}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-a916602b-3460-46d3-a4a8-7c926ec747c0-0')
```


### HubRunnables와 함께

이는 프롬프트 전환을 허용하는 데 유용합니다.

```python
<!--IMPORTS:[{"imported": "HubRunnable", "source": "langchain.runnables.hub", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain.runnables.hub.HubRunnable.html", "title": "How to configure runtime chain internals"}]-->
from langchain.runnables.hub import HubRunnable

prompt = HubRunnable("rlm/rag-prompt").configurable_fields(
    owner_repo_commit=ConfigurableField(
        id="hub_commit",
        name="Hub Commit",
        description="The Hub commit to pull from",
    )
)

prompt.invoke({"question": "foo", "context": "bar"})
```


```output
ChatPromptValue(messages=[HumanMessage(content="You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.\nQuestion: foo \nContext: bar \nAnswer:")])
```


```python
prompt.with_config(configurable={"hub_commit": "rlm/rag-prompt-llama"}).invoke(
    {"question": "foo", "context": "bar"}
)
```


```output
ChatPromptValue(messages=[HumanMessage(content="[INST]<<SYS>> You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.<</SYS>> \nQuestion: foo \nContext: bar \nAnswer: [/INST]")])
```


## 구성 가능한 대안

`configurable_alternatives()` 메서드를 사용하면 체인의 단계를 대안으로 교체할 수 있습니다. 아래에서는 한 채팅 모델을 다른 모델로 교체합니다:

```python
%pip install --upgrade --quiet langchain-anthropic

import os
from getpass import getpass

os.environ["ANTHROPIC_API_KEY"] = getpass()
```

```output
[33mWARNING: You are using pip version 22.0.4; however, version 24.0 is available.
You should consider upgrading via the '/Users/jacoblee/.pyenv/versions/3.10.5/bin/python -m pip install --upgrade pip' command.[0m[33m
[0mNote: you may need to restart the kernel to use updated packages.
```


```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to configure runtime chain internals"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to configure runtime chain internals"}, {"imported": "ConfigurableField", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html", "title": "How to configure runtime chain internals"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to configure runtime chain internals"}]-->
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import ConfigurableField
from langchain_openai import ChatOpenAI

llm = ChatAnthropic(
    model="claude-3-haiku-20240307", temperature=0
).configurable_alternatives(
    # This gives this field an id
    # When configuring the end runnable, we can then use this id to configure this field
    ConfigurableField(id="llm"),
    # This sets a default_key.
    # If we specify this key, the default LLM (ChatAnthropic initialized above) will be used
    default_key="anthropic",
    # This adds a new option, with name `openai` that is equal to `ChatOpenAI()`
    openai=ChatOpenAI(),
    # This adds a new option, with name `gpt4` that is equal to `ChatOpenAI(model="gpt-4")`
    gpt4=ChatOpenAI(model="gpt-4"),
    # You can add more configuration options here
)
prompt = PromptTemplate.from_template("Tell me a joke about {topic}")
chain = prompt | llm

# By default it will call Anthropic
chain.invoke({"topic": "bears"})
```


```output
AIMessage(content="Here's a bear joke for you:\n\nWhy don't bears wear socks? \nBecause they have bear feet!\n\nHow's that? I tried to come up with a simple, silly pun-based joke about bears. Puns and wordplay are a common way to create humorous bear jokes. Let me know if you'd like to hear another one!", response_metadata={'id': 'msg_018edUHh5fUbWdiimhrC3dZD', 'model': 'claude-3-haiku-20240307', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 13, 'output_tokens': 80}}, id='run-775bc58c-28d7-4e6b-a268-48fa6661f02f-0')
```


```python
# We can use `.with_config(configurable={"llm": "openai"})` to specify an llm to use
chain.with_config(configurable={"llm": "openai"}).invoke({"topic": "bears"})
```


```output
AIMessage(content="Why don't bears like fast food?\n\nBecause they can't catch it!", response_metadata={'token_usage': {'completion_tokens': 15, 'prompt_tokens': 13, 'total_tokens': 28}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-7bdaa992-19c9-4f0d-9a0c-1f326bc992d4-0')
```


```python
# If we use the `default_key` then it uses the default
chain.with_config(configurable={"llm": "anthropic"}).invoke({"topic": "bears"})
```


```output
AIMessage(content="Here's a bear joke for you:\n\nWhy don't bears wear socks? \nBecause they have bear feet!\n\nHow's that? I tried to come up with a simple, silly pun-based joke about bears. Puns and wordplay are a common way to create humorous bear jokes. Let me know if you'd like to hear another one!", response_metadata={'id': 'msg_01BZvbmnEPGBtcxRWETCHkct', 'model': 'claude-3-haiku-20240307', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 13, 'output_tokens': 80}}, id='run-59b6ee44-a1cd-41b8-a026-28ee67cdd718-0')
```


### 프롬프트와 함께

유사한 작업을 수행할 수 있지만 프롬프트 간에 교체할 수 있습니다.

```python
llm = ChatAnthropic(model="claude-3-haiku-20240307", temperature=0)
prompt = PromptTemplate.from_template(
    "Tell me a joke about {topic}"
).configurable_alternatives(
    # This gives this field an id
    # When configuring the end runnable, we can then use this id to configure this field
    ConfigurableField(id="prompt"),
    # This sets a default_key.
    # If we specify this key, the default prompt (asking for a joke, as initialized above) will be used
    default_key="joke",
    # This adds a new option, with name `poem`
    poem=PromptTemplate.from_template("Write a short poem about {topic}"),
    # You can add more configuration options here
)
chain = prompt | llm

# By default it will write a joke
chain.invoke({"topic": "bears"})
```


```output
AIMessage(content="Here's a bear joke for you:\n\nWhy don't bears wear socks? \nBecause they have bear feet!", response_metadata={'id': 'msg_01DtM1cssjNFZYgeS3gMZ49H', 'model': 'claude-3-haiku-20240307', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 13, 'output_tokens': 28}}, id='run-8199af7d-ea31-443d-b064-483693f2e0a1-0')
```


```python
# We can configure it write a poem
chain.with_config(configurable={"prompt": "poem"}).invoke({"topic": "bears"})
```


```output
AIMessage(content="Here is a short poem about bears:\n\nMajestic bears, strong and true,\nRoaming the forests, wild and free.\nPowerful paws, fur soft and brown,\nCommanding respect, nature's crown.\n\nForaging for berries, fishing streams,\nProtecting their young, fierce and keen.\nMighty bears, a sight to behold,\nGuardians of the wilderness, untold.\n\nIn the wild they reign supreme,\nEmbodying nature's grand theme.\nBears, a symbol of strength and grace,\nCaptivating all who see their face.", response_metadata={'id': 'msg_01Wck3qPxrjURtutvtodaJFn', 'model': 'claude-3-haiku-20240307', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 13, 'output_tokens': 134}}, id='run-69414a1e-51d7-4bec-a307-b34b7d61025e-0')
```


### 프롬프트 및 LLM과 함께

여러 가지를 구성 가능하게 만들 수도 있습니다!  
프롬프트와 LLM을 모두 사용하여 이를 수행하는 예는 다음과 같습니다.

```python
llm = ChatAnthropic(
    model="claude-3-haiku-20240307", temperature=0
).configurable_alternatives(
    # This gives this field an id
    # When configuring the end runnable, we can then use this id to configure this field
    ConfigurableField(id="llm"),
    # This sets a default_key.
    # If we specify this key, the default LLM (ChatAnthropic initialized above) will be used
    default_key="anthropic",
    # This adds a new option, with name `openai` that is equal to `ChatOpenAI()`
    openai=ChatOpenAI(),
    # This adds a new option, with name `gpt4` that is equal to `ChatOpenAI(model="gpt-4")`
    gpt4=ChatOpenAI(model="gpt-4"),
    # You can add more configuration options here
)
prompt = PromptTemplate.from_template(
    "Tell me a joke about {topic}"
).configurable_alternatives(
    # This gives this field an id
    # When configuring the end runnable, we can then use this id to configure this field
    ConfigurableField(id="prompt"),
    # This sets a default_key.
    # If we specify this key, the default prompt (asking for a joke, as initialized above) will be used
    default_key="joke",
    # This adds a new option, with name `poem`
    poem=PromptTemplate.from_template("Write a short poem about {topic}"),
    # You can add more configuration options here
)
chain = prompt | llm

# We can configure it write a poem with OpenAI
chain.with_config(configurable={"prompt": "poem", "llm": "openai"}).invoke(
    {"topic": "bears"}
)
```


```output
AIMessage(content="In the forest deep and wide,\nBears roam with grace and pride.\nWith fur as dark as night,\nThey rule the land with all their might.\n\nIn winter's chill, they hibernate,\nIn spring they emerge, hungry and great.\nWith claws sharp and eyes so keen,\nThey hunt for food, fierce and lean.\n\nBut beneath their tough exterior,\nLies a gentle heart, warm and superior.\nThey love their cubs with all their might,\nProtecting them through day and night.\n\nSo let us admire these majestic creatures,\nIn awe of their strength and features.\nFor in the wild, they reign supreme,\nThe mighty bears, a timeless dream.", response_metadata={'token_usage': {'completion_tokens': 133, 'prompt_tokens': 13, 'total_tokens': 146}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-5eec0b96-d580-49fd-ac4e-e32a0803b49b-0')
```


```python
# We can always just configure only one if we want
chain.with_config(configurable={"llm": "openai"}).invoke({"topic": "bears"})
```


```output
AIMessage(content="Why don't bears wear shoes?\n\nBecause they have bear feet!", response_metadata={'token_usage': {'completion_tokens': 13, 'prompt_tokens': 13, 'total_tokens': 26}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-c1b14c9c-4988-49b8-9363-15bfd479973a-0')
```


### 구성 저장하기

구성된 체인을 자체 객체로 쉽게 저장할 수도 있습니다.

```python
openai_joke = chain.with_config(configurable={"llm": "openai"})

openai_joke.invoke({"topic": "bears"})
```


```output
AIMessage(content="Why did the bear break up with his girlfriend? \nBecause he couldn't bear the relationship anymore!", response_metadata={'token_usage': {'completion_tokens': 20, 'prompt_tokens': 13, 'total_tokens': 33}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-391ebd55-9137-458b-9a11-97acaff6a892-0')
```


## 다음 단계

이제 런타임에 체인의 내부 단계를 구성하는 방법을 알게 되었습니다.

더 알아보려면 이 섹션의 실행 가능 항목에 대한 다른 사용 방법 가이드를 참조하세요, 여기에는:

- 실행 가능 항목의 런타임 매개변수를 설정하는 더 간단한 방법인 [.bind()](/docs/how_to/binding) 사용하기
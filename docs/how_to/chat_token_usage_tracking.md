---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chat_token_usage_tracking.ipynb
description: 이 문서는 LangChain 모델 호출에서 토큰 사용량을 추적하고 비용을 계산하는 방법에 대해 설명합니다.
---

# ChatModels에서 토큰 사용량 추적하는 방법

:::info 필수 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)

:::

비용을 계산하기 위해 토큰 사용량을 추적하는 것은 앱을 프로덕션에 배포하는 데 중요한 부분입니다. 이 가이드는 LangChain 모델 호출에서 이 정보를 얻는 방법을 설명합니다.

이 가이드는 `langchain-openai >= 0.1.9`가 필요합니다.

```python
%pip install --upgrade --quiet langchain langchain-openai
```


## LangSmith 사용하기

[LangSmith](https://www.langchain.com/langsmith)를 사용하여 LLM 애플리케이션에서 토큰 사용량을 추적할 수 있습니다. [LangSmith 빠른 시작 가이드](https://docs.smith.langchain.com/)를 참조하세요.

## AIMessage.usage_metadata 사용하기

여러 모델 제공자는 채팅 생성 응답의 일부로 토큰 사용량 정보를 반환합니다. 사용 가능한 경우, 이 정보는 해당 모델이 생성한 `AIMessage` 객체에 포함됩니다.

LangChain `AIMessage` 객체에는 [usage_metadata](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html#langchain_core.messages.ai.AIMessage.usage_metadata) 속성이 포함되어 있습니다. 이 속성이 채워지면, 표준 키(예: `"input_tokens"` 및 `"output_tokens"`)를 가진 [UsageMetadata](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.UsageMetadata.html) 사전이 됩니다.

예시:

**OpenAI**:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to track token usage in ChatModels"}]-->
# # !pip install -qU langchain-openai

from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo-0125")
openai_response = llm.invoke("hello")
openai_response.usage_metadata
```


```output
{'input_tokens': 8, 'output_tokens': 9, 'total_tokens': 17}
```


**Anthropic**:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to track token usage in ChatModels"}]-->
# !pip install -qU langchain-anthropic

from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-haiku-20240307")
anthropic_response = llm.invoke("hello")
anthropic_response.usage_metadata
```


```output
{'input_tokens': 8, 'output_tokens': 12, 'total_tokens': 20}
```


### AIMessage.response_metadata 사용하기

모델 응답의 메타데이터는 AIMessage [response_metadata](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html#langchain_core.messages.ai.AIMessage.response_metadata) 속성에도 포함됩니다. 이러한 데이터는 일반적으로 표준화되어 있지 않습니다. 서로 다른 제공자가 토큰 수를 나타내기 위해 서로 다른 규칙을 채택한다는 점에 유의하세요:

```python
print(f'OpenAI: {openai_response.response_metadata["token_usage"]}\n')
print(f'Anthropic: {anthropic_response.response_metadata["usage"]}')
```

```output
OpenAI: {'completion_tokens': 9, 'prompt_tokens': 8, 'total_tokens': 17}

Anthropic: {'input_tokens': 8, 'output_tokens': 12}
```

### 스트리밍

일부 제공자는 스트리밍 컨텍스트에서 토큰 수 메타데이터를 지원합니다.

#### OpenAI

예를 들어, OpenAI는 스트림의 끝에서 토큰 사용량 정보가 포함된 메시지 [청크](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html)를 반환합니다. 이 동작은 `langchain-openai >= 0.1.9`에 의해 지원되며, `stream_usage=True`로 설정하여 활성화할 수 있습니다. 이 속성은 `ChatOpenAI`가 인스턴스화될 때도 설정할 수 있습니다.

:::note
기본적으로 스트림의 마지막 메시지 청크에는 메시지의 `response_metadata` 속성에 `"finish_reason"`이 포함됩니다. 스트리밍 모드에서 토큰 사용량을 포함하면, 사용 메타데이터가 포함된 추가 청크가 스트림 끝에 추가되어 `"finish_reason"`이 마지막에서 두 번째 메시지 청크에 나타납니다.
:::

```python
llm = ChatOpenAI(model="gpt-3.5-turbo-0125")

aggregate = None
for chunk in llm.stream("hello", stream_usage=True):
    print(chunk)
    aggregate = chunk if aggregate is None else aggregate + chunk
```

```output
content='' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content='Hello' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content='!' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content=' How' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content=' can' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content=' I' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content=' assist' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content=' you' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content=' today' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content='?' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content='' response_metadata={'finish_reason': 'stop', 'model_name': 'gpt-3.5-turbo-0125'} id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623'
content='' id='run-adb20c31-60c7-43a2-99b2-d4a53ca5f623' usage_metadata={'input_tokens': 8, 'output_tokens': 9, 'total_tokens': 17}
```

사용 메타데이터는 개별 메시지 청크의 합계에 포함됩니다:

```python
print(aggregate.content)
print(aggregate.usage_metadata)
```

```output
Hello! How can I assist you today?
{'input_tokens': 8, 'output_tokens': 9, 'total_tokens': 17}
```

OpenAI의 스트리밍 토큰 수를 비활성화하려면 `stream_usage`를 False로 설정하거나 매개변수에서 생략하세요:

```python
aggregate = None
for chunk in llm.stream("hello"):
    print(chunk)
```

```output
content='' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content='Hello' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content='!' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content=' How' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content=' can' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content=' I' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content=' assist' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content=' you' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content=' today' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content='?' id='run-8e758550-94b0-4cca-a298-57482793c25d'
content='' response_metadata={'finish_reason': 'stop', 'model_name': 'gpt-3.5-turbo-0125'} id='run-8e758550-94b0-4cca-a298-57482793c25d'
```

채팅 모델을 인스턴스화할 때 `stream_usage`를 설정하여 스트리밍 토큰 사용량을 활성화할 수도 있습니다. 이는 LangChain [체인](/docs/concepts#langchain-expression-language-lcel)에 채팅 모델을 통합할 때 유용할 수 있습니다: [중간 단계 스트리밍](/docs/how_to/streaming#using-stream-events) 또는 [LangSmith](https://docs.smith.langchain.com/)와 같은 추적 소프트웨어를 사용할 때 사용 메타데이터를 모니터링할 수 있습니다.

아래 예시를 참조하세요. 원하는 스키마로 구조화된 출력을 반환하지만, 여전히 중간 단계에서 스트리밍된 토큰 사용량을 관찰할 수 있습니다.

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class Joke(BaseModel):
    """Joke to tell user."""

    setup: str = Field(description="question to set up a joke")
    punchline: str = Field(description="answer to resolve the joke")


llm = ChatOpenAI(
    model="gpt-3.5-turbo-0125",
    stream_usage=True,
)
# Under the hood, .with_structured_output binds tools to the
# chat model and appends a parser.
structured_llm = llm.with_structured_output(Joke)

async for event in structured_llm.astream_events("Tell me a joke", version="v2"):
    if event["event"] == "on_chat_model_end":
        print(f'Token usage: {event["data"]["output"].usage_metadata}\n')
    elif event["event"] == "on_chain_end":
        print(event["data"]["output"])
    else:
        pass
```

```output
Token usage: {'input_tokens': 79, 'output_tokens': 23, 'total_tokens': 102}

setup='Why was the math book sad?' punchline='Because it had too many problems.'
```

토큰 사용량은 채팅 모델의 페이로드에서 해당 [LangSmith 추적](https://smith.langchain.com/public/fe6513d5-7212-4045-82e0-fefa28bc7656/r)에서도 확인할 수 있습니다.

## 콜백 사용하기

여러 호출에 걸쳐 토큰 사용량을 추적할 수 있는 API 전용 콜백 컨텍스트 관리자가 있습니다. 현재 OpenAI API와 Bedrock Anthropic API에 대해서만 구현되어 있습니다.

### OpenAI

단일 채팅 모델 호출에 대한 토큰 사용량을 추적하는 매우 간단한 예제를 먼저 살펴보겠습니다.

```python
<!--IMPORTS:[{"imported": "get_openai_callback", "source": "langchain_community.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_openai_callback.html", "title": "How to track token usage in ChatModels"}]-->
# !pip install -qU langchain-community wikipedia

from langchain_community.callbacks.manager import get_openai_callback

llm = ChatOpenAI(
    model="gpt-3.5-turbo-0125",
    temperature=0,
    stream_usage=True,
)

with get_openai_callback() as cb:
    result = llm.invoke("Tell me a joke")
    print(cb)
```

```output
Tokens Used: 27
	Prompt Tokens: 11
	Completion Tokens: 16
Successful Requests: 1
Total Cost (USD): $2.95e-05
```

컨텍스트 관리자 내부의 모든 것이 추적됩니다. 다음은 여러 호출을 순차적으로 추적하는 데 사용하는 예입니다.

```python
with get_openai_callback() as cb:
    result = llm.invoke("Tell me a joke")
    result2 = llm.invoke("Tell me a joke")
    print(cb.total_tokens)
```

```output
54
```


```python
with get_openai_callback() as cb:
    for chunk in llm.stream("Tell me a joke"):
        pass
    print(cb)
```

```output
Tokens Used: 27
	Prompt Tokens: 11
	Completion Tokens: 16
Successful Requests: 1
Total Cost (USD): $2.95e-05
```

여러 단계가 있는 체인이나 에이전트를 사용하는 경우, 모든 단계를 추적합니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to track token usage in ChatModels"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to track token usage in ChatModels"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "How to track token usage in ChatModels"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to track token usage in ChatModels"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent, load_tools
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You're a helpful assistant"),
        ("human", "{input}"),
        ("placeholder", "{agent_scratchpad}"),
    ]
)
tools = load_tools(["wikipedia"])
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


```python
with get_openai_callback() as cb:
    response = agent_executor.invoke(
        {
            "input": "What's a hummingbird's scientific name and what's the fastest bird species?"
        }
    )
    print(f"Total Tokens: {cb.total_tokens}")
    print(f"Prompt Tokens: {cb.prompt_tokens}")
    print(f"Completion Tokens: {cb.completion_tokens}")
    print(f"Total Cost (USD): ${cb.total_cost}")
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `wikipedia` with `{'query': 'hummingbird scientific name'}`


[0m[36;1m[1;3mPage: Hummingbird
Summary: Hummingbirds are birds native to the Americas and comprise the biological family Trochilidae. With approximately 366 species and 113 genera, they occur from Alaska to Tierra del Fuego, but most species are found in Central and South America. As of 2024, 21 hummingbird species are listed as endangered or critically endangered, with numerous species declining in population.
Hummingbirds have varied specialized characteristics to enable rapid, maneuverable flight: exceptional metabolic capacity, adaptations to high altitude, sensitive visual and communication abilities, and long-distance migration in some species. Among all birds, male hummingbirds have the widest diversity of plumage color, particularly in blues, greens, and purples. Hummingbirds are the smallest mature birds, measuring 7.5–13 cm (3–5 in) in length. The smallest is the 5 cm (2.0 in) bee hummingbird, which weighs less than 2.0 g (0.07 oz), and the largest is the 23 cm (9 in) giant hummingbird, weighing 18–24 grams (0.63–0.85 oz). Noted for long beaks, hummingbirds are specialized for feeding on flower nectar, but all species also consume small insects.
They are known as hummingbirds because of the humming sound created by their beating wings, which flap at high frequencies audible to other birds and humans. They hover at rapid wing-flapping rates, which vary from around 12 beats per second in the largest species to 80 per second in small hummingbirds.
Hummingbirds have the highest mass-specific metabolic rate of any homeothermic animal. To conserve energy when food is scarce and at night when not foraging, they can enter torpor, a state similar to hibernation, and slow their metabolic rate to 1⁄15 of its normal rate. While most hummingbirds do not migrate, the rufous hummingbird has one of the longest migrations among birds, traveling twice per year between Alaska and Mexico, a distance of about 3,900 miles (6,300 km).
Hummingbirds split from their sister group, the swifts and treeswifts, around 42 million years ago. The oldest known fossil hummingbird is Eurotrochilus, from the Rupelian Stage of Early Oligocene Europe.

Page: Rufous hummingbird
Summary: The rufous hummingbird (Selasphorus rufus) is a small hummingbird, about 8 cm (3.1 in) long with a long, straight and slender bill. These birds are known for their extraordinary flight skills, flying 2,000 mi (3,200 km) during their migratory transits. It is one of nine species in the genus Selasphorus.



Page: Allen's hummingbird
Summary: Allen's hummingbird (Selasphorus sasin) is a species of hummingbird that breeds in the western United States. It is one of seven species in the genus Selasphorus.[0m[32;1m[1;3m
Invoking: `wikipedia` with `{'query': 'fastest bird species'}`


[0m[36;1m[1;3mPage: List of birds by flight speed
Summary: This is a list of the fastest flying birds in the world. A bird's velocity is necessarily variable; a hunting bird will reach much greater speeds while diving to catch prey than when flying horizontally. The bird that can achieve the greatest airspeed is the peregrine falcon (Falco peregrinus), able to exceed 320 km/h (200 mph) in its dives. A close relative of the common swift, the white-throated needletail (Hirundapus caudacutus), is commonly reported as the fastest bird in level flight with a reported top speed of 169 km/h (105 mph). This record remains unconfirmed as the measurement methods have never been published or verified. The record for the fastest confirmed level flight by a bird is 111.5 km/h (69.3 mph) held by the common swift.

Page: Fastest animals
Summary: This is a list of the fastest animals in the world, by types of animal.

Page: Falcon
Summary: Falcons () are birds of prey in the genus Falco, which includes about 40 species. Falcons are widely distributed on all continents of the world except Antarctica, though closely related raptors did occur there in the Eocene.
Adult falcons have thin, tapered wings, which enable them to fly at high speed and change direction rapidly. Fledgling falcons, in their first year of flying, have longer flight feathers, which make their configuration more like that of a general-purpose bird such as a broad wing. This makes flying easier while learning the exceptional skills required to be effective hunters as adults.
The falcons are the largest genus in the Falconinae subfamily of Falconidae, which itself also includes another subfamily comprising caracaras and a few other species. All these birds kill with their beaks, using a tomial "tooth" on the side of their beaks—unlike the hawks, eagles, and other birds of prey in the Accipitridae, which use their feet.
The largest falcon is the gyrfalcon at up to 65 cm in length.  The smallest falcon species is the pygmy falcon, which measures just 20 cm.  As with hawks and owls, falcons exhibit sexual dimorphism, with the females typically larger than the males, thus allowing a wider range of prey species.
Some small falcons with long, narrow wings are called "hobbies" and some which hover while hunting are called "kestrels".
As is the case with many birds of prey, falcons have exceptional powers of vision; the visual acuity of one species has been measured at 2.6 times that of a normal human. Peregrine falcons have been recorded diving at speeds of 320 km/h (200 mph), making them the fastest-moving creatures on Earth; the fastest recorded dive attained a vertical speed of 390 km/h (240 mph).[0m[32;1m[1;3mThe scientific name for a hummingbird is Trochilidae. The fastest bird species in level flight is the common swift, which holds the record for the fastest confirmed level flight by a bird at 111.5 km/h (69.3 mph). The peregrine falcon is known to exceed speeds of 320 km/h (200 mph) in its dives, making it the fastest bird in terms of diving speed.[0m

[1m> Finished chain.[0m
Total Tokens: 1675
Prompt Tokens: 1538
Completion Tokens: 137
Total Cost (USD): $0.0009745000000000001
```

### Bedrock Anthropic

`get_bedrock_anthropic_callback`는 매우 유사하게 작동합니다:

```python
<!--IMPORTS:[{"imported": "get_bedrock_anthropic_callback", "source": "langchain_community.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_bedrock_anthropic_callback.html", "title": "How to track token usage in ChatModels"}]-->
# !pip install langchain-aws
from langchain_aws import ChatBedrock
from langchain_community.callbacks.manager import get_bedrock_anthropic_callback

llm = ChatBedrock(model_id="anthropic.claude-v2")

with get_bedrock_anthropic_callback() as cb:
    result = llm.invoke("Tell me a joke")
    result2 = llm.invoke("Tell me a joke")
    print(cb)
```

```output
Tokens Used: 96
	Prompt Tokens: 26
	Completion Tokens: 70
Successful Requests: 2
Total Cost (USD): $0.001888
```

## 다음 단계

이제 지원되는 제공자에 대한 토큰 사용량을 추적하는 몇 가지 예를 보았습니다.

다음으로, 이 섹션의 다른 채팅 모델 사용 방법 가이드를 확인하세요. 예를 들어, [모델이 구조화된 출력을 반환하도록 하는 방법](/docs/how_to/structured_output)이나 [채팅 모델에 캐싱 추가하는 방법](/docs/how_to/chat_model_caching) 등이 있습니다.
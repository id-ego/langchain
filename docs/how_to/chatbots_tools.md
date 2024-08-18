---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chatbots_tools.ipynb
description: 챗봇에 도구를 추가하는 방법을 안내합니다. 대화형 에이전트를 설정하고, Tavily를 사용하여 웹 검색 기능을 구현하는 방법을
  설명합니다.
---

# 챗봇에 도구 추가하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [챗봇](/docs/concepts/#messages)
- [에이전트](/docs/tutorials/agents)
- [채팅 기록](/docs/concepts/#chat-history)

:::

이 섹션에서는 도구를 사용하여 다른 시스템 및 API와 상호작용할 수 있는 대화형 에이전트를 만드는 방법을 다룹니다.

## 설정

이 가이드에서는 웹 검색을 위한 단일 도구를 사용하는 [도구 호출 에이전트](/docs/how_to/agent_executor)를 사용할 것입니다. 기본적으로 [Tavily](/docs/integrations/tools/tavily_search)를 사용하지만, 유사한 도구로 변경할 수 있습니다. 이 섹션의 나머지는 Tavily를 사용한다고 가정합니다.

Tavily 웹사이트에서 [계정을 등록](https://tavily.com/)하고 다음 패키지를 설치해야 합니다:

```python
%pip install --upgrade --quiet langchain-community langchain-openai tavily-python

# Set env var OPENAI_API_KEY or load from a .env file:
import dotenv

dotenv.load_dotenv()
```


또한 `OPENAI_API_KEY`로 OpenAI 키를 설정하고 `TAVILY_API_KEY`로 Tavily API 키를 설정해야 합니다.

## 에이전트 생성

우리의 최종 목표는 사용자 질문에 대화형으로 응답하면서 필요한 정보를 조회할 수 있는 에이전트를 만드는 것입니다.

먼저, 도구 호출이 가능한 OpenAI 채팅 모델과 Tavily를 초기화합시다:

```python
<!--IMPORTS:[{"imported": "TavilySearchResults", "source": "langchain_community.tools.tavily_search", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.tavily_search.tool.TavilySearchResults.html", "title": "How to add tools to chatbots"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add tools to chatbots"}]-->
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_openai import ChatOpenAI

tools = [TavilySearchResults(max_results=1)]

# Choose the LLM that will drive the agent
# Only certain models support this
chat = ChatOpenAI(model="gpt-3.5-turbo-1106", temperature=0)
```


우리 에이전트를 대화형으로 만들기 위해, 채팅 기록을 위한 플레이스홀더가 있는 프롬프트를 선택해야 합니다. 예를 들어:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add tools to chatbots"}]-->
from langchain_core.prompts import ChatPromptTemplate

# Adapted from https://smith.langchain.com/hub/jacob/tool-calling-agent
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. You may not need to use tools for every query - the user may just want to chat!",
        ),
        ("placeholder", "{messages}"),
        ("placeholder", "{agent_scratchpad}"),
    ]
)
```


좋습니다! 이제 에이전트를 조립해봅시다:

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to add tools to chatbots"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to add tools to chatbots"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent

agent = create_tool_calling_agent(chat, tools, prompt)

agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


## 에이전트 실행

이제 에이전트를 설정했으니, 상호작용해봅시다! 에이전트는 조회가 필요 없는 사소한 쿼리도 처리할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to add tools to chatbots"}]-->
from langchain_core.messages import HumanMessage

agent_executor.invoke({"messages": [HumanMessage(content="I'm Nemo!")]})
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mHello Nemo! It's great to meet you. How can I assist you today?[0m

[1m> Finished chain.[0m
```


```output
{'messages': [HumanMessage(content="I'm Nemo!")],
 'output': "Hello Nemo! It's great to meet you. How can I assist you today?"}
```


또한, 필요할 경우 전달된 검색 도구를 사용하여 최신 정보를 얻을 수 있습니다:

```python
agent_executor.invoke(
    {
        "messages": [
            HumanMessage(
                content="What is the current conservation status of the Great Barrier Reef?"
            )
        ],
    }
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `tavily_search_results_json` with `{'query': 'current conservation status of the Great Barrier Reef'}`


[0m[36;1m[1;3m[{'url': 'https://www.abc.net.au/news/2022-08-04/great-barrier-reef-report-says-coral-recovering-after-bleaching/101296186', 'content': 'Great Barrier Reef hit with widespread and severe bleaching event\n\'Devastating\': Over 90pc of reefs on Great Barrier Reef suffered bleaching over summer, report reveals\nTop Stories\nJailed Russian opposition leader Alexei Navalny is dead, says prison service\nTaylor Swift puts an Aussie twist on a classic as she packs the MCG for the biggest show of her career — as it happened\nMelbourne comes alive with Swifties, as even those without tickets turn up to soak in the atmosphere\nAustralian Border Force investigates after arrival of more than 20 men by boat north of Broome\nOpenAI launches video model that can instantly create short clips from text prompts\nAntoinette Lattouf loses bid to force ABC to produce emails calling for her dismissal\nCategory one cyclone makes landfall in Gulf of Carpentaria off NT-Queensland border\nWhy the RBA may be forced to cut before the Fed\nBrisbane records \'wettest day since 2022\', as woman dies in floodwaters near Mount Isa\n$45m Sydney beachside home once owned by late radio star is demolished less than a year after sale\nAnnabel Sutherland\'s historic double century puts Australia within reach of Test victory over South Africa\nAlmighty defensive effort delivers Indigenous victory in NRL All Stars clash\nLisa Wilkinson feared she would have to sell home to pay legal costs of Bruce Lehrmann\'s defamation case, court documents reveal\nSupermarkets as you know them are disappearing from our cities\nNRL issues Broncos\' Reynolds, Carrigan with breach notices after public scrap\nPopular Now\nJailed Russian opposition leader Alexei Navalny is dead, says prison service\nTaylor Swift puts an Aussie twist on a classic as she packs the MCG for the biggest show of her career — as it happened\n$45m Sydney beachside home once owned by late radio star is demolished less than a year after sale\nAustralian Border Force investigates after arrival of more than 20 men by boat north of Broome\nDealer sentenced for injecting children as young as 12 with methylamphetamine\nMelbourne comes alive with Swifties, as even those without tickets turn up to soak in the atmosphere\nTop Stories\nJailed Russian opposition leader Alexei Navalny is dead, says prison service\nTaylor Swift puts an Aussie twist on a classic as she packs the MCG for the biggest show of her career — as it happened\nMelbourne comes alive with Swifties, as even those without tickets turn up to soak in the atmosphere\nAustralian Border Force investigates after arrival of more than 20 men by boat north of Broome\nOpenAI launches video model that can instantly create short clips from text prompts\nJust In\nJailed Russian opposition leader Alexei Navalny is dead, says prison service\nMelbourne comes alive with Swifties, as even those without tickets turn up to soak in the atmosphere\nTraveller alert after one-year-old in Adelaide reported with measles\nAntoinette Lattouf loses bid to force ABC to produce emails calling for her dismissal\nFooter\nWe acknowledge Aboriginal and Torres Strait Islander peoples as the First Australians and Traditional Custodians of the lands where we live, learn, and work.\n Increased coral cover could come at a cost\nThe rapid growth in coral cover appears to have come at the expense of the diversity of coral on the reef, with most of the increases accounted for by fast-growing branching coral called Acropora.\n Documents obtained by the ABC under Freedom of Information laws revealed the Morrison government had forced AIMS to rush the report\'s release and orchestrated a "leak" of the material to select media outlets ahead of the reef being considered for inclusion on the World Heritage In Danger list.\n The reef\'s status and potential inclusion on the In Danger list were due to be discussed at the 45th session of the World Heritage Committee in Russia in June this year, but the meeting was indefinitely postponed due to the war in Ukraine.\n More from ABC\nEditorial Policies\nGreat Barrier Reef coral cover at record levels after mass-bleaching events, report shows\nGreat Barrier Reef coral cover at record levels after mass-bleaching events, report shows\nRecord coral cover is being seen across much of the Great Barrier Reef as it recovers from past storms and mass-bleaching events.'}][0m[32;1m[1;3mThe Great Barrier Reef is currently showing signs of recovery, with record coral cover being seen across much of the reef. This recovery comes after past storms and mass-bleaching events. However, the rapid growth in coral cover appears to have come at the expense of the diversity of coral on the reef, with most of the increases accounted for by fast-growing branching coral called Acropora. There were discussions about the reef's potential inclusion on the World Heritage In Danger list, but the meeting to consider this was indefinitely postponed due to the war in Ukraine.

You can read more about it in this article: [Great Barrier Reef hit with widespread and severe bleaching event](https://www.abc.net.au/news/2022-08-04/great-barrier-reef-report-says-coral-recovering-after-bleaching/101296186)[0m

[1m> Finished chain.[0m
```


```output
{'messages': [HumanMessage(content='What is the current conservation status of the Great Barrier Reef?')],
 'output': "The Great Barrier Reef is currently showing signs of recovery, with record coral cover being seen across much of the reef. This recovery comes after past storms and mass-bleaching events. However, the rapid growth in coral cover appears to have come at the expense of the diversity of coral on the reef, with most of the increases accounted for by fast-growing branching coral called Acropora. There were discussions about the reef's potential inclusion on the World Heritage In Danger list, but the meeting to consider this was indefinitely postponed due to the war in Ukraine.\n\nYou can read more about it in this article: [Great Barrier Reef hit with widespread and severe bleaching event](https://www.abc.net.au/news/2022-08-04/great-barrier-reef-report-says-coral-recovering-after-bleaching/101296186)"}
```


## 대화형 응답

우리의 프롬프트에는 채팅 기록 메시지를 위한 플레이스홀더가 포함되어 있기 때문에, 에이전트는 이전 상호작용을 고려하여 표준 챗봇처럼 대화형으로 응답할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to add tools to chatbots"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to add tools to chatbots"}]-->
from langchain_core.messages import AIMessage, HumanMessage

agent_executor.invoke(
    {
        "messages": [
            HumanMessage(content="I'm Nemo!"),
            AIMessage(content="Hello Nemo! How can I assist you today?"),
            HumanMessage(content="What is my name?"),
        ],
    }
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mYour name is Nemo![0m

[1m> Finished chain.[0m
```


```output
{'messages': [HumanMessage(content="I'm Nemo!"),
  AIMessage(content='Hello Nemo! How can I assist you today?'),
  HumanMessage(content='What is my name?')],
 'output': 'Your name is Nemo!'}
```


원하는 경우, 에이전트 실행기를 [`RunnableWithMessageHistory`](/docs/how_to/message_history/) 클래스에 감싸서 내부적으로 기록 메시지를 관리할 수 있습니다. 이렇게 다시 선언해봅시다:

```python
agent = create_tool_calling_agent(chat, tools, prompt)

agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


그런 다음, 에이전트 실행기가 여러 출력을 가지므로, 래퍼를 초기화할 때 `output_messages_key` 속성도 설정해야 합니다:

```python
<!--IMPORTS:[{"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "How to add tools to chatbots"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "How to add tools to chatbots"}]-->
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

demo_ephemeral_chat_history_for_chain = ChatMessageHistory()

conversational_agent_executor = RunnableWithMessageHistory(
    agent_executor,
    lambda session_id: demo_ephemeral_chat_history_for_chain,
    input_messages_key="messages",
    output_messages_key="output",
)

conversational_agent_executor.invoke(
    {"messages": [HumanMessage("I'm Nemo!")]},
    {"configurable": {"session_id": "unused"}},
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mHi Nemo! It's great to meet you. How can I assist you today?[0m

[1m> Finished chain.[0m
```


```output
{'messages': [HumanMessage(content="I'm Nemo!")],
 'output': "Hi Nemo! It's great to meet you. How can I assist you today?"}
```


그리고 나서 래핑된 에이전트 실행기를 다시 실행하면:

```python
conversational_agent_executor.invoke(
    {"messages": [HumanMessage("What is my name?")]},
    {"configurable": {"session_id": "unused"}},
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mYour name is Nemo! How can I assist you today, Nemo?[0m

[1m> Finished chain.[0m
```


```output
{'messages': [HumanMessage(content="I'm Nemo!"),
  AIMessage(content="Hi Nemo! It's great to meet you. How can I assist you today?"),
  HumanMessage(content='What is my name?')],
 'output': 'Your name is Nemo! How can I assist you today, Nemo?'}
```


이 [LangSmith 추적](https://smith.langchain.com/public/1a9f712a-7918-4661-b3ff-d979bcc2af42/r)는 내부에서 무슨 일이 일어나고 있는지를 보여줍니다.

## 추가 읽기

다른 유형의 에이전트도 대화형 응답을 지원할 수 있습니다 - 더 많은 정보는 [에이전트 섹션](/docs/tutorials/agents)을 확인하세요.

도구 사용에 대한 더 많은 정보는 [이 사용 사례 섹션](/docs/how_to#tools)을 확인할 수 있습니다.
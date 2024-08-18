---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/steam.ipynb
description: Steam Toolkit은 Steam API를 사용하여 게임 추천 및 게임 정보 검색을 위한 LangChain 기반 도구를
  제공합니다.
---

# Steam Toolkit

> [Steam (위키백과)](https://en.wikipedia.org/wiki/Steam_(service))는 `Valve Corporation`에서 개발한 비디오 게임 디지털 배급 서비스 및 상점입니다. 이 서비스는 Valve의 게임에 대한 업데이트를 자동으로 제공하며, 제3자 타이틀 배급으로 확장되었습니다. `Steam`은 Valve의 안티 치트 조치를 통한 게임 서버 매칭, 소셜 네트워킹, 게임 스트리밍 서비스와 같은 다양한 기능을 제공합니다.

> [Steam](https://store.steampowered.com/about/)은 게임을 플레이하고, 토론하고, 만드는 궁극적인 목적지입니다.

Steam toolkit에는 두 가지 도구가 있습니다:
- `게임 세부정보`
- `추천 게임`

이 노트북은 현재 Steam 게임 인벤토리를 기반으로 Steam 게임 추천을 검색하거나 제공한 Steam 게임에 대한 정보를 수집하기 위해 LangChain과 함께 Steam API를 사용하는 방법을 안내합니다.

## 설정하기

두 개의 파이썬 라이브러리를 설치해야 합니다.

## 가져오기

```python
%pip install --upgrade --quiet  python-steam-api python-decouple
```


## 환경 변수 할당
이 툴킷을 사용하려면 OpenAI API 키, Steam API 키(여기에서 [받기](https://steamcommunity.com/dev/apikey)) 및 자신의 SteamID를 준비하세요. Steam API 키를 받으면 아래에 환경 변수로 입력할 수 있습니다. 툴킷은 "STEAM_KEY" API 키를 환경 변수로 읽어 인증하므로 여기에 설정해 주세요. 또한 "OPENAI_API_KEY"와 "STEAM_ID"를 설정해야 합니다.

```python
import os

os.environ["STEAM_KEY"] = "xyz"
os.environ["STEAM_ID"] = "123"
os.environ["OPENAI_API_KEY"] = "abc"
```


## 초기화:
LLM, SteamWebAPIWrapper, SteamToolkit을 초기화하고 가장 중요하게는 쿼리를 처리할 langchain 에이전트를 초기화합니다!
## 예시

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Steam Toolkit"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Steam Toolkit"}, {"imported": "SteamToolkit", "source": "langchain_community.agent_toolkits.steam.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.steam.toolkit.SteamToolkit.html", "title": "Steam Toolkit"}, {"imported": "SteamWebAPIWrapper", "source": "langchain_community.utilities.steam", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.steam.SteamWebAPIWrapper.html", "title": "Steam Toolkit"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Steam Toolkit"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_community.agent_toolkits.steam.toolkit import SteamToolkit
from langchain_community.utilities.steam import SteamWebAPIWrapper
from langchain_openai import OpenAI
```


```python
llm = OpenAI(temperature=0)
Steam = SteamWebAPIWrapper()
toolkit = SteamToolkit.from_steam_api_wrapper(Steam)
agent = initialize_agent(
    toolkit.get_tools(), llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
```


```python
out = agent("can you give the information about the game Terraria")
print(out)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m I need to find the game details
Action: Get Games Details
Action Input: Terraria[0m
Observation: [36;1m[1;3mThe id is: 105600
The link is: https://store.steampowered.com/app/105600/Terraria/?snr=1_7_15__13
The price is: $9.99
The summary of the game is: Dig, Fight, Explore, Build:  The very world is at your fingertips as you fight for survival, fortune, and glory.   Will you delve deep into cavernous expanses in search of treasure and raw materials with which to craft ever-evolving gear, machinery, and aesthetics?   Perhaps you will choose instead to seek out ever-greater foes to test your mettle in combat?   Maybe you will decide to construct your own city to house the host of mysterious allies you may encounter along your travels? In the World of Terraria, the choice is yours!Blending elements of classic action games with the freedom of sandbox-style creativity, Terraria is a unique gaming experience where both the journey and the destination are completely in the player’s control.   The Terraria adventure is truly as unique as the players themselves!  Are you up for the monumental task of exploring, creating, and defending a world of your own?   Key features: Sandbox Play  Randomly generated worlds Free Content Updates 
The supported languages of the game are: English, French, Italian, German, Spanish - Spain, Polish, Portuguese - Brazil, Russian, Simplified Chinese
[0m
Thought:[32;1m[1;3m I now know the final answer
Final Answer: Terraria is a game with an id of 105600, a link of https://store.steampowered.com/app/105600/Terraria/?snr=1_7_15__13, a price of $9.99, a summary of "Dig, Fight, Explore, Build:  The very world is at your fingertips as you fight for survival, fortune, and glory.   Will you delve deep into cavernous expanses in search of treasure and raw materials with which to craft ever-evolving gear, machinery, and aesthetics?   Perhaps you will choose instead to seek out ever-greater foes to test your mettle in combat?   Maybe you will decide to construct your own city to house the host of mysterious allies you may encounter along your travels? In the World of Terraria, the choice is yours!Blending elements of classic action games with the freedom of sandbox-style creativity, Terraria is a unique gaming experience where both the journey and the destination are completely in the player’s control.   The Terraria adventure is truly as unique as the players themselves!  Are you up for the monumental task of exploring, creating, and defending a[0m

[1m> Finished chain.[0m
{'input': 'can you give the information about the game Terraria', 'output': 'Terraria is a game with an id of 105600, a link of https://store.steampowered.com/app/105600/Terraria/?snr=1_7_15__13, a price of $9.99, a summary of "Dig, Fight, Explore, Build:  The very world is at your fingertips as you fight for survival, fortune, and glory.   Will you delve deep into cavernous expanses in search of treasure and raw materials with which to craft ever-evolving gear, machinery, and aesthetics?   Perhaps you will choose instead to seek out ever-greater foes to test your mettle in combat?   Maybe you will decide to construct your own city to house the host of mysterious allies you may encounter along your travels? In the World of Terraria, the choice is yours!Blending elements of classic action games with the freedom of sandbox-style creativity, Terraria is a unique gaming experience where both the journey and the destination are completely in the player’s control.   The Terraria adventure is truly as unique as the players themselves!  Are you up for the monumental task of exploring, creating, and defending a'}
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/openweathermap.ipynb
description: 이 문서는 OpenWeatherMap API를 사용하여 날씨 정보를 가져오는 방법을 설명합니다. API 키 등록 및 환경 변수
  설정 방법이 포함되어 있습니다.
---

# OpenWeatherMap

이 노트북은 `OpenWeatherMap` 컴포넌트를 사용하여 날씨 정보를 가져오는 방법을 다룹니다.

먼저, `OpenWeatherMap API` 키에 가입해야 합니다:

1. OpenWeatherMap에 가서 [여기](https://openweathermap.org/api/)에서 API 키에 가입하세요.
2. pip install pyowm

그런 다음 몇 가지 환경 변수를 설정해야 합니다:
1. OPENWEATHERMAP_API_KEY 환경 변수에 API KEY를 저장하세요.

## 래퍼 사용하기

```python
<!--IMPORTS:[{"imported": "OpenWeatherMapAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.openweathermap.OpenWeatherMapAPIWrapper.html", "title": "OpenWeatherMap"}]-->
import os

from langchain_community.utilities import OpenWeatherMapAPIWrapper

os.environ["OPENWEATHERMAP_API_KEY"] = ""

weather = OpenWeatherMapAPIWrapper()
```


```python
weather_data = weather.run("London,GB")
print(weather_data)
```

```output
In London,GB, the current weather is as follows:
Detailed status: broken clouds
Wind speed: 2.57 m/s, direction: 240°
Humidity: 55%
Temperature: 
  - Current: 20.12°C
  - High: 21.75°C
  - Low: 18.68°C
  - Feels like: 19.62°C
Rain: {}
Heat index: None
Cloud cover: 75%
```

## 도구 사용하기

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "OpenWeatherMap"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "OpenWeatherMap"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "OpenWeatherMap"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "OpenWeatherMap"}]-->
import os

from langchain.agents import AgentType, initialize_agent, load_tools
from langchain_openai import OpenAI

os.environ["OPENAI_API_KEY"] = ""
os.environ["OPENWEATHERMAP_API_KEY"] = ""

llm = OpenAI(temperature=0)

tools = load_tools(["openweathermap-api"], llm)

agent_chain = initialize_agent(
    tools=tools, llm=llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
```


```python
agent_chain.run("What's the weather like in London?")
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m I need to find out the current weather in London.
Action: OpenWeatherMap
Action Input: London,GB[0m
Observation: [36;1m[1;3mIn London,GB, the current weather is as follows:
Detailed status: broken clouds
Wind speed: 2.57 m/s, direction: 240°
Humidity: 56%
Temperature: 
  - Current: 20.11°C
  - High: 21.75°C
  - Low: 18.68°C
  - Feels like: 19.64°C
Rain: {}
Heat index: None
Cloud cover: 75%[0m
Thought:[32;1m[1;3m I now know the current weather in London.
Final Answer: The current weather in London is broken clouds, with a wind speed of 2.57 m/s, direction 240°, humidity of 56%, temperature of 20.11°C, high of 21.75°C, low of 18.68°C, and a heat index of None.[0m

[1m> Finished chain.[0m
```


```output
'The current weather in London is broken clouds, with a wind speed of 2.57 m/s, direction 240°, humidity of 56%, temperature of 20.11°C, high of 21.75°C, low of 18.68°C, and a heat index of None.'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
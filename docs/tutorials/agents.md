---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/agents.ipynb
description: 이 문서는 LLM을 활용한 에이전트 구축 방법을 설명하며, 검색 엔진과 상호작용하는 기능을 포함합니다.
keywords:
- agent
- agents
---

# 에이전트 구축하기

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [채팅 모델](/docs/concepts/#chat-models)
- [도구](/docs/concepts/#tools)
- [에이전트](/docs/concepts/#agents)

:::

언어 모델 자체로는 행동을 취할 수 없습니다 - 단지 텍스트를 출력할 뿐입니다. LangChain의 주요 사용 사례 중 하나는 **에이전트**를 만드는 것입니다. 에이전트는 LLM을 추론 엔진으로 사용하여 어떤 행동을 취할지와 그에 전달할 입력을 결정하는 시스템입니다. 행동을 실행한 후, 결과는 LLM에 피드백되어 추가 행동이 필요한지, 아니면 종료해도 되는지를 판단할 수 있습니다.

이 튜토리얼에서는 검색 엔진과 상호작용할 수 있는 에이전트를 구축할 것입니다. 이 에이전트에게 질문을 하고, 검색 도구를 호출하는 모습을 지켜보며, 대화를 나눌 수 있습니다.

## 엔드 투 엔드 에이전트

아래의 코드 스니펫은 LLM을 사용하여 어떤 도구를 사용할지 결정하는 완전한 기능의 에이전트를 나타냅니다. 일반 검색 도구가 장착되어 있으며, 대화 기억 기능이 있어 다중 턴 챗봇으로 사용할 수 있습니다.

가이드의 나머지 부분에서는 개별 구성 요소와 각 부분이 하는 일을 살펴보겠지만, 코드를 간단히 가져가고 시작하고 싶다면 자유롭게 사용하세요!

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "Build an Agent"}, {"imported": "TavilySearchResults", "source": "langchain_community.tools.tavily_search", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.tavily_search.tool.TavilySearchResults.html", "title": "Build an Agent"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Build an Agent"}]-->
# Import relevant functionality
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.messages import HumanMessage
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import create_react_agent

# Create the agent
memory = MemorySaver()
model = ChatAnthropic(model_name="claude-3-sonnet-20240229")
search = TavilySearchResults(max_results=2)
tools = [search]
agent_executor = create_react_agent(model, tools, checkpointer=memory)

# Use the agent
config = {"configurable": {"thread_id": "abc123"}}
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="hi im bob! and i live in sf")]}, config
):
    print(chunk)
    print("----")

for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="whats the weather where I live?")]}, config
):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content="Hello Bob! Since you didn't ask a specific question, I don't need to use any tools to respond. It's nice to meet you. San Francisco is a wonderful city with lots to see and do. I hope you're enjoying living there. Please let me know if you have any other questions!", response_metadata={'id': 'msg_01Mmfzfs9m4XMgVzsCZYMWqH', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 271, 'output_tokens': 65}}, id='run-44c57f9c-a637-4888-b7d9-6d985031ae48-0', usage_metadata={'input_tokens': 271, 'output_tokens': 65, 'total_tokens': 336})]}}
----
{'agent': {'messages': [AIMessage(content=[{'text': 'To get current weather information for your location in San Francisco, let me invoke the search tool:', 'type': 'text'}, {'id': 'toolu_01BGEyQaSz3pTq8RwUUHSRoo', 'input': {'query': 'san francisco weather'}, 'name': 'tavily_search_results_json', 'type': 'tool_use'}], response_metadata={'id': 'msg_013AVSVsRLKYZjduLpJBY4us', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'tool_use', 'stop_sequence': None, 'usage': {'input_tokens': 347, 'output_tokens': 80}}, id='run-de7923b6-5ee2-4ebe-bd95-5aed4933d0e3-0', tool_calls=[{'name': 'tavily_search_results_json', 'args': {'query': 'san francisco weather'}, 'id': 'toolu_01BGEyQaSz3pTq8RwUUHSRoo'}], usage_metadata={'input_tokens': 347, 'output_tokens': 80, 'total_tokens': 427})]}}
----
{'tools': {'messages': [ToolMessage(content='[{"url": "https://www.weatherapi.com/", "content": "{\'location\': {\'name\': \'San Francisco\', \'region\': \'California\', \'country\': \'United States of America\', \'lat\': 37.78, \'lon\': -122.42, \'tz_id\': \'America/Los_Angeles\', \'localtime_epoch\': 1717238643, \'localtime\': \'2024-06-01 3:44\'}, \'current\': {\'last_updated_epoch\': 1717237800, \'last_updated\': \'2024-06-01 03:30\', \'temp_c\': 12.0, \'temp_f\': 53.6, \'is_day\': 0, \'condition\': {\'text\': \'Mist\', \'icon\': \'//cdn.weatherapi.com/weather/64x64/night/143.png\', \'code\': 1030}, \'wind_mph\': 5.6, \'wind_kph\': 9.0, \'wind_degree\': 310, \'wind_dir\': \'NW\', \'pressure_mb\': 1013.0, \'pressure_in\': 29.92, \'precip_mm\': 0.0, \'precip_in\': 0.0, \'humidity\': 88, \'cloud\': 100, \'feelslike_c\': 10.5, \'feelslike_f\': 50.8, \'windchill_c\': 9.3, \'windchill_f\': 48.7, \'heatindex_c\': 11.1, \'heatindex_f\': 51.9, \'dewpoint_c\': 8.8, \'dewpoint_f\': 47.8, \'vis_km\': 6.4, \'vis_miles\': 3.0, \'uv\': 1.0, \'gust_mph\': 12.5, \'gust_kph\': 20.1}}"}, {"url": "https://www.timeanddate.com/weather/usa/san-francisco/historic", "content": "Past Weather in San Francisco, California, USA \\u2014 Yesterday and Last 2 Weeks. Time/General. Weather. Time Zone. DST Changes. Sun & Moon. Weather Today Weather Hourly 14 Day Forecast Yesterday/Past Weather Climate (Averages) Currently: 68 \\u00b0F. Passing clouds."}]', name='tavily_search_results_json', tool_call_id='toolu_01BGEyQaSz3pTq8RwUUHSRoo')]}}
----
{'agent': {'messages': [AIMessage(content='Based on the search results, the current weather in San Francisco is:\n\nTemperature: 53.6°F (12°C)\nConditions: Misty\nWind: 5.6 mph (9 kph) from the Northwest\nHumidity: 88%\nCloud Cover: 100% \n\nThe results provide detailed information like wind chill, heat index, visibility and more. It looks like a typical cool, foggy morning in San Francisco. Let me know if you need any other details about the weather where you live!', response_metadata={'id': 'msg_019WGLbaojuNdbCnqac7zaGW', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 1035, 'output_tokens': 120}}, id='run-1bb68bf3-b212-4ef4-8a31-10c830421c78-0', usage_metadata={'input_tokens': 1035, 'output_tokens': 120, 'total_tokens': 1155})]}}
----
```


## 설정

### 주피터 노트북

이 가이드(및 문서의 대부분의 다른 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며, 독자가 주피터 노트북을 사용할 것이라고 가정합니다. 주피터 노트북은 LLM 시스템과 작업하는 방법을 배우기에 완벽한 대화형 환경입니다. 종종 예상치 못한 출력, API 다운 등 문제가 발생할 수 있으며, 이러한 사례를 관찰하는 것은 LLM으로 구축하는 것을 더 잘 이해하는 좋은 방법입니다.

이 튜토리얼과 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행할 수 있습니다. 설치 방법은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

LangChain을 설치하려면 다음을 실행하세요:

```python
%pip install -U langchain-community langgraph langchain-anthropic tavily-python langgraph-checkpoint-sqlite
```


자세한 내용은 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 번의 LLM 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)입니다.

위 링크에서 가입한 후, 추적 로그를 시작하기 위해 환경 변수를 설정하세요:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```


또는 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


### Tavily

우리는 도구로 [Tavily](/docs/integrations/tools/tavily_search) (검색 엔진)를 사용할 것입니다. 이를 사용하려면 API 키를 얻고 설정해야 합니다:

```bash
export TAVILY_API_KEY="..."
```


또는 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["TAVILY_API_KEY"] = getpass.getpass()
```


## 도구 정의하기

먼저 사용하고자 하는 도구를 만들어야 합니다. 우리가 선택할 주요 도구는 [Tavily](/docs/integrations/tools/tavily_search) - 검색 엔진입니다. LangChain에는 Tavily 검색 엔진을 도구로 쉽게 사용할 수 있는 내장 도구가 있습니다.

```python
<!--IMPORTS:[{"imported": "TavilySearchResults", "source": "langchain_community.tools.tavily_search", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.tavily_search.tool.TavilySearchResults.html", "title": "Build an Agent"}]-->
from langchain_community.tools.tavily_search import TavilySearchResults

search = TavilySearchResults(max_results=2)
search_results = search.invoke("what is the weather in SF")
print(search_results)
# If we want, we can create other tools.
# Once we have all the tools we want, we can put them in a list that we will reference later.
tools = [search]
```


```output
[{'url': 'https://www.weatherapi.com/',
  'content': "{'location': {'name': 'San Francisco', 'region': 'California', 'country': 'United States of America', 'lat': 37.78, 'lon': -122.42, 'tz_id': 'America/Los_Angeles', 'localtime_epoch': 1717238703, 'localtime': '2024-06-01 3:45'}, 'current': {'last_updated_epoch': 1717237800, 'last_updated': '2024-06-01 03:30', 'temp_c': 12.0, 'temp_f': 53.6, 'is_day': 0, 'condition': {'text': 'Mist', 'icon': '//cdn.weatherapi.com/weather/64x64/night/143.png', 'code': 1030}, 'wind_mph': 5.6, 'wind_kph': 9.0, 'wind_degree': 310, 'wind_dir': 'NW', 'pressure_mb': 1013.0, 'pressure_in': 29.92, 'precip_mm': 0.0, 'precip_in': 0.0, 'humidity': 88, 'cloud': 100, 'feelslike_c': 10.5, 'feelslike_f': 50.8, 'windchill_c': 9.3, 'windchill_f': 48.7, 'heatindex_c': 11.1, 'heatindex_f': 51.9, 'dewpoint_c': 8.8, 'dewpoint_f': 47.8, 'vis_km': 6.4, 'vis_miles': 3.0, 'uv': 1.0, 'gust_mph': 12.5, 'gust_kph': 20.1}}"},
 {'url': 'https://www.wunderground.com/hourly/us/ca/san-francisco/date/2024-01-06',
  'content': 'Current Weather for Popular Cities . San Francisco, CA 58 ° F Partly Cloudy; Manhattan, NY warning 51 ° F Cloudy; Schiller Park, IL (60176) warning 51 ° F Fair; Boston, MA warning 41 ° F ...'}]
```


## 언어 모델 사용하기

다음으로, 도구를 호출하기 위해 언어 모델을 사용하는 방법을 배워봅시다. LangChain은 서로 교환 가능하게 사용할 수 있는 다양한 언어 모델을 지원합니다 - 아래에서 사용하고자 하는 모델을 선택하세요!

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs openaiParams={`model="gpt-4"`} />

언어 모델을 호출하려면 메시지 목록을 전달하면 됩니다. 기본적으로 응답은 `content` 문자열입니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Build an Agent"}]-->
from langchain_core.messages import HumanMessage

response = model.invoke([HumanMessage(content="hi!")])
response.content
```


```output
'Hi there!'
```


이제 이 모델이 도구 호출을 수행하도록 활성화하는 것이 어떤 것인지 볼 수 있습니다. 이를 활성화하기 위해 `.bind_tools`를 사용하여 언어 모델에 이러한 도구에 대한 지식을 제공합니다.

```python
model_with_tools = model.bind_tools(tools)
```


이제 모델을 호출할 수 있습니다. 먼저 일반 메시지로 호출하여 응답을 확인해 보겠습니다. `content` 필드와 `tool_calls` 필드를 모두 살펴볼 수 있습니다.

```python
response = model_with_tools.invoke([HumanMessage(content="Hi!")])

print(f"ContentString: {response.content}")
print(f"ToolCalls: {response.tool_calls}")
```

```output
ContentString: Hello!
ToolCalls: []
```


이제 도구가 호출될 것으로 예상되는 입력으로 호출해 보겠습니다.

```python
response = model_with_tools.invoke([HumanMessage(content="What's the weather in SF?")])

print(f"ContentString: {response.content}")
print(f"ToolCalls: {response.tool_calls}")
```

```output
ContentString: 
ToolCalls: [{'name': 'tavily_search_results_json', 'args': {'query': 'weather san francisco'}, 'id': 'toolu_01VTP7DUvSfgtYxsq9x4EwMp'}]
```


이제 텍스트 콘텐츠는 없지만 도구 호출이 있습니다! Tavily 검색 도구를 호출하길 원합니다.

이것은 아직 도구를 호출하는 것이 아닙니다 - 단지 호출하라고 알려주는 것입니다. 실제로 호출하려면 에이전트를 생성해야 합니다.

## 에이전트 생성하기

이제 도구와 LLM을 정의했으므로 에이전트를 생성할 수 있습니다. 우리는 [LangGraph](/docs/concepts/#langgraph)를 사용하여 에이전트를 구성할 것입니다. 현재 우리는 에이전트를 구성하기 위해 고급 인터페이스를 사용하고 있지만, LangGraph의 좋은 점은 이 고급 인터페이스가 에이전트 로직을 수정하고자 할 때 사용할 수 있는 저수준의 고도로 제어 가능한 API에 의해 지원된다는 것입니다.

이제 LLM과 도구로 에이전트를 초기화할 수 있습니다.

`model_with_tools`가 아닌 `model`을 전달하고 있다는 점에 유의하세요. 이는 `create_react_agent`가 내부적으로 `.bind_tools`를 호출하기 때문입니다.

```python
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(model, tools)
```


## 에이전트 실행하기

이제 몇 가지 쿼리에 대해 에이전트를 실행할 수 있습니다! 현재로서는 모두 **무상태** 쿼리입니다(이전 상호작용을 기억하지 않습니다). 에이전트는 상호작용의 마지막 상태를 반환합니다(여기에는 모든 입력이 포함되며, 나중에 출력만 얻는 방법을 살펴보겠습니다).

먼저, 도구를 호출할 필요가 없을 때 어떻게 반응하는지 살펴보겠습니다:

```python
response = agent_executor.invoke({"messages": [HumanMessage(content="hi!")]})

response["messages"]
```


```output
[HumanMessage(content='hi!', id='a820fcc5-9b87-457a-9af0-f21768143ee3'),
 AIMessage(content='Hello!', response_metadata={'id': 'msg_01VbC493X1VEDyusgttiEr1z', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 264, 'output_tokens': 5}}, id='run-0e0ddae8-a85b-4bd6-947c-c36c857a4698-0', usage_metadata={'input_tokens': 264, 'output_tokens': 5, 'total_tokens': 269})]
```


정확히 무슨 일이 일어나고 있는지 확인하고(그리고 도구를 호출하지 않는지 확인하기 위해) [LangSmith 추적](https://smith.langchain.com/public/28311faa-e135-4d6a-ab6b-caecf6482aaa/r)을 살펴볼 수 있습니다.

이제 도구를 호출해야 하는 예제에서 시도해 보겠습니다.

```python
response = agent_executor.invoke(
    {"messages": [HumanMessage(content="whats the weather in sf?")]}
)
response["messages"]
```


```output
[HumanMessage(content='whats the weather in sf?', id='1d6c96bb-4ddb-415c-a579-a07d5264de0d'),
 AIMessage(content=[{'id': 'toolu_01Y5EK4bw2LqsQXeaUv8iueF', 'input': {'query': 'weather in san francisco'}, 'name': 'tavily_search_results_json', 'type': 'tool_use'}], response_metadata={'id': 'msg_0132wQUcEduJ8UKVVVqwJzM4', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'tool_use', 'stop_sequence': None, 'usage': {'input_tokens': 269, 'output_tokens': 61}}, id='run-26d5e5e8-d4fd-46d2-a197-87b95b10e823-0', tool_calls=[{'name': 'tavily_search_results_json', 'args': {'query': 'weather in san francisco'}, 'id': 'toolu_01Y5EK4bw2LqsQXeaUv8iueF'}], usage_metadata={'input_tokens': 269, 'output_tokens': 61, 'total_tokens': 330}),
 ToolMessage(content='[{"url": "https://www.weatherapi.com/", "content": "{\'location\': {\'name\': \'San Francisco\', \'region\': \'California\', \'country\': \'United States of America\', \'lat\': 37.78, \'lon\': -122.42, \'tz_id\': \'America/Los_Angeles\', \'localtime_epoch\': 1717238703, \'localtime\': \'2024-06-01 3:45\'}, \'current\': {\'last_updated_epoch\': 1717237800, \'last_updated\': \'2024-06-01 03:30\', \'temp_c\': 12.0, \'temp_f\': 53.6, \'is_day\': 0, \'condition\': {\'text\': \'Mist\', \'icon\': \'//cdn.weatherapi.com/weather/64x64/night/143.png\', \'code\': 1030}, \'wind_mph\': 5.6, \'wind_kph\': 9.0, \'wind_degree\': 310, \'wind_dir\': \'NW\', \'pressure_mb\': 1013.0, \'pressure_in\': 29.92, \'precip_mm\': 0.0, \'precip_in\': 0.0, \'humidity\': 88, \'cloud\': 100, \'feelslike_c\': 10.5, \'feelslike_f\': 50.8, \'windchill_c\': 9.3, \'windchill_f\': 48.7, \'heatindex_c\': 11.1, \'heatindex_f\': 51.9, \'dewpoint_c\': 8.8, \'dewpoint_f\': 47.8, \'vis_km\': 6.4, \'vis_miles\': 3.0, \'uv\': 1.0, \'gust_mph\': 12.5, \'gust_kph\': 20.1}}"}, {"url": "https://www.timeanddate.com/weather/usa/san-francisco/hourly", "content": "Sun & Moon. Weather Today Weather Hourly 14 Day Forecast Yesterday/Past Weather Climate (Averages) Currently: 59 \\u00b0F. Passing clouds. (Weather station: San Francisco International Airport, USA). See more current weather."}]', name='tavily_search_results_json', id='37aa1fd9-b232-4a02-bd22-bc5b9b44a22c', tool_call_id='toolu_01Y5EK4bw2LqsQXeaUv8iueF'),
 AIMessage(content='Based on the search results, here is a summary of the current weather in San Francisco:\n\nThe weather in San Francisco is currently misty with a temperature of around 53°F (12°C). There is complete cloud cover and moderate winds from the northwest around 5-9 mph (9-14 km/h). Humidity is high at 88%. Visibility is around 3 miles (6.4 km). \n\nThe results provide an hourly forecast as well as current conditions from a couple different weather sources. Let me know if you need any additional details about the San Francisco weather!', response_metadata={'id': 'msg_01BRX9mrT19nBDdHYtR7wJ92', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 920, 'output_tokens': 132}}, id='run-d0325583-3ddc-4432-b2b2-d023eb97660f-0', usage_metadata={'input_tokens': 920, 'output_tokens': 132, 'total_tokens': 1052})]
```


검색 도구를 효과적으로 호출하고 있는지 확인하기 위해 [LangSmith 추적](https://smith.langchain.com/public/f520839d-cd4d-4495-8764-e32b548e235d/r)을 확인할 수 있습니다.

## 메시지 스트리밍

우리는 에이전트를 `.invoke`로 호출하여 최종 응답을 받을 수 있는 방법을 보았습니다. 에이전트가 여러 단계를 실행하는 경우 시간이 걸릴 수 있습니다. 중간 진행 상황을 보여주기 위해 메시지를 스트리밍하여 반환할 수 있습니다.

```python
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="whats the weather in sf?")]}
):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_50Kb8zHmFqPYavQwF5TgcOH8', 'function': {'arguments': '{\n  "query": "current weather in San Francisco"\n}', 'name': 'tavily_search_results_json'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 23, 'prompt_tokens': 134, 'total_tokens': 157}, 'model_name': 'gpt-4', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-042d5feb-c2cc-4c3f-b8fd-dbc22fd0bc07-0', tool_calls=[{'name': 'tavily_search_results_json', 'args': {'query': 'current weather in San Francisco'}, 'id': 'call_50Kb8zHmFqPYavQwF5TgcOH8'}])]}}
----
{'action': {'messages': [ToolMessage(content='[{"url": "https://www.weatherapi.com/", "content": "{\'location\': {\'name\': \'San Francisco\', \'region\': \'California\', \'country\': \'United States of America\', \'lat\': 37.78, \'lon\': -122.42, \'tz_id\': \'America/Los_Angeles\', \'localtime_epoch\': 1714426906, \'localtime\': \'2024-04-29 14:41\'}, \'current\': {\'last_updated_epoch\': 1714426200, \'last_updated\': \'2024-04-29 14:30\', \'temp_c\': 17.8, \'temp_f\': 64.0, \'is_day\': 1, \'condition\': {\'text\': \'Sunny\', \'icon\': \'//cdn.weatherapi.com/weather/64x64/day/113.png\', \'code\': 1000}, \'wind_mph\': 23.0, \'wind_kph\': 37.1, \'wind_degree\': 290, \'wind_dir\': \'WNW\', \'pressure_mb\': 1019.0, \'pressure_in\': 30.09, \'precip_mm\': 0.0, \'precip_in\': 0.0, \'humidity\': 50, \'cloud\': 0, \'feelslike_c\': 17.8, \'feelslike_f\': 64.0, \'vis_km\': 16.0, \'vis_miles\': 9.0, \'uv\': 5.0, \'gust_mph\': 27.5, \'gust_kph\': 44.3}}"}, {"url": "https://world-weather.info/forecast/usa/san_francisco/april-2024/", "content": "Extended weather forecast in San Francisco. Hourly Week 10 days 14 days 30 days Year. Detailed \\u26a1 San Francisco Weather Forecast for April 2024 - day/night \\ud83c\\udf21\\ufe0f temperatures, precipitations - World-Weather.info."}]', name='tavily_search_results_json', id='d88320ac-3fe1-4f73-870a-3681f15f6982', tool_call_id='call_50Kb8zHmFqPYavQwF5TgcOH8')]}}
----
{'agent': {'messages': [AIMessage(content='The current weather in San Francisco, California is sunny with a temperature of 17.8°C (64.0°F). The wind is coming from the WNW at 23.0 mph. The humidity is at 50%. [source](https://www.weatherapi.com/)', response_metadata={'token_usage': {'completion_tokens': 58, 'prompt_tokens': 602, 'total_tokens': 660}, 'model_name': 'gpt-4', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-0cd2a507-ded5-4601-afe3-3807400e9989-0')]}}
----
```


## 토큰 스트리밍

메시지를 스트리밍하여 반환하는 것 외에도, 토큰을 스트리밍하여 반환하는 것도 유용합니다. 이는 `.astream_events` 메서드를 사용하여 수행할 수 있습니다.

:::important
이 `.astream_events` 메서드는 Python 3.11 이상에서만 작동합니다.
:::

```python
async for event in agent_executor.astream_events(
    {"messages": [HumanMessage(content="whats the weather in sf?")]}, version="v1"
):
    kind = event["event"]
    if kind == "on_chain_start":
        if (
            event["name"] == "Agent"
        ):  # Was assigned when creating the agent with `.with_config({"run_name": "Agent"})`
            print(
                f"Starting agent: {event['name']} with input: {event['data'].get('input')}"
            )
    elif kind == "on_chain_end":
        if (
            event["name"] == "Agent"
        ):  # Was assigned when creating the agent with `.with_config({"run_name": "Agent"})`
            print()
            print("--")
            print(
                f"Done agent: {event['name']} with output: {event['data'].get('output')['output']}"
            )
    if kind == "on_chat_model_stream":
        content = event["data"]["chunk"].content
        if content:
            # Empty content in the context of OpenAI means
            # that the model is asking for a tool to be invoked.
            # So we only print non-empty content
            print(content, end="|")
    elif kind == "on_tool_start":
        print("--")
        print(
            f"Starting tool: {event['name']} with inputs: {event['data'].get('input')}"
        )
    elif kind == "on_tool_end":
        print(f"Done tool: {event['name']}")
        print(f"Tool output was: {event['data'].get('output')}")
        print("--")
```

```output
--
Starting tool: tavily_search_results_json with inputs: {'query': 'current weather in San Francisco'}
Done tool: tavily_search_results_json
Tool output was: [{'url': 'https://www.weatherapi.com/', 'content': "{'location': {'name': 'San Francisco', 'region': 'California', 'country': 'United States of America', 'lat': 37.78, 'lon': -122.42, 'tz_id': 'America/Los_Angeles', 'localtime_epoch': 1714427052, 'localtime': '2024-04-29 14:44'}, 'current': {'last_updated_epoch': 1714426200, 'last_updated': '2024-04-29 14:30', 'temp_c': 17.8, 'temp_f': 64.0, 'is_day': 1, 'condition': {'text': 'Sunny', 'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png', 'code': 1000}, 'wind_mph': 23.0, 'wind_kph': 37.1, 'wind_degree': 290, 'wind_dir': 'WNW', 'pressure_mb': 1019.0, 'pressure_in': 30.09, 'precip_mm': 0.0, 'precip_in': 0.0, 'humidity': 50, 'cloud': 0, 'feelslike_c': 17.8, 'feelslike_f': 64.0, 'vis_km': 16.0, 'vis_miles': 9.0, 'uv': 5.0, 'gust_mph': 27.5, 'gust_kph': 44.3}}"}, {'url': 'https://www.weathertab.com/en/c/e/04/united-states/california/san-francisco/', 'content': 'San Francisco Weather Forecast for Apr 2024 - Risk of Rain Graph. Rain Risk Graph: Monthly Overview. Bar heights indicate rain risk percentages. Yellow bars mark low-risk days, while black and grey bars signal higher risks. Grey-yellow bars act as buffers, advising to keep at least one day clear from the riskier grey and black days, guiding ...'}]
--
The| current| weather| in| San| Francisco|,| California|,| USA| is| sunny| with| a| temperature| of| |17|.|8|°C| (|64|.|0|°F|).| The| wind| is| blowing| from| the| W|NW| at| a| speed| of| |37|.|1| k|ph| (|23|.|0| mph|).| The| humidity| level| is| at| |50|%.| [|Source|](|https|://|www|.weather|api|.com|/)|
```


## 메모리 추가하기

앞서 언급했듯이, 이 에이전트는 무상태입니다. 이는 이전 상호작용을 기억하지 않는다는 것을 의미합니다. 메모리를 주기 위해 체크포인터를 전달해야 합니다. 체크포인터를 전달할 때 에이전트를 호출할 때 `thread_id`도 전달해야 합니다(어떤 스레드/대화를 재개할지 알 수 있도록).

```python
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()
```


```python
agent_executor = create_react_agent(model, tools, checkpointer=memory)

config = {"configurable": {"thread_id": "abc123"}}
```


```python
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="hi im bob!")]}, config
):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content="Hello Bob! It's nice to meet you again.", response_metadata={'id': 'msg_013C1z2ZySagEFwmU1EsysR2', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 1162, 'output_tokens': 14}}, id='run-f878acfd-d195-44e8-9166-e2796317e3f8-0', usage_metadata={'input_tokens': 1162, 'output_tokens': 14, 'total_tokens': 1176})]}}
----
```


```python
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="whats my name?")]}, config
):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='You mentioned your name is Bob when you introduced yourself earlier. So your name is Bob.', response_metadata={'id': 'msg_01WNwnRNGwGDRw6vRdivt6i1', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 1184, 'output_tokens': 21}}, id='run-f5c0b957-8878-405a-9d4b-a7cd38efe81f-0', usage_metadata={'input_tokens': 1184, 'output_tokens': 21, 'total_tokens': 1205})]}}
----
```


예시 [LangSmith 추적](https://smith.langchain.com/public/fa73960b-0f7d-4910-b73d-757a12f33b2b/r)

새로운 대화를 시작하고 싶다면, 사용되는 `thread_id`만 변경하면 됩니다.

```python
config = {"configurable": {"thread_id": "xyz123"}}
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="whats my name?")]}, config
):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content="I'm afraid I don't actually know your name. As an AI assistant without personal information about you, I don't have a specific name associated with our conversation.", response_metadata={'id': 'msg_01NoaXNNYZKSoBncPcLkdcbo', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 267, 'output_tokens': 36}}, id='run-c9f7df3d-525a-4d8f-bbcf-a5b4a5d2e4b0-0', usage_metadata={'input_tokens': 267, 'output_tokens': 36, 'total_tokens': 303})]}}
----
```


## 결론

이제 마무리하겠습니다! 이 빠른 시작에서는 간단한 에이전트를 만드는 방법을 다루었습니다. 그런 다음 중간 단계뿐만 아니라 토큰도 스트리밍하여 응답을 반환하는 방법을 보여주었습니다! 또한 대화할 수 있도록 메모리를 추가했습니다. 에이전트는 복잡한 주제이며, 배울 것이 많습니다!

에이전트에 대한 더 많은 정보는 [LangGraph](/docs/concepts/#langgraph) 문서를 확인하세요. 이 문서에는 자체 개념, 튜토리얼 및 사용 방법 가이드가 있습니다.
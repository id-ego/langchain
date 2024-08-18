---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/nasa.ipynb
description: NASA 툴킷을 사용하여 NASA 이미지 및 비디오 라이브러리 API에 접근하는 방법을 보여주는 노트북입니다.
---

# NASA 툴킷

이 노트북은 에이전트를 사용하여 NASA 툴킷과 상호작용하는 방법을 보여줍니다. 이 툴킷은 NASA 이미지 및 비디오 라이브러리 API에 접근할 수 있으며, 향후 반복에서 다른 접근 가능한 NASA API를 포함할 가능성이 있습니다.

**참고: NASA 이미지 및 비디오 라이브러리 검색 쿼리는 원하는 미디어 결과 수가 지정되지 않을 경우 큰 응답을 초래할 수 있습니다. LLM 토큰 크레딧으로 에이전트를 사용하기 전에 이를 고려하십시오.**

## 사용 예:
* * *
### 에이전트 초기화

```python
%pip install -qU langchain-community
```


```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "NASA Toolkit"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "NASA Toolkit"}, {"imported": "NasaToolkit", "source": "langchain_community.agent_toolkits.nasa.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.nasa.toolkit.NasaToolkit.html", "title": "NASA Toolkit"}, {"imported": "NasaAPIWrapper", "source": "langchain_community.utilities.nasa", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.nasa.NasaAPIWrapper.html", "title": "NASA Toolkit"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "NASA Toolkit"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_community.agent_toolkits.nasa.toolkit import NasaToolkit
from langchain_community.utilities.nasa import NasaAPIWrapper
from langchain_openai import OpenAI

llm = OpenAI(temperature=0, openai_api_key="")
nasa = NasaAPIWrapper()
toolkit = NasaToolkit.from_nasa_api_wrapper(nasa)
agent = initialize_agent(
    toolkit.get_tools(), llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
```


### 미디어 자산 쿼리

```python
agent.run(
    "Can you find three pictures of the moon published between the years 2014 and 2020?"
)
```


### 미디어 자산에 대한 세부정보 쿼리

```python
output = agent.run(
    "I've just queried an image of the moon with the NASA id NHQ_2019_0311_Go Forward to the Moon."
    " Where can I find the metadata manifest for this asset?"
)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
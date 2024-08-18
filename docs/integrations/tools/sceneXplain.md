---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/sceneXplain.ipynb
description: SceneXplain은 이미지 캡셔닝 서비스로, API 토큰을 통해 LangChain 에이전트에서 사용할 수 있습니다.
---

# SceneXplain

[SceneXplain](https://scenex.jina.ai/)는 SceneXplain 도구를 통해 접근할 수 있는 이미지 캡셔닝 서비스입니다.

이 도구를 사용하려면 계정을 만들고 [웹사이트](https://scenex.jina.ai/api)에서 API 토큰을 가져와야 합니다. 그런 다음 도구를 인스턴스화할 수 있습니다.

```python
import os

os.environ["SCENEX_API_KEY"] = "<YOUR_API_KEY>"
```


```python
<!--IMPORTS:[{"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "SceneXplain"}]-->
from langchain.agents import load_tools

tools = load_tools(["sceneXplain"])
```


또는 도구를 직접 인스턴스화할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "SceneXplainTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.scenexplain.tool.SceneXplainTool.html", "title": "SceneXplain"}]-->
from langchain_community.tools import SceneXplainTool

tool = SceneXplainTool()
```


## 에이전트에서의 사용

이 도구는 다음과 같이 모든 LangChain 에이전트에서 사용할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "SceneXplain"}, {"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "SceneXplain"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "SceneXplain"}]-->
from langchain.agents import initialize_agent
from langchain.memory import ConversationBufferMemory
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)
memory = ConversationBufferMemory(memory_key="chat_history")
agent = initialize_agent(
    tools, llm, memory=memory, agent="conversational-react-description", verbose=True
)
output = agent.run(
    input=(
        "What is in this image https://storage.googleapis.com/causal-diffusion.appspot.com/imagePrompts%2F0rw369i5h9t%2Foriginal.png. "
        "Is it movie or a game? If it is a movie, what is the name of the movie?"
    )
)

print(output)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Thought: Do I need to use a tool? Yes
Action: Image Explainer
Action Input: https://storage.googleapis.com/causal-diffusion.appspot.com/imagePrompts%2F0rw369i5h9t%2Foriginal.png[0m
Observation: [36;1m[1;3mIn a charmingly whimsical scene, a young girl is seen braving the rain alongside her furry companion, the lovable Totoro. The two are depicted standing on a bustling street corner, where they are sheltered from the rain by a bright yellow umbrella. The girl, dressed in a cheerful yellow frock, holds onto the umbrella with both hands while gazing up at Totoro with an expression of wonder and delight.

Totoro, meanwhile, stands tall and proud beside his young friend, holding his own umbrella aloft to protect them both from the downpour. His furry body is rendered in rich shades of grey and white, while his large ears and wide eyes lend him an endearing charm.

In the background of the scene, a street sign can be seen jutting out from the pavement amidst a flurry of raindrops. A sign with Chinese characters adorns its surface, adding to the sense of cultural diversity and intrigue. Despite the dreary weather, there is an undeniable sense of joy and camaraderie in this heartwarming image.[0m
Thought:[32;1m[1;3m Do I need to use a tool? No
AI: This image appears to be a still from the 1988 Japanese animated fantasy film My Neighbor Totoro. The film follows two young girls, Satsuki and Mei, as they explore the countryside and befriend the magical forest spirits, including the titular character Totoro.[0m

[1m> Finished chain.[0m
This image appears to be a still from the 1988 Japanese animated fantasy film My Neighbor Totoro. The film follows two young girls, Satsuki and Mei, as they explore the countryside and befriend the magical forest spirits, including the titular character Totoro.
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
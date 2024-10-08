---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/sceneXplain/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/sceneXplain.ipynb
---

# SceneXplain

[SceneXplain](https://scenex.jina.ai/) is an ImageCaptioning service accessible through the SceneXplain Tool.

To use this tool, you'll need to make an account and fetch your API Token [from the website](https://scenex.jina.ai/api). Then you can instantiate the tool.

```python
import os

os.environ["SCENEX_API_KEY"] = "<YOUR_API_KEY>"
```

```python
<!--IMPORTS:[{"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "SceneXplain"}]-->
from langchain.agents import load_tools

tools = load_tools(["sceneXplain"])
```

Or directly instantiate the tool.

```python
<!--IMPORTS:[{"imported": "SceneXplainTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.scenexplain.tool.SceneXplainTool.html", "title": "SceneXplain"}]-->
from langchain_community.tools import SceneXplainTool

tool = SceneXplainTool()
```

## Usage in an Agent

The tool can be used in any LangChain agent as follows:

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

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)
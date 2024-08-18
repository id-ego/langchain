---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/mlx.ipynb
description: 이 문서는 `MLX` LLM을 채팅 모델로 사용하는 방법을 소개하며, `ChatMLX` 클래스를 활용한 예제를 제공합니다.
---

# MLX

이 노트북은 `MLX` LLM을 채팅 모델로 사용하는 방법을 보여줍니다.

특히, 우리는:
1. [MLXPipeline](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/llms/mlx_pipeline.py)을 활용합니다,
2. `ChatMLX` 클래스를 사용하여 이러한 LLM이 LangChain의 [채팅 메시지](https://python.langchain.com/docs/modules/model_io/chat/#messages) 추상화와 인터페이스할 수 있도록 합니다.
3. 오픈 소스 LLM을 사용하여 `ChatAgent` 파이프라인을 작동시키는 방법을 시연합니다.

```python
%pip install --upgrade --quiet  mlx-lm transformers huggingface_hub
```


## 1. LLM 인스턴스화

선택할 수 있는 LLM 옵션이 세 가지 있습니다.

```python
<!--IMPORTS:[{"imported": "MLXPipeline", "source": "langchain_community.llms.mlx_pipeline", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.mlx_pipeline.MLXPipeline.html", "title": "MLX"}]-->
from langchain_community.llms.mlx_pipeline import MLXPipeline

llm = MLXPipeline.from_model_id(
    "mlx-community/quantized-gemma-2b-it",
    pipeline_kwargs={"max_tokens": 10, "temp": 0.1},
)
```


## 2. 채팅 템플릿을 적용하기 위해 `ChatMLX` 인스턴스화

채팅 모델과 전달할 메시지를 인스턴스화합니다.

```python
<!--IMPORTS:[{"imported": "ChatMLX", "source": "langchain_community.chat_models.mlx", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.mlx.ChatMLX.html", "title": "MLX"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "MLX"}]-->
from langchain_community.chat_models.mlx import ChatMLX
from langchain_core.messages import HumanMessage

messages = [
    HumanMessage(
        content="What happens when an unstoppable force meets an immovable object?"
    ),
]

chat_model = ChatMLX(llm=llm)
```


LLM 호출을 위한 채팅 메시지가 어떻게 형식화되는지 확인합니다.

```python
chat_model._to_chat_prompt(messages)
```


모델을 호출합니다.

```python
res = chat_model.invoke(messages)
print(res.content)
```


## 3. 에이전트로 사용해보기!

여기서는 `gemma-2b-it`를 제로샷 `ReAct` 에이전트로 테스트합니다. 아래 예시는 [여기](https://python.langchain.com/docs/modules/agents/agent_types/react#using-chat-models)에서 가져온 것입니다.

> 주의: 이 섹션을 실행하려면 [SerpAPI Token](https://serpapi.com/)을 환경 변수로 저장해야 합니다: `SERPAPI_API_KEY`

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "MLX"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "MLX"}, {"imported": "format_log_to_str", "source": "langchain.agents.format_scratchpad", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.format_scratchpad.log.format_log_to_str.html", "title": "MLX"}, {"imported": "ReActJsonSingleInputOutputParser", "source": "langchain.agents.output_parsers", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.output_parsers.react_json_single_input.ReActJsonSingleInputOutputParser.html", "title": "MLX"}, {"imported": "render_text_description", "source": "langchain.tools.render", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.render.render_text_description.html", "title": "MLX"}, {"imported": "SerpAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.serpapi.SerpAPIWrapper.html", "title": "MLX"}]-->
from langchain import hub
from langchain.agents import AgentExecutor, load_tools
from langchain.agents.format_scratchpad import format_log_to_str
from langchain.agents.output_parsers import (
    ReActJsonSingleInputOutputParser,
)
from langchain.tools.render import render_text_description
from langchain_community.utilities import SerpAPIWrapper
```


에이전트를 `react-json` 스타일 프롬프트와 검색 엔진 및 계산기에 대한 접근으로 구성합니다.

```python
# setup tools
tools = load_tools(["serpapi", "llm-math"], llm=llm)

# setup ReAct style prompt
prompt = hub.pull("hwchase17/react-json")
prompt = prompt.partial(
    tools=render_text_description(tools),
    tool_names=", ".join([t.name for t in tools]),
)

# define the agent
chat_model_with_stop = chat_model.bind(stop=["\nObservation"])
agent = (
    {
        "input": lambda x: x["input"],
        "agent_scratchpad": lambda x: format_log_to_str(x["intermediate_steps"]),
    }
    | prompt
    | chat_model_with_stop
    | ReActJsonSingleInputOutputParser()
)

# instantiate AgentExecutor
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


```python
agent_executor.invoke(
    {
        "input": "Who is Leo DiCaprio's girlfriend? What is her current age raised to the 0.43 power?"
    }
)
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
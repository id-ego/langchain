---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/multion.ipynb
description: MultiOn 툴킷은 LangChain과 MultiOn 클라이언트를 연결하여 AI 에이전트를 활용한 맞춤형 워크플로우를 생성하는
  방법을 안내합니다.
---

# MultiOn Toolkit

[MultiON](https://www.multion.ai/blog/multion-building-a-brighter-future-for-humanity-with-ai-agents)는 다양한 웹 서비스 및 애플리케이션과 상호작용할 수 있는 AI 에이전트를 구축했습니다.

이 노트북은 브라우저에서 `MultiOn` 클라이언트에 LangChain을 연결하는 방법을 안내합니다.

이것은 MultiON 에이전트의 힘을 활용하는 맞춤형 에이전틱 워크플로우를 가능하게 합니다.

이 도구 키트를 사용하려면 브라우저에 `MultiOn Extension`을 추가해야 합니다:

* [MultiON 계정](https://app.multion.ai/login?callbackUrl=%2Fprofile)을 생성합니다.
* [Chrome용 MultiOn 확장 프로그램](https://multion.notion.site/Download-MultiOn-ddddcfe719f94ab182107ca2612c07a5)을 추가합니다.

```python
%pip install --upgrade --quiet  multion langchain -q
```


```python
%pip install -qU langchain-community
```


```python
<!--IMPORTS:[{"imported": "MultionToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.multion.toolkit.MultionToolkit.html", "title": "MultiOn Toolkit"}]-->
from langchain_community.agent_toolkits import MultionToolkit

toolkit = MultionToolkit()
toolkit
```


```output
MultionToolkit()
```


```python
tools = toolkit.get_tools()
tools
```


```output
[MultionCreateSession(), MultionUpdateSession(), MultionCloseSession()]
```


## MultiOn 설정

계정을 생성한 후 https://app.multion.ai/에서 API 키를 생성합니다.

확장 프로그램과의 연결을 위해 로그인합니다.

```python
# Authorize connection to your Browser extention
import multion

multion.login()
```

```output
Logged in.
```


## 에이전트 내에서 Multion Toolkit 사용

이것은 MultiON Chrome 확장 프로그램을 사용하여 원하는 작업을 수행합니다.

아래를 실행하고 [추적](https://smith.langchain.com/public/34aaf36d-204a-4ce3-a54e-4a0976f09670/r)을 확인하여 다음을 확인할 수 있습니다:

* 에이전트는 `create_multion_session` 도구를 사용합니다.
* 그런 다음 MultiON을 사용하여 쿼리를 실행합니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "MultiOn Toolkit"}, {"imported": "create_openai_functions_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_functions_agent.base.create_openai_functions_agent.html", "title": "MultiOn Toolkit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "MultiOn Toolkit"}]-->
from langchain import hub
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
```


```python
# Prompt
instructions = """You are an assistant."""
base_prompt = hub.pull("langchain-ai/openai-functions-template")
prompt = base_prompt.partial(instructions=instructions)
```


```python
# LLM
llm = ChatOpenAI(temperature=0)
```


```python
# Agent
agent = create_openai_functions_agent(llm, toolkit.get_tools(), prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=toolkit.get_tools(),
    verbose=False,
)
```


```python
agent_executor.invoke(
    {
        "input": "Use multion to explain how AlphaCodium works, a recently released code language model."
    }
)
```

```output
WARNING: 'new_session' is deprecated and will be removed in a future version. Use 'create_session' instead.
WARNING: 'update_session' is deprecated and will be removed in a future version. Use 'step_session' instead.
WARNING: 'update_session' is deprecated and will be removed in a future version. Use 'step_session' instead.
WARNING: 'update_session' is deprecated and will be removed in a future version. Use 'step_session' instead.
WARNING: 'update_session' is deprecated and will be removed in a future version. Use 'step_session' instead.
```


```output
{'input': 'Use multion to how AlphaCodium works, a recently released code language model.',
 'output': 'AlphaCodium is a recently released code language model that is designed to assist developers in writing code more efficiently. It is based on advanced machine learning techniques and natural language processing. AlphaCodium can understand and generate code in multiple programming languages, making it a versatile tool for developers.\n\nThe model is trained on a large dataset of code snippets and programming examples, allowing it to learn patterns and best practices in coding. It can provide suggestions and auto-complete code based on the context and the desired outcome.\n\nAlphaCodium also has the ability to analyze code and identify potential errors or bugs. It can offer recommendations for improving code quality and performance.\n\nOverall, AlphaCodium aims to enhance the coding experience by providing intelligent assistance and reducing the time and effort required to write high-quality code.\n\nFor more detailed information, you can visit the official AlphaCodium website or refer to the documentation and resources available online.\n\nI hope this helps! Let me know if you have any other questions.'}
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
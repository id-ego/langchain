---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/bash.ipynb
description: 이 문서는 에이전트가 셸을 사용하여 로컬 파일 시스템과 상호작용하고 웹 페이지에서 링크를 가져오는 방법을 설명합니다.
---

# 셸 (bash)

에이전트에게 셸에 대한 접근을 허용하는 것은 강력하지만 (샌드박스 환경 외부에서는 위험할 수 있습니다).

LLM은 이를 사용하여 모든 셸 명령을 실행할 수 있습니다. 일반적인 사용 사례는 LLM이 로컬 파일 시스템과 상호작용하도록 하는 것입니다.

**참고:** 셸 도구는 Windows OS에서 작동하지 않습니다.

```python
%pip install --upgrade --quiet langchain-community
```


```python
<!--IMPORTS:[{"imported": "ShellTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.shell.tool.ShellTool.html", "title": "Shell (bash)"}]-->
from langchain_community.tools import ShellTool

shell_tool = ShellTool()
```


```python
print(shell_tool.run({"commands": ["echo 'Hello World!'", "time"]}))
```

```output
Hello World!

real	0m0.000s
user	0m0.000s
sys	0m0.000s
``````output
/Users/wfh/code/lc/lckg/langchain/tools/shell/tool.py:34: UserWarning: The shell tool has no safeguards by default. Use at your own risk.
  warnings.warn(
```

### 에이전트와 함께 사용하기

모든 도구와 마찬가지로, 이러한 도구는 에이전트에게 주어져 더 복잡한 작업을 수행할 수 있습니다. 에이전트가 웹 페이지에서 링크를 가져오도록 해보겠습니다.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Shell (bash)"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Shell (bash)"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Shell (bash)"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0)

shell_tool.description = shell_tool.description + f"args {shell_tool.args}".replace(
    "{", "{{"
).replace("}", "}}")
self_ask_with_search = initialize_agent(
    [shell_tool], llm, agent=AgentType.CHAT_ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
self_ask_with_search.run(
    "Download the langchain.com webpage and grep for all urls. Return only a sorted list of them. Be sure to use double quotes."
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mQuestion: What is the task?
Thought: We need to download the langchain.com webpage and extract all the URLs from it. Then we need to sort the URLs and return them.
Action:
```

{
"action": "shell",
"action_input": {
"commands": [
"curl -s https://langchain.com | grep -o 'http[s]*://[^\" ]*' | sort"
]
}
}
```
[0m
``````output
/Users/wfh/code/lc/lckg/langchain/tools/shell/tool.py:34: UserWarning: The shell tool has no safeguards by default. Use at your own risk.
  warnings.warn(
``````output

Observation: [36;1m[1;3mhttps://blog.langchain.dev/
https://discord.gg/6adMQxSpJS
https://docs.langchain.com/docs/
https://github.com/hwchase17/chat-langchain
https://github.com/hwchase17/langchain
https://github.com/hwchase17/langchainjs
https://github.com/sullivan-sean/chat-langchainjs
https://js.langchain.com/docs/
https://python.langchain.com/en/latest/
https://twitter.com/langchainai
[0m
Thought:[32;1m[1;3mThe URLs have been successfully extracted and sorted. We can return the list of URLs as the final answer.
Final Answer: ["https://blog.langchain.dev/", "https://discord.gg/6adMQxSpJS", "https://docs.langchain.com/docs/", "https://github.com/hwchase17/chat-langchain", "https://github.com/hwchase17/langchain", "https://github.com/hwchase17/langchainjs", "https://github.com/sullivan-sean/chat-langchainjs", "https://js.langchain.com/docs/", "https://python.langchain.com/en/latest/", "https://twitter.com/langchainai"][0m

[1m> Finished chain.[0m
```


```output
'["https://blog.langchain.dev/", "https://discord.gg/6adMQxSpJS", "https://docs.langchain.com/docs/", "https://github.com/hwchase17/chat-langchain", "https://github.com/hwchase17/langchain", "https://github.com/hwchase17/langchainjs", "https://github.com/sullivan-sean/chat-langchainjs", "https://js.langchain.com/docs/", "https://python.langchain.com/en/latest/", "https://twitter.com/langchainai"]'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
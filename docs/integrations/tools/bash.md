---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/bash/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/bash.ipynb
---

# Shell (bash)

Giving agents access to the shell is powerful (though risky outside a sandboxed environment).

The LLM can use it to execute any shell commands. A common use case for this is letting the LLM interact with your local file system.

**Note:** Shell tool does not work with Windows OS.


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
### Use with Agents

As with all tools, these can be given to an agent to accomplish more complex tasks. Let's have the agent fetch some links from a web page.


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



## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)
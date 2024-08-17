---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/slack/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/slack.ipynb
---

# Slack Toolkit

This will help you getting started with the Slack [toolkit](/docs/concepts/#toolkits). For detailed documentation of all SlackToolkit features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.slack.toolkit.SlackToolkit.html).

## Setup

To use this toolkit, you will need to get a token as explained in the [Slack API docs](https://api.slack.com/tutorials/tracks/getting-a-token). Once you've received a SLACK_USER_TOKEN, you can input it as an environment variable below.

```python
import getpass
import os

if not os.getenv("SLACK_USER_TOKEN"):
    os.environ["SLACK_USER_TOKEN"] = getpass.getpass("Enter your Slack user token: ")
```

If you want to get automated tracing from runs of individual tools, you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

This toolkit lives in the `langchain-community` package. We will also need the Slack SDK:

```python
%pip install -qU langchain-community slack_sdk
```

Optionally, we can install beautifulsoup4 to assist in parsing HTML messages:

```python
%pip install -qU beautifulsoup4 # This is optional but is useful for parsing HTML messages
```

## Instantiation

Now we can instantiate our toolkit:

```python
<!--IMPORTS:[{"imported": "SlackToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.slack.toolkit.SlackToolkit.html", "title": "Slack Toolkit"}]-->
from langchain_community.agent_toolkits import SlackToolkit

toolkit = SlackToolkit()
```

## Tools

View available tools:

```python
tools = toolkit.get_tools()

tools
```

```output
[SlackGetChannel(client=<slack_sdk.web.client.WebClient object at 0x113caa8c0>),
 SlackGetMessage(client=<slack_sdk.web.client.WebClient object at 0x113caa4d0>),
 SlackScheduleMessage(client=<slack_sdk.web.client.WebClient object at 0x113caa440>),
 SlackSendMessage(client=<slack_sdk.web.client.WebClient object at 0x113caa410>)]
```

This toolkit loads:

- [SlackGetChannel](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.get_channel.SlackGetChannel.html)
- [SlackGetMessage](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.get_message.SlackGetMessage.html)
- [SlackScheduleMessage](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.schedule_message.SlackScheduleMessage.html)
- [SlackSendMessage](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.send_message.SlackSendMessage.html)

## Use within an agent

Let's equip an agent with the Slack toolkit and query for information about a channel.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Slack Toolkit"}]-->
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent

llm = ChatOpenAI(model="gpt-3.5-turbo-0125")

agent_executor = create_react_agent(llm, tools)
```

```python
example_query = "When was the #general channel created?"

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    message = event["messages"][-1]
    if message.type != "tool":  # mask sensitive information
        event["messages"][-1].pretty_print()
```
```output
================================[1m Human Message [0m=================================

When was the #general channel created?
==================================[1m Ai Message [0m==================================
Tool Calls:
  get_channelid_name_dict (call_NXDkALjoOx97uF1v0CoZTqtJ)
 Call ID: call_NXDkALjoOx97uF1v0CoZTqtJ
  Args:
==================================[1m Ai Message [0m==================================

The #general channel was created on timestamp 1671043305.
```

```python
example_query = "Send a friendly greeting to channel C072Q1LP4QM."

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    message = event["messages"][-1]
    if message.type != "tool":  # mask sensitive information
        event["messages"][-1].pretty_print()
```
```output
================================[1m Human Message [0m=================================

Send a friendly greeting to channel C072Q1LP4QM.
==================================[1m Ai Message [0m==================================
Tool Calls:
  send_message (call_xQxpv4wFeAZNZgSBJRIuaizi)
 Call ID: call_xQxpv4wFeAZNZgSBJRIuaizi
  Args:
    message: Hello! Have a great day!
    channel: C072Q1LP4QM
==================================[1m Ai Message [0m==================================

I have sent a friendly greeting to the channel C072Q1LP4QM.
```
## API reference

For detailed documentation of all `SlackToolkit` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.slack.toolkit.SlackToolkit.html).

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)
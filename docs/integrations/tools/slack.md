---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/slack.ipynb
description: 슬랙 툴킷을 시작하는 방법과 API 참조 링크, 설치 방법 및 환경 변수 설정에 대한 정보를 제공합니다.
---

# 슬랙 툴킷

이 문서는 슬랙 [툴킷](/docs/concepts/#toolkits) 사용을 시작하는 데 도움을 줄 것입니다. 슬랙 툴킷의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.slack.toolkit.SlackToolkit.html)에서 확인할 수 있습니다.

## 설정

이 툴킷을 사용하려면 [슬랙 API 문서](https://api.slack.com/tutorials/tracks/getting-a-token)에서 설명한 대로 토큰을 받아야 합니다. SLACK_USER_TOKEN을 받으면 아래에 환경 변수로 입력할 수 있습니다.

```python
import getpass
import os

if not os.getenv("SLACK_USER_TOKEN"):
    os.environ["SLACK_USER_TOKEN"] = getpass.getpass("Enter your Slack user token: ")
```


개별 도구 실행에서 자동 추적을 받으려면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 툴킷은 `langchain-community` 패키지에 포함되어 있습니다. 슬랙 SDK도 필요합니다:

```python
%pip install -qU langchain-community slack_sdk
```


선택적으로 HTML 메시지를 파싱하는 데 도움을 주기 위해 beautifulsoup4를 설치할 수 있습니다:

```python
%pip install -qU beautifulsoup4 # This is optional but is useful for parsing HTML messages
```


## 인스턴스화

이제 툴킷을 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SlackToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.slack.toolkit.SlackToolkit.html", "title": "Slack Toolkit"}]-->
from langchain_community.agent_toolkits import SlackToolkit

toolkit = SlackToolkit()
```


## 도구

사용 가능한 도구 보기:

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


이 툴킷은 다음을 로드합니다:

- [SlackGetChannel](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.get_channel.SlackGetChannel.html)
- [SlackGetMessage](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.get_message.SlackGetMessage.html)
- [SlackScheduleMessage](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.schedule_message.SlackScheduleMessage.html)
- [SlackSendMessage](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.slack.send_message.SlackSendMessage.html)

## 에이전트 내에서 사용

슬랙 툴킷으로 에이전트를 장비하고 채널에 대한 정보를 쿼리해 보겠습니다.

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

## API 참조

모든 `SlackToolkit` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.slack.toolkit.SlackToolkit.html)에서 확인할 수 있습니다.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
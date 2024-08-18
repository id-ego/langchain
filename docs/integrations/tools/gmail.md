---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/gmail.ipynb
description: Gmail Toolkit은 GMail API와 상호작용하여 메시지를 읽고, 작성하고, 전송하는 데 도움을 줍니다.
---

# Gmail Toolkit

이 문서는 GMail [toolkit](/docs/concepts/#toolkits)를 시작하는 데 도움을 줄 것입니다. 이 툴킷은 GMail API와 상호작용하여 메시지를 읽고, 초안을 작성하고, 메시지를 전송하는 등의 작업을 수행합니다. GmailToolkit의 모든 기능 및 구성에 대한 자세한 문서는 [API reference](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.toolkit.GmailToolkit.html)에서 확인할 수 있습니다.

## Setup

이 툴킷을 사용하려면 [Gmail API docs](https://developers.google.com/gmail/api/quickstart/python#authorize_credentials_for_a_desktop_application)에서 설명한 대로 자격 증명을 설정해야 합니다. `credentials.json` 파일을 다운로드한 후, Gmail API를 사용하기 시작할 수 있습니다.

### Installation

이 툴킷은 `langchain-google-community` 패키지에 포함되어 있습니다. `gmail` 추가 기능이 필요합니다:

```python
%pip install -qU langchain-google-community\[gmail\]
```


개별 도구의 실행에서 자동 추적을 받으려면 아래 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


## Instantiation

기본적으로 툴킷은 로컬 `credentials.json` 파일을 읽습니다. 또한 수동으로 `Credentials` 객체를 제공할 수도 있습니다.

```python
from langchain_google_community import GmailToolkit

toolkit = GmailToolkit()
```


### Customizing Authentication

백그라운드에서는 다음 방법을 사용하여 `googleapi` 리소스가 생성됩니다. 더 많은 인증 제어를 위해 수동으로 `googleapi` 리소스를 구축할 수 있습니다.

```python
from langchain_google_community.gmail.utils import (
    build_resource_service,
    get_gmail_credentials,
)

# Can review scopes here https://developers.google.com/gmail/api/auth/scopes
# For instance, readonly scope is 'https://www.googleapis.com/auth/gmail.readonly'
credentials = get_gmail_credentials(
    token_file="token.json",
    scopes=["https://mail.google.com/"],
    client_secrets_file="credentials.json",
)
api_resource = build_resource_service(credentials=credentials)
toolkit = GmailToolkit(api_resource=api_resource)
```


## Tools

사용 가능한 도구 보기:

```python
tools = toolkit.get_tools()
tools
```


```output
[GmailCreateDraft(api_resource=<googleapiclient.discovery.Resource object at 0x1094509d0>),
 GmailSendMessage(api_resource=<googleapiclient.discovery.Resource object at 0x1094509d0>),
 GmailSearch(api_resource=<googleapiclient.discovery.Resource object at 0x1094509d0>),
 GmailGetMessage(api_resource=<googleapiclient.discovery.Resource object at 0x1094509d0>),
 GmailGetThread(api_resource=<googleapiclient.discovery.Resource object at 0x1094509d0>)]
```


- [GmailCreateDraft](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.create_draft.GmailCreateDraft.html)
- [GmailSendMessage](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.send_message.GmailSendMessage.html)
- [GmailSearch](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.search.GmailSearch.html)
- [GmailGetMessage](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.get_message.GmailGetMessage.html)
- [GmailGetThread](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.get_thread.GmailGetThread.html)

## Use within an agent

아래에서는 툴킷을 [agent](/docs/tutorials/agents)에 통합하는 방법을 보여줍니다.

LLM 또는 채팅 모델이 필요합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(llm, tools)
```


```python
example_query = "Draft an email to fake@fake.com thanking them for coffee."

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

```output
================================[1m Human Message [0m=================================

Draft an email to fake@fake.com thanking them for coffee.
==================================[1m Ai Message [0m==================================
Tool Calls:
  create_gmail_draft (call_slGkYKZKA6h3Mf1CraUBzs6M)
 Call ID: call_slGkYKZKA6h3Mf1CraUBzs6M
  Args:
    message: Dear Fake,

I wanted to take a moment to thank you for the coffee yesterday. It was a pleasure catching up with you. Let's do it again soon!

Best regards,
[Your Name]
    to: ['fake@fake.com']
    subject: Thank You for the Coffee
=================================[1m Tool Message [0m=================================
Name: create_gmail_draft

Draft created. Draft Id: r-7233782721440261513
==================================[1m Ai Message [0m==================================

I have drafted an email to fake@fake.com thanking them for the coffee. You can review and send it from your email draft with the subject "Thank You for the Coffee".
```

## API reference

`GmailToolkit`의 모든 기능 및 구성에 대한 자세한 문서는 [API reference](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.gmail.toolkit.GmailToolkit.html)에서 확인할 수 있습니다.

## Related

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
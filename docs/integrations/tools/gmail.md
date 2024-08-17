---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/gmail/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/gmail.ipynb
---

# Gmail Toolkit

This will help you getting started with the GMail [toolkit](/docs/concepts/#toolkits). This toolkit interacts with the GMail API to read messages, draft and send messages, and more. For detailed documentation of all GmailToolkit features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/gmail/langchain_google_community.gmail.toolkit.GmailToolkit.html).

## Setup

To use this toolkit, you will need to set up your credentials explained in the [Gmail API docs](https://developers.google.com/gmail/api/quickstart/python#authorize_credentials_for_a_desktop_application). Once you've downloaded the `credentials.json` file, you can start using the Gmail API.

### Installation

This toolkit lives in the `langchain-google-community` package. We'll need the `gmail` extra:

```python
%pip install -qU langchain-google-community\[gmail\]
```

If you want to get automated tracing from runs of individual tools, you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```

## Instantiation

By default the toolkit reads the local `credentials.json` file. You can also manually provide a `Credentials` object.

```python
from langchain_google_community import GmailToolkit

toolkit = GmailToolkit()
```

### Customizing Authentication

Behind the scenes, a `googleapi` resource is created using the following methods.
you can manually build a `googleapi` resource for more auth control. 

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

View available tools:

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

Below we show how to incorporate the toolkit into an [agent](/docs/tutorials/agents).

We will need a LLM or chat model:

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

For detailed documentation of all `GmailToolkit` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.gmail.toolkit.GmailToolkit.html).

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)
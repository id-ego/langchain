---
canonical: https://python.langchain.com/v0.2/docs/integrations/callbacks/trubrics/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/trubrics.ipynb
---

# Trubrics


>[Trubrics](https://trubrics.com) is an LLM user analytics platform that lets you collect, analyse and manage user
prompts & feedback on AI models.
>
>Check out [Trubrics repo](https://github.com/trubrics/trubrics-sdk) for more information on `Trubrics`.

In this guide, we will go over how to set up the `TrubricsCallbackHandler`. 


## Installation and Setup


```python
%pip install --upgrade --quiet  trubrics langchain langchain-community
```

### Getting Trubrics Credentials

If you do not have a Trubrics account, create one on [here](https://trubrics.streamlit.app/). In this tutorial, we will use the `default` project that is built upon account creation.

Now set your credentials as environment variables:


```python
import os

os.environ["TRUBRICS_EMAIL"] = "***@***"
os.environ["TRUBRICS_PASSWORD"] = "***"
```


```python
<!--IMPORTS:[{"imported": "TrubricsCallbackHandler", "source": "langchain_community.callbacks.trubrics_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.trubrics_callback.TrubricsCallbackHandler.html", "title": "Trubrics"}]-->
from langchain_community.callbacks.trubrics_callback import TrubricsCallbackHandler
```

### Usage

The `TrubricsCallbackHandler` can receive various optional arguments. See [here](https://trubrics.github.io/trubrics-sdk/platform/user_prompts/#saving-prompts-to-trubrics) for kwargs that can be passed to Trubrics prompts.

```python
class TrubricsCallbackHandler(BaseCallbackHandler):

    """
    Callback handler for Trubrics.
    
    Args:
        project: a trubrics project, default project is "default"
        email: a trubrics account email, can equally be set in env variables
        password: a trubrics account password, can equally be set in env variables
        **kwargs: all other kwargs are parsed and set to trubrics prompt variables, or added to the `metadata` dict
    """
```

## Examples

Here are two examples of how to use the `TrubricsCallbackHandler` with Langchain [LLMs](/docs/how_to#llms) or [Chat Models](/docs/how_to#chat-models). We will use OpenAI models, so set your `OPENAI_API_KEY` key here:


```python
os.environ["OPENAI_API_KEY"] = "sk-***"
```

### 1. With an LLM


```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Trubrics"}]-->
from langchain_openai import OpenAI
```


```python
llm = OpenAI(callbacks=[TrubricsCallbackHandler()])
```
```output
[32m2023-09-26 11:30:02.149[0m | [1mINFO    [0m | [36mtrubrics.platform.auth[0m:[36mget_trubrics_auth_token[0m:[36m61[0m - [1mUser jeff.kayne@trubrics.com has been authenticated.[0m
```

```python
res = llm.generate(["Tell me a joke", "Write me a poem"])
```
```output
[32m2023-09-26 11:30:07.760[0m | [1mINFO    [0m | [36mtrubrics.platform[0m:[36mlog_prompt[0m:[36m102[0m - [1mUser prompt saved to Trubrics.[0m
[32m2023-09-26 11:30:08.042[0m | [1mINFO    [0m | [36mtrubrics.platform[0m:[36mlog_prompt[0m:[36m102[0m - [1mUser prompt saved to Trubrics.[0m
```

```python
print("--> GPT's joke: ", res.generations[0][0].text)
print()
print("--> GPT's poem: ", res.generations[1][0].text)
```
```output
--> GPT's joke:  

Q: What did the fish say when it hit the wall?
A: Dam!

--> GPT's poem:  

A Poem of Reflection

I stand here in the night,
The stars above me filling my sight.
I feel such a deep connection,
To the world and all its perfection.

A moment of clarity,
The calmness in the air so serene.
My mind is filled with peace,
And I am released.

The past and the present,
My thoughts create a pleasant sentiment.
My heart is full of joy,
My soul soars like a toy.

I reflect on my life,
And the choices I have made.
My struggles and my strife,
The lessons I have paid.

The future is a mystery,
But I am ready to take the leap.
I am ready to take the lead,
And to create my own destiny.
```
### 2. With a chat model


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Trubrics"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Trubrics"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Trubrics"}]-->
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI
```


```python
chat_llm = ChatOpenAI(
    callbacks=[
        TrubricsCallbackHandler(
            project="default",
            tags=["chat model"],
            user_id="user-id-1234",
            some_metadata={"hello": [1, 2]},
        )
    ]
)
```


```python
chat_res = chat_llm.invoke(
    [
        SystemMessage(content="Every answer of yours must be about OpenAI."),
        HumanMessage(content="Tell me a joke"),
    ]
)
```
```output
[32m2023-09-26 11:30:10.550[0m | [1mINFO    [0m | [36mtrubrics.platform[0m:[36mlog_prompt[0m:[36m102[0m - [1mUser prompt saved to Trubrics.[0m
```

```python
print(chat_res.content)
```
```output
Why did the OpenAI computer go to the party?

Because it wanted to meet its AI friends and have a byte of fun!
```
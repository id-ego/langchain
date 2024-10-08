---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/databricks/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/databricks.ipynb
sidebar_label: Databricks
---

# ChatDatabricks

> [Databricks](https://www.databricks.com/) Lakehouse Platform unifies data, analytics, and AI on one platform. 

This notebook provides a quick overview for getting started with Databricks [chat models](/docs/concepts/#chat-models). For detailed documentation of all ChatDatabricks features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html).

## Overview

`ChatDatabricks` class wraps a chat model endpoint hosted on [Databricks Model Serving](https://docs.databricks.com/en/machine-learning/model-serving/index.html). This example notebook shows how to wrap your serving endpoint and use it as a chat model in your LangChain application.

### Integration details

| Class | Package | Local | Serializable | Package downloads | Package latest |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [ChatDatabricks](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html) | [langchain-community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | beta | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-community?style=flat-square&label=%20) |

### Model features
| [Tool calling](/docs/how_to/tool_calling/) | [Structured output](/docs/how_to/structured_output/) | JSON mode | [Image input](/docs/how_to/multimodal_inputs/) | Audio input | Video input | [Token-level streaming](/docs/how_to/chat_streaming/) | Native async | [Token usage](/docs/how_to/chat_token_usage_tracking/) | [Logprobs](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |  ✅ | ✅ | ✅ | ❌ | 

### Supported Methods

`ChatDatabricks` supports all methods of `ChatModel` including async APIs.

### Endpoint Requirement

The serving endpoint `ChatDatabricks` wraps must have OpenAI-compatible chat input/output format ([reference](https://mlflow.org/docs/latest/llms/deployments/index.html#chat)). As long as the input format is compatible, `ChatDatabricks` can be used for any endpoint type hosted on [Databricks Model Serving](https://docs.databricks.com/en/machine-learning/model-serving/index.html):

1. Foundation Models - Curated list of state-of-the-art foundation models such as DRBX, Llama3, Mixtral-8x7B, and etc. These endpoint are ready to use in your Databricks workspace without any set up.
2. Custom Models - You can also deploy custom models to a serving endpoint via MLflow with
your choice of framework such as LangChain, Pytorch, Transformers, etc.
3. External Models - Databricks endpoints can serve models that are hosted outside Databricks as a proxy, such as proprietary model service like OpenAI GPT4.

## Setup

To access Databricks models you'll need to create a Databricks account, set up credentials (only if you are outside Databricks workspace), and install required packages.

### Credentials (only if you are outside Databricks)

If you are running LangChain app inside Databricks, you can skip this step.

Otherwise, you need manually set the Databricks workspace hostname and personal access token to `DATABRICKS_HOST` and `DATABRICKS_TOKEN` environment variables, respectively. See [Authentication Documentation](https://docs.databricks.com/en/dev-tools/auth/index.html#databricks-personal-access-tokens) for how to get an access token.

```python
import getpass
import os

os.environ["DATABRICKS_HOST"] = "https://your-workspace.cloud.databricks.com"
os.environ["DATABRICKS_TOKEN"] = getpass.getpass("Enter your Databricks access token: ")
```
```output
Enter your Databricks access token:  ········
```
### Installation

The LangChain Databricks integration lives in the `langchain-community` package. Also, `mlflow >= 2.9 ` is required to run the code in this notebook.

```python
%pip install -qU langchain-community mlflow>=2.9.0
```

We first demonstrates how to query DBRX-instruct model hosted as Foundation Models endpoint with `ChatDatabricks`.

For other type of endpoints, there are some difference in how to set up the endpoint itself, however, once the endpoint is ready, there is no difference in how to query it with `ChatDatabricks`. Please refer to the bottom of this notebook for the examples with other type of endpoints.

## Instantiation

```python
<!--IMPORTS:[{"imported": "ChatDatabricks", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html", "title": "ChatDatabricks"}]-->
from langchain_community.chat_models import ChatDatabricks

chat_model = ChatDatabricks(
    endpoint="databricks-dbrx-instruct",
    temperature=0.1,
    max_tokens=256,
    # See https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html for other supported parameters
)
```

## Invocation

```python
chat_model.invoke("What is MLflow?")
```

```output
AIMessage(content='MLflow is an open-source platform for managing end-to-end machine learning workflows. It was introduced by Databricks in 2018. MLflow provides tools for tracking experiments, packaging and sharing code, and deploying models. It is designed to work with any machine learning library and can be used in a variety of environments, including local machines, virtual machines, and cloud-based clusters. MLflow aims to streamline the machine learning development lifecycle, making it easier for data scientists and engineers to collaborate and deploy models into production.', response_metadata={'prompt_tokens': 229, 'completion_tokens': 104, 'total_tokens': 333}, id='run-d3fb4d06-3e10-4471-83c9-c282cc62b74d-0')
```

```python
# You can also pass a list of messages
messages = [
    ("system", "You are a chatbot that can answer questions about Databricks."),
    ("user", "What is Databricks Model Serving?"),
]
chat_model.invoke(messages)
```

```output
AIMessage(content='Databricks Model Serving is a feature of the Databricks platform that allows data scientists and engineers to easily deploy machine learning models into production. With Model Serving, you can host, manage, and serve machine learning models as APIs, making it easy to integrate them into applications and business processes. It supports a variety of popular machine learning frameworks, including TensorFlow, PyTorch, and scikit-learn, and provides tools for monitoring and managing the performance of deployed models. Model Serving is designed to be scalable, secure, and easy to use, making it a great choice for organizations that want to quickly and efficiently deploy machine learning models into production.', response_metadata={'prompt_tokens': 35, 'completion_tokens': 130, 'total_tokens': 165}, id='run-b3feea21-223e-4105-8627-41d647d5ccab-0')
```

## Chaining
Similar to other chat models, `ChatDatabricks` can be used as a part of a complex chain.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatDatabricks"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a chatbot that can answer questions about {topic}.",
        ),
        ("user", "{question}"),
    ]
)

chain = prompt | chat_model
chain.invoke(
    {
        "topic": "Databricks",
        "question": "What is Unity Catalog?",
    }
)
```

```output
AIMessage(content="Unity Catalog is a new data catalog feature in Databricks that allows you to discover, manage, and govern all your data assets across your data landscape, including data lakes, data warehouses, and data marts. It provides a centralized repository for storing and managing metadata, data lineage, and access controls for all your data assets. Unity Catalog enables data teams to easily discover and access the data they need, while ensuring compliance with data privacy and security regulations. It is designed to work seamlessly with Databricks' Lakehouse platform, providing a unified experience for managing and analyzing all your data.", response_metadata={'prompt_tokens': 32, 'completion_tokens': 118, 'total_tokens': 150}, id='run-82d72624-f8df-4c0d-a976-919feec09a55-0')
```

## Invocation (streaming)

`ChatDatabricks` supports streaming response by `stream` method since `langchain-community>=0.2.1`.

```python
for chunk in chat_model.stream("How are you?"):
    print(chunk.content, end="|")
```
```output
I|'m| an| AI| and| don|'t| have| feelings|,| but| I|'m| here| and| ready| to| assist| you|.| How| can| I| help| you| today|?||
```
## Async Invocation

```python
import asyncio

country = ["Japan", "Italy", "Australia"]
futures = [chat_model.ainvoke(f"Where is the capital of {c}?") for c in country]
await asyncio.gather(*futures)
```

## Wrapping Custom Model Endpoint

Prerequisites:

* An LLM was registered and deployed to [a Databricks serving endpoint](https://docs.databricks.com/machine-learning/model-serving/index.html) via MLflow. The endpoint must have OpenAI-compatible chat input/output format ([reference](https://mlflow.org/docs/latest/llms/deployments/index.html#chat))
* You have ["Can Query" permission](https://docs.databricks.com/security/auth-authz/access-control/serving-endpoint-acl.html) to the endpoint.

Once the endpoint is ready, the usage pattern is completely same as Foundation Models.

```python
chat_model_custom = ChatDatabricks(
    endpoint="YOUR_ENDPOINT_NAME",
    temperature=0.1,
    max_tokens=256,
)

chat_model_custom.invoke("How are you?")
```

## Wrapping External Models

Prerequisite: Create Proxy Endpoint

First, create a new Databricks serving endpoint that proxies requests to the target external model. The endpoint creation should be fairy quick for proxying external models.

This requires registering OpenAI API Key in Databricks secret manager with the following comment:
```sh
# Replace `<scope>` with your scope
databricks secrets create-scope <scope>
databricks secrets put-secret <scope> openai-api-key --string-value $OPENAI_API_KEY
```

For how to set up Databricks CLI and manage secrets, please refer to https://docs.databricks.com/en/security/secrets/secrets.html

```python
from mlflow.deployments import get_deploy_client

client = get_deploy_client("databricks")

secret = "secrets/<scope>/openai-api-key"  # replace `<scope>` with your scope
endpoint_name = "my-chat"  # rename this if my-chat already exists
client.create_endpoint(
    name=endpoint_name,
    config={
        "served_entities": [
            {
                "name": "my-chat",
                "external_model": {
                    "name": "gpt-3.5-turbo",
                    "provider": "openai",
                    "task": "llm/v1/chat",
                    "openai_config": {
                        "openai_api_key": "{{" + secret + "}}",
                    },
                },
            }
        ],
    },
)
```

Once the endpoint status has become "Ready", you can query the endpoint in the same way as other types of endpoints.

```python
chat_model_external = ChatDatabricks(
    endpoint=endpoint_name,
    temperature=0.1,
    max_tokens=256,
)
chat_model_external.invoke("How to use Databricks?")
```

## Function calling on Databricks

Databricks Function Calling is OpenAI-compatible and is only available during model serving as part of Foundation Model APIs.

See [Databricks function calling introduction](https://docs.databricks.com/en/machine-learning/model-serving/function-calling.html#supported-models) for supported models.

```python
<!--IMPORTS:[{"imported": "ChatDatabricks", "source": "langchain_community.chat_models.databricks", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html", "title": "ChatDatabricks"}]-->
from langchain_community.chat_models.databricks import ChatDatabricks

llm = ChatDatabricks(endpoint="databricks-meta-llama-3-70b-instruct")
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
            },
        },
    }
]

# supported tool_choice values: "auto", "required", "none", function name in string format,
# or a dictionary as {"type": "function", "function": {"name": <<tool_name>>}}
model = llm.bind_tools(tools, tool_choice="auto")

messages = [{"role": "user", "content": "What is the current temperature of Chicago?"}]
print(model.invoke(messages))
```

See [Databricks Unity Catalog](docs/integrations/tools/databricks.md) about how to use UC functions in chains.

## API reference

For detailed documentation of all ChatDatabricks features and configurations head to the API reference: https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.ChatDatabricks.html

## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)
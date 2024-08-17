---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/oci_generative_ai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/oci_generative_ai.ipynb
---

## Oracle Cloud Infrastructure Generative AI

Oracle Cloud Infrastructure (OCI) Generative AI is a fully managed service that provides a set of state-of-the-art, customizable large language models (LLMs) that cover a wide range of use cases, and which is available through a single API.
Using the OCI Generative AI service you can access ready-to-use pretrained models, or create and host your own fine-tuned custom models based on your own data on dedicated AI clusters. Detailed documentation of the service and API is available **[here](https://docs.oracle.com/en-us/iaas/Content/generative-ai/home.htm)** and **[here](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai/20231130/)**.

This notebook explains how to use OCI's Generative AI complete models with LangChain.

## Setup
Ensure that the oci sdk and the langchain-community package are installed

```python
!pip install -U oci langchain-community
```

## Usage

```python
<!--IMPORTS:[{"imported": "OCIGenAI", "source": "langchain_community.llms.oci_generative_ai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.oci_generative_ai.OCIGenAI.html", "title": "# Oracle Cloud Infrastructure Generative AI"}]-->
from langchain_community.llms.oci_generative_ai import OCIGenAI

llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0, "max_tokens": 500},
)

response = llm.invoke("Tell me one fact about earth", temperature=0.7)
print(response)
```

#### Chaining with prompt templates

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Oracle Cloud Infrastructure Generative AI"}]-->
from langchain_core.prompts import PromptTemplate

llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0, "max_tokens": 500},
)

prompt = PromptTemplate(input_variables=["query"], template="{query}")
llm_chain = prompt | llm

response = llm_chain.invoke("what is the capital of france?")
print(response)
```

#### Streaming

```python
llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0, "max_tokens": 500},
)

for chunk in llm.stream("Write me a song about sparkling water."):
    print(chunk, end="", flush=True)
```

## Authentication
The authentication methods supported for LlamaIndex are equivalent to those used with other OCI services and follow the **[standard SDK authentication](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdk_authentication_methods.htm)** methods, specifically API Key, session token, instance principal, and resource principal.

API key is the default authentication method used in the examples above. The following example demonstrates how to use a different authentication method (session token)

```python
llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    auth_type="SECURITY_TOKEN",
    auth_profile="MY_PROFILE",  # replace with your profile name
)
```

## Dedicated AI Cluster
To access models hosted in a dedicated AI cluster **[create an endpoint](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai-inference/20231130/)** whose assigned OCID (currently prefixed by ‘ocid1.generativeaiendpoint.oc1.us-chicago-1’) is used as your model ID.

When accessing models hosted in a dedicated AI cluster you will need to initialize the OCIGenAI interface with two extra required params ("provider" and "context_size").

```python
llm = OCIGenAI(
    model_id="ocid1.generativeaiendpoint.oc1.us-chicago-1....",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="DEDICATED_COMPARTMENT_OCID",
    auth_profile="MY_PROFILE",  # replace with your profile name,
    provider="MODEL_PROVIDER",  # e.g., "cohere" or "meta"
    context_size="MODEL_CONTEXT_SIZE",  # e.g., 128000
)
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
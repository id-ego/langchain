---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/octoai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/octoai.ipynb
---

# OctoAI

[OctoAI](https://docs.octoai.cloud/docs) offers easy access to efficient compute and enables users to integrate their choice of AI models into applications. The `OctoAI` compute service helps you run, tune, and scale AI applications easily.

This example goes over how to use LangChain to interact with `OctoAI` [LLM endpoints](https://octoai.cloud/templates)

## Setup

To run our example app, there are two simple steps to take:

1. Get an API Token from [your OctoAI account page](https://octoai.cloud/settings).
2. Paste your API key in in the code cell below.

Note: If you want to use a different LLM model, you can containerize the model and make a custom OctoAI endpoint yourself, by following [Build a Container from Python](https://octo.ai/docs/bring-your-own-model/advanced-build-a-container-from-scratch-in-python) and [Create a Custom Endpoint from a Container](https://octo.ai/docs/bring-your-own-model/create-custom-endpoints-from-a-container/create-custom-endpoints-from-a-container) and then updating your `OCTOAI_API_BASE` environment variable.

```python
import os

os.environ["OCTOAI_API_TOKEN"] = "OCTOAI_API_TOKEN"
```

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "OctoAI"}, {"imported": "OctoAIEndpoint", "source": "langchain_community.llms.octoai_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.octoai_endpoint.OctoAIEndpoint.html", "title": "OctoAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OctoAI"}]-->
from langchain.chains import LLMChain
from langchain_community.llms.octoai_endpoint import OctoAIEndpoint
from langchain_core.prompts import PromptTemplate
```

## Example

```python
template = """Below is an instruction that describes a task. Write a response that appropriately completes the request.\n Instruction:\n{question}\n Response: """
prompt = PromptTemplate.from_template(template)
```

```python
llm = OctoAIEndpoint(
    model_name="llama-2-13b-chat-fp16",
    max_tokens=200,
    presence_penalty=0,
    temperature=0.1,
    top_p=0.9,
)
```

```python
question = "Who was Leonardo da Vinci?"

chain = prompt | llm

print(chain.invoke(question))
```

Leonardo da Vinci was a true Renaissance man. He was born in 1452 in Vinci, Italy and was known for his work in various fields, including art, science, engineering, and mathematics. He is considered one of the greatest painters of all time, and his most famous works include the Mona Lisa and The Last Supper. In addition to his art, da Vinci made significant contributions to engineering and anatomy, and his designs for machines and inventions were centuries ahead of his time. He is also known for his extensive journals and drawings, which provide valuable insights into his thoughts and ideas. Da Vinci's legacy continues to inspire and influence artists, scientists, and thinkers around the world today.

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
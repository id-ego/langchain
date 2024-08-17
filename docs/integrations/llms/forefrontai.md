---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/forefrontai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/forefrontai.ipynb
---

# ForefrontAI

The `Forefront` platform gives you the ability to fine-tune and use [open-source large language models](https://docs.forefront.ai/forefront/master/models).

This notebook goes over how to use Langchain with [ForefrontAI](https://www.forefront.ai/).

## Imports

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "ForefrontAI"}, {"imported": "ForefrontAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.forefrontai.ForefrontAI.html", "title": "ForefrontAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "ForefrontAI"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import ForefrontAI
from langchain_core.prompts import PromptTemplate
```

## Set the Environment API Key
Make sure to get your API key from ForefrontAI. You are given a 5 day free trial to test different models.

```python
# get a new token: https://docs.forefront.ai/forefront/api-reference/authentication

from getpass import getpass

FOREFRONTAI_API_KEY = getpass()
```

```python
os.environ["FOREFRONTAI_API_KEY"] = FOREFRONTAI_API_KEY
```

## Create the ForefrontAI instance
You can specify different parameters such as the model endpoint url, length, temperature, etc. You must provide an endpoint url.

```python
llm = ForefrontAI(endpoint_url="YOUR ENDPOINT URL HERE")
```

## Create a Prompt Template
We will create a prompt template for Question and Answer.

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```

## Initiate the LLMChain

```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```

## Run the LLMChain
Provide a question and run the LLMChain.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
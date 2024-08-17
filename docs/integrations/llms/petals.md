---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/petals/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/petals.ipynb
---

# Petals

`Petals` runs 100B+ language models at home, BitTorrent-style.

This notebook goes over how to use Langchain with [Petals](https://github.com/bigscience-workshop/petals).

## Install petals
The `petals` package is required to use the Petals API. Install `petals` using `pip3 install petals`.

For Apple Silicon(M1/M2) users please follow this guide [https://github.com/bigscience-workshop/petals/issues/147#issuecomment-1365379642](https://github.com/bigscience-workshop/petals/issues/147#issuecomment-1365379642) to install petals 

```python
!pip3 install petals
```

## Imports

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Petals"}, {"imported": "Petals", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.petals.Petals.html", "title": "Petals"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Petals"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import Petals
from langchain_core.prompts import PromptTemplate
```

## Set the Environment API Key
Make sure to get [your API key](https://huggingface.co/docs/api-inference/quicktour#get-your-api-token) from Huggingface.

```python
from getpass import getpass

HUGGINGFACE_API_KEY = getpass()
```
```output
 ········
```

```python
os.environ["HUGGINGFACE_API_KEY"] = HUGGINGFACE_API_KEY
```

## Create the Petals instance
You can specify different parameters such as the model name, max new tokens, temperature, etc.

```python
# this can take several minutes to download big files!

llm = Petals(model_name="bigscience/bloom-petals")
```
```output
Downloading:   1%|▏                        | 40.8M/7.19G [00:24<15:44, 7.57MB/s]
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
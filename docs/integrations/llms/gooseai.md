---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/gooseai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/gooseai.ipynb
---

# GooseAI

`GooseAI` is a fully managed NLP-as-a-Service, delivered via API. GooseAI provides access to [these models](https://goose.ai/docs/models).

This notebook goes over how to use Langchain with [GooseAI](https://goose.ai/).


## Install openai
The `openai` package is required to use the GooseAI API. Install `openai` using `pip install openai`.


```python
%pip install --upgrade --quiet  langchain-openai
```

## Imports


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "GooseAI"}, {"imported": "GooseAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gooseai.GooseAI.html", "title": "GooseAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "GooseAI"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import GooseAI
from langchain_core.prompts import PromptTemplate
```

## Set the Environment API Key
Make sure to get your API key from GooseAI. You are given $10 in free credits to test different models.


```python
from getpass import getpass

GOOSEAI_API_KEY = getpass()
```


```python
os.environ["GOOSEAI_API_KEY"] = GOOSEAI_API_KEY
```

## Create the GooseAI instance
You can specify different parameters such as the model name, max tokens generated, temperature, etc.


```python
llm = GooseAI()
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
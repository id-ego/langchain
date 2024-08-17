---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/pipelineai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/pipelineai.ipynb
---

# PipelineAI

> [PipelineAI](https://pipeline.ai) allows you to run your ML models at scale in the cloud. It also provides API access to [several LLM models](https://pipeline.ai).

This notebook goes over how to use Langchain with [PipelineAI](https://docs.pipeline.ai/docs).

## PipelineAI example

[This example shows how PipelineAI integrated with LangChain](https://docs.pipeline.ai/docs/langchain) and it is created by PipelineAI.

## Setup
The `pipeline-ai` library is required to use the `PipelineAI` API, AKA `Pipeline Cloud`. Install `pipeline-ai` using `pip install pipeline-ai`.

```python
# Install the package
%pip install --upgrade --quiet  pipeline-ai
```

## Example

### Imports

```python
<!--IMPORTS:[{"imported": "PipelineAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.pipelineai.PipelineAI.html", "title": "PipelineAI"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "PipelineAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "PipelineAI"}]-->
import os

from langchain_community.llms import PipelineAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
```

### Set the Environment API Key
Make sure to get your API key from PipelineAI. Check out the [cloud quickstart guide](https://docs.pipeline.ai/docs/cloud-quickstart). You'll be given a 30 day free trial with 10 hours of serverless GPU compute to test different models.

```python
os.environ["PIPELINE_API_KEY"] = "YOUR_API_KEY_HERE"
```

## Create the PipelineAI instance
When instantiating PipelineAI, you need to specify the id or tag of the pipeline you want to use, e.g. `pipeline_key = "public/gpt-j:base"`. You then have the option of passing additional pipeline-specific keyword arguments:

```python
llm = PipelineAI(pipeline_key="YOUR_PIPELINE_KEY", pipeline_kwargs={...})
```

### Create a Prompt Template
We will create a prompt template for Question and Answer.

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```

### Initiate the LLMChain

```python
llm_chain = prompt | llm | StrOutputParser()
```

### Run the LLMChain
Provide a question and run the LLMChain.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.invoke(question)
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
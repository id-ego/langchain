---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/xinference/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/xinference.ipynb
---

# Xorbits Inference (Xinference)

[Xinference](https://github.com/xorbitsai/inference) is a powerful and versatile library designed to serve LLMs,
speech recognition models, and multimodal models, even on your laptop. It supports a variety of models compatible with GGML, such as chatglm, baichuan, whisper, vicuna, orca, and many others. This notebook demonstrates how to use Xinference with LangChain.

## Installation

Install `Xinference` through PyPI:

```python
%pip install --upgrade --quiet  "xinference[all]"
```

## Deploy Xinference Locally or in a Distributed Cluster.

For local deployment, run `xinference`. 

To deploy Xinference in a cluster, first start an Xinference supervisor using the `xinference-supervisor`. You can also use the option -p to specify the port and -H to specify the host. The default port is 9997.

Then, start the Xinference workers using `xinference-worker` on each server you want to run them on. 

You can consult the README file from [Xinference](https://github.com/xorbitsai/inference) for more information.
## Wrapper

To use Xinference with LangChain, you need to first launch a model. You can use command line interface (CLI) to do so:

```python
!xinference launch -n vicuna-v1.3 -f ggmlv3 -q q4_0
```
```output
Model uid: 7167b2b0-2a04-11ee-83f0-d29396a3f064
```
A model UID is returned for you to use. Now you can use Xinference with LangChain:

```python
<!--IMPORTS:[{"imported": "Xinference", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.xinference.Xinference.html", "title": "Xorbits Inference (Xinference)"}]-->
from langchain_community.llms import Xinference

llm = Xinference(
    server_url="http://0.0.0.0:9997", model_uid="7167b2b0-2a04-11ee-83f0-d29396a3f064"
)

llm(
    prompt="Q: where can we visit in the capital of France? A:",
    generate_config={"max_tokens": 1024, "stream": True},
)
```

```output
' You can visit the Eiffel Tower, Notre-Dame Cathedral, the Louvre Museum, and many other historical sites in Paris, the capital of France.'
```

### Integrate with a LLMChain

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Xorbits Inference (Xinference)"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Xorbits Inference (Xinference)"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = "Where can we visit in the capital of {country}?"

prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

generated = llm_chain.run(country="France")
print(generated)
```
```output

A: You can visit many places in Paris, such as the Eiffel Tower, the Louvre Museum, Notre-Dame Cathedral, the Champs-Elysées, Montmartre, Sacré-Cœur, and the Palace of Versailles.
```
Lastly, terminate the model when you do not need to use it:

```python
!xinference terminate --model-uid "7167b2b0-2a04-11ee-83f0-d29396a3f064"
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
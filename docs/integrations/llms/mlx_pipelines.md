---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/mlx_pipelines/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/mlx_pipelines.ipynb
---

# MLX Local Pipelines

MLX models can be run locally through the `MLXPipeline` class.

The [MLX Community](https://huggingface.co/mlx-community) hosts over 150 models, all open source and publicly available on Hugging Face Model Hub a online platform where people can easily collaborate and build ML together.

These can be called from LangChain either through this local pipeline wrapper or by calling their hosted inference endpoints through the MlXPipeline class. For more information on mlx, see the [examples repo](https://github.com/ml-explore/mlx-examples/tree/main/llms) notebook.

To use, you should have the ``mlx-lm`` python [package installed](https://pypi.org/project/mlx-lm/), as well as [transformers](https://pypi.org/project/transformers/). You can also install `huggingface_hub`.


```python
%pip install --upgrade --quiet  mlx-lm transformers huggingface_hub
```

### Model Loading

Models can be loaded by specifying the model parameters using the `from_model_id` method.


```python
<!--IMPORTS:[{"imported": "MLXPipeline", "source": "langchain_community.llms.mlx_pipeline", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.mlx_pipeline.MLXPipeline.html", "title": "MLX Local Pipelines"}]-->
from langchain_community.llms.mlx_pipeline import MLXPipeline

pipe = MLXPipeline.from_model_id(
    "mlx-community/quantized-gemma-2b-it",
    pipeline_kwargs={"max_tokens": 10, "temp": 0.1},
)
```

They can also be loaded by passing in an existing `transformers` pipeline directly


```python
from mlx_lm import load

model, tokenizer = load("mlx-community/quantized-gemma-2b-it")
pipe = MLXPipeline(model=model, tokenizer=tokenizer)
```

### Create Chain

With the model loaded into memory, you can compose it with a prompt to
form a chain.


```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "MLX Local Pipelines"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | pipe

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
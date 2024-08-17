---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/gpt4all/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/gpt4all.ipynb
---

# GPT4All

[GitHub:nomic-ai/gpt4all](https://github.com/nomic-ai/gpt4all) an ecosystem of open-source chatbots trained on a massive collections of clean assistant data including code, stories and dialogue.

This example goes over how to use LangChain to interact with `GPT4All` models.


```python
%pip install --upgrade --quiet langchain-community gpt4all
```

### Import GPT4All


```python
<!--IMPORTS:[{"imported": "GPT4All", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gpt4all.GPT4All.html", "title": "GPT4All"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "GPT4All"}]-->
from langchain_community.llms import GPT4All
from langchain_core.prompts import PromptTemplate
```

### Set Up Question to pass to LLM


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```

### Specify Model

To run locally, download a compatible ggml-formatted model. 
 
The [gpt4all page](https://gpt4all.io/index.html) has a useful `Model Explorer` section:

* Select a model of interest
* Download using the UI and move the `.bin` to the `local_path` (noted below)

For more info, visit https://github.com/nomic-ai/gpt4all.

---

This integration does not yet support streaming in chunks via the [`.stream()`](https://python.langchain.com/v0.2/docs/how_to/streaming/) method. The below example uses a callback handler with `streaming=True`:


```python
local_path = (
    "./models/Meta-Llama-3-8B-Instruct.Q4_0.gguf"  # replace with your local file path
)
```


```python
<!--IMPORTS:[{"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "GPT4All"}]-->
from langchain_core.callbacks import BaseCallbackHandler

count = 0


class MyCustomHandler(BaseCallbackHandler):
    def on_llm_new_token(self, token: str, **kwargs) -> None:
        global count
        if count < 10:
            print(f"Token: {token}")
            count += 1


# Verbose is required to pass to the callback manager
llm = GPT4All(model=local_path, callbacks=[MyCustomHandler()], streaming=True)

# If you want to use a custom model add the backend parameter
# Check https://docs.gpt4all.io/gpt4all_python.html for supported backends
# llm = GPT4All(model=local_path, backend="gptj", callbacks=callbacks, streaming=True)

chain = prompt | llm

question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"

# Streamed tokens will be logged/aggregated via the passed callback
res = chain.invoke({"question": question})
```
```output
Token:  Justin
Token:  Bieber
Token:  was
Token:  born
Token:  on
Token:  March
Token:  
Token: 1
Token: ,
Token:
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
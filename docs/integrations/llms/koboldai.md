---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/koboldai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/koboldai.ipynb
---

# KoboldAI API

[KoboldAI](https://github.com/KoboldAI/KoboldAI-Client) is a "a browser-based front-end for AI-assisted writing with multiple local & remote AI models...". It has a public and local API that is able to be used in langchain.

This example goes over how to use LangChain with that API.

Documentation can be found in the browser adding /api to the end of your endpoint (i.e http://127.0.0.1/:5000/api).



```python
<!--IMPORTS:[{"imported": "KoboldApiLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.koboldai.KoboldApiLLM.html", "title": "KoboldAI API"}]-->
from langchain_community.llms import KoboldApiLLM
```

Replace the endpoint seen below with the one shown in the output after starting the webui with --api or --public-api

Optionally, you can pass in parameters like temperature or max_length


```python
llm = KoboldApiLLM(endpoint="http://192.168.1.144:5000", max_length=80)
```


```python
response = llm.invoke(
    "### Instruction:\nWhat is the first book of the bible?\n### Response:"
)
```


## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
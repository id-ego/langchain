---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/baichuan/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/baichuan.ipynb
---

# Baichuan LLM
Baichuan Inc. (https://www.baichuan-ai.com/) is a Chinese startup in the era of AGI, dedicated to addressing fundamental human needs: Efficiency, Health, and Happiness.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```

## Prerequisite
An API key is required to access Baichuan LLM API. Visit https://platform.baichuan-ai.com/ to get your API key.

## Use Baichuan LLM

```python
import os

os.environ["BAICHUAN_API_KEY"] = "YOUR_API_KEY"
```

```python
<!--IMPORTS:[{"imported": "BaichuanLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.baichuan.BaichuanLLM.html", "title": "Baichuan LLM"}]-->
from langchain_community.llms import BaichuanLLM

# Load the model
llm = BaichuanLLM()

res = llm.invoke("What's your name?")
print(res)
```

```python
res = llm.generate(prompts=["你好！"])
res
```

```python
for res in llm.stream("Who won the second world war?"):
    print(res)
```

```python
import asyncio


async def run_aio_stream():
    async for res in llm.astream("Write a poem about the sun."):
        print(res)


asyncio.run(run_aio_stream())
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)
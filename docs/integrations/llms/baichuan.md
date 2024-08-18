---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/baichuan.ipynb
description: Baichuan LLM은 효율성, 건강, 행복을 추구하는 AGI 시대의 중국 스타트업입니다. API 키를 통해 접근할 수 있습니다.
---

# Baichuan LLM
Baichuan Inc. (https://www.baichuan-ai.com/)는 AGI 시대의 중국 스타트업으로, 기본적인 인간의 필요인 효율성, 건강, 행복을 해결하는 데 전념하고 있습니다.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


## 전제 조건
Baichuan LLM API에 접근하려면 API 키가 필요합니다. API 키를 얻으려면 https://platform.baichuan-ai.com/를 방문하세요.

## Baichuan LLM 사용하기

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


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
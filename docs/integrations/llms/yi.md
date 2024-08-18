---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/yi.ipynb
description: Yi는 Dr. Kai-Fu Lee가 설립한 AI 2.0의 선두주자로, 다양한 언어 모델과 API 플랫폼을 제공합니다.
---

# Yi
[01.AI](https://www.lingyiwanwu.com/en) 는 Dr. Kai-Fu Lee가 설립한 글로벌 기업으로, AI 2.0의 최전선에 있습니다. 그들은 6B에서 수백억 개의 매개변수에 이르는 Yi 시리즈를 포함한 최첨단 대형 언어 모델을 제공합니다. 01.AI는 또한 다중 모달 모델, 오픈 API 플랫폼 및 Yi-34B/9B/6B와 Yi-VL과 같은 오픈 소스 옵션을 제공합니다.

```python
## Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


## 전제 조건
Yi LLM API에 접근하려면 API 키가 필요합니다. API 키를 얻으려면 https://www.lingyiwanwu.com/ 를 방문하세요. API 키를 신청할 때, 국내(중국) 또는 국제 사용을 명시해야 합니다.

## Yi LLM 사용하기

```python
<!--IMPORTS:[{"imported": "YiLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.yi.YiLLM.html", "title": "Yi"}]-->
import os

os.environ["YI_API_KEY"] = "YOUR_API_KEY"

from langchain_community.llms import YiLLM

# Load the model
llm = YiLLM(model="yi-large")

# You can specify the region if needed (default is "auto")
# llm = YiLLM(model="yi-large", region="domestic")  # or "international"

# Basic usage
res = llm.invoke("What's your name?")
print(res)
```


```python
# Generate method
res = llm.generate(
    prompts=[
        "Explain the concept of large language models.",
        "What are the potential applications of AI in healthcare?",
    ]
)
print(res)
```


```python
# Streaming
for chunk in llm.stream("Describe the key features of the Yi language model series."):
    print(chunk, end="", flush=True)
```


```python
# Asynchronous streaming
import asyncio


async def run_aio_stream():
    async for chunk in llm.astream(
        "Write a brief on the future of AI according to Dr. Kai-Fu Lee's vision."
    ):
        print(chunk, end="", flush=True)


asyncio.run(run_aio_stream())
```


```python
# Adjusting parameters
llm_with_params = YiLLM(
    model="yi-large",
    temperature=0.7,
    top_p=0.9,
)

res = llm_with_params(
    "Propose an innovative AI application that could benefit society."
)
print(res)
```


## 관련 자료

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
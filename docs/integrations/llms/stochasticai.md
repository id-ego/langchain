---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/stochasticai.ipynb
description: StochasticAI는 딥러닝 모델의 생애 주기를 간소화하는 플랫폼으로, LangChain을 통해 모델과 상호작용하는 방법을
  설명합니다.
---

# StochasticAI

> [Stochastic Acceleration Platform](https://docs.stochastic.ai/docs/introduction/)는 딥 러닝 모델의 생애 주기를 단순화하는 것을 목표로 합니다. 모델의 업로드 및 버전 관리, 훈련, 압축 및 가속을 거쳐 프로덕션에 배포하는 과정까지 포함됩니다.

이 예제는 LangChain을 사용하여 `StochasticAI` 모델과 상호작용하는 방법을 설명합니다.

API_KEY와 API_URL을 [여기](https://app.stochastic.ai/workspace/profile/settings?tab=profile)에서 받아야 합니다.

```python
from getpass import getpass

STOCHASTICAI_API_KEY = getpass()
```

```output
 ········
```


```python
import os

os.environ["STOCHASTICAI_API_KEY"] = STOCHASTICAI_API_KEY
```


```python
YOUR_API_URL = getpass()
```

```output
 ········
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "StochasticAI"}, {"imported": "StochasticAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.stochasticai.StochasticAI.html", "title": "StochasticAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "StochasticAI"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import StochasticAI
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
llm = StochasticAI(api_url=YOUR_API_URL)
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


```output
"\n\nStep 1: In 1999, the St. Louis Rams won the Super Bowl.\n\nStep 2: In 1999, Beiber was born.\n\nStep 3: The Rams were in Los Angeles at the time.\n\nStep 4: So they didn't play in the Super Bowl that year.\n"
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
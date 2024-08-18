---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/banana.ipynb
description: 이 문서는 LangChain을 사용하여 Banana 모델과 상호작용하는 방법을 설명합니다. 머신러닝 인프라 구축에 중점을 두고
  있습니다.
---

# 바나나

[바나나](https://www.banana.dev/about-us)는 머신 러닝 인프라 구축에 집중하고 있습니다.

이 예제는 LangChain을 사용하여 바나나 모델과 상호작용하는 방법에 대해 설명합니다.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU  langchain-community
```


```python
# Install the package  https://docs.banana.dev/banana-docs/core-concepts/sdks/python
%pip install --upgrade --quiet  banana-dev
```


```python
# get new tokens: https://app.banana.dev/
# We need three parameters to make a Banana.dev API call:
# * a team api key
# * the model's unique key
# * the model's url slug

import os

# You can get this from the main dashboard
# at https://app.banana.dev
os.environ["BANANA_API_KEY"] = "YOUR_API_KEY"
# OR
# BANANA_API_KEY = getpass()
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Banana"}, {"imported": "Banana", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.bananadev.Banana.html", "title": "Banana"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Banana"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import Banana
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
# Both of these are found in your model's
# detail page in https://app.banana.dev
llm = Banana(model_key="YOUR_MODEL_KEY", model_url_slug="YOUR_MODEL_URL_SLUG")
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/aleph_alpha.ipynb
description: Aleph Alpha의 Luminous 시리즈 모델을 LangChain을 통해 활용하는 방법을 소개하는 문서입니다.
---

# 알레프 알파

[루미너스 시리즈](https://docs.aleph-alpha.com/docs/introduction/luminous/)는 대형 언어 모델의 집합입니다.

이 예제는 LangChain을 사용하여 알레프 알파 모델과 상호작용하는 방법을 설명합니다.

```python
# Installing the langchain package needed to use the integration
%pip install -qU langchain-community
```


```python
# Install the package
%pip install --upgrade --quiet  aleph-alpha-client
```


```python
# create a new token: https://docs.aleph-alpha.com/docs/account/#create-a-new-token

from getpass import getpass

ALEPH_ALPHA_API_KEY = getpass()
```

```output
········
```


```python
<!--IMPORTS:[{"imported": "AlephAlpha", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.aleph_alpha.AlephAlpha.html", "title": "Aleph Alpha"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Aleph Alpha"}]-->
from langchain_community.llms import AlephAlpha
from langchain_core.prompts import PromptTemplate
```


```python
template = """Q: {question}

A:"""

prompt = PromptTemplate.from_template(template)
```


```python
llm = AlephAlpha(
    model="luminous-extended",
    maximum_tokens=20,
    stop_sequences=["Q:"],
    aleph_alpha_api_key=ALEPH_ALPHA_API_KEY,
)
```


```python
llm_chain = prompt | llm
```


```python
question = "What is AI?"

llm_chain.invoke({"question": question})
```


```output
' Artificial Intelligence is the simulation of human intelligence processes by machines.\n\n'
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
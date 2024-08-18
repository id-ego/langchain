---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/anyscale.ipynb
description: Anyscale은 AI 및 Python 애플리케이션을 구축, 배포 및 관리할 수 있는 완전 관리형 Ray 플랫폼입니다. LangChain을
  사용하여 Anyscale Endpoint와 상호작용하는 방법을 설명합니다.
---

# Anyscale

[Anyscale](https://www.anyscale.com/)는 확장 가능한 AI 및 Python 애플리케이션을 구축, 배포 및 관리할 수 있는 완전 관리형 [Ray](https://www.ray.io/) 플랫폼입니다.

이 예제는 LangChain을 사용하여 [Anyscale Endpoint](https://app.endpoints.anyscale.com/)와 상호작용하는 방법을 설명합니다.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


```python
ANYSCALE_API_BASE = "..."
ANYSCALE_API_KEY = "..."
ANYSCALE_MODEL_NAME = "..."
```


```python
import os

os.environ["ANYSCALE_API_BASE"] = ANYSCALE_API_BASE
os.environ["ANYSCALE_API_KEY"] = ANYSCALE_API_KEY
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Anyscale"}, {"imported": "Anyscale", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.anyscale.Anyscale.html", "title": "Anyscale"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Anyscale"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import Anyscale
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
llm = Anyscale(model_name=ANYSCALE_MODEL_NAME)
```


```python
llm_chain = prompt | llm
```


```python
question = "When was George Washington president?"

llm_chain.invoke({"question": question})
```


Ray를 사용하면 비동기 구현 없이 쿼리를 분산할 수 있습니다. 이는 Anyscale LLM 모델뿐만 아니라 `_acall` 또는 `_agenerate`가 구현되지 않은 다른 모든 Langchain LLM 모델에도 적용됩니다.

```python
prompt_list = [
    "When was George Washington president?",
    "Explain to me the difference between nuclear fission and fusion.",
    "Give me a list of 5 science fiction books I should read next.",
    "Explain the difference between Spark and Ray.",
    "Suggest some fun holiday ideas.",
    "Tell a joke.",
    "What is 2+2?",
    "Explain what is machine learning like I am five years old.",
    "Explain what is artifical intelligence.",
]
```


```python
import ray


@ray.remote(num_cpus=0.1)
def send_query(llm, prompt):
    resp = llm.invoke(prompt)
    return resp


futures = [send_query.remote(llm, prompt) for prompt in prompt_list]
results = ray.get(futures)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
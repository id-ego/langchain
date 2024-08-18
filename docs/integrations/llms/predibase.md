---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/predibase.ipynb
description: Predibase를 사용하여 ML 모델을 훈련, 미세 조정 및 배포하는 방법을 Langchain과 함께 보여주는 예제입니다.
---

# Predibase

[Predibase](https://predibase.com/)는 선형 회귀부터 대형 언어 모델에 이르기까지 모든 ML 모델을 학습, 미세 조정 및 배포할 수 있게 해줍니다.

이 예제는 Predibase에 배포된 모델과 함께 Langchain을 사용하는 방법을 보여줍니다.

# 설정

이 노트북을 실행하려면 [Predibase 계정](https://predibase.com/free-trial/?utm_source=langchain)과 [API 키](https://docs.predibase.com/sdk-guide/intro)가 필요합니다.

또한 Predibase Python 패키지를 설치해야 합니다:

```python
%pip install --upgrade --quiet  predibase
import os

os.environ["PREDIBASE_API_TOKEN"] = "{PREDIBASE_API_TOKEN}"
```


## 초기 호출

```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
from langchain_community.llms import Predibase

model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
)
```


```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
from langchain_community.llms import Predibase

# With a fine-tuned adapter hosted at Predibase (adapter_version must be specified).
model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="e2e_nlg",
    adapter_version=1,
)
```


```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
from langchain_community.llms import Predibase

# With a fine-tuned adapter hosted at HuggingFace (adapter_version does not apply and will be ignored).
model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="predibase/e2e_nlg",
)
```


```python
response = model.invoke("Can you recommend me a nice dry wine?")
print(response)
```


## 체인 호출 설정

```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
from langchain_community.llms import Predibase

model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
)
```


```python
# With a fine-tuned adapter hosted at Predibase (adapter_version must be specified).
model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="e2e_nlg",
    adapter_version=1,
)
```


```python
# With a fine-tuned adapter hosted at HuggingFace (adapter_version does not apply and will be ignored).
llm = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="predibase/e2e_nlg",
)
```


## SequentialChain

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Predibase"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Predibase"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate
```


```python
# This is an LLMChain to write a synopsis given a title of a play.
template = """You are a playwright. Given the title of play, it is your job to write a synopsis for that title.

Title: {title}
Playwright: This is a synopsis for the above play:"""
prompt_template = PromptTemplate(input_variables=["title"], template=template)
synopsis_chain = LLMChain(llm=llm, prompt=prompt_template)
```


```python
# This is an LLMChain to write a review of a play given a synopsis.
template = """You are a play critic from the New York Times. Given the synopsis of play, it is your job to write a review for that play.

Play Synopsis:
{synopsis}
Review from a New York Times play critic of the above play:"""
prompt_template = PromptTemplate(input_variables=["synopsis"], template=template)
review_chain = LLMChain(llm=llm, prompt=prompt_template)
```


```python
<!--IMPORTS:[{"imported": "SimpleSequentialChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sequential.SimpleSequentialChain.html", "title": "Predibase"}]-->
# This is the overall chain where we run these two chains in sequence.
from langchain.chains import SimpleSequentialChain

overall_chain = SimpleSequentialChain(
    chains=[synopsis_chain, review_chain], verbose=True
)
```


```python
review = overall_chain.run("Tragedy at sunset on the beach")
```


## 미세 조정된 LLM (Predibase에서 미세 조정한 LLM 사용)

```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
from langchain_community.llms import Predibase

model = Predibase(
    model="my-base-LLM",
    predibase_api_key=os.environ.get(
        "PREDIBASE_API_TOKEN"
    ),  # Adapter argument is optional.
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="my-finetuned-adapter-id",  # Supports both, Predibase-hosted and HuggingFace-hosted adapter repositories.
    adapter_version=1,  # required for Predibase-hosted adapters (ignored for HuggingFace-hosted adapters)
)
# replace my-base-LLM with the name of your choice of a serverless base model in Predibase
```


```python
# response = model.invoke("Can you help categorize the following emails into positive, negative, and neutral?")
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
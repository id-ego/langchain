---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/forefrontai.ipynb
description: ForefrontAI 플랫폼을 사용하여 Langchain과 함께 오픈 소스 대형 언어 모델을 조정하고 활용하는 방법을 설명합니다.
---

# ForefrontAI

`Forefront` 플랫폼은 [오픈 소스 대형 언어 모델](https://docs.forefront.ai/forefront/master/models)을 미세 조정하고 사용할 수 있는 기능을 제공합니다.

이 노트북은 [ForefrontAI](https://www.forefront.ai/)와 함께 Langchain을 사용하는 방법에 대해 설명합니다.

## Imports

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "ForefrontAI"}, {"imported": "ForefrontAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.forefrontai.ForefrontAI.html", "title": "ForefrontAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "ForefrontAI"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import ForefrontAI
from langchain_core.prompts import PromptTemplate
```


## 환경 API 키 설정
ForefrontAI에서 API 키를 받아야 합니다. 다양한 모델을 테스트할 수 있는 5일 무료 체험이 제공됩니다.

```python
# get a new token: https://docs.forefront.ai/forefront/api-reference/authentication

from getpass import getpass

FOREFRONTAI_API_KEY = getpass()
```


```python
os.environ["FOREFRONTAI_API_KEY"] = FOREFRONTAI_API_KEY
```


## ForefrontAI 인스턴스 생성
모델 엔드포인트 URL, 길이, 온도 등과 같은 다양한 매개변수를 지정할 수 있습니다. 엔드포인트 URL을 제공해야 합니다.

```python
llm = ForefrontAI(endpoint_url="YOUR ENDPOINT URL HERE")
```


## 프롬프트 템플릿 생성
질문과 답변을 위한 프롬프트 템플릿을 생성합니다.

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


## LLMChain 시작

```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


## LLMChain 실행
질문을 제공하고 LLMChain을 실행합니다.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
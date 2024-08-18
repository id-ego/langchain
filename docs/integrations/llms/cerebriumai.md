---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/cerebriumai.ipynb
description: CerebriumAI는 AWS Sagemaker 대안으로, Langchain과 함께 사용하여 다양한 LLM 모델에 API 접근을
  제공합니다.
---

# CerebriumAI

`Cerebrium`은 AWS Sagemaker의 대안입니다. 또한 [여러 LLM 모델](https://docs.cerebrium.ai/cerebrium/prebuilt-models/deployment)에 대한 API 액세스를 제공합니다.

이 노트북에서는 [CerebriumAI](https://docs.cerebrium.ai/introduction)와 함께 Langchain을 사용하는 방법을 설명합니다.

## cerebrium 설치
`CerebriumAI` API를 사용하려면 `cerebrium` 패키지가 필요합니다. `pip3 install cerebrium`을 사용하여 `cerebrium`을 설치하세요.

```python
# Install the package
!pip3 install cerebrium
```


## 가져오기

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "CerebriumAI"}, {"imported": "CerebriumAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.cerebriumai.CerebriumAI.html", "title": "CerebriumAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "CerebriumAI"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import CerebriumAI
from langchain_core.prompts import PromptTemplate
```


## 환경 API 키 설정
CerebriumAI에서 API 키를 받아야 합니다. [여기](https://dashboard.cerebrium.ai/login)를 참조하세요. 다양한 모델을 테스트하기 위해 1시간의 서버리스 GPU 컴퓨팅이 제공됩니다.

```python
os.environ["CEREBRIUMAI_API_KEY"] = "YOUR_KEY_HERE"
```


## CerebriumAI 인스턴스 생성
모델 엔드포인트 URL, 최대 길이, 온도 등과 같은 다양한 매개변수를 지정할 수 있습니다. 엔드포인트 URL을 제공해야 합니다.

```python
llm = CerebriumAI(endpoint_url="YOUR ENDPOINT URL HERE")
```


## 프롬프트 템플릿 생성
질문과 답변을 위한 프롬프트 템플릿을 생성할 것입니다.

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


## LLMChain 초기화

```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


## LLMChain 실행
질문을 제공하고 LLMChain을 실행하세요.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/petals.ipynb
description: 이 문서는 Petals를 사용하여 Langchain과 함께 100B+ 언어 모델을 실행하는 방법을 설명합니다. 설치 및 설정
  과정을 안내합니다.
---

# Petals

`Petals`는 100B+ 언어 모델을 집에서 BitTorrent 스타일로 실행합니다.

이 노트북은 Langchain을 [Petals](https://github.com/bigscience-workshop/petals)와 함께 사용하는 방법을 설명합니다.

## petals 설치
`petals` 패키지는 Petals API를 사용하기 위해 필요합니다. `pip3 install petals`를 사용하여 `petals`를 설치하세요.

Apple Silicon(M1/M2) 사용자들은 [이 가이드](https://github.com/bigscience-workshop/petals/issues/147#issuecomment-1365379642)를 따라 petals를 설치하세요.

```python
!pip3 install petals
```


## 임포트

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Petals"}, {"imported": "Petals", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.petals.Petals.html", "title": "Petals"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Petals"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import Petals
from langchain_core.prompts import PromptTemplate
```


## 환경 API 키 설정
Huggingface에서 [API 키](https://huggingface.co/docs/api-inference/quicktour#get-your-api-token)를 꼭 받아야 합니다.

```python
from getpass import getpass

HUGGINGFACE_API_KEY = getpass()
```

```output
 ········
```


```python
os.environ["HUGGINGFACE_API_KEY"] = HUGGINGFACE_API_KEY
```


## Petals 인스턴스 생성
모델 이름, 최대 새 토큰, 온도 등과 같은 다양한 매개변수를 지정할 수 있습니다.

```python
# this can take several minutes to download big files!

llm = Petals(model_name="bigscience/bloom-petals")
```

```output
Downloading:   1%|▏                        | 40.8M/7.19G [00:24<15:44, 7.57MB/s]
```


## 프롬프트 템플릿 생성
질문과 답변을 위한 프롬프트 템플릿을 생성하겠습니다.

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
질문을 제공하고 LLMChain을 실행하세요.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/pipelineai.ipynb
description: PipelineAI를 사용하여 클라우드에서 ML 모델을 대규모로 실행하는 방법과 Langchain 통합 예제를 다루는 노트북입니다.
---

# PipelineAI

> [PipelineAI](https://pipeline.ai)는 클라우드에서 ML 모델을 대규모로 실행할 수 있게 해줍니다. 또한 [여러 LLM 모델](https://pipeline.ai)에 대한 API 액세스를 제공합니다.

이 노트북은 [PipelineAI](https://docs.pipeline.ai/docs)와 Langchain을 사용하는 방법을 설명합니다.

## PipelineAI 예제

[이 예제는 PipelineAI가 LangChain과 통합된 방법을 보여줍니다](https://docs.pipeline.ai/docs/langchain) 및 PipelineAI에 의해 생성되었습니다.

## 설정
`PipelineAI` API를 사용하려면 `pipeline-ai` 라이브러리가 필요합니다. `pip install pipeline-ai`를 사용하여 `pipeline-ai`를 설치하세요.

```python
# Install the package
%pip install --upgrade --quiet  pipeline-ai
```


## 예제

### 임포트

```python
<!--IMPORTS:[{"imported": "PipelineAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.pipelineai.PipelineAI.html", "title": "PipelineAI"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "PipelineAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "PipelineAI"}]-->
import os

from langchain_community.llms import PipelineAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
```


### 환경 API 키 설정
PipelineAI에서 API 키를 받아야 합니다. [클라우드 빠른 시작 가이드](https://docs.pipeline.ai/docs/cloud-quickstart)를 확인하세요. 다양한 모델을 테스트할 수 있는 30일 무료 체험과 10시간의 서버리스 GPU 컴퓨팅이 제공됩니다.

```python
os.environ["PIPELINE_API_KEY"] = "YOUR_API_KEY_HERE"
```


## PipelineAI 인스턴스 생성
PipelineAI를 인스턴스화할 때 사용하려는 파이프라인의 ID 또는 태그를 지정해야 합니다. 예: `pipeline_key = "public/gpt-j:base"` 추가적인 파이프라인 전용 키워드 인수를 전달할 수 있는 옵션이 있습니다:

```python
llm = PipelineAI(pipeline_key="YOUR_PIPELINE_KEY", pipeline_kwargs={...})
```


### 프롬프트 템플릿 생성
질문과 답변을 위한 프롬프트 템플릿을 생성하겠습니다.

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


### LLMChain 시작

```python
llm_chain = prompt | llm | StrOutputParser()
```


### LLMChain 실행
질문을 제공하고 LLMChain을 실행합니다.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.invoke(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
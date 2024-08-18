---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/mosaicml.ipynb
description: MosaicML은 다양한 오픈 소스 모델을 사용하거나 자체 모델을 배포하여 텍스트 완성을 위한 관리형 추론 서비스를 제공합니다.
---

# MosaicML

[MosaicML](https://docs.mosaicml.com/en/latest/inference.html)은 관리형 추론 서비스를 제공합니다. 다양한 오픈 소스 모델을 사용하거나, 자신의 모델을 배포할 수 있습니다.

이 예제는 LangChain을 사용하여 MosaicML Inference와 상호 작용하여 텍스트 완성을 수행하는 방법을 설명합니다.

```python
# sign up for an account: https://forms.mosaicml.com/demo?utm_source=langchain

from getpass import getpass

MOSAICML_API_TOKEN = getpass()
```


```python
import os

os.environ["MOSAICML_API_TOKEN"] = MOSAICML_API_TOKEN
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "MosaicML"}, {"imported": "MosaicML", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.mosaicml.MosaicML.html", "title": "MosaicML"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "MosaicML"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import MosaicML
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}"""

prompt = PromptTemplate.from_template(template)
```


```python
llm = MosaicML(inject_instruction_format=True, model_kwargs={"max_new_tokens": 128})
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What is one good reason why you should train a large language model on domain specific data?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
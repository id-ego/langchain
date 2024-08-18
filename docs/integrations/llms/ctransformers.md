---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/ctransformers.ipynb
description: C Transformers 라이브러리는 GGML 모델을 위한 Python 바인딩을 제공하며, LangChain을 사용하여 모델과
  상호작용하는 방법을 설명합니다.
---

# C Transformers

[C Transformers](https://github.com/marella/ctransformers) 라이브러리는 GGML 모델을 위한 Python 바인딩을 제공합니다.

이 예제는 LangChain을 사용하여 `C Transformers` [모델](https://github.com/marella/ctransformers#supported-models)과 상호작용하는 방법을 설명합니다.

**설치**

```python
%pip install --upgrade --quiet  ctransformers
```


**모델 로드**

```python
<!--IMPORTS:[{"imported": "CTransformers", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.ctransformers.CTransformers.html", "title": "C Transformers"}]-->
from langchain_community.llms import CTransformers

llm = CTransformers(model="marella/gpt-2-ggml")
```


**텍스트 생성**

```python
print(llm.invoke("AI is going to"))
```


**스트리밍**

```python
<!--IMPORTS:[{"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "C Transformers"}]-->
from langchain_core.callbacks import StreamingStdOutCallbackHandler

llm = CTransformers(
    model="marella/gpt-2-ggml", callbacks=[StreamingStdOutCallbackHandler()]
)

response = llm.invoke("AI is going to")
```


**LLMChain**

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "C Transformers"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "C Transformers"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer:"""

prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

response = llm_chain.run("What is AI?")
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
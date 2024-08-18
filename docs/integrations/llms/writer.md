---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/writer.ipynb
description: Writer 플랫폼을 사용하여 LangChain으로 다양한 언어 콘텐츠를 생성하는 방법에 대한 예제를 제공합니다. API 키를
  얻는 방법도 포함되어 있습니다.
---

# Writer

[Writer](https://writer.com/)는 다양한 언어 콘텐츠를 생성하는 플랫폼입니다.

이 예제는 LangChain을 사용하여 `Writer` [모델](https://dev.writer.com/docs/models)과 상호작용하는 방법을 설명합니다.

여기에서 WRITER_API_KEY를 받아야 합니다 [여기](https://dev.writer.com/docs).

```python
from getpass import getpass

WRITER_API_KEY = getpass()
```

```output
 ········
```


```python
import os

os.environ["WRITER_API_KEY"] = WRITER_API_KEY
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Writer"}, {"imported": "Writer", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.writer.Writer.html", "title": "Writer"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Writer"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import Writer
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
# If you get an error, probably, you need to set up the "base_url" parameter that can be taken from the error log.

llm = Writer()
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## Related

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
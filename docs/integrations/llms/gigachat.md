---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/gigachat.ipynb
description: 이 노트북은 LangChain을 사용하여 GigaChat을 활용하는 방법을 보여줍니다. GigaChat API 사용을 위한
  설치 및 인증 절차를 안내합니다.
---

# GigaChat
이 노트북은 LangChain을 [GigaChat](https://developers.sber.ru/portal/products/gigachat)과 함께 사용하는 방법을 보여줍니다.
사용하려면 `gigachat` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  gigachat
```


GigaChat 자격 증명을 얻으려면 [계정을 생성](https://developers.sber.ru/studio/login)하고 [API에 대한 액세스를 얻어야](https://developers.sber.ru/docs/ru/gigachat/individuals-quickstart) 합니다.

## 예제

```python
import os
from getpass import getpass

os.environ["GIGACHAT_CREDENTIALS"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "GigaChat", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gigachat.GigaChat.html", "title": "GigaChat"}]-->
from langchain_community.llms import GigaChat

llm = GigaChat(verify_ssl_certs=False, scope="GIGACHAT_API_PERS")
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "GigaChat"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "GigaChat"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = "What is capital of {country}?"

prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

generated = llm_chain.invoke(input={"country": "Russia"})
print(generated["text"])
```

```output
The capital of Russia is Moscow.
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/llm_chain.ipynb
description: 이 문서는 `LLMChain`의 LCEL 구현으로의 전환 이점과 코드 예제를 설명합니다. 더 나은 명확성과 스트리밍 기능을
  제공합니다.
title: Migrating from LLMChain
---

[`LLMChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html) 프롬프트 템플릿, LLM 및 출력 파서를 클래스에 결합했습니다.

LCEL 구현으로 전환하는 몇 가지 장점은 다음과 같습니다:

- 내용 및 매개변수에 대한 명확성. 레거시 `LLMChain`은 기본 출력 파서 및 기타 옵션을 포함합니다.
- 스트리밍이 더 쉬워졌습니다. `LLMChain`은 콜백을 통해서만 스트리밍을 지원합니다.
- 원시 메시지 출력에 더 쉽게 접근할 수 있습니다. `LLMChain`은 이러한 출력을 매개변수 또는 콜백을 통해서만 노출합니다.

```python
%pip install --upgrade --quiet langchain-openai
```


```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


## 레거시

<details open>

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [("user", "Tell me a {adjective} joke")],
)

chain = LLMChain(llm=ChatOpenAI(), prompt=prompt)

chain({"adjective": "funny"})
```


```output
{'adjective': 'funny',
 'text': "Why couldn't the bicycle stand up by itself?\n\nBecause it was two tired!"}
```


</details>

## LCEL

<details open>

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [("user", "Tell me a {adjective} joke")],
)

chain = prompt | ChatOpenAI() | StrOutputParser()

chain.invoke({"adjective": "funny"})
```


```output
'Why was the math book sad?\n\nBecause it had too many problems.'
```


기본적으로 `LLMChain`은 입력과 출력을 모두 포함하는 `dict`를 반환합니다. 이 동작이 필요하다면, 다른 LCEL 원시인 [`RunnablePassthrough`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html)를 사용하여 이를 복제할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "# Legacy"}]-->
from langchain_core.runnables import RunnablePassthrough

outer_chain = RunnablePassthrough().assign(text=chain)

outer_chain.invoke({"adjective": "funny"})
```


```output
{'adjective': 'funny',
 'text': 'Why did the scarecrow win an award? Because he was outstanding in his field!'}
```


</details>

## 다음 단계

프롬프트 템플릿, LLM 및 출력 파서를 사용하여 구축하는 방법에 대한 자세한 내용은 [이 튜토리얼](/docs/tutorials/llm_chain)을 참조하세요.

더 많은 배경 정보를 원하시면 [LCEL 개념 문서](/docs/concepts/#langchain-expression-language-lcel)를 확인하세요.
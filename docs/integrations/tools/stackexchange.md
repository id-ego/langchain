---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/stackexchange.ipynb
description: Stack Exchange는 다양한 주제를 다루는 Q&A 웹사이트 네트워크로, StackOverflow API를 통해 프로그래밍
  관련 질문과 답변에 접근할 수 있습니다.
---

# StackExchange

> [Stack Exchange](https://stackexchange.com/)는 다양한 분야의 주제에 대한 질문과 답변(Q&A) 웹사이트 네트워크로, 각 사이트는 특정 주제를 다루며, 질문, 답변 및 사용자는 평판 보상 프로세스의 대상이 됩니다. 평판 시스템은 사이트가 자율적으로 관리될 수 있도록 합니다.

`StackExchange` 구성 요소는 StackExchange API를 LangChain에 통합하여 Stack Excange 네트워크의 [StackOverflow](https://stackoverflow.com/) 사이트에 접근할 수 있게 합니다. Stack Overflow는 컴퓨터 프로그래밍에 중점을 둡니다.

이 노트북은 `StackExchange` 구성 요소를 사용하는 방법을 설명합니다.

먼저 Stack Exchange API를 구현하는 python 패키지 stackapi를 설치해야 합니다.

```python
pip install --upgrade stackapi
```


```python
<!--IMPORTS:[{"imported": "StackExchangeAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.stackexchange.StackExchangeAPIWrapper.html", "title": "StackExchange"}]-->
from langchain_community.utilities import StackExchangeAPIWrapper

stackexchange = StackExchangeAPIWrapper()

stackexchange.run("zsh: command not found: python")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
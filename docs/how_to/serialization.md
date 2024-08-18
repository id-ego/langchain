---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/serialization.ipynb
description: LangChain 객체를 저장하고 로드하는 방법에 대한 설명으로, 직렬화 및 역직렬화의 장점을 다룹니다.
---

# LangChain 객체 저장 및 로드 방법

LangChain 클래스는 직렬화를 위한 표준 메서드를 구현합니다. 이러한 메서드를 사용하여 LangChain 객체를 직렬화하면 몇 가지 이점이 있습니다:

- API 키와 같은 비밀이 다른 매개변수와 분리되어 있으며, 비직렬화 시 객체로 다시 로드할 수 있습니다;
- 비직렬화는 패키지 버전 간의 호환성을 유지하므로, 한 버전의 LangChain으로 직렬화된 객체는 다른 버전으로 적절하게 비직렬화될 수 있습니다.

이 시스템을 사용하여 LangChain 객체를 저장하고 로드하려면 `langchain-core`의 [load 모듈](https://api.python.langchain.com/en/latest/core_api_reference.html#module-langchain_core.load)에서 `dumpd`, `dumps`, `load`, 및 `loads` 함수를 사용하십시오. 이러한 함수는 JSON 및 JSON 직렬화 가능한 객체를 지원합니다.

[Serializable](https://api.python.langchain.com/en/latest/load/langchain_core.load.serializable.Serializable.html)에서 상속된 모든 LangChain 객체는 JSON 직렬화가 가능합니다. 예를 들어 [messages](https://api.python.langchain.com/en/latest/core_api_reference.html#module-langchain_core.messages), [문서 객체](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) (예: [retrievers](/docs/concepts/#retrievers)에서 반환된 것) 및 대부분의 [Runnables](/docs/concepts/#langchain-expression-language-lcel), 예를 들어 채팅 모델, 리트리버 및 LangChain 표현 언어로 구현된 [체인](/docs/how_to/sequence)이 포함됩니다.

아래에서는 간단한 [LLM 체인](/docs/tutorials/llm_chain) 예제를 살펴봅니다.

:::caution

`load` 및 `loads`를 사용한 비직렬화는 직렬화 가능한 LangChain 객체를 인스턴스화할 수 있습니다. 신뢰할 수 있는 입력에 대해서만 이 기능을 사용하십시오!

비직렬화는 베타 기능이며 변경될 수 있습니다.
:::

```python
<!--IMPORTS:[{"imported": "dumpd", "source": "langchain_core.load", "docs": "https://api.python.langchain.com/en/latest/load/langchain_core.load.dump.dumpd.html", "title": "How to save and load LangChain objects"}, {"imported": "dumps", "source": "langchain_core.load", "docs": "https://api.python.langchain.com/en/latest/load/langchain_core.load.dump.dumps.html", "title": "How to save and load LangChain objects"}, {"imported": "load", "source": "langchain_core.load", "docs": "https://api.python.langchain.com/en/latest/load/langchain_core.load.load.load.html", "title": "How to save and load LangChain objects"}, {"imported": "loads", "source": "langchain_core.load", "docs": "https://api.python.langchain.com/en/latest/load/langchain_core.load.load.loads.html", "title": "How to save and load LangChain objects"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to save and load LangChain objects"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to save and load LangChain objects"}]-->
from langchain_core.load import dumpd, dumps, load, loads
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "Translate the following into {language}:"),
        ("user", "{text}"),
    ],
)

llm = ChatOpenAI(model="gpt-3.5-turbo-0125", api_key="llm-api-key")

chain = prompt | llm
```


## 객체 저장

### JSON으로

```python
string_representation = dumps(chain, pretty=True)
print(string_representation[:500])
```

```output
{
  "lc": 1,
  "type": "constructor",
  "id": [
    "langchain",
    "schema",
    "runnable",
    "RunnableSequence"
  ],
  "kwargs": {
    "first": {
      "lc": 1,
      "type": "constructor",
      "id": [
        "langchain",
        "prompts",
        "chat",
        "ChatPromptTemplate"
      ],
      "kwargs": {
        "input_variables": [
          "language",
          "text"
        ],
        "messages": [
          {
            "lc": 1,
            "type": "constructor",
```

### JSON 직렬화 가능한 Python dict로

```python
dict_representation = dumpd(chain)

print(type(dict_representation))
```

```output
<class 'dict'>
```

### 디스크에

```python
import json

with open("/tmp/chain.json", "w") as fp:
    json.dump(string_representation, fp)
```


API 키는 직렬화된 표현에서 제외됩니다. 비밀로 간주되는 매개변수는 LangChain 객체의 `.lc_secrets` 속성으로 지정됩니다:

```python
chain.last.lc_secrets
```


```output
{'openai_api_key': 'OPENAI_API_KEY'}
```


## 객체 로드

`load` 및 `loads`에서 `secrets_map`을 지정하면 비직렬화된 LangChain 객체에 해당 비밀이 로드됩니다.

### 문자열에서

```python
chain = loads(string_representation, secrets_map={"OPENAI_API_KEY": "llm-api-key"})
```


### dict에서

```python
chain = load(dict_representation, secrets_map={"OPENAI_API_KEY": "llm-api-key"})
```


### 디스크에서

```python
with open("/tmp/chain.json", "r") as fp:
    chain = loads(json.load(fp), secrets_map={"OPENAI_API_KEY": "llm-api-key"})
```


가이드 시작 부분에 지정된 API 키를 복구합니다:

```python
chain.last.openai_api_key.get_secret_value()
```


```output
'llm-api-key'
```
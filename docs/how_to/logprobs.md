---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/logprobs.ipynb
description: 이 가이드는 LangChain에서 OpenAI 모델의 토큰 수준 로그 확률을 얻는 방법을 설명합니다. 필요한 설정과 코드 예제를
  제공합니다.
---

# 로그 확률 가져오는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)

:::

특정 채팅 모델은 주어진 토큰의 가능성을 나타내는 토큰 수준의 로그 확률을 반환하도록 구성할 수 있습니다. 이 가이드는 LangChain에서 이 정보를 얻는 방법을 안내합니다.

## OpenAI

LangChain x OpenAI 패키지를 설치하고 API 키를 설정합니다.

```python
%pip install -qU langchain-openai
```


```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()
```


OpenAI API가 로그 확률을 반환하도록 하려면 `logprobs=True` 매개변수를 구성해야 합니다. 그런 다음, 로그 확률은 각 출력 [`AIMessage`](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html)의 `response_metadata`의 일부로 포함됩니다:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to get log probabilities"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo-0125").bind(logprobs=True)

msg = llm.invoke(("human", "how are you today"))

msg.response_metadata["logprobs"]["content"][:5]
```


```output
[{'token': 'I', 'bytes': [73], 'logprob': -0.26341408, 'top_logprobs': []},
 {'token': "'m",
  'bytes': [39, 109],
  'logprob': -0.48584133,
  'top_logprobs': []},
 {'token': ' just',
  'bytes': [32, 106, 117, 115, 116],
  'logprob': -0.23484154,
  'top_logprobs': []},
 {'token': ' a',
  'bytes': [32, 97],
  'logprob': -0.0018291725,
  'top_logprobs': []},
 {'token': ' computer',
  'bytes': [32, 99, 111, 109, 112, 117, 116, 101, 114],
  'logprob': -0.052299336,
  'top_logprobs': []}]
```


또한 스트리밍된 메시지 청크의 일부이기도 합니다:

```python
ct = 0
full = None
for chunk in llm.stream(("human", "how are you today")):
    if ct < 5:
        full = chunk if full is None else full + chunk
        if "logprobs" in full.response_metadata:
            print(full.response_metadata["logprobs"]["content"])
    else:
        break
    ct += 1
```

```output
[]
[{'token': 'I', 'bytes': [73], 'logprob': -0.26593843, 'top_logprobs': []}]
[{'token': 'I', 'bytes': [73], 'logprob': -0.26593843, 'top_logprobs': []}, {'token': "'m", 'bytes': [39, 109], 'logprob': -0.3238896, 'top_logprobs': []}]
[{'token': 'I', 'bytes': [73], 'logprob': -0.26593843, 'top_logprobs': []}, {'token': "'m", 'bytes': [39, 109], 'logprob': -0.3238896, 'top_logprobs': []}, {'token': ' just', 'bytes': [32, 106, 117, 115, 116], 'logprob': -0.23778509, 'top_logprobs': []}]
[{'token': 'I', 'bytes': [73], 'logprob': -0.26593843, 'top_logprobs': []}, {'token': "'m", 'bytes': [39, 109], 'logprob': -0.3238896, 'top_logprobs': []}, {'token': ' just', 'bytes': [32, 106, 117, 115, 116], 'logprob': -0.23778509, 'top_logprobs': []}, {'token': ' a', 'bytes': [32, 97], 'logprob': -0.0022134194, 'top_logprobs': []}]
```


## 다음 단계

이제 LangChain에서 OpenAI 모델의 로그 확률을 가져오는 방법을 배웠습니다.

다음으로, 이 섹션의 다른 채팅 모델에 대한 사용 방법 가이드를 확인하세요. 예를 들어 [모델이 구조화된 출력을 반환하도록 하는 방법](/docs/how_to/structured_output) 또는 [토큰 사용량 추적하는 방법](/docs/how_to/chat_token_usage_tracking).
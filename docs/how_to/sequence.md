---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/sequence.ipynb
description: 이 문서는 LangChain에서 런너블을 체인으로 연결하는 방법을 설명하며, 기본 개념과 사용법을 안내합니다.
keywords:
- Runnable
- Runnables
- RunnableSequence
- LCEL
- chain
- chains
- chaining
---

# 어떻게 실행 가능한 것들을 연결하는가

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [채팅 모델](/docs/concepts/#chat-models)
- [출력 파서](/docs/concepts/#output-parsers)

:::

[LangChain 표현 언어](/docs/concepts/#langchain-expression-language)에 대한 한 가지 점은 두 개의 실행 가능한 것들이 "연결"되어 순서대로 실행될 수 있다는 것입니다. 이전 실행 가능한 것의 `.invoke()` 호출의 출력이 다음 실행 가능한 것의 입력으로 전달됩니다. 이는 파이프 연산자(`|`)를 사용하거나, 동일한 작업을 수행하는 보다 명시적인 `.pipe()` 메서드를 사용하여 수행할 수 있습니다.

결과적으로 생성된 [`RunnableSequence`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableSequence.html)는 자체적으로 실행 가능하므로, 다른 실행 가능한 것처럼 호출되거나 스트리밍되거나 추가로 연결될 수 있습니다. 이러한 방식으로 실행 가능한 것들을 연결하는 장점은 효율적인 스트리밍(시퀀스는 출력이 사용 가능해지자마자 스트리밍됨)과 [LangSmith](/docs/how_to/debugging)와 같은 도구를 사용한 디버깅 및 추적입니다.

## 파이프 연산자: `|`

이것이 어떻게 작동하는지 보여주기 위해, 예제를 살펴보겠습니다. 우리는 LangChain에서의 일반적인 패턴을 살펴볼 것입니다: [프롬프트 템플릿](/docs/how_to#prompt-templates)을 사용하여 입력을 [채팅 모델](/docs/how_to#chat-models)로 형식화하고, 마지막으로 채팅 메시지 출력을 문자열로 변환하는 [출력 파서](/docs/how_to#output-parsers)를 사용하는 것입니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="model"
/>

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to chain runnables"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to chain runnables"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("tell me a joke about {topic}")

chain = prompt | model | StrOutputParser()
```


프롬프트와 모델은 모두 실행 가능하며, 프롬프트 호출의 출력 유형은 채팅 모델의 입력 유형과 동일하므로 이를 연결할 수 있습니다. 그런 다음 결과 시퀀스를 다른 실행 가능한 것처럼 호출할 수 있습니다:

```python
chain.invoke({"topic": "bears"})
```


```output
"Here's a bear joke for you:\n\nWhy did the bear dissolve in water?\nBecause it was a polar bear!"
```


### 강제 변환

우리는 이 체인을 더 많은 실행 가능한 것들과 결합하여 또 다른 체인을 만들 수도 있습니다. 이는 체인 구성 요소의 필요한 입력 및 출력에 따라 다른 유형의 실행 가능한 것을 사용하여 일부 입력/출력 형식을 조정해야 할 수 있습니다.

예를 들어, 생성된 농담이 재미있는지 평가하는 또 다른 체인과 농담 생성 체인을 구성하고 싶다고 가정해 보겠습니다.

다음 체인으로의 입력 형식을 조정하는 데 주의해야 합니다. 아래 예제에서 체인의 dict는 자동으로 파싱되고 [`RunnableParallel`](/docs/how_to/parallel)로 변환되며, 이는 모든 값을 병렬로 실행하고 결과와 함께 dict를 반환합니다.

이는 다음 프롬프트 템플릿이 기대하는 동일한 형식입니다. 여기서 작동하는 모습입니다:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to chain runnables"}]-->
from langchain_core.output_parsers import StrOutputParser

analysis_prompt = ChatPromptTemplate.from_template("is this a funny joke? {joke}")

composed_chain = {"joke": chain} | analysis_prompt | model | StrOutputParser()

composed_chain.invoke({"topic": "bears"})
```


```output
'Haha, that\'s a clever play on words! Using "polar" to imply the bear dissolved or became polar/polarized when put in water. Not the most hilarious joke ever, but it has a cute, groan-worthy pun that makes it mildly amusing. I appreciate a good pun or wordplay joke.'
```


함수도 실행 가능하게 강제 변환되므로, 체인에 사용자 정의 논리를 추가할 수 있습니다. 아래 체인은 이전과 동일한 논리 흐름을 생성합니다:

```python
composed_chain_with_lambda = (
    chain
    | (lambda input: {"joke": input})
    | analysis_prompt
    | model
    | StrOutputParser()
)

composed_chain_with_lambda.invoke({"topic": "beets"})
```


```output
"Haha, that's a cute and punny joke! I like how it plays on the idea of beets blushing or turning red like someone blushing. Food puns can be quite amusing. While not a total knee-slapper, it's a light-hearted, groan-worthy dad joke that would make me chuckle and shake my head. Simple vegetable humor!"
```


그러나 이렇게 함수를 사용하는 것은 스트리밍과 같은 작업에 영향을 줄 수 있습니다. 더 많은 정보는 [이 섹션](/docs/how_to/functions)을 참조하십시오.

## `.pipe()` 메서드

우리는 `.pipe()` 메서드를 사용하여 동일한 시퀀스를 구성할 수도 있습니다. 그 모습은 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "How to chain runnables"}]-->
from langchain_core.runnables import RunnableParallel

composed_chain_with_pipe = (
    RunnableParallel({"joke": chain})
    .pipe(analysis_prompt)
    .pipe(model)
    .pipe(StrOutputParser())
)

composed_chain_with_pipe.invoke({"topic": "battlestar galactica"})
```


```output
"I cannot reproduce any copyrighted material verbatim, but I can try to analyze the humor in the joke you provided without quoting it directly.\n\nThe joke plays on the idea that the Cylon raiders, who are the antagonists in the Battlestar Galactica universe, failed to locate the human survivors after attacking their home planets (the Twelve Colonies) due to using an outdated and poorly performing operating system (Windows Vista) for their targeting systems.\n\nThe humor stems from the juxtaposition of a futuristic science fiction setting with a relatable real-world frustration – the use of buggy, slow, or unreliable software or technology. It pokes fun at the perceived inadequacies of Windows Vista, which was widely criticized for its performance issues and other problems when it was released.\n\nBy attributing the Cylons' failure to locate the humans to their use of Vista, the joke creates an amusing and unexpected connection between a fictional advanced race of robots and a familiar technological annoyance experienced by many people in the real world.\n\nOverall, the joke relies on incongruity and relatability to generate humor, but without reproducing any copyrighted material directly."
```


또는 축약된 형태로:

```python
composed_chain_with_pipe = RunnableParallel({"joke": chain}).pipe(
    analysis_prompt, model, StrOutputParser()
)
```


## 관련

- [스트리밍](/docs/how_to/streaming/): 체인의 스트리밍 동작을 이해하기 위해 스트리밍 가이드를 확인하십시오.
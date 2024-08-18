---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/streaming.ipynb
description: 이 문서는 LLM 기반 애플리케이션의 반응성을 높이기 위한 스트리밍 실행 방법과 LangChain의 런너블 인터페이스를 설명합니다.
keywords:
- stream
---

# 실행 가능한 스트리밍 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [LangChain 표현 언어](/docs/concepts/#langchain-expression-language)
- [출력 파서](/docs/concepts/#output-parsers)

:::

스트리밍은 LLM 기반 애플리케이션이 최종 사용자에게 반응하는 느낌을 주는 데 중요합니다.

[채팅 모델](/docs/concepts/#chat-models), [출력 파서](/docs/concepts/#output-parsers), [프롬프트](/docs/concepts/#prompt-templates), [검색기](/docs/concepts/#retrievers), [에이전트](/docs/concepts/#agents)와 같은 중요한 LangChain 기본 요소들은 LangChain [Runnable 인터페이스](/docs/concepts#interface)를 구현합니다.

이 인터페이스는 콘텐츠를 스트리밍하는 두 가지 일반적인 접근 방식을 제공합니다:

1. 동기 `stream` 및 비동기 `astream`: 체인에서 **최종 출력**을 스트리밍하는 **기본 구현**입니다.
2. 비동기 `astream_events` 및 비동기 `astream_log`: 이들은 체인에서 **중간 단계**와 **최종 출력**을 모두 스트리밍하는 방법을 제공합니다.

두 가지 접근 방식을 살펴보고 이를 사용하는 방법을 이해해 보겠습니다.

:::info
LangChain의 스트리밍 기술에 대한 더 높은 수준의 개요는 [개념 가이드의 이 섹션](/docs/concepts/#streaming)을 참조하십시오.
:::

## 스트림 사용하기

모든 `Runnable` 객체는 `stream`이라는 동기 메서드와 `astream`이라는 비동기 변형을 구현합니다.

이 메서드는 최종 출력을 청크로 스트리밍하도록 설계되었으며, 각 청크가 사용 가능해지는 즉시 이를 반환합니다.

스트리밍은 프로그램의 모든 단계가 **입력 스트림**을 처리하는 방법을 알고 있을 때만 가능합니다; 즉, 입력 청크를 하나씩 처리하고 해당 출력 청크를 반환해야 합니다.

이 처리의 복잡성은 LLM이 생성한 토큰을 방출하는 것과 같은 간단한 작업에서부터 전체 JSON이 완료되기 전에 JSON 결과의 일부를 스트리밍하는 것과 같은 더 도전적인 작업까지 다양할 수 있습니다.

스트리밍을 탐색하기 시작하는 가장 좋은 장소는 LLM 애플리케이션에서 가장 중요한 구성 요소인 LLM 자체입니다!

### LLM 및 채팅 모델

대형 언어 모델과 그 채팅 변형은 LLM 기반 애플리케이션의 주요 병목 현상입니다.

대형 언어 모델은 쿼리에 대한 완전한 응답을 생성하는 데 **수 초**가 걸릴 수 있습니다. 이는 애플리케이션이 최종 사용자에게 반응하는 느낌을 주는 **~200-300 ms** 임계값보다 훨씬 느립니다.

애플리케이션이 더 반응적으로 느껴지도록 하는 핵심 전략은 중간 진행 상황을 보여주는 것입니다; 즉, 모델의 출력을 **토큰 단위로** 스트리밍하는 것입니다.

채팅 모델을 사용하여 스트리밍 예제를 보여드리겠습니다. 아래 옵션 중 하나를 선택하세요:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="model"
/>

동기 `stream` API부터 시작해 보겠습니다:

```python
chunks = []
for chunk in model.stream("what color is the sky?"):
    chunks.append(chunk)
    print(chunk.content, end="|", flush=True)
```

```output
The| sky| appears| blue| during| the| day|.|
```

대안으로 비동기 환경에서 작업하는 경우 비동기 `astream` API를 사용하는 것을 고려할 수 있습니다:

```python
chunks = []
async for chunk in model.astream("what color is the sky?"):
    chunks.append(chunk)
    print(chunk.content, end="|", flush=True)
```

```output
The| sky| appears| blue| during| the| day|.|
```

청크 중 하나를 살펴보겠습니다

```python
chunks[0]
```


```output
AIMessageChunk(content='The', id='run-b36bea64-5511-4d7a-b6a3-a07b3db0c8e7')
```


우리는 `AIMessageChunk`라는 것을 받았습니다. 이 청크는 `AIMessage`의 일부를 나타냅니다.

메시지 청크는 설계상 추가적입니다 -- 단순히 더하여 지금까지의 응답 상태를 얻을 수 있습니다!

```python
chunks[0] + chunks[1] + chunks[2] + chunks[3] + chunks[4]
```


```output
AIMessageChunk(content='The sky appears blue during', id='run-b36bea64-5511-4d7a-b6a3-a07b3db0c8e7')
```


### 체인

사실상 모든 LLM 애플리케이션은 언어 모델에 대한 호출 이상의 단계를 포함합니다.

프롬프트, 모델 및 파서를 결합하여 스트리밍이 작동하는지 확인하는 간단한 체인을 `LangChain 표현 언어`(`LCEL`)를 사용하여 구축해 보겠습니다.

우리는 [`StrOutputParser`](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html)를 사용하여 모델의 출력을 파싱할 것입니다. 이는 `AIMessageChunk`에서 `content` 필드를 추출하여 모델이 반환한 `token`을 제공합니다.

:::tip
LCEL은 다양한 LangChain 기본 요소를 연결하여 "프로그램"을 지정하는 *선언적* 방법입니다. LCEL을 사용하여 생성된 체인은 최종 출출의 스트리밍을 허용하는 `stream` 및 `astream`의 자동 구현의 이점을 누립니다. 실제로 LCEL로 생성된 체인은 전체 표준 Runnable 인터페이스를 구현합니다.
:::

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to stream runnables"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to stream runnables"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("tell me a joke about {topic}")
parser = StrOutputParser()
chain = prompt | model | parser

async for chunk in chain.astream({"topic": "parrot"}):
    print(chunk, end="|", flush=True)
```

```output
Here|'s| a| joke| about| a| par|rot|:|

A man| goes| to| a| pet| shop| to| buy| a| par|rot|.| The| shop| owner| shows| him| two| stunning| pa|rr|ots| with| beautiful| pl|um|age|.|

"|There|'s| a| talking| par|rot| an|d a| non|-|talking| par|rot|,"| the| owner| says|.| "|The| talking| par|rot| costs| $|100|,| an|d the| non|-|talking| par|rot| is| $|20|."|

The| man| says|,| "|I|'ll| take| the| non|-|talking| par|rot| at| $|20|."|

He| pays| an|d leaves| with| the| par|rot|.| As| he|'s| walking| down| the| street|,| the| par|rot| looks| up| at| him| an|d says|,| "|You| know|,| you| really| are| a| stupi|d man|!"|

The| man| is| stun|ne|d an|d looks| at| the| par|rot| in| dis|bel|ief|.| The| par|rot| continues|,| "|Yes|,| you| got| r|ippe|d off| big| time|!| I| can| talk| just| as| well| as| that| other| par|rot|,| an|d you| only| pai|d $|20| |for| me|!"|
```

위의 체인 끝에서 `parser`를 사용하고 있음에도 불구하고 스트리밍 출력을 받고 있다는 점에 유의하십시오. `parser`는 각 스트리밍 청크를 개별적으로 처리합니다. 많은 [LCEL 기본 요소](/docs/how_to#langchain-expression-language-lcel)도 이러한 변환 스타일의 통과 스트리밍을 지원하며, 이는 애플리케이션을 구성할 때 매우 편리할 수 있습니다.

사용자 정의 함수는 [제너레이터를 반환하도록 설계될 수 있습니다](/docs/how_to/functions#streaming), 이는 스트림에서 작동할 수 있습니다.

일부 실행 가능 요소, 예를 들어 [프롬프트 템플릿](/docs/how_to#prompt-templates) 및 [채팅 모델](/docs/how_to#chat-models)은 개별 청크를 처리할 수 없으며 대신 모든 이전 단계를 집계합니다. 이러한 실행 가능 요소는 스트리밍 프로세스를 중단할 수 있습니다.

:::note
LangChain 표현 언어는 체인의 구성과 사용 모드(예: 동기/비동기, 배치/스트리밍 등)를 분리할 수 있습니다. 이것이 당신이 구축하는 것과 관련이 없다면, 각 구성 요소에 대해 `invoke`, `batch` 또는 `stream`을 호출하여 표준 **명령형** 프로그래밍 접근 방식을 사용할 수 있으며, 결과를 변수에 할당한 다음 필요에 따라 하류에서 사용할 수 있습니다.
:::

### 입력 스트림 작업하기

출력이 생성되는 동안 JSON을 스트리밍하고 싶다면 어떻게 해야 할까요?

`json.loads`를 사용하여 부분 JSON을 파싱하려고 하면, 부분 JSON이 유효한 JSON이 아니기 때문에 파싱이 실패할 것입니다.

당신은 아마도 무엇을 해야 할지 완전히 막막해질 것이며 JSON을 스트리밍하는 것이 불가능하다고 주장할 것입니다.

하지만, 방법이 있습니다 -- 파서는 **입력 스트림**에서 작동해야 하며, 부분 JSON을 유효한 상태로 "자동 완성"하려고 시도해야 합니다.

이것이 의미하는 바를 이해하기 위해 이러한 파서를 실제로 살펴보겠습니다.

```python
<!--IMPORTS:[{"imported": "JsonOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html", "title": "How to stream runnables"}]-->
from langchain_core.output_parsers import JsonOutputParser

chain = (
    model | JsonOutputParser()
)  # Due to a bug in older versions of Langchain, JsonOutputParser did not stream results from some models
async for text in chain.astream(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`"
):
    print(text, flush=True)
```

```output
{}
{'countries': []}
{'countries': [{}]}
{'countries': [{'name': ''}]}
{'countries': [{'name': 'France'}]}
{'countries': [{'name': 'France', 'population': 67}]}
{'countries': [{'name': 'France', 'population': 67413}]}
{'countries': [{'name': 'France', 'population': 67413000}]}
{'countries': [{'name': 'France', 'population': 67413000}, {}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': ''}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain'}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}, {}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}, {'name': ''}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}, {'name': 'Japan'}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}, {'name': 'Japan', 'population': 125}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}, {'name': 'Japan', 'population': 125584}]}
{'countries': [{'name': 'France', 'population': 67413000}, {'name': 'Spain', 'population': 47351567}, {'name': 'Japan', 'population': 125584000}]}
```

이제 스트리밍을 **중단**해 보겠습니다. 이전 예제를 사용하고 최종 JSON에서 국가 이름을 추출하는 함수를 끝에 추가하겠습니다.

:::warning
체인에서 **최종화된 입력**에서 작동하는 모든 단계는 `stream` 또는 `astream`을 통해 스트리밍 기능을 중단할 수 있습니다.
:::

:::tip
나중에 중간 단계에서 결과를 스트리밍하는 `astream_events` API에 대해 논의할 것입니다. 이 API는 체인에 **최종화된 입력**에서만 작동하는 단계가 포함되어 있더라도 중간 단계에서 결과를 스트리밍합니다.
:::

```python
<!--IMPORTS:[{"imported": "JsonOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html", "title": "How to stream runnables"}]-->
from langchain_core.output_parsers import (
    JsonOutputParser,
)


# A function that operates on finalized inputs
# rather than on an input_stream
def _extract_country_names(inputs):
    """A function that does not operates on input streams and breaks streaming."""
    if not isinstance(inputs, dict):
        return ""

    if "countries" not in inputs:
        return ""

    countries = inputs["countries"]

    if not isinstance(countries, list):
        return ""

    country_names = [
        country.get("name") for country in countries if isinstance(country, dict)
    ]
    return country_names


chain = model | JsonOutputParser() | _extract_country_names

async for text in chain.astream(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`"
):
    print(text, end="|", flush=True)
```

```output
['France', 'Spain', 'Japan']|
```

#### 제너레이터 함수

입력 스트림에서 작동할 수 있는 제너레이터 함수를 사용하여 스트리밍을 수정해 보겠습니다.

:::tip
제너레이터 함수(즉, `yield`를 사용하는 함수)는 **입력 스트림**에서 작동하는 코드를 작성할 수 있게 해줍니다.
:::

```python
<!--IMPORTS:[{"imported": "JsonOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html", "title": "How to stream runnables"}]-->
from langchain_core.output_parsers import JsonOutputParser


async def _extract_country_names_streaming(input_stream):
    """A function that operates on input streams."""
    country_names_so_far = set()

    async for input in input_stream:
        if not isinstance(input, dict):
            continue

        if "countries" not in input:
            continue

        countries = input["countries"]

        if not isinstance(countries, list):
            continue

        for country in countries:
            name = country.get("name")
            if not name:
                continue
            if name not in country_names_so_far:
                yield name
                country_names_so_far.add(name)


chain = model | JsonOutputParser() | _extract_country_names_streaming

async for text in chain.astream(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`",
):
    print(text, end="|", flush=True)
```

```output
France|Spain|Japan|
```

:::note
위의 코드는 JSON 자동 완성에 의존하고 있기 때문에 국가의 부분 이름(예: `Sp`와 `Spain`)이 표시될 수 있으며, 이는 추출 결과로 원하는 것이 아닙니다!

우리는 스트리밍 개념에 집중하고 있으며, 체인의 결과는 반드시 포함되지 않습니다.
:::

### 비스트리밍 구성 요소

검색기와 같은 일부 내장 구성 요소는 `스트리밍`을 제공하지 않습니다. 이들을 `stream`하려고 하면 어떻게 될까요? 🤨

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to stream runnables"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to stream runnables"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to stream runnables"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to stream runnables"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to stream runnables"}]-->
from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import OpenAIEmbeddings

template = """Answer the question based only on the following context:
{context}

Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

vectorstore = FAISS.from_texts(
    ["harrison worked at kensho", "harrison likes spicy food"],
    embedding=OpenAIEmbeddings(),
)
retriever = vectorstore.as_retriever()

chunks = [chunk for chunk in retriever.stream("where did harrison work?")]
chunks
```


```output
[[Document(page_content='harrison worked at kensho'),
  Document(page_content='harrison likes spicy food')]]
```


스트림은 해당 구성 요소에서 최종 결과를 반환했습니다.

괜찮습니다 🥹! 모든 구성 요소가 스트리밍을 구현해야 하는 것은 아닙니다 -- 경우에 따라 스트리밍은 불필요하거나 어렵거나 그저 의미가 없을 수 있습니다.

:::tip
비스트리밍 구성 요소를 사용하여 구성된 LCEL 체인은 여전히 많은 경우에 스트리밍할 수 있으며, 체인에서 마지막 비스트리밍 단계 이후에 부분 출력을 스트리밍하기 시작합니다.
:::

```python
retrieval_chain = (
    {
        "context": retriever.with_config(run_name="Docs"),
        "question": RunnablePassthrough(),
    }
    | prompt
    | model
    | StrOutputParser()
)
```


```python
for chunk in retrieval_chain.stream(
    "Where did harrison work? " "Write 3 made up sentences about this place."
):
    print(chunk, end="|", flush=True)
```

```output
Base|d on| the| given| context|,| Harrison| worke|d at| K|ens|ho|.|

Here| are| |3| |made| up| sentences| about| this| place|:|

1|.| K|ens|ho| was| a| cutting|-|edge| technology| company| known| for| its| innovative| solutions| in| artificial| intelligence| an|d data| analytics|.|

2|.| The| modern| office| space| at| K|ens|ho| feature|d open| floor| plans|,| collaborative| work|sp|aces|,| an|d a| vib|rant| atmosphere| that| fos|tere|d creativity| an|d team|work|.|

3|.| With| its| prime| location| in| the| heart| of| the| city|,| K|ens|ho| attracte|d top| talent| from| aroun|d the| worl|d,| creating| a| diverse| an|d dynamic| work| environment|.|
```

이제 `stream`과 `astream`이 어떻게 작동하는지 살펴보았으니, 스트리밍 이벤트의 세계로 나아가 보겠습니다. 🏞️

## 스트림 이벤트 사용하기

이벤트 스트리밍은 **베타** API입니다. 이 API는 피드백에 따라 약간 변경될 수 있습니다.

:::note

이 가이드는 `V2` API를 보여주며 langchain-core >= 0.2가 필요합니다. 이전 버전의 LangChain과 호환되는 `V1` API는 [여기](https://python.langchain.com/v0.1/docs/expression_language/streaming/#using-stream-events)를 참조하십시오.
:::

```python
import langchain_core

langchain_core.__version__
```


`astream_events` API가 제대로 작동하려면:

* 가능한 한 코드 전반에 걸쳐 `async`를 사용하십시오 (예: 비동기 도구 등)
* 사용자 정의 함수/실행 가능 요소를 정의할 경우 콜백을 전파하십시오.
* LCEL 없이 실행 가능 요소를 사용할 때는 LLM에서 `.ainvoke` 대신 `.astream()`을 호출하여 LLM이 토큰을 스트리밍하도록 강제하십시오.
* 예상대로 작동하지 않는 것이 있다면 알려주세요! :)

### 이벤트 참조

아래는 다양한 Runnable 객체에서 발생할 수 있는 몇 가지 이벤트를 보여주는 참조 표입니다.

:::note
스트리밍이 제대로 구현되면, 실행 가능 요소에 대한 입력은 입력 스트림이 완전히 소모된 후에만 알려집니다. 이는 `inputs`가 종종 `end` 이벤트에만 포함되고 `start` 이벤트에는 포함되지 않음을 의미합니다.
:::

| 이벤트                | 이름             | 청크                           | 입력                                         | 출력                                          |
|----------------------|------------------|---------------------------------|-----------------------------------------------|-------------------------------------------------|
| on_chat_model_start  | [모델 이름]     |                                 | {"messages": [[SystemMessage, HumanMessage]]} |                                                 |
| on_chat_model_stream | [모델 이름]     | AIMessageChunk(content="hello") |                                               |                                                 |
| on_chat_model_end    | [모델 이름]     |                                 | {"messages": [[SystemMessage, HumanMessage]]} | AIMessageChunk(content="hello world")           |
| on_llm_start         | [모델 이름]     |                                 | {'input': 'hello'}                            |                                                 |
| on_llm_stream        | [모델 이름]     | 'Hello'                         |                                               |                                                 |
| on_llm_end           | [모델 이름]     |                                 | 'Hello human!'                                |                                                 |
| on_chain_start       | format_docs      |                                 |                                               |                                                 |
| on_chain_stream      | format_docs      | "hello world!, goodbye world!"  |                                               |                                                 |
| on_chain_end         | format_docs      |                                 | [Document(...)]                               | "hello world!, goodbye world!"                  |
| on_tool_start        | some_tool        |                                 | {"x": 1, "y": "2"}                            |                                                 |
| on_tool_end          | some_tool        |                                 |                                               | {"x": 1, "y": "2"}                              |
| on_retriever_start   | [retriever name] |                                 | {"query": "hello"}                            |                                                 |
| on_retriever_end     | [retriever name] |                                 | {"query": "hello"}                            | [Document(...), ..]                             |
| on_prompt_start      | [template_name]  |                                 | {"question": "hello"}                         |                                                 |
| on_prompt_end        | [template_name]  |                                 | {"question": "hello"}                         | ChatPromptValue(messages: [SystemMessage, ...]) |

### 채팅 모델

채팅 모델에서 생성된 이벤트를 살펴보겠습니다.

```python
events = []
async for event in model.astream_events("hello", version="v2"):
    events.append(event)
```

```output
/home/eugene/src/langchain/libs/core/langchain_core/_api/beta_decorator.py:87: LangChainBetaWarning: This API is in beta and may change in the future.
  warn_beta(
```

:::note

API의 그 재미있는 version="v2" 매개변수는 무엇인가요?! 😾

이것은 **베타 API**이며, 우리는 거의 확실히 이를 변경할 것입니다 (사실, 이미 변경했습니다!)

이 버전 매개변수는 코드에 대한 이러한 파괴적인 변경을 최소화할 수 있게 해줍니다.

간단히 말해, 우리는 지금 당신을 귀찮게 하고 있으므로, 나중에 귀찮게 하지 않기 위해서입니다.

`v2`는 langchain-core>=0.2.0에서만 사용할 수 있습니다.

:::

시작 이벤트 몇 개와 종료 이벤트 몇 개를 살펴보겠습니다.

```python
events[:3]
```


```output
[{'event': 'on_chat_model_start',
  'data': {'input': 'hello'},
  'name': 'ChatAnthropic',
  'tags': [],
  'run_id': 'a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3',
  'metadata': {}},
 {'event': 'on_chat_model_stream',
  'data': {'chunk': AIMessageChunk(content='Hello', id='run-a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3')},
  'run_id': 'a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3',
  'name': 'ChatAnthropic',
  'tags': [],
  'metadata': {}},
 {'event': 'on_chat_model_stream',
  'data': {'chunk': AIMessageChunk(content='!', id='run-a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3')},
  'run_id': 'a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3',
  'name': 'ChatAnthropic',
  'tags': [],
  'metadata': {}}]
```


```python
events[-2:]
```


```output
[{'event': 'on_chat_model_stream',
  'data': {'chunk': AIMessageChunk(content='?', id='run-a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3')},
  'run_id': 'a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3',
  'name': 'ChatAnthropic',
  'tags': [],
  'metadata': {}},
 {'event': 'on_chat_model_end',
  'data': {'output': AIMessageChunk(content='Hello! How can I assist you today?', id='run-a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3')},
  'run_id': 'a81e4c0f-fc36-4d33-93bc-1ac25b9bb2c3',
  'name': 'ChatAnthropic',
  'tags': [],
  'metadata': {}}]
```


### 체인

스트리밍 JSON을 파싱한 예제 체인으로 돌아가 스트리밍 이벤트 API를 탐색해 보겠습니다.

```python
chain = (
    model | JsonOutputParser()
)  # Due to a bug in older versions of Langchain, JsonOutputParser did not stream results from some models

events = [
    event
    async for event in chain.astream_events(
        "output a list of the countries france, spain and japan and their populations in JSON format. "
        'Use a dict with an outer key of "countries" which contains a list of countries. '
        "Each country should have the key `name` and `population`",
        version="v2",
    )
]
```


처음 몇 개의 이벤트를 살펴보면, **2**개의 시작 이벤트가 아닌 **3**개의 시작 이벤트가 있다는 것을 알 수 있습니다.

세 개의 시작 이벤트는 다음에 해당합니다:

1. 체인 (모델 + 파서)
2. 모델
3. 파서

```python
events[:3]
```


```output
[{'event': 'on_chain_start',
  'data': {'input': 'output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`'},
  'name': 'RunnableSequence',
  'tags': [],
  'run_id': '4765006b-16e2-4b1d-a523-edd9fd64cb92',
  'metadata': {}},
 {'event': 'on_chat_model_start',
  'data': {'input': {'messages': [[HumanMessage(content='output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`')]]}},
  'name': 'ChatAnthropic',
  'tags': ['seq:step:1'],
  'run_id': '0320c234-7b52-4a14-ae4e-5f100949e589',
  'metadata': {}},
 {'event': 'on_chat_model_stream',
  'data': {'chunk': AIMessageChunk(content='{', id='run-0320c234-7b52-4a14-ae4e-5f100949e589')},
  'run_id': '0320c234-7b52-4a14-ae4e-5f100949e589',
  'name': 'ChatAnthropic',
  'tags': ['seq:step:1'],
  'metadata': {}}]
```


마지막 3개의 이벤트를 살펴보면 무엇을 보게 될까요? 중간은 어떨까요?

이 API를 사용하여 모델과 파서의 스트림 이벤트 출력을 가져오겠습니다. 우리는 시작 이벤트, 종료 이벤트 및 체인에서의 이벤트는 무시하고 있습니다.

```python
num_events = 0

async for event in chain.astream_events(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`",
    version="v2",
):
    kind = event["event"]
    if kind == "on_chat_model_stream":
        print(
            f"Chat model chunk: {repr(event['data']['chunk'].content)}",
            flush=True,
        )
    if kind == "on_parser_stream":
        print(f"Parser chunk: {event['data']['chunk']}", flush=True)
    num_events += 1
    if num_events > 30:
        # Truncate the output
        print("...")
        break
```

```output
Chat model chunk: '{'
Parser chunk: {}
Chat model chunk: '\n  '
Chat model chunk: '"'
Chat model chunk: 'countries'
Chat model chunk: '":'
Chat model chunk: ' ['
Parser chunk: {'countries': []}
Chat model chunk: '\n    '
Chat model chunk: '{'
Parser chunk: {'countries': [{}]}
Chat model chunk: '\n      '
Chat model chunk: '"'
Chat model chunk: 'name'
Chat model chunk: '":'
Chat model chunk: ' "'
Parser chunk: {'countries': [{'name': ''}]}
Chat model chunk: 'France'
Parser chunk: {'countries': [{'name': 'France'}]}
Chat model chunk: '",'
Chat model chunk: '\n      '
Chat model chunk: '"'
Chat model chunk: 'population'
...
```

모델과 파서 모두 스트리밍을 지원하므로, 두 구성 요소에서 실시간으로 스트리밍 이벤트를 볼 수 있습니다! 멋지지 않나요? 🦜

### 이벤트 필터링

이 API는 많은 이벤트를 생성하므로, 이벤트를 필터링할 수 있는 기능이 유용합니다.

구성 요소 `name`, 구성 요소 `tags` 또는 구성 요소 `type`으로 필터링할 수 있습니다.

#### 이름으로 필터링

```python
chain = model.with_config({"run_name": "model"}) | JsonOutputParser().with_config(
    {"run_name": "my_parser"}
)

max_events = 0
async for event in chain.astream_events(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`",
    version="v2",
    include_names=["my_parser"],
):
    print(event)
    max_events += 1
    if max_events > 10:
        # Truncate output
        print("...")
        break
```

```output
{'event': 'on_parser_start', 'data': {'input': 'output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`'}, 'name': 'my_parser', 'tags': ['seq:step:2'], 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': []}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': ''}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': 'France'}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': 'France', 'population': 67}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': 'France', 'population': 67413}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': 'France', 'population': 67413000}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': 'France', 'population': 67413000}, {}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {'countries': [{'name': 'France', 'population': 67413000}, {'name': ''}]}}, 'run_id': 'e058d750-f2c2-40f6-aa61-10f84cd671a9', 'name': 'my_parser', 'tags': ['seq:step:2'], 'metadata': {}}
...
```

#### 유형으로 필터링

```python
chain = model.with_config({"run_name": "model"}) | JsonOutputParser().with_config(
    {"run_name": "my_parser"}
)

max_events = 0
async for event in chain.astream_events(
    'output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`',
    version="v2",
    include_types=["chat_model"],
):
    print(event)
    max_events += 1
    if max_events > 10:
        # Truncate output
        print("...")
        break
```

```output
{'event': 'on_chat_model_start', 'data': {'input': 'output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`'}, 'name': 'model', 'tags': ['seq:step:1'], 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='{', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='\n  ', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='"', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='countries', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='":', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' [', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='\n    ', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='{', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='\n      ', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='"', id='run-db246792-2a91-4eb3-a14b-29658947065d')}, 'run_id': 'db246792-2a91-4eb3-a14b-29658947065d', 'name': 'model', 'tags': ['seq:step:1'], 'metadata': {}}
...
```

#### 태그로 필터링

:::caution

태그는 주어진 실행 가능 요소의 자식 구성 요소에 의해 상속됩니다.

필터링에 태그를 사용하는 경우, 이것이 당신이 원하는 것인지 확인하십시오.
:::

```python
chain = (model | JsonOutputParser()).with_config({"tags": ["my_chain"]})

max_events = 0
async for event in chain.astream_events(
    'output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`',
    version="v2",
    include_tags=["my_chain"],
):
    print(event)
    max_events += 1
    if max_events > 10:
        # Truncate output
        print("...")
        break
```

```output
{'event': 'on_chain_start', 'data': {'input': 'output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`'}, 'name': 'RunnableSequence', 'tags': ['my_chain'], 'run_id': 'fd68dd64-7a4d-4bdb-a0c2-ee592db0d024', 'metadata': {}}
{'event': 'on_chat_model_start', 'data': {'input': {'messages': [[HumanMessage(content='output a list of the countries france, spain and japan and their populations in JSON format. Use a dict with an outer key of "countries" which contains a list of countries. Each country should have the key `name` and `population`')]]}}, 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='{', id='run-efd3c8af-4be5-4f6c-9327-e3f9865dd1cd')}, 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'metadata': {}}
{'event': 'on_parser_start', 'data': {}, 'name': 'JsonOutputParser', 'tags': ['seq:step:2', 'my_chain'], 'run_id': 'afde30b9-beac-4b36-b4c7-dbbe423ddcdb', 'metadata': {}}
{'event': 'on_parser_stream', 'data': {'chunk': {}}, 'run_id': 'afde30b9-beac-4b36-b4c7-dbbe423ddcdb', 'name': 'JsonOutputParser', 'tags': ['seq:step:2', 'my_chain'], 'metadata': {}}
{'event': 'on_chain_stream', 'data': {'chunk': {}}, 'run_id': 'fd68dd64-7a4d-4bdb-a0c2-ee592db0d024', 'name': 'RunnableSequence', 'tags': ['my_chain'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='\n  ', id='run-efd3c8af-4be5-4f6c-9327-e3f9865dd1cd')}, 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='"', id='run-efd3c8af-4be5-4f6c-9327-e3f9865dd1cd')}, 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='countries', id='run-efd3c8af-4be5-4f6c-9327-e3f9865dd1cd')}, 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='":', id='run-efd3c8af-4be5-4f6c-9327-e3f9865dd1cd')}, 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'metadata': {}}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' [', id='run-efd3c8af-4be5-4f6c-9327-e3f9865dd1cd')}, 'run_id': 'efd3c8af-4be5-4f6c-9327-e3f9865dd1cd', 'name': 'ChatAnthropic', 'tags': ['seq:step:1', 'my_chain'], 'metadata': {}}
...
```

### 비스트리밍 컴포넌트

일부 컴포넌트가 **입력 스트림**에서 작동하지 않기 때문에 스트리밍이 잘 되지 않는다는 것을 기억하나요?

이러한 컴포넌트는 `astream`을 사용할 때 최종 출력의 스트리밍을 중단할 수 있지만, `astream_events`는 여전히 스트리밍을 지원하는 중간 단계에서 스트리밍 이벤트를 생성합니다!

```python
# Function that does not support streaming.
# It operates on the finalizes inputs rather than
# operating on the input stream.
def _extract_country_names(inputs):
    """A function that does not operates on input streams and breaks streaming."""
    if not isinstance(inputs, dict):
        return ""

    if "countries" not in inputs:
        return ""

    countries = inputs["countries"]

    if not isinstance(countries, list):
        return ""

    country_names = [
        country.get("name") for country in countries if isinstance(country, dict)
    ]
    return country_names


chain = (
    model | JsonOutputParser() | _extract_country_names
)  # This parser only works with OpenAI right now
```


예상대로, `_extract_country_names`가 스트림에서 작동하지 않기 때문에 `astream` API는 제대로 작동하지 않습니다.

```python
async for chunk in chain.astream(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`",
):
    print(chunk, flush=True)
```

```output
['France', 'Spain', 'Japan']
```

이제, `astream_events`를 사용하여 모델과 파서에서 여전히 스트리밍 출력을 보고 있는지 확인해 봅시다.

```python
num_events = 0

async for event in chain.astream_events(
    "output a list of the countries france, spain and japan and their populations in JSON format. "
    'Use a dict with an outer key of "countries" which contains a list of countries. '
    "Each country should have the key `name` and `population`",
    version="v2",
):
    kind = event["event"]
    if kind == "on_chat_model_stream":
        print(
            f"Chat model chunk: {repr(event['data']['chunk'].content)}",
            flush=True,
        )
    if kind == "on_parser_stream":
        print(f"Parser chunk: {event['data']['chunk']}", flush=True)
    num_events += 1
    if num_events > 30:
        # Truncate the output
        print("...")
        break
```

```output
Chat model chunk: '{'
Parser chunk: {}
Chat model chunk: '\n  '
Chat model chunk: '"'
Chat model chunk: 'countries'
Chat model chunk: '":'
Chat model chunk: ' ['
Parser chunk: {'countries': []}
Chat model chunk: '\n    '
Chat model chunk: '{'
Parser chunk: {'countries': [{}]}
Chat model chunk: '\n      '
Chat model chunk: '"'
Chat model chunk: 'name'
Chat model chunk: '":'
Chat model chunk: ' "'
Parser chunk: {'countries': [{'name': ''}]}
Chat model chunk: 'France'
Parser chunk: {'countries': [{'name': 'France'}]}
Chat model chunk: '",'
Chat model chunk: '\n      '
Chat model chunk: '"'
Chat model chunk: 'population'
Chat model chunk: '":'
Chat model chunk: ' '
Chat model chunk: '67'
Parser chunk: {'countries': [{'name': 'France', 'population': 67}]}
...
```

### 콜백 전파

:::caution
도구 내에서 실행 가능한 항목을 호출하는 경우, 콜백을 실행 가능한 항목으로 전파해야 합니다. 그렇지 않으면 스트림 이벤트가 생성되지 않습니다.
:::

:::note
`RunnableLambdas` 또는 `@chain` 데코레이터를 사용할 때, 콜백은 자동으로 뒷면에서 전파됩니다.
:::

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to stream runnables"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to stream runnables"}]-->
from langchain_core.runnables import RunnableLambda
from langchain_core.tools import tool


def reverse_word(word: str):
    return word[::-1]


reverse_word = RunnableLambda(reverse_word)


@tool
def bad_tool(word: str):
    """Custom tool that doesn't propagate callbacks."""
    return reverse_word.invoke(word)


async for event in bad_tool.astream_events("hello", version="v2"):
    print(event)
```

```output
{'event': 'on_tool_start', 'data': {'input': 'hello'}, 'name': 'bad_tool', 'tags': [], 'run_id': 'ea900472-a8f7-425d-b627-facdef936ee8', 'metadata': {}}
{'event': 'on_chain_start', 'data': {'input': 'hello'}, 'name': 'reverse_word', 'tags': [], 'run_id': '77b01284-0515-48f4-8d7c-eb27c1882f86', 'metadata': {}}
{'event': 'on_chain_end', 'data': {'output': 'olleh', 'input': 'hello'}, 'run_id': '77b01284-0515-48f4-8d7c-eb27c1882f86', 'name': 'reverse_word', 'tags': [], 'metadata': {}}
{'event': 'on_tool_end', 'data': {'output': 'olleh'}, 'run_id': 'ea900472-a8f7-425d-b627-facdef936ee8', 'name': 'bad_tool', 'tags': [], 'metadata': {}}
```

콜백을 올바르게 전파하는 재구현이 있습니다. 이제 `reverse_word` 실행 가능한 항목에서 이벤트를 받고 있다는 것을 알 수 있습니다.

```python
@tool
def correct_tool(word: str, callbacks):
    """A tool that correctly propagates callbacks."""
    return reverse_word.invoke(word, {"callbacks": callbacks})


async for event in correct_tool.astream_events("hello", version="v2"):
    print(event)
```

```output
{'event': 'on_tool_start', 'data': {'input': 'hello'}, 'name': 'correct_tool', 'tags': [], 'run_id': 'd5ea83b9-9278-49cc-9f1d-aa302d671040', 'metadata': {}}
{'event': 'on_chain_start', 'data': {'input': 'hello'}, 'name': 'reverse_word', 'tags': [], 'run_id': '44dafbf4-2f87-412b-ae0e-9f71713810df', 'metadata': {}}
{'event': 'on_chain_end', 'data': {'output': 'olleh', 'input': 'hello'}, 'run_id': '44dafbf4-2f87-412b-ae0e-9f71713810df', 'name': 'reverse_word', 'tags': [], 'metadata': {}}
{'event': 'on_tool_end', 'data': {'output': 'olleh'}, 'run_id': 'd5ea83b9-9278-49cc-9f1d-aa302d671040', 'name': 'correct_tool', 'tags': [], 'metadata': {}}
```

`Runnable Lambdas` 또는 `@chains` 내에서 실행 가능한 항목을 호출하는 경우, 콜백은 자동으로 귀하를 대신하여 전달됩니다.

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to stream runnables"}]-->
from langchain_core.runnables import RunnableLambda


async def reverse_and_double(word: str):
    return await reverse_word.ainvoke(word) * 2


reverse_and_double = RunnableLambda(reverse_and_double)

await reverse_and_double.ainvoke("1234")

async for event in reverse_and_double.astream_events("1234", version="v2"):
    print(event)
```

```output
{'event': 'on_chain_start', 'data': {'input': '1234'}, 'name': 'reverse_and_double', 'tags': [], 'run_id': '03b0e6a1-3e60-42fc-8373-1e7829198d80', 'metadata': {}}
{'event': 'on_chain_start', 'data': {'input': '1234'}, 'name': 'reverse_word', 'tags': [], 'run_id': '5cf26fc8-840b-4642-98ed-623dda28707a', 'metadata': {}}
{'event': 'on_chain_end', 'data': {'output': '4321', 'input': '1234'}, 'run_id': '5cf26fc8-840b-4642-98ed-623dda28707a', 'name': 'reverse_word', 'tags': [], 'metadata': {}}
{'event': 'on_chain_stream', 'data': {'chunk': '43214321'}, 'run_id': '03b0e6a1-3e60-42fc-8373-1e7829198d80', 'name': 'reverse_and_double', 'tags': [], 'metadata': {}}
{'event': 'on_chain_end', 'data': {'output': '43214321'}, 'run_id': '03b0e6a1-3e60-42fc-8373-1e7829198d80', 'name': 'reverse_and_double', 'tags': [], 'metadata': {}}
```

그리고 `@chain` 데코레이터와 함께:

```python
<!--IMPORTS:[{"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to stream runnables"}]-->
from langchain_core.runnables import chain


@chain
async def reverse_and_double(word: str):
    return await reverse_word.ainvoke(word) * 2


await reverse_and_double.ainvoke("1234")

async for event in reverse_and_double.astream_events("1234", version="v2"):
    print(event)
```

```output
{'event': 'on_chain_start', 'data': {'input': '1234'}, 'name': 'reverse_and_double', 'tags': [], 'run_id': '1bfcaedc-f4aa-4d8e-beee-9bba6ef17008', 'metadata': {}}
{'event': 'on_chain_start', 'data': {'input': '1234'}, 'name': 'reverse_word', 'tags': [], 'run_id': '64fc99f0-5d7d-442b-b4f5-4537129f67d1', 'metadata': {}}
{'event': 'on_chain_end', 'data': {'output': '4321', 'input': '1234'}, 'run_id': '64fc99f0-5d7d-442b-b4f5-4537129f67d1', 'name': 'reverse_word', 'tags': [], 'metadata': {}}
{'event': 'on_chain_stream', 'data': {'chunk': '43214321'}, 'run_id': '1bfcaedc-f4aa-4d8e-beee-9bba6ef17008', 'name': 'reverse_and_double', 'tags': [], 'metadata': {}}
{'event': 'on_chain_end', 'data': {'output': '43214321'}, 'run_id': '1bfcaedc-f4aa-4d8e-beee-9bba6ef17008', 'name': 'reverse_and_double', 'tags': [], 'metadata': {}}
```

## 다음 단계

이제 LangChain을 사용하여 최종 출력과 내부 단계를 스트리밍하는 몇 가지 방법을 배웠습니다.

더 알아보려면 이 섹션의 다른 사용 방법 가이드를 확인하거나 [Langchain 표현 언어에 대한 개념 가이드](/docs/concepts/#langchain-expression-language/)를 참조하세요.
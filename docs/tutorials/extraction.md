---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/extraction.ipynb
description: 이 튜토리얼에서는 비구조화된 텍스트에서 구조화된 정보를 추출하는 체인을 구축하는 방법을 안내합니다.
sidebar_position: 4
---

# 추출 체인 구축하기

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [채팅 모델](/docs/concepts/#chat-models)
- [도구](/docs/concepts/#tools)
- [도구 호출](/docs/concepts/#function-tool-calling)

:::

이 튜토리얼에서는 비구조적 텍스트에서 구조화된 정보를 추출하는 체인을 구축할 것입니다.

:::important
이 튜토리얼은 **도구 호출**을 지원하는 모델에서만 작동합니다.
:::

## 설정

### 주피터 노트북

이 가이드(및 문서의 다른 대부분의 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며, 독자가 주피터 노트북을 사용하고 있다고 가정합니다. 주피터 노트북은 LLM 시스템을 다루는 방법을 배우기에 완벽합니다. 종종 예상치 못한 출력, API 다운 등 문제가 발생할 수 있으며, 인터랙티브 환경에서 가이드를 진행하는 것은 이를 더 잘 이해하는 데 큰 도움이 됩니다.

이 튜토리얼과 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행됩니다. 설치 방법은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

LangChain을 설치하려면 다음을 실행하세요:

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import CodeBlock from "@theme/CodeBlock";

<Tabs>
  <TabItem value="pip" label="Pip" default>
    <CodeBlock language="bash">pip install langchain</CodeBlock>
  </TabItem>
  <TabItem value="conda" label="Conda">
    <CodeBlock language="bash">conda install langchain -c conda-forge</CodeBlock>
  </TabItem>
</Tabs>

자세한 내용은 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 LLM 호출의 여러 번의 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 위한 가장 좋은 방법은 [LangSmith](https://smith.langchain.com)를 사용하는 것입니다.

위 링크에서 가입한 후, 추적 로그를 시작하기 위해 환경 변수를 설정하세요:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```


또는, 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 스키마

먼저, 텍스트에서 추출하고자 하는 정보를 설명해야 합니다.

개인 정보를 추출하기 위한 예제 스키마를 정의하기 위해 Pydantic을 사용할 것입니다.

```python
from typing import Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Person(BaseModel):
    """Information about a person."""

    # ^ Doc-string for the entity Person.
    # This doc-string is sent to the LLM as the description of the schema Person,
    # and it can help to improve extraction results.

    # Note that:
    # 1. Each field is an `optional` -- this allows the model to decline to extract it!
    # 2. Each field has a `description` -- this description is used by the LLM.
    # Having a good description can help improve extraction results.
    name: Optional[str] = Field(default=None, description="The name of the person")
    hair_color: Optional[str] = Field(
        default=None, description="The color of the person's hair if known"
    )
    height_in_meters: Optional[str] = Field(
        default=None, description="Height measured in meters"
    )
```


스키마를 정의할 때 두 가지 모범 사례가 있습니다:

1. **속성** 및 **스키마** 자체를 문서화하세요: 이 정보는 LLM에 전송되며 정보 추출 품질을 개선하는 데 사용됩니다.
2. LLM이 정보를 만들어내도록 강요하지 마세요! 위에서 속성에 대해 `Optional`을 사용하여 LLM이 답을 모를 경우 `None`을 출력할 수 있도록 했습니다.

:::important
최고의 성능을 위해 스키마를 잘 문서화하고, 텍스트에서 추출할 정보가 없을 경우 모델이 결과를 반환하지 않도록 하세요.
:::

## 추출기

위에서 정의한 스키마를 사용하여 정보 추출기를 만들어 봅시다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build an Extraction Chain"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Build an Extraction Chain"}]-->
from typing import Optional

from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.pydantic_v1 import BaseModel, Field

# Define a custom prompt to provide instructions and any additional context.
# 1) You can add examples into the prompt template to improve extraction quality
# 2) Introduce additional parameters to take context into account (e.g., include metadata
#    about the document from which the text was extracted.)
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an expert extraction algorithm. "
            "Only extract relevant information from the text. "
            "If you do not know the value of an attribute asked to extract, "
            "return null for the attribute's value.",
        ),
        # Please see the how-to about improving performance with
        # reference examples.
        # MessagesPlaceholder('examples'),
        ("human", "{text}"),
    ]
)
```


함수/도구 호출을 지원하는 모델을 사용해야 합니다.

이 API와 함께 사용할 수 있는 모델 목록은 [문서](https://docs/concepts#function-tool-calling)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "ChatMistralAI", "source": "langchain_mistralai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_mistralai.chat_models.ChatMistralAI.html", "title": "Build an Extraction Chain"}]-->
from langchain_mistralai import ChatMistralAI

llm = ChatMistralAI(model="mistral-large-latest", temperature=0)

runnable = prompt | llm.with_structured_output(schema=Person)
```

```output
/Users/harrisonchase/workplace/langchain/libs/core/langchain_core/_api/beta_decorator.py:87: LangChainBetaWarning: The method `ChatMistralAI.with_structured_output` is in beta. It is actively being worked on, so the API may change.
  warn_beta(
```

테스트해 보겠습니다.

```python
text = "Alan Smith is 6 feet tall and has blond hair."
runnable.invoke({"text": text})
```


```output
Person(name='Alan Smith', hair_color='blond', height_in_meters='1.83')
```


:::important 

추출은 생성적입니다 🤯

LLM은 생성 모델이므로 피트로 제공된 사람의 신장을 미터로 정확하게 추출하는 것과 같은 멋진 일을 할 수 있습니다!
:::

여기에서 LangSmith 추적을 볼 수 있습니다: https://smith.langchain.com/public/44b69a63-3b3b-47b8-8a6d-61b46533f015/r

## 다중 엔티티

**대부분의 경우**, 단일 엔티티보다는 엔티티 목록을 추출해야 합니다.

이는 Pydantic을 사용하여 모델을 서로 중첩시킴으로써 쉽게 달성할 수 있습니다.

```python
from typing import List, Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Person(BaseModel):
    """Information about a person."""

    # ^ Doc-string for the entity Person.
    # This doc-string is sent to the LLM as the description of the schema Person,
    # and it can help to improve extraction results.

    # Note that:
    # 1. Each field is an `optional` -- this allows the model to decline to extract it!
    # 2. Each field has a `description` -- this description is used by the LLM.
    # Having a good description can help improve extraction results.
    name: Optional[str] = Field(default=None, description="The name of the person")
    hair_color: Optional[str] = Field(
        default=None, description="The color of the person's hair if known"
    )
    height_in_meters: Optional[str] = Field(
        default=None, description="Height measured in meters"
    )


class Data(BaseModel):
    """Extracted data about people."""

    # Creates a model so that we can extract multiple entities.
    people: List[Person]
```


:::important
추출이 완벽하지 않을 수 있습니다. **참조 예제**를 사용하여 추출 품질을 개선하는 방법과 **지침** 섹션을 계속 확인하세요!
:::

```python
runnable = prompt | llm.with_structured_output(schema=Data)
text = "My name is Jeff, my hair is black and i am 6 feet tall. Anna has the same color hair as me."
runnable.invoke({"text": text})
```


```output
Data(people=[Person(name='Jeff', hair_color=None, height_in_meters=None), Person(name='Anna', hair_color=None, height_in_meters=None)])
```


:::tip
스키마가 **다중 엔티티** 추출을 수용할 때, 모델이 텍스트에 관련 정보가 없을 경우 **엔티티 없음**을 추출할 수 있도록 빈 목록을 제공할 수 있습니다. 

이는 일반적으로 **좋은** 일입니다! 이는 엔티티에 대해 **필수** 속성을 지정할 수 있게 하면서 모델이 반드시 이 엔티티를 감지하도록 강요하지 않습니다.
:::

여기에서 LangSmith 추적을 볼 수 있습니다: https://smith.langchain.com/public/7173764d-5e76-45fe-8496-84460bd9cdef/r

## 다음 단계

LangChain을 사용한 추출의 기본을 이해했으므로, 나머지 사용 방법 가이드로 진행할 준비가 되었습니다:

- [예제 추가하기](/docs/how_to/extraction_examples): **참조 예제**를 사용하여 성능을 개선하는 방법을 배우세요.
- [긴 텍스트 처리하기](/docs/how_to/extraction_long_text): 텍스트가 LLM의 컨텍스트 창에 맞지 않을 경우 어떻게 해야 하나요?
- [파싱 접근 방식 사용하기](/docs/how_to/extraction_parse): **도구/함수 호출**을 지원하지 않는 모델로 추출하기 위해 프롬프트 기반 접근 방식을 사용하세요.
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/output_parser_json.ipynb
description: 이 문서는 JSON 출력을 파싱하는 방법을 안내하며, 출력 파서를 사용하여 사용자 지정 JSON 스키마를 처리하는 방법을 설명합니다.
---

# JSON 출력 파싱 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [출력 파서](/docs/concepts/#output-parsers)
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [구조화된 출력](/docs/how_to/structured_output)
- [실행 가능한 항목 연결하기](/docs/how_to/sequence/)

:::

일부 모델 제공자는 [구조화된 출력을 반환하는 내장 방법](/docs/how_to/structured_output)을 지원하지만, 모든 모델이 그렇지는 않습니다. 우리는 출력 파서를 사용하여 사용자가 프롬프트를 통해 임의의 JSON 스키마를 지정하고, 해당 스키마에 맞는 출력을 모델에 요청하며, 마지막으로 그 스키마를 JSON으로 파싱할 수 있도록 도와줄 수 있습니다.

:::note
대형 언어 모델은 누수 추상화라는 점을 염두에 두세요! 잘 형성된 JSON을 생성하기 위해서는 충분한 용량을 가진 LLM을 사용해야 합니다.
:::

[`JsonOutputParser`](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html)는 JSON 출력을 요청하고 파싱하기 위한 내장 옵션 중 하나입니다. 이는 [`PydanticOutputParser`](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html)와 기능적으로 유사하지만, 부분 JSON 객체를 스트리밍으로 반환하는 것도 지원합니다.

다음은 [Pydantic](https://docs.pydantic.dev/)와 함께 사용하여 예상되는 스키마를 편리하게 선언하는 방법의 예입니다:

```python
%pip install -qU langchain langchain-openai

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "JsonOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.JsonOutputParser.html", "title": "How to parse JSON output"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to parse JSON output"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to parse JSON output"}]-->
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_openai import ChatOpenAI

model = ChatOpenAI(temperature=0)


# Define your desired data structure.
class Joke(BaseModel):
    setup: str = Field(description="question to set up a joke")
    punchline: str = Field(description="answer to resolve the joke")


# And a query intented to prompt a language model to populate the data structure.
joke_query = "Tell me a joke."

# Set up a parser + inject instructions into the prompt template.
parser = JsonOutputParser(pydantic_object=Joke)

prompt = PromptTemplate(
    template="Answer the user query.\n{format_instructions}\n{query}\n",
    input_variables=["query"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

chain = prompt | model | parser

chain.invoke({"query": joke_query})
```


```output
{'setup': "Why couldn't the bicycle stand up by itself?",
 'punchline': 'Because it was two tired!'}
```


우리는 파서에서 `format_instructions`를 프롬프트에 직접 전달하고 있다는 점에 유의하세요. 기본 지침을 보강하거나 대체하기 위해 프롬프트의 다른 부분에 자신의 형식 힌트를 추가하는 실험을 할 수 있으며, 해야 합니다:

```python
parser.get_format_instructions()
```


```output
'The output should be formatted as a JSON instance that conforms to the JSON schema below.\n\nAs an example, for the schema {"properties": {"foo": {"title": "Foo", "description": "a list of strings", "type": "array", "items": {"type": "string"}}}, "required": ["foo"]}\nthe object {"foo": ["bar", "baz"]} is a well-formatted instance of the schema. The object {"properties": {"foo": ["bar", "baz"]}} is not well-formatted.\n\nHere is the output schema:\n```\n{"properties": {"setup": {"title": "Setup", "description": "question to set up a joke", "type": "string"}, "punchline": {"title": "Punchline", "description": "answer to resolve the joke", "type": "string"}}, "required": ["setup", "punchline"]}\n```'
```


## 스트리밍

위에서 언급했듯이, `JsonOutputParser`와 `PydanticOutputParser`의 주요 차이점은 `JsonOutputParser` 출력 파서가 부분 청크를 스트리밍하는 것을 지원한다는 점입니다. 다음은 그 모습입니다:

```python
for s in chain.stream({"query": joke_query}):
    print(s)
```

```output
{}
{'setup': ''}
{'setup': 'Why'}
{'setup': 'Why couldn'}
{'setup': "Why couldn't"}
{'setup': "Why couldn't the"}
{'setup': "Why couldn't the bicycle"}
{'setup': "Why couldn't the bicycle stand"}
{'setup': "Why couldn't the bicycle stand up"}
{'setup': "Why couldn't the bicycle stand up by"}
{'setup': "Why couldn't the bicycle stand up by itself"}
{'setup': "Why couldn't the bicycle stand up by itself?"}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': ''}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': 'Because'}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': 'Because it'}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': 'Because it was'}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': 'Because it was two'}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': 'Because it was two tired'}
{'setup': "Why couldn't the bicycle stand up by itself?", 'punchline': 'Because it was two tired!'}
```

## Pydantic 없이

Pydantic 없이도 `JsonOutputParser`를 사용할 수 있습니다. 이는 모델에게 JSON을 반환하도록 요청하지만, 스키마가 무엇이어야 하는지에 대한 세부정보는 제공하지 않습니다.

```python
joke_query = "Tell me a joke."

parser = JsonOutputParser()

prompt = PromptTemplate(
    template="Answer the user query.\n{format_instructions}\n{query}\n",
    input_variables=["query"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

chain = prompt | model | parser

chain.invoke({"query": joke_query})
```


```output
{'response': "Sure! Here's a joke for you: Why couldn't the bicycle stand up by itself? Because it was two tired!"}
```


## 다음 단계

이제 모델에게 구조화된 JSON을 반환하도록 요청하는 한 가지 방법을 배웠습니다. 다음으로, 다른 기술을 위한 [구조화된 출력 얻기](/docs/how_to/structured_output)에 대한 더 넓은 가이드를 확인하세요.
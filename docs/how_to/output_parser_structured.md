---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/output_parser_structured.ipynb
description: 언어 모델의 응답을 구조화된 형식으로 파싱하는 방법과 출력 파서의 주요 메서드에 대해 설명합니다.
sidebar_position: 3
---

# 출력 파서를 사용하여 LLM 응답을 구조화된 형식으로 파싱하는 방법

언어 모델은 텍스트를 출력합니다. 그러나 때때로 텍스트 이상의 구조화된 정보를 얻고 싶을 때가 있습니다. 일부 모델 제공자는 [구조화된 출력을 반환하는 내장 방법](/docs/how_to/structured_output)을 지원하지만, 모든 모델이 그렇지는 않습니다.

출력 파서는 언어 모델 응답을 구조화하는 데 도움을 주는 클래스입니다. 출력 파서는 두 가지 주요 메서드를 구현해야 합니다:

- "형식 지침 가져오기": 언어 모델의 출력이 어떻게 형식화되어야 하는지에 대한 지침을 포함하는 문자열을 반환하는 메서드입니다.
- "파싱": 문자열(언어 모델의 응답으로 가정됨)을 입력으로 받아 이를 일부 구조로 파싱하는 메서드입니다.

그리고 하나의 선택적 메서드가 있습니다:

- "프롬프트로 파싱": 문자열(언어 모델의 응답으로 가정됨)과 프롬프트(이러한 응답을 생성한 프롬프트로 가정됨)를 입력으로 받아 이를 일부 구조로 파싱하는 메서드입니다. 프롬프트는 주로 OutputParser가 출력을 재시도하거나 수정하고 싶을 때 제공되며, 이를 위해 프롬프트에서 정보를 필요로 합니다.

## 시작하기

아래에서는 주요 출력 파서 유형인 `PydanticOutputParser`에 대해 설명합니다.

```python
<!--IMPORTS:[{"imported": "PydanticOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html", "title": "How to use output parsers to parse an LLM response into structured format"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to use output parsers to parse an LLM response into structured format"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to use output parsers to parse an LLM response into structured format"}]-->
from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field, validator
from langchain_openai import OpenAI

model = OpenAI(model_name="gpt-3.5-turbo-instruct", temperature=0.0)


# Define your desired data structure.
class Joke(BaseModel):
    setup: str = Field(description="question to set up a joke")
    punchline: str = Field(description="answer to resolve the joke")

    # You can add custom validation logic easily with Pydantic.
    @validator("setup")
    def question_ends_with_question_mark(cls, field):
        if field[-1] != "?":
            raise ValueError("Badly formed question!")
        return field


# Set up a parser + inject instructions into the prompt template.
parser = PydanticOutputParser(pydantic_object=Joke)

prompt = PromptTemplate(
    template="Answer the user query.\n{format_instructions}\n{query}\n",
    input_variables=["query"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

# And a query intended to prompt a language model to populate the data structure.
prompt_and_model = prompt | model
output = prompt_and_model.invoke({"query": "Tell me a joke."})
parser.invoke(output)
```


```output
Joke(setup='Why did the chicken cross the road?', punchline='To get to the other side!')
```


## LCEL

출력 파서는 [Runnable 인터페이스](/docs/concepts#interface)를 구현하며, 이는 [LangChain 표현 언어 (LCEL)](/docs/concepts#langchain-expression-language-lcel)의 기본 빌딩 블록입니다. 이는 `invoke`, `ainvoke`, `stream`, `astream`, `batch`, `abatch`, `astream_log` 호출을 지원함을 의미합니다.

출력 파서는 문자열 또는 `BaseMessage`를 입력으로 받아 임의의 유형을 반환할 수 있습니다.

```python
parser.invoke(output)
```


```output
Joke(setup='Why did the chicken cross the road?', punchline='To get to the other side!')
```


파서를 수동으로 호출하는 대신, 이를 `Runnable` 시퀀스에 추가할 수도 있습니다:

```python
chain = prompt | model | parser
chain.invoke({"query": "Tell me a joke."})
```


```output
Joke(setup='Why did the chicken cross the road?', punchline='To get to the other side!')
```


모든 파서가 스트리밍 인터페이스를 지원하지만, 특정 파서만 부분적으로 파싱된 객체를 스트리밍할 수 있습니다. 이는 출력 유형에 크게 의존하기 때문입니다. 부분 객체를 구성할 수 없는 파서는 단순히 완전히 파싱된 출력을 생성합니다.

예를 들어 `SimpleJsonOutputParser`는 부분 출력을 스트리밍할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SimpleJsonOutputParser", "source": "langchain.output_parsers.json", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.json.SimpleJsonOutputParser.html", "title": "How to use output parsers to parse an LLM response into structured format"}]-->
from langchain.output_parsers.json import SimpleJsonOutputParser

json_prompt = PromptTemplate.from_template(
    "Return a JSON object with an `answer` key that answers the following question: {question}"
)
json_parser = SimpleJsonOutputParser()
json_chain = json_prompt | model | json_parser
```


```python
list(json_chain.stream({"question": "Who invented the microscope?"}))
```


```output
[{},
 {'answer': ''},
 {'answer': 'Ant'},
 {'answer': 'Anton'},
 {'answer': 'Antonie'},
 {'answer': 'Antonie van'},
 {'answer': 'Antonie van Lee'},
 {'answer': 'Antonie van Leeu'},
 {'answer': 'Antonie van Leeuwen'},
 {'answer': 'Antonie van Leeuwenho'},
 {'answer': 'Antonie van Leeuwenhoek'}]
```


반면 PydanticOutputParser는 그렇지 않습니다:

```python
list(chain.stream({"query": "Tell me a joke."}))
```


```output
[Joke(setup='Why did the chicken cross the road?', punchline='To get to the other side!')]
```
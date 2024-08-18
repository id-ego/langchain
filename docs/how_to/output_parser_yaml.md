---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/output_parser_yaml.ipynb
description: 이 문서는 YAML 출력을 파싱하는 방법을 안내하며, LLM의 스키마에 맞는 출력을 생성하는 방법을 설명합니다.
---

# YAML 출력 파싱 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [출력 파서](/docs/concepts/#output-parsers)
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [구조화된 출력](/docs/how_to/structured_output)
- [러너블 체이닝](/docs/how_to/sequence/)

:::

다양한 제공업체의 LLM은 특정 데이터에 따라 서로 다른 강점을 가질 수 있습니다. 이는 JSON 이외의 형식으로 출력을 생성하는 데 있어 일부가 "더 나은" 신뢰성을 가질 수 있음을 의미합니다.

이 출력 파서는 사용자가 임의의 스키마를 지정하고 LLM에 해당 스키마에 부합하는 출력을 요청할 수 있도록 하며, YAML을 사용하여 응답을 형식화합니다.

:::note
대형 언어 모델은 누수 추상화라는 점을 기억하세요! 잘 형성된 YAML을 생성하기 위해서는 충분한 용량을 가진 LLM을 사용해야 합니다.
:::

```python
%pip install -qU langchain langchain-openai

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


우리는 [Pydantic](https://docs.pydantic.dev)과 [`YamlOutputParser`](https://api.python.langchain.com/en/latest/output_parsers/langchain.output_parsers.yaml.YamlOutputParser.html#langchain.output_parsers.yaml.YamlOutputParser)를 사용하여 데이터 모델을 선언하고 모델이 생성해야 할 YAML의 유형에 대한 더 많은 맥락을 제공합니다:

```python
<!--IMPORTS:[{"imported": "YamlOutputParser", "source": "langchain.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain.output_parsers.yaml.YamlOutputParser.html", "title": "How to parse YAML output"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to parse YAML output"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to parse YAML output"}]-->
from langchain.output_parsers import YamlOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_openai import ChatOpenAI


# Define your desired data structure.
class Joke(BaseModel):
    setup: str = Field(description="question to set up a joke")
    punchline: str = Field(description="answer to resolve the joke")


model = ChatOpenAI(temperature=0)

# And a query intented to prompt a language model to populate the data structure.
joke_query = "Tell me a joke."

# Set up a parser + inject instructions into the prompt template.
parser = YamlOutputParser(pydantic_object=Joke)

prompt = PromptTemplate(
    template="Answer the user query.\n{format_instructions}\n{query}\n",
    input_variables=["query"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

chain = prompt | model | parser

chain.invoke({"query": joke_query})
```


```output
Joke(setup="Why couldn't the bicycle find its way home?", punchline='Because it lost its bearings!')
```


파서는 출력 YAML을 자동으로 파싱하고 데이터를 가진 Pydantic 모델을 생성합니다. 우리는 프롬프트에 추가되는 파서의 `format_instructions`를 볼 수 있습니다:

```python
parser.get_format_instructions()
```


```output
'The output should be formatted as a YAML instance that conforms to the given JSON schema below.\n\n# Examples\n## Schema\n```\n{"title": "Players", "description": "A list of players", "type": "array", "items": {"$ref": "#/definitions/Player"}, "definitions": {"Player": {"title": "Player", "type": "object", "properties": {"name": {"title": "Name", "description": "Player name", "type": "string"}, "avg": {"title": "Avg", "description": "Batting average", "type": "number"}}, "required": ["name", "avg"]}}}\n```\n## Well formatted instance\n```\n- name: John Doe\n  avg: 0.3\n- name: Jane Maxfield\n  avg: 1.4\n```\n\n## Schema\n```\n{"properties": {"habit": { "description": "A common daily habit", "type": "string" }, "sustainable_alternative": { "description": "An environmentally friendly alternative to the habit", "type": "string"}}, "required": ["habit", "sustainable_alternative"]}\n```\n## Well formatted instance\n```\nhabit: Using disposable water bottles for daily hydration.\nsustainable_alternative: Switch to a reusable water bottle to reduce plastic waste and decrease your environmental footprint.\n``` \n\nPlease follow the standard YAML formatting conventions with an indent of 2 spaces and make sure that the data types adhere strictly to the following JSON schema: \n```\n{"properties": {"setup": {"title": "Setup", "description": "question to set up a joke", "type": "string"}, "punchline": {"title": "Punchline", "description": "answer to resolve the joke", "type": "string"}}, "required": ["setup", "punchline"]}\n```\n\nMake sure to always enclose the YAML output in triple backticks (```). Please do not add anything other than valid YAML output!'
```


기본 지침을 보강하거나 교체하기 위해 프롬프트의 다른 부분에 자신의 형식 힌트를 추가하는 실험을 할 수 있으며, 그렇게 해야 합니다.

## 다음 단계

이제 모델에 XML을 반환하도록 요청하는 방법을 배웠습니다. 다음으로, 다른 관련 기술에 대한 [구조화된 출력 얻기](/docs/how_to/structured_output)에 대한 더 넓은 가이드를 확인하세요.
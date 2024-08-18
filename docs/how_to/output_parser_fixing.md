---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/output_parser_fixing.ipynb
description: 이 문서는 출력 수정 파서를 사용하여 형식 오류를 수정하는 방법과 Pydantic 출력 파서의 활용 예제를 설명합니다.
---

# 출력 수정 파서를 사용하는 방법

이 출력 파서는 다른 출력 파서를 감싸고, 첫 번째 파서가 실패할 경우 다른 LLM을 호출하여 오류를 수정합니다.

하지만 우리는 오류를 던지는 것 외에도 다른 작업을 수행할 수 있습니다. 구체적으로, 잘못 형식화된 출력과 형식화된 지침을 모델에 전달하고 수정하도록 요청할 수 있습니다.

이 예제에서는 위의 Pydantic 출력 파서를 사용할 것입니다. 스키마를 준수하지 않는 결과를 전달하면 다음과 같은 일이 발생합니다:

```python
<!--IMPORTS:[{"imported": "PydanticOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html", "title": "How to use the output-fixing parser"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use the output-fixing parser"}]-->
from typing import List

from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_openai import ChatOpenAI
```


```python
class Actor(BaseModel):
    name: str = Field(description="name of an actor")
    film_names: List[str] = Field(description="list of names of films they starred in")


actor_query = "Generate the filmography for a random actor."

parser = PydanticOutputParser(pydantic_object=Actor)
```


```python
misformatted = "{'name': 'Tom Hanks', 'film_names': ['Forrest Gump']}"
```


```python
parser.parse(misformatted)
```


```output
---------------------------------------------------------------------------
``````output
JSONDecodeError                           Traceback (most recent call last)
``````output
File ~/workplace/langchain/libs/langchain/langchain/output_parsers/pydantic.py:29, in PydanticOutputParser.parse(self, text)
     28     json_str = match.group()
---> 29 json_object = json.loads(json_str, strict=False)
     30 return self.pydantic_object.parse_obj(json_object)
``````output
File ~/.pyenv/versions/3.10.1/lib/python3.10/json/__init__.py:359, in loads(s, cls, object_hook, parse_float, parse_int, parse_constant, object_pairs_hook, **kw)
    358     kw['parse_constant'] = parse_constant
--> 359 return cls(**kw).decode(s)
``````output
File ~/.pyenv/versions/3.10.1/lib/python3.10/json/decoder.py:337, in JSONDecoder.decode(self, s, _w)
    333 """Return the Python representation of ``s`` (a ``str`` instance
    334 containing a JSON document).
    335 
    336 """
--> 337 obj, end = self.raw_decode(s, idx=_w(s, 0).end())
    338 end = _w(s, end).end()
``````output
File ~/.pyenv/versions/3.10.1/lib/python3.10/json/decoder.py:353, in JSONDecoder.raw_decode(self, s, idx)
    352 try:
--> 353     obj, end = self.scan_once(s, idx)
    354 except StopIteration as err:
``````output
JSONDecodeError: Expecting property name enclosed in double quotes: line 1 column 2 (char 1)
``````output

During handling of the above exception, another exception occurred:
``````output
OutputParserException                     Traceback (most recent call last)
``````output
Cell In[4], line 1
----> 1 parser.parse(misformatted)
``````output
File ~/workplace/langchain/libs/langchain/langchain/output_parsers/pydantic.py:35, in PydanticOutputParser.parse(self, text)
     33 name = self.pydantic_object.__name__
     34 msg = f"Failed to parse {name} from completion {text}. Got: {e}"
---> 35 raise OutputParserException(msg, llm_output=text)
``````output
OutputParserException: Failed to parse Actor from completion {'name': 'Tom Hanks', 'film_names': ['Forrest Gump']}. Got: Expecting property name enclosed in double quotes: line 1 column 2 (char 1)
```


이제 `OutputFixingParser`를 구성하고 사용할 수 있습니다. 이 출력 파서는 다른 출력 파서를 인수로 받지만 형식 오류를 수정하기 위해 시도할 LLM도 포함합니다.

```python
<!--IMPORTS:[{"imported": "OutputFixingParser", "source": "langchain.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain.output_parsers.fix.OutputFixingParser.html", "title": "How to use the output-fixing parser"}]-->
from langchain.output_parsers import OutputFixingParser

new_parser = OutputFixingParser.from_llm(parser=parser, llm=ChatOpenAI())
```


```python
new_parser.parse(misformatted)
```


```output
Actor(name='Tom Hanks', film_names=['Forrest Gump'])
```


[OutputFixingParser](https://api.python.langchain.com/en/latest/output_parsers/langchain.output_parsers.fix.OutputFixingParser.html#langchain.output_parsers.fix.OutputFixingParser)의 API 문서를 확인하세요.
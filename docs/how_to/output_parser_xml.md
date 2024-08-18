---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/output_parser_xml.ipynb
description: 이 가이드는 XML 출력을 생성하고 파싱하는 방법을 설명하며, XMLOutputParser를 사용하여 LLM의 XML 출력
  활용법을 안내합니다.
---

# XML 출력 파싱 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [출력 파서](/docs/concepts/#output-parsers)
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [구조화된 출력](/docs/how_to/structured_output)
- [러너블 연결하기](/docs/how_to/sequence/)

:::

다양한 제공자의 LLM은 특정 데이터에 따라 서로 다른 강점을 가지고 있습니다. 이는 JSON 이외의 형식으로 출력을 생성하는 데 있어 일부가 "더 나은" 신뢰성을 가질 수 있음을 의미합니다.

이 가이드는 [`XMLOutputParser`](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.xml.XMLOutputParser.html)를 사용하여 모델에 XML 출력을 요청하고, 그 출력을 사용 가능한 형식으로 파싱하는 방법을 보여줍니다.

:::note
대형 언어 모델은 누수 추상화라는 점을 명심하세요! 잘 형성된 XML을 생성하기 위해서는 충분한 용량을 가진 LLM을 사용해야 합니다.
:::

다음 예제에서는 XML 태그에 최적화된 모델인 Anthropic의 Claude-2 모델(https://docs.anthropic.com/claude/docs)을 사용합니다.

```python
%pip install -qU langchain langchain-anthropic

import os
from getpass import getpass

os.environ["ANTHROPIC_API_KEY"] = getpass()
```


모델에 간단한 요청을 시작해 봅시다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to parse XML output"}, {"imported": "XMLOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.xml.XMLOutputParser.html", "title": "How to parse XML output"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to parse XML output"}]-->
from langchain_anthropic import ChatAnthropic
from langchain_core.output_parsers import XMLOutputParser
from langchain_core.prompts import PromptTemplate

model = ChatAnthropic(model="claude-2.1", max_tokens_to_sample=512, temperature=0.1)

actor_query = "Generate the shortened filmography for Tom Hanks."

output = model.invoke(
    f"""{actor_query}
Please enclose the movies in <movie></movie> tags"""
)

print(output.content)
```

```output
Here is the shortened filmography for Tom Hanks, with movies enclosed in XML tags:

<movie>Splash</movie>
<movie>Big</movie>
<movie>A League of Their Own</movie>
<movie>Sleepless in Seattle</movie>
<movie>Forrest Gump</movie>
<movie>Toy Story</movie>
<movie>Apollo 13</movie>
<movie>Saving Private Ryan</movie>
<movie>Cast Away</movie>
<movie>The Da Vinci Code</movie>
```

실제로 꽤 잘 작동했습니다! 하지만 그 XML을 더 쉽게 사용할 수 있는 형식으로 파싱하면 좋을 것입니다. `XMLOutputParser`를 사용하여 프롬프트에 기본 형식 지침을 추가하고 출력된 XML을 dict로 파싱할 수 있습니다:

```python
parser = XMLOutputParser()

# We will add these instructions to the prompt below
parser.get_format_instructions()
```


```output
'The output should be formatted as a XML file.\n1. Output should conform to the tags below. \n2. If tags are not given, make them on your own.\n3. Remember to always open and close all the tags.\n\nAs an example, for the tags ["foo", "bar", "baz"]:\n1. String "<foo>\n   <bar>\n      <baz></baz>\n   </bar>\n</foo>" is a well-formatted instance of the schema. \n2. String "<foo>\n   <bar>\n   </foo>" is a badly-formatted instance.\n3. String "<foo>\n   <tag>\n   </tag>\n</foo>" is a badly-formatted instance.\n\nHere are the output tags:\n```\nNone\n```'
```


```python
prompt = PromptTemplate(
    template="""{query}\n{format_instructions}""",
    input_variables=["query"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

chain = prompt | model | parser

output = chain.invoke({"query": actor_query})
print(output)
```

```output
{'filmography': [{'movie': [{'title': 'Big'}, {'year': '1988'}]}, {'movie': [{'title': 'Forrest Gump'}, {'year': '1994'}]}, {'movie': [{'title': 'Toy Story'}, {'year': '1995'}]}, {'movie': [{'title': 'Saving Private Ryan'}, {'year': '1998'}]}, {'movie': [{'title': 'Cast Away'}, {'year': '2000'}]}]}
```

출력을 우리의 필요에 맞게 조정하기 위해 몇 가지 태그를 추가할 수도 있습니다. 기본 지침을 보강하거나 교체하기 위해 프롬프트의 다른 부분에 자신의 형식 힌트를 추가하는 실험을 해보는 것이 좋습니다:

```python
parser = XMLOutputParser(tags=["movies", "actor", "film", "name", "genre"])

# We will add these instructions to the prompt below
parser.get_format_instructions()
```


```output
'The output should be formatted as a XML file.\n1. Output should conform to the tags below. \n2. If tags are not given, make them on your own.\n3. Remember to always open and close all the tags.\n\nAs an example, for the tags ["foo", "bar", "baz"]:\n1. String "<foo>\n   <bar>\n      <baz></baz>\n   </bar>\n</foo>" is a well-formatted instance of the schema. \n2. String "<foo>\n   <bar>\n   </foo>" is a badly-formatted instance.\n3. String "<foo>\n   <tag>\n   </tag>\n</foo>" is a badly-formatted instance.\n\nHere are the output tags:\n```\n[\'movies\', \'actor\', \'film\', \'name\', \'genre\']\n```'
```


```python
prompt = PromptTemplate(
    template="""{query}\n{format_instructions}""",
    input_variables=["query"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)


chain = prompt | model | parser

output = chain.invoke({"query": actor_query})

print(output)
```

```output
{'movies': [{'actor': [{'name': 'Tom Hanks'}, {'film': [{'name': 'Forrest Gump'}, {'genre': 'Drama'}]}, {'film': [{'name': 'Cast Away'}, {'genre': 'Adventure'}]}, {'film': [{'name': 'Saving Private Ryan'}, {'genre': 'War'}]}]}]}
```

이 출력 파서는 부분 청크의 스트리밍도 지원합니다. 예를 들면 다음과 같습니다:

```python
for s in chain.stream({"query": actor_query}):
    print(s)
```

```output
{'movies': [{'actor': [{'name': 'Tom Hanks'}]}]}
{'movies': [{'actor': [{'film': [{'name': 'Forrest Gump'}]}]}]}
{'movies': [{'actor': [{'film': [{'genre': 'Drama'}]}]}]}
{'movies': [{'actor': [{'film': [{'name': 'Cast Away'}]}]}]}
{'movies': [{'actor': [{'film': [{'genre': 'Adventure'}]}]}]}
{'movies': [{'actor': [{'film': [{'name': 'Saving Private Ryan'}]}]}]}
{'movies': [{'actor': [{'film': [{'genre': 'War'}]}]}]}
```

## 다음 단계

이제 모델에 XML을 반환하도록 요청하는 방법을 배웠습니다. 다음으로, 다른 관련 기술에 대한 [구조화된 출력 얻기 위한 더 넓은 가이드](/docs/how_to/structured_output)를 확인하세요.
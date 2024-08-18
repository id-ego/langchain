---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_builtin.ipynb
description: 이 문서는 LangChain의 내장 도구 및 툴킷 사용법을 안내하며, 3rd 파티 도구 통합 및 사용자 정의 방법을 설명합니다.
sidebar_class_name: hidden
sidebar_position: 4
---

# 내장 도구 및 툴킷 사용 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [LangChain 도구](/docs/concepts/#tools)
- [LangChain 툴킷](/docs/concepts/#tools)

:::

## 도구

LangChain은 방대한 3자 도구 모음을 가지고 있습니다. 사용 가능한 도구 목록은 [도구 통합](/docs/integrations/tools/)를 방문해 주세요.

:::important

3자 도구를 사용할 때는 도구의 작동 방식과 권한을 이해해야 합니다. 문서를 읽고 보안 관점에서 요구되는 사항이 있는지 확인하세요. 자세한 내용은 [보안](https://python.langchain.com/v0.2/docs/security/) 지침을 참조하세요.

:::

[위키백과 통합](/docs/integrations/tools/wikipedia/)를 사용해 보겠습니다.

```python
!pip install -qU wikipedia
```


```python
<!--IMPORTS:[{"imported": "WikipediaQueryRun", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.wikipedia.tool.WikipediaQueryRun.html", "title": "How to use built-in tools and toolkits"}, {"imported": "WikipediaAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.wikipedia.WikipediaAPIWrapper.html", "title": "How to use built-in tools and toolkits"}]-->
from langchain_community.tools import WikipediaQueryRun
from langchain_community.utilities import WikipediaAPIWrapper

api_wrapper = WikipediaAPIWrapper(top_k_results=1, doc_content_chars_max=100)
tool = WikipediaQueryRun(api_wrapper=api_wrapper)

print(tool.invoke({"query": "langchain"}))
```

```output
Page: LangChain
Summary: LangChain is a framework designed to simplify the creation of applications
```

이 도구에는 다음과 같은 기본값이 연결되어 있습니다:

```python
print(f"Name: {tool.name}")
print(f"Description: {tool.description}")
print(f"args schema: {tool.args}")
print(f"returns directly?: {tool.return_direct}")
```

```output
Name: wiki-tool
Description: look up things in wikipedia
args schema: {'query': {'title': 'Query', 'description': 'query to look up in Wikipedia, should be 3 or less words', 'type': 'string'}}
returns directly?: True
```

## 기본 도구 사용자 정의
내장된 이름, 설명 및 인수의 JSON 스키마를 수정할 수도 있습니다.

인수의 JSON 스키마를 정의할 때, 입력이 함수와 동일하게 유지되는 것이 중요하므로 변경하지 않아야 합니다. 그러나 각 입력에 대한 사용자 정의 설명을 쉽게 정의할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "WikipediaQueryRun", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.wikipedia.tool.WikipediaQueryRun.html", "title": "How to use built-in tools and toolkits"}, {"imported": "WikipediaAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.wikipedia.WikipediaAPIWrapper.html", "title": "How to use built-in tools and toolkits"}]-->
from langchain_community.tools import WikipediaQueryRun
from langchain_community.utilities import WikipediaAPIWrapper
from langchain_core.pydantic_v1 import BaseModel, Field


class WikiInputs(BaseModel):
    """Inputs to the wikipedia tool."""

    query: str = Field(
        description="query to look up in Wikipedia, should be 3 or less words"
    )


tool = WikipediaQueryRun(
    name="wiki-tool",
    description="look up things in wikipedia",
    args_schema=WikiInputs,
    api_wrapper=api_wrapper,
    return_direct=True,
)

print(tool.run("langchain"))
```

```output
Page: LangChain
Summary: LangChain is a framework designed to simplify the creation of applications
```


```python
print(f"Name: {tool.name}")
print(f"Description: {tool.description}")
print(f"args schema: {tool.args}")
print(f"returns directly?: {tool.return_direct}")
```

```output
Name: wiki-tool
Description: look up things in wikipedia
args schema: {'query': {'title': 'Query', 'description': 'query to look up in Wikipedia, should be 3 or less words', 'type': 'string'}}
returns directly?: True
```

## 내장 툴킷 사용 방법

툴킷은 특정 작업을 위해 함께 사용하도록 설계된 도구 모음입니다. 편리한 로딩 방법을 제공합니다.

모든 툴킷은 도구 목록을 반환하는 `get_tools` 메서드를 노출합니다.

일반적으로 다음과 같이 사용해야 합니다:

```python
# Initialize a toolkit
toolkit = ExampleTookit(...)

# Get list of tools
tools = toolkit.get_tools()
```
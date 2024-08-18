---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/serpapi.ipynb
description: 이 문서는 SerpAPI 컴포넌트를 사용하여 웹 검색을 수행하는 방법과 사용자 정의 매개변수 설정에 대해 설명합니다.
---

# SerpAPI

이 노트북은 SerpAPI 구성 요소를 사용하여 웹을 검색하는 방법에 대해 설명합니다.

```python
<!--IMPORTS:[{"imported": "SerpAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.serpapi.SerpAPIWrapper.html", "title": "SerpAPI"}]-->
from langchain_community.utilities import SerpAPIWrapper
```


```python
search = SerpAPIWrapper()
```


```python
search.run("Obama's first name?")
```


```output
'Barack Hussein Obama II'
```


## 사용자 정의 매개변수
임의의 매개변수로 SerpAPI 래퍼를 사용자 정의할 수도 있습니다. 예를 들어, 아래 예제에서는 `google` 대신 `bing`을 사용할 것입니다.

```python
params = {
    "engine": "bing",
    "gl": "us",
    "hl": "en",
}
search = SerpAPIWrapper(params=params)
```


```python
search.run("Obama's first name?")
```


```output
'Barack Hussein Obama II is an American politician who served as the 44th president of the United States from 2009 to 2017. A member of the Democratic Party, Obama was the first African-American presi…New content will be added above the current area of focus upon selectionBarack Hussein Obama II is an American politician who served as the 44th president of the United States from 2009 to 2017. A member of the Democratic Party, Obama was the first African-American president of the United States. He previously served as a U.S. senator from Illinois from 2005 to 2008 and as an Illinois state senator from 1997 to 2004, and previously worked as a civil rights lawyer before entering politics.Wikipediabarackobama.com'
```


```python
<!--IMPORTS:[{"imported": "Tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.simple.Tool.html", "title": "SerpAPI"}]-->
from langchain_core.tools import Tool

# You can create the tool to pass to an agent
repl_tool = Tool(
    name="python_repl",
    description="A Python shell. Use this to execute python commands. Input should be a valid python command. If you want to see the output of a value, you should print it out with `print(...)`.",
    func=search.run,
)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
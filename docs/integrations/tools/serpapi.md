---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/serpapi/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/serpapi.ipynb
---

# SerpAPI

This notebook goes over how to use the SerpAPI component to search the web.

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

## Custom Parameters
You can also customize the SerpAPI wrapper with arbitrary parameters. For example, in the below example we will use `bing` instead of `google`.

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

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)
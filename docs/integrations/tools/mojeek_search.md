---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/mojeek_search.ipynb
description: Mojeek Search를 사용하여 결과를 얻는 방법을 설명합니다. API 키는 Mojeek 웹사이트에서 확인하세요.
---

# Mojeek 검색

다음 노트북은 Mojeek 검색을 사용하여 결과를 얻는 방법을 설명합니다. API 키를 얻으려면 [Mojeek 웹사이트](https://www.mojeek.com/services/search/web-search-api/)를 방문하십시오.

```python
<!--IMPORTS:[{"imported": "MojeekSearch", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.mojeek_search.tool.MojeekSearch.html", "title": "Mojeek Search"}]-->
from langchain_community.tools import MojeekSearch
```


```python
api_key = "KEY"  # obtained from Mojeek Website
```


```python
search = MojeekSearch.config(api_key=api_key, search_kwargs={"t": 10})
```


`search_kwargs`에서는 [Mojeek 문서](https://www.mojeek.com/support/api/search/request_parameters.html)에서 찾을 수 있는 모든 검색 매개변수를 추가할 수 있습니다.

```python
search.run("mojeek")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
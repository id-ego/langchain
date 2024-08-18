---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/youtube.ipynb
description: YouTube 비디오를 검색하는 방법을 보여주는 노트북으로, 제한된 API를 우회하여 결과를 스크랩하는 패키지를 사용합니다.
---

# YouTube

> [YouTube Search](https://github.com/joetats/youtube_search) 패키지는 `YouTube` 비디오를 검색하며, 그들의 제한된 API를 사용하지 않습니다.
> 
> 이는 `YouTube` 홈페이지의 양식을 사용하고 결과 페이지를 스크랩합니다.

이 노트북은 YouTube를 검색하기 위한 도구를 사용하는 방법을 보여줍니다.

[https://github.com/venuv/langchain_yt_tools](https://github.com/venuv/langchain_yt_tools)에서 수정됨

```python
%pip install --upgrade --quiet  youtube_search
```


```python
<!--IMPORTS:[{"imported": "YouTubeSearchTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.youtube.search.YouTubeSearchTool.html", "title": "YouTube"}]-->
from langchain_community.tools import YouTubeSearchTool
```


```python
tool = YouTubeSearchTool()
```


```python
tool.run("lex fridman")
```


```output
"['/watch?v=VcVfceTsD0A&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=gPfriiHBBek&pp=ygUMbGV4IGZyaWVkbWFu']"
```


반환되는 결과의 수를 지정할 수도 있습니다.

```python
tool.run("lex friedman,5")
```


```output
"['/watch?v=VcVfceTsD0A&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=YVJ8gTnDC4Y&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=Udh22kuLebg&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=gPfriiHBBek&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=L_Guz73e6fw&pp=ygUMbGV4IGZyaWVkbWFu']"
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_places.ipynb
description: Google Places API를 사용하는 방법을 다룬 노트북입니다. 다양한 코드 예제를 통해 API 활용법을 배울 수 있습니다.
---

# 구글 플레이스

이 노트북은 구글 플레이스 API를 사용하는 방법을 설명합니다.

```python
%pip install --upgrade --quiet  googlemaps langchain-community
```


```python
import os

os.environ["GPLACES_API_KEY"] = ""
```


```python
<!--IMPORTS:[{"imported": "GooglePlacesTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.google_places.tool.GooglePlacesTool.html", "title": "Google Places"}]-->
from langchain_community.tools import GooglePlacesTool
```


```python
places = GooglePlacesTool()
```


```python
places.run("al fornos")
```


```output
"1. Delfina Restaurant\nAddress: 3621 18th St, San Francisco, CA 94110, USA\nPhone: (415) 552-4055\nWebsite: https://www.delfinasf.com/\n\n\n2. Piccolo Forno\nAddress: 725 Columbus Ave, San Francisco, CA 94133, USA\nPhone: (415) 757-0087\nWebsite: https://piccolo-forno-sf.com/\n\n\n3. L'Osteria del Forno\nAddress: 519 Columbus Ave, San Francisco, CA 94133, USA\nPhone: (415) 982-1124\nWebsite: Unknown\n\n\n4. Il Fornaio\nAddress: 1265 Battery St, San Francisco, CA 94111, USA\nPhone: (415) 986-0100\nWebsite: https://www.ilfornaio.com/\n\n"
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
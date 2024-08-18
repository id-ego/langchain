---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/wolfram_alpha.ipynb
description: 이 문서는 Wolfram Alpha 구성 요소를 사용하는 방법과 APP ID 설정, 환경 변수 구성에 대한 안내를 제공합니다.
---

# Wolfram Alpha

이 노트북은 Wolfram Alpha 구성 요소를 사용하는 방법에 대해 설명합니다.

먼저, Wolfram Alpha 개발자 계정을 설정하고 APP ID를 받아야 합니다:

1. Wolfram Alpha에 가서 [여기](https://developer.wolframalpha.com/)에서 개발자 계정에 가입합니다.
2. 앱을 생성하고 APP ID를 받습니다.
3. pip install wolframalpha

그런 다음 몇 가지 환경 변수를 설정해야 합니다:
1. APP ID를 WOLFRAM_ALPHA_APPID 환경 변수에 저장합니다.

```python
pip install wolframalpha
```


```python
import os

os.environ["WOLFRAM_ALPHA_APPID"] = ""
```


```python
<!--IMPORTS:[{"imported": "WolframAlphaAPIWrapper", "source": "langchain_community.utilities.wolfram_alpha", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.wolfram_alpha.WolframAlphaAPIWrapper.html", "title": "Wolfram Alpha"}]-->
from langchain_community.utilities.wolfram_alpha import WolframAlphaAPIWrapper
```


```python
wolfram = WolframAlphaAPIWrapper()
```


```python
wolfram.run("What is 2x+5 = -3x + 7?")
```


```output
'x = 2/5'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
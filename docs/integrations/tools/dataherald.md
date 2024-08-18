---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/dataherald.ipynb
description: 이 문서는 Dataherald 구성 요소를 사용하는 방법과 API 키 설정, 환경 변수 저장 방법에 대해 설명합니다.
---

# Dataherald

이 노트북은 dataherald 구성 요소를 사용하는 방법에 대해 설명합니다.

먼저, Dataherald 계정을 설정하고 API KEY를 받아야 합니다:

1. dataherald에 가서 [여기](https://www.dataherald.com/)에서 가입하세요.
2. 관리 콘솔에 로그인한 후, API KEY를 생성하세요.
3. pip install dataherald

그런 다음 몇 가지 환경 변수를 설정해야 합니다:
1. API KEY를 DATAHERALD_API_KEY 환경 변수에 저장하세요.

```python
pip install dataherald
%pip install --upgrade --quiet langchain-community
```


```python
import os

os.environ["DATAHERALD_API_KEY"] = ""
```


```python
<!--IMPORTS:[{"imported": "DataheraldAPIWrapper", "source": "langchain_community.utilities.dataherald", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.dataherald.DataheraldAPIWrapper.html", "title": "Dataherald"}]-->
from langchain_community.utilities.dataherald import DataheraldAPIWrapper
```


```python
dataherald = DataheraldAPIWrapper(db_connection_id="65fb766367dd22c99ce1a12d")
```


```python
dataherald.run("How many employees are in the company?")
```


```output
'select COUNT(*) from employees'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
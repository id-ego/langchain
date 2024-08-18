---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/upstage_groundedness_check.ipynb
description: 이 문서는 Upstage groundedness check 모델을 시작하는 방법과 설치, 환경 설정, 사용법을 안내합니다.
sidebar_label: Upstage
---

# 업스테이지 그라운디드니스 체크

이 노트북은 업스테이지 그라운디드니스 체크 모델을 시작하는 방법을 다룹니다.

## 설치

`langchain-upstage` 패키지를 설치합니다.

```bash
pip install -U langchain-upstage
```


## 환경 설정

다음 환경 변수를 설정해야 합니다:

- `UPSTAGE_API_KEY`: [업스테이지 개발자 문서](https://developers.upstage.ai/docs/getting-started/quick-start)에서 가져온 업스테이지 API 키입니다.

```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```


## 사용법

`UpstageGroundednessCheck` 클래스를 초기화합니다.

```python
from langchain_upstage import UpstageGroundednessCheck

groundedness_check = UpstageGroundednessCheck()
```


입력 텍스트의 그라운디드니스를 확인하기 위해 `run` 메서드를 사용합니다.

```python
request_input = {
    "context": "Mauna Kea is an inactive volcano on the island of Hawai'i. Its peak is 4,207.3 m above sea level, making it the highest point in Hawaii and second-highest peak of an island on Earth.",
    "answer": "Mauna Kea is 5,207.3 meters tall.",
}

response = groundedness_check.invoke(request_input)
print(response)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
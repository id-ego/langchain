---
description: UpTrain은 생성 AI 애플리케이션을 평가하고 개선하기 위한 오픈 소스 통합 플랫폼입니다. 20개 이상의 평가를 제공합니다.
---

# UpTrain

> [UpTrain](https://uptrain.ai/)는 생성 AI 애플리케이션을 평가하고 개선하기 위한 오픈 소스 통합 플랫폼입니다. 언어, 코드, 임베딩 사용 사례를 포함한 20개 이상의 사전 구성된 평가에 대한 점수를 제공하고, 실패 사례에 대한 근본 원인 분석을 수행하며, 이를 해결하는 방법에 대한 통찰을 제공합니다.

## 설치 및 설정

```bash
pip install uptrain
```


## 콜백

```python
<!--IMPORTS:[{"imported": "UpTrainCallbackHandler", "source": "langchain_community.callbacks.uptrain_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.uptrain_callback.UpTrainCallbackHandler.html", "title": "UpTrain"}]-->
from langchain_community.callbacks.uptrain_callback import UpTrainCallbackHandler
```


[예제](/docs/integrations/callbacks/uptrain)를 참조하세요.
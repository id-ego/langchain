---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/alibaba_cloud_pai_eas.ipynb
description: Alibaba Cloud PAI EAS는 클라우드 기반의 경량 머신러닝 플랫폼으로, 효율적인 모델링 서비스와 다양한 산업 시나리오를
  지원합니다.
sidebar_label: Alibaba Cloud PAI EAS
---

# Alibaba Cloud PAI EAS

> [Alibaba Cloud PAI (AI 플랫폼)](https://www.alibabacloud.com/help/en/pai/?spm=a2c63.p38356.0.0.c26a426ckrxUwZ)는 클라우드 네이티브 기술을 사용하는 경량 및 비용 효율적인 머신 러닝 플랫폼입니다. 이는 엔드 투 엔드 모델링 서비스를 제공합니다. 100개 이상의 시나리오에서 수십억 개의 특징과 수백억 개의 샘플을 기반으로 모델 훈련을 가속화합니다.

> [Alibaba Cloud의 AI를 위한 머신 러닝 플랫폼](https://www.alibabacloud.com/help/en/machine-learning-platform-for-ai/latest/what-is-machine-learning-pai)은 기업과 개발자를 위한 머신 러닝 또는 딥 러닝 엔지니어링 플랫폼입니다. 이는 다양한 산업 시나리오에 적용할 수 있는 사용하기 쉽고, 비용 효율적이며, 고성능의 확장 가능한 플러그인을 제공합니다. 140개 이상의 내장 최적화 알고리즘을 통해 `Machine Learning Platform for AI`는 데이터 라벨링(`PAI-iTAG`), 모델 구축(`PAI-Designer` 및 `PAI-DSW`), 모델 훈련(`PAI-DLC`), 컴파일 최적화 및 추론 배포(`PAI-EAS`)를 포함한 전체 프로세스 AI 엔지니어링 기능을 제공합니다.
> 
> `PAI-EAS`는 CPU 및 GPU를 포함한 다양한 유형의 하드웨어 리소스를 지원하며, 높은 처리량과 낮은 대기 시간을 특징으로 합니다. 몇 번의 클릭으로 대규모 복잡한 모델을 배포하고 실시간으로 탄력적인 스케일 인 및 스케일 아웃을 수행할 수 있습니다. 또한 포괄적인 운영 및 모니터링 시스템을 제공합니다.

## EAS 서비스 설정

EAS 서비스 URL 및 토큰을 초기화하기 위해 환경 변수를 설정합니다.  
자세한 정보는 [이 문서](https://www.alibabacloud.com/help/en/pai/user-guide/service-deployment/)를 참조하세요.

```bash
export EAS_SERVICE_URL=XXX
export EAS_SERVICE_TOKEN=XXX
```
  
또 다른 옵션은 이 코드를 사용하는 것입니다:

```python
<!--IMPORTS:[{"imported": "PaiEasChatEndpoint", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.pai_eas_endpoint.PaiEasChatEndpoint.html", "title": "Alibaba Cloud PAI EAS"}, {"imported": "HumanMessage", "source": "langchain_core.language_models.chat_models", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Alibaba Cloud PAI EAS"}]-->
import os

from langchain_community.chat_models import PaiEasChatEndpoint
from langchain_core.language_models.chat_models import HumanMessage

os.environ["EAS_SERVICE_URL"] = "Your_EAS_Service_URL"
os.environ["EAS_SERVICE_TOKEN"] = "Your_EAS_Service_Token"
chat = PaiEasChatEndpoint(
    eas_service_url=os.environ["EAS_SERVICE_URL"],
    eas_service_token=os.environ["EAS_SERVICE_TOKEN"],
)
```


## 챗 모델 실행

기본 설정을 사용하여 EAS 서비스를 다음과 같이 호출할 수 있습니다:

```python
output = chat.invoke([HumanMessage(content="write a funny joke")])
print("output:", output)
```


또는 새로운 추론 매개변수로 EAS 서비스를 호출합니다:

```python
kwargs = {"temperature": 0.8, "top_p": 0.8, "top_k": 5}
output = chat.invoke([HumanMessage(content="write a funny joke")], **kwargs)
print("output:", output)
```


또는 스트림 응답을 얻기 위해 스트림 호출을 실행합니다:

```python
outputs = chat.stream([HumanMessage(content="hi")], streaming=True)
for output in outputs:
    print("stream output:", output)
```


## 관련

- 챗 모델 [개념 가이드](/docs/concepts/#chat-models)
- 챗 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
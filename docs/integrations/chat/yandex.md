---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/yandex.ipynb
description: 이 문서는 Langchain을 사용하여 YandexGPT 채팅 모델을 활용하는 방법을 설명합니다. 설치 및 인증 방법을 안내합니다.
sidebar_label: YandexGPT
---

# ChatYandexGPT

이 노트북은 Langchain을 [YandexGPT](https://cloud.yandex.com/en/services/yandexgpt) 채팅 모델과 함께 사용하는 방법을 다룹니다.

사용하려면 `yandexcloud` 파이썬 패키지가 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  yandexcloud
```


먼저, `ai.languageModels.user` 역할을 가진 [서비스 계정](https://cloud.yandex.com/en/docs/iam/operations/sa/create)을 생성해야 합니다.

다음으로, 두 가지 인증 옵션이 있습니다:
- [IAM 토큰](https://cloud.yandex.com/en/docs/iam/operations/iam-token/create-for-sa).
토큰을 생성자 매개변수 `iam_token` 또는 환경 변수 `YC_IAM_TOKEN`에 지정할 수 있습니다.
- [API 키](https://cloud.yandex.com/en/docs/iam/operations/api-key/create)
키를 생성자 매개변수 `api_key` 또는 환경 변수 `YC_API_KEY`에 지정할 수 있습니다.

모델을 지정하려면 `model_uri` 매개변수를 사용할 수 있으며, 자세한 내용은 [문서](https://cloud.yandex.com/en/docs/yandexgpt/concepts/models#yandexgpt-generation)를 참조하십시오.

기본적으로, `folder_id` 매개변수 또는 `YC_FOLDER_ID` 환경 변수에 지정된 폴더에서 최신 버전의 `yandexgpt-lite`가 사용됩니다.

```python
<!--IMPORTS:[{"imported": "ChatYandexGPT", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yandex.ChatYandexGPT.html", "title": "ChatYandexGPT"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatYandexGPT"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatYandexGPT"}]-->
from langchain_community.chat_models import ChatYandexGPT
from langchain_core.messages import HumanMessage, SystemMessage
```


```python
chat_model = ChatYandexGPT()
```


```python
answer = chat_model.invoke(
    [
        SystemMessage(
            content="You are a helpful assistant that translates English to French."
        ),
        HumanMessage(content="I love programming."),
    ]
)
answer
```


```output
AIMessage(content='Je adore le programmement.')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
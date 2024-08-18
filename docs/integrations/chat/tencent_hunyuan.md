---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/tencent_hunyuan.ipynb
description: 텐센트의 혼합 모델 API인 Hunyuan은 대화, 콘텐츠 생성, 분석 등 다양한 시나리오에 활용될 수 있습니다.
sidebar_label: Tencent Hunyuan
---

# 텐센트 혼위안

> [텐센트의 하이브리드 모델 API](https://cloud.tencent.com/document/product/1729) (`Hunyuan API`)
대화 통신, 콘텐츠 생성,
분석 및 이해를 구현하며, 지능형
고객 서비스, 지능형 마케팅, 역할 놀이, 광고 카피 작성, 제품 설명,
스크립트 생성, 이력서 생성, 기사 작성, 코드 생성, 데이터 분석 및 콘텐츠
분석과 같은 다양한 시나리오에서 널리 사용될 수 있습니다.

자세한 내용은 [여기](https://cloud.tencent.com/document/product/1729)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "ChatHunyuan", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.hunyuan.ChatHunyuan.html", "title": "Tencent Hunyuan"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Tencent Hunyuan"}]-->
from langchain_community.chat_models import ChatHunyuan
from langchain_core.messages import HumanMessage
```


```python
chat = ChatHunyuan(
    hunyuan_app_id=111111111,
    hunyuan_secret_id="YOUR_SECRET_ID",
    hunyuan_secret_key="YOUR_SECRET_KEY",
)
```


```python
chat(
    [
        HumanMessage(
            content="You are a helpful assistant that translates English to French.Translate this sentence from English to French. I love programming."
        )
    ]
)
```


```output
AIMessage(content="J'aime programmer.")
```


## 스트리밍을 통한 ChatHunyuan

```python
chat = ChatHunyuan(
    hunyuan_app_id="YOUR_APP_ID",
    hunyuan_secret_id="YOUR_SECRET_ID",
    hunyuan_secret_key="YOUR_SECRET_KEY",
    streaming=True,
)
```


```python
chat(
    [
        HumanMessage(
            content="You are a helpful assistant that translates English to French.Translate this sentence from English to French. I love programming."
        )
    ]
)
```


```output
AIMessageChunk(content="J'aime programmer.")
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
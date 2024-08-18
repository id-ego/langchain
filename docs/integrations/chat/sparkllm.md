---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/sparkllm.ipynb
description: 이 문서는 iFlyTek의 SparkLLM 채팅 모델 API 사용법과 환경 변수 설정 방법을 안내합니다. 스트리밍 및 v2에
  대한 정보도 포함되어 있습니다.
---

# SparkLLM 채팅

iFlyTek의 SparkLLM 채팅 모델 API. 더 많은 정보는 [iFlyTek 오픈 플랫폼](https://www.xfyun.cn/)을 참조하세요.

## 기본 사용법

```python
<!--IMPORTS:[{"imported": "ChatSparkLLM", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.sparkllm.ChatSparkLLM.html", "title": "SparkLLM Chat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "SparkLLM Chat"}]-->
"""For basic init and call"""
from langchain_community.chat_models import ChatSparkLLM
from langchain_core.messages import HumanMessage

chat = ChatSparkLLM(
    spark_app_id="<app_id>", spark_api_key="<api_key>", spark_api_secret="<api_secret>"
)
message = HumanMessage(content="Hello")
chat([message])
```


```output
AIMessage(content='Hello! How can I help you today?')
```


- SparkLLM의 app_id, api_key 및 api_secret을 [iFlyTek SparkLLM API 콘솔](https://console.xfyun.cn/services/bm3)에서 가져오세요 (자세한 내용은 [iFlyTek SparkLLM 소개](https://xinghuo.xfyun.cn/sparkapi) 참조). 그런 다음 환경 변수 `IFLYTEK_SPARK_APP_ID`, `IFLYTEK_SPARK_API_KEY` 및 `IFLYTEK_SPARK_API_SECRET`를 설정하거나 위의 데모와 같이 `ChatSparkLLM`을 생성할 때 매개변수를 전달하세요.

## 스트리밍을 위한 ChatSparkLLM

```python
chat = ChatSparkLLM(
    spark_app_id="<app_id>",
    spark_api_key="<api_key>",
    spark_api_secret="<api_secret>",
    streaming=True,
)
for chunk in chat.stream("Hello!"):
    print(chunk.content, end="")
```

```output
Hello! How can I help you today?
```


## v2용

```python
<!--IMPORTS:[{"imported": "ChatSparkLLM", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.sparkllm.ChatSparkLLM.html", "title": "SparkLLM Chat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "SparkLLM Chat"}]-->
"""For basic init and call"""
from langchain_community.chat_models import ChatSparkLLM
from langchain_core.messages import HumanMessage

chat = ChatSparkLLM(
    spark_app_id="<app_id>",
    spark_api_key="<api_key>",
    spark_api_secret="<api_secret>",
    spark_api_url="wss://spark-api.xf-yun.com/v2.1/chat",
    spark_llm_domain="generalv2",
)
message = HumanMessage(content="Hello")
chat([message])
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
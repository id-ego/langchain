---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/twilio.ipynb
description: 이 문서는 Twilio API를 사용하여 SMS 및 다양한 메시징 채널을 통해 메시지를 전송하는 방법을 설명합니다.
---

# 트윌리오

이 노트북은 [트윌리오](https://www.twilio.com) API 래퍼를 사용하여 SMS 또는 [트윌리오 메시징 채널](https://www.twilio.com/docs/messaging/channels)을 통해 메시지를 보내는 방법을 설명합니다.

트윌리오 메시징 채널은 3rd 파티 메시징 앱과의 통합을 용이하게 하며, WhatsApp 비즈니스 플랫폼(GA), Facebook Messenger(공식 베타) 및 Google 비즈니스 메시지(비공식 베타)를 통해 메시지를 보낼 수 있게 해줍니다.

## 설정

이 도구를 사용하려면 Python 트윌리오 패키지 `twilio`를 설치해야 합니다.

```python
%pip install --upgrade --quiet  twilio
```


또한 트윌리오 계정을 설정하고 자격 증명을 받아야 합니다. 계정 문자열 식별자(SID)와 인증 토큰이 필요합니다. 메시지를 보낼 번호도 필요합니다.

이 값을 트윌리오 API 래퍼에 이름 있는 매개변수 `account_sid`, `auth_token`, `from_number`로 전달하거나 환경 변수 `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM_NUMBER`를 설정할 수 있습니다.

## SMS 보내기

```python
<!--IMPORTS:[{"imported": "TwilioAPIWrapper", "source": "langchain_community.utilities.twilio", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.twilio.TwilioAPIWrapper.html", "title": "Twilio"}]-->
from langchain_community.utilities.twilio import TwilioAPIWrapper
```


```python
twilio = TwilioAPIWrapper(
    #     account_sid="foo",
    #     auth_token="bar",
    #     from_number="baz,"
)
```


```python
twilio.run("hello world", "+16162904619")
```


## WhatsApp 메시지 보내기

WhatsApp 비즈니스 계정을 트윌리오와 연결해야 합니다. 또한 메시지를 보낼 번호가 트윌리오에서 WhatsApp 활성화 발신자로 구성되어 있고 WhatsApp에 등록되어 있는지 확인해야 합니다.

```python
<!--IMPORTS:[{"imported": "TwilioAPIWrapper", "source": "langchain_community.utilities.twilio", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.twilio.TwilioAPIWrapper.html", "title": "Twilio"}]-->
from langchain_community.utilities.twilio import TwilioAPIWrapper
```


```python
twilio = TwilioAPIWrapper(
    #     account_sid="foo",
    #     auth_token="bar",
    #     from_number="whatsapp: baz,"
)
```


```python
twilio.run("hello world", "whatsapp: +16162904619")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
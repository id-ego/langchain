---
description: Remembrall은 LangChain 내에서 언어 모델에 장기 기억과 정보 검색 기능을 추가하는 간편한 도구입니다.
---

# Remembrall

이 페이지는 LangChain 내에서 [Remembrall](https://remembrall.dev) 생태계를 사용하는 방법을 다룹니다.

## Remembrall이란?

Remembrall은 언어 모델에 장기 기억, 검색 보강 생성 및 완전한 관찰 가능성을 제공하며, 몇 줄의 코드만으로 가능합니다.

![Remembrall 대시보드의 스크린샷, 요청 통계 및 모델 상호작용을 보여줍니다.](/img/RemembrallDashboard.png "Remembrall 대시보드 인터페이스")

이것은 OpenAI 호출 위에 경량 프록시로 작동하며, 수집된 관련 사실로 채팅 호출의 컨텍스트를 런타임에서 단순히 보강합니다.

## 설정

시작하려면 [Remembrall 플랫폼에서 Github로 로그인](https://remembrall.dev/login)하고 [설정 페이지에서 API 키를 복사](https://remembrall.dev/dashboard/settings)하세요.

수정된 `openai_api_base`(아래 참조) 및 Remembrall API 키로 보낸 모든 요청은 자동으로 Remembrall 대시보드에서 추적됩니다. 귀하는 **절대** OpenAI 키를 우리 플랫폼과 공유할 필요가 없으며, 이 정보는 **절대** Remembrall 시스템에 저장되지 않습니다.

이를 위해 다음 종속성을 설치해야 합니다:

```bash
pip install -U langchain-openai
```


### 장기 기억 활성화

`x-gp-api-key`를 통해 `openai_api_base` 및 Remembrall API 키를 설정하는 것 외에도, 기억을 유지할 UID를 지정해야 합니다. 이는 일반적으로 고유한 사용자 식별자(예: 이메일)가 됩니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Remembrall"}]-->
from langchain_openai import ChatOpenAI
chat_model = ChatOpenAI(openai_api_base="https://remembrall.dev/api/openai/v1",
                        model_kwargs={
                            "headers":{
                                "x-gp-api-key": "remembrall-api-key-here",
                                "x-gp-remember": "user@email.com",
                            }
                        })

chat_model.predict("My favorite color is blue.")
import time; time.sleep(5)  # wait for system to save fact via auto save
print(chat_model.predict("What is my favorite color?"))
```


### 검색 보강 생성 활성화

먼저, [Remembrall 대시보드](https://remembrall.dev/dashboard/spells)에서 문서 컨텍스트를 생성합니다. 문서 텍스트를 붙여넣거나 PDF로 문서를 업로드하여 처리합니다. 문서 컨텍스트 ID를 저장하고 아래와 같이 삽입합니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Remembrall"}]-->
from langchain_openai import ChatOpenAI
chat_model = ChatOpenAI(openai_api_base="https://remembrall.dev/api/openai/v1",
                        model_kwargs={
                            "headers":{
                                "x-gp-api-key": "remembrall-api-key-here",
                                "x-gp-context": "document-context-id-goes-here",
                            }
                        })

print(chat_model.predict("This is a question that can be answered with my document."))
```
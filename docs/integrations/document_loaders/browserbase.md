---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/browserbase.ipynb
description: Browserbase는 헤드리스 브라우저를 안정적으로 실행, 관리 및 모니터링할 수 있는 개발자 플랫폼입니다. AI 데이터
  수집을 지원합니다.
---

# Browserbase

[Browserbase](https://browserbase.com)는 헤드리스 브라우저를 신뢰성 있게 실행, 관리 및 모니터링하기 위한 개발자 플랫폼입니다.

AI 데이터 검색을 다음으로 강화하세요:
- [서버리스 인프라](https://docs.browserbase.com/under-the-hood)는 복잡한 UI에서 데이터를 추출하기 위한 신뢰할 수 있는 브라우저를 제공합니다.
- [스텔스 모드](https://docs.browserbase.com/features/stealth-mode)는 포함된 지문 인식 전술과 자동 캡차 해결 기능을 제공합니다.
- [세션 디버거](https://docs.browserbase.com/features/sessions)는 네트워크 타임라인 및 로그와 함께 브라우저 세션을 검사합니다.
- [라이브 디버그](https://docs.browserbase.com/guides/session-debug-connection/browser-remote-control)는 자동화를 빠르게 디버그할 수 있도록 합니다.

## 설치 및 설정

- [browserbase.com](https://browserbase.com)에서 API 키와 프로젝트 ID를 가져와 환경 변수(`BROWSERBASE_API_KEY`, `BROWSERBASE_PROJECT_ID`)에 설정합니다.
- [Browserbase SDK](http://github.com/browserbase/python-sdk)를 설치합니다:

```python
% pip install browserbase
```


## 문서 로딩

`BrowserbaseLoader`를 사용하여 LangChain에 웹페이지를 로드할 수 있습니다. 선택적으로 `text_content` 매개변수를 설정하여 페이지를 텍스트 전용 표현으로 변환할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "BrowserbaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.browserbase.BrowserbaseLoader.html", "title": "Browserbase"}]-->
from langchain_community.document_loaders import BrowserbaseLoader
```


```python
loader = BrowserbaseLoader(
    urls=[
        "https://example.com",
    ],
    # Text mode
    text_content=False,
)

docs = loader.load()
print(docs[0].page_content[:61])
```


### 로더 옵션

- `urls` 필수. 가져올 URL 목록입니다.
- `text_content` 텍스트 콘텐츠만 검색합니다. 기본값은 `False`입니다.
- `api_key` 선택 사항. Browserbase API 키입니다. 기본값은 `BROWSERBASE_API_KEY` 환경 변수입니다.
- `project_id` 선택 사항. Browserbase 프로젝트 ID입니다. 기본값은 `BROWSERBASE_PROJECT_ID` 환경 변수입니다.
- `session_id` 선택 사항. 기존 세션 ID를 제공합니다.
- `proxy` 선택 사항. 프록시 사용/사용 중지 설정입니다.

## 이미지 로딩

다중 모달 모델을 위해 웹페이지의 스크린샷(바이트 형식)도 로드할 수 있습니다.

GPT-4V를 사용한 전체 예제:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Browserbase"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Browserbase"}]-->
from browserbase import Browserbase
from browserbase.helpers.gpt4 import GPT4VImage, GPT4VImageDetail
from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI

chat = ChatOpenAI(model="gpt-4-vision-preview", max_tokens=256)
browser = Browserbase()

screenshot = browser.screenshot("https://browserbase.com")

result = chat.invoke(
    [
        HumanMessage(
            content=[
                {"type": "text", "text": "What color is the logo?"},
                GPT4VImage(screenshot, GPT4VImageDetail.auto),
            ]
        )
    ]
)

print(result.content)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
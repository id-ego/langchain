---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/gmail.ipynb
description: GMail에서 데이터를 로드하는 방법을 설명하며, 이메일 응답을 기반으로 훈련 예제를 생성하는 로더에 대해 안내합니다.
---

# GMail

이 로더는 GMail에서 데이터를 로드하는 방법에 대해 설명합니다. GMail에서 데이터를 로드하는 방법은 여러 가지가 있을 수 있습니다. 이 로더는 현재 이를 수행하는 방법에 대해 상당히 특정한 의견을 가지고 있습니다. 이 로더는 먼저 사용자가 보낸 모든 메시지를 찾습니다. 그런 다음 이전 이메일에 응답하는 메시지를 찾습니다. 이후 그 이전 이메일을 가져와서 해당 이메일과 사용자의 이메일로 구성된 학습 예제를 생성합니다.

여기에는 명확한 한계가 있습니다. 예를 들어, 생성된 모든 예제는 이전 이메일만을 컨텍스트로 보고 있습니다.

사용 방법:

- Google 개발자 계정 설정: Google 개발자 콘솔로 이동하여 프로젝트를 생성하고 해당 프로젝트에 대해 Gmail API를 활성화합니다. 이렇게 하면 나중에 필요할 credentials.json 파일이 생성됩니다.
- Google 클라이언트 라이브러리 설치: 다음 명령어를 실행하여 Google 클라이언트 라이브러리를 설치합니다:

```python
%pip install --upgrade --quiet  google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client
```


```python
import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]


creds = None
# The file token.json stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
if os.path.exists("email_token.json"):
    creds = Credentials.from_authorized_user_file("email_token.json", SCOPES)
# If there are no (valid) credentials available, let the user log in.
if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            # your creds file here. Please create json file as here https://cloud.google.com/docs/authentication/getting-started
            "creds.json",
            SCOPES,
        )
        creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("email_token.json", "w") as token:
        token.write(creds.to_json())
```


```python
<!--IMPORTS:[{"imported": "GMailLoader", "source": "langchain_community.chat_loaders.gmail", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.gmail.GMailLoader.html", "title": "GMail"}]-->
from langchain_community.chat_loaders.gmail import GMailLoader
```


```python
loader = GMailLoader(creds=creds, n=3)
```


```python
data = loader.load()
```


```python
# Sometimes there can be errors which we silently ignore
len(data)
```


```output
2
```


```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "GMail"}]-->
from langchain_community.chat_loaders.utils import (
    map_ai_messages,
)
```


```python
# This makes messages sent by hchase@langchain.com the AI Messages
# This means you will train an LLM to predict as if it's responding as hchase
training_data = list(
    map_ai_messages(data, sender="Harrison Chase <hchase@langchain.com>")
)
```
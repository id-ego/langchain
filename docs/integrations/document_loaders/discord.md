---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/discord.ipynb
description: Discord는 음성 통화, 영상 통화, 문자 메시지를 통해 사용자들이 소통할 수 있는 플랫폼입니다. 데이터 다운로드 방법도
  안내합니다.
---

# 디스코드

> [디스코드](https://discord.com/)는 VoIP 및 인스턴트 메시징 소셜 플랫폼입니다. 사용자는 음성 통화, 영상 통화, 문자 메시지, 미디어 및 파일을 개인 채팅 또는 "서버"라고 불리는 커뮤니티의 일환으로 소통할 수 있습니다. 서버는 초대 링크를 통해 접근할 수 있는 지속적인 채팅룸 및 음성 채널의 모음입니다.

다음 단계를 따라 `디스코드` 데이터를 다운로드하세요:

1. **사용자 설정**으로 이동합니다.
2. **개인정보 및 안전**으로 이동합니다.
3. **내 모든 데이터 요청**으로 가서 **데이터 요청** 버튼을 클릭합니다.

데이터를 받는 데 30일이 걸릴 수 있습니다. 디스코드에 등록된 이메일 주소로 이메일을 받게 됩니다. 해당 이메일에는 개인 디스코드 데이터를 다운로드할 수 있는 버튼이 포함되어 있습니다.

```python
import os

import pandas as pd
```


```python
path = input('Please enter the path to the contents of the Discord "messages" folder: ')
li = []
for f in os.listdir(path):
    expected_csv_path = os.path.join(path, f, "messages.csv")
    csv_exists = os.path.isfile(expected_csv_path)
    if csv_exists:
        df = pd.read_csv(expected_csv_path, index_col=None, header=0)
        li.append(df)

df = pd.concat(li, axis=0, ignore_index=True, sort=False)
```


```python
<!--IMPORTS:[{"imported": "DiscordChatLoader", "source": "langchain_community.document_loaders.discord", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.discord.DiscordChatLoader.html", "title": "Discord"}]-->
from langchain_community.document_loaders.discord import DiscordChatLoader
```


```python
loader = DiscordChatLoader(df, user_id_col="ID")
print(loader.load())
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
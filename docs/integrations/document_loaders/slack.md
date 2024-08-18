---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/slack.ipynb
description: 이 문서는 Slack에서 생성된 Zip 파일에서 문서를 로드하는 방법과 데이터 세트를 가져오는 지침을 제공합니다.
---

# 슬랙

> [슬랙](https://slack.com/)은 인스턴트 메시징 프로그램입니다.

이 노트북은 `슬랙` 내보내기로 생성된 Zipfile에서 문서를 로드하는 방법을 다룹니다.

이 `슬랙` 내보내기를 받으려면 다음 지침을 따르세요:

## 🧑 데이터셋 수집을 위한 지침

슬랙 데이터를 내보내세요. 이를 위해 워크스페이스 관리 페이지로 이동하여 가져오기/내보내기 옵션을 클릭합니다 ({your_slack_domain}.slack.com/services/export). 그런 다음 적절한 날짜 범위를 선택하고 `내보내기 시작`을 클릭하세요. 슬랙은 내보내기가 준비되면 이메일과 DM을 보냅니다.

다운로드는 다운로드 폴더(또는 OS 구성에 따라 다운로드를 찾을 수 있는 위치)에 `.zip` 파일을 생성합니다.

`.zip` 파일의 경로를 복사하고 아래에 `LOCAL_ZIPFILE`로 지정하세요.

```python
<!--IMPORTS:[{"imported": "SlackDirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.slack_directory.SlackDirectoryLoader.html", "title": "Slack"}]-->
from langchain_community.document_loaders import SlackDirectoryLoader
```


```python
# Optionally set your Slack URL. This will give you proper URLs in the docs sources.
SLACK_WORKSPACE_URL = "https://xxx.slack.com"
LOCAL_ZIPFILE = ""  # Paste the local paty to your Slack zip file here.

loader = SlackDirectoryLoader(LOCAL_ZIPFILE, SLACK_WORKSPACE_URL)
```


```python
docs = loader.load()
docs
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
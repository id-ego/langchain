---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_drive.ipynb
description: 이 문서는 LangChain을 Google Drive API에 연결하는 방법을 안내합니다. 필요한 준비물과 Google Docs
  데이터 검색 방법을 설명합니다.
---

# 구글 드라이브

이 노트북은 LangChain을 `Google Drive API`에 연결하는 방법을 설명합니다.

## 전제 조건

1. 구글 클라우드 프로젝트를 생성하거나 기존 프로젝트를 사용합니다.
2. [Google Drive API](https://console.cloud.google.com/flows/enableapi?apiid=drive.googleapis.com)를 활성화합니다.
3. [데스크탑 앱에 대한 인증 자격 증명 승인](https://developers.google.com/drive/api/quickstart/python#authorize_credentials_for_a_desktop_application)을 수행합니다.
4. `pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib`를 실행합니다.

## Google Docs 데이터 검색 지침
기본적으로 `GoogleDriveTools`와 `GoogleDriveWrapper`는 `credentials.json` 파일이 `~/.credentials/credentials.json`에 있기를 기대하지만, 이는 `GOOGLE_ACCOUNT_FILE` 환경 변수를 사용하여 구성할 수 있습니다.
`token.json`의 위치는 동일한 디렉토리를 사용하거나 `token_path` 매개변수를 사용할 수 있습니다. `token.json`은 도구를 처음 사용할 때 자동으로 생성됩니다.

`GoogleDriveSearchTool`은 몇 가지 요청으로 파일 선택을 검색할 수 있습니다.

기본적으로 `folder_id`를 사용하는 경우, 쿼리와 이름이 일치하면 이 폴더 내의 모든 파일을 `Document`로 검색할 수 있습니다.

```python
%pip install --upgrade --quiet  google-api-python-client google-auth-httplib2 google-auth-oauthlib langchain-community
```


URL에서 폴더 및 문서 ID를 얻을 수 있습니다:

* 폴더: https://drive.google.com/drive/u/0/folders/1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5 -> 폴더 ID는 `"1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5"`입니다.
* 문서: https://docs.google.com/document/d/1bfaMQ18_i56204VaQDVeAFpqEijJTgvurupdEDiaUQw/edit -> 문서 ID는 `"1bfaMQ18_i56204VaQDVeAFpqEijJTgvurupdEDiaUQw"`입니다.

특별 값 `root`는 개인 홈을 나타냅니다.

```python
folder_id = "root"
# folder_id='1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5'
```


기본적으로 이러한 MIME 유형을 가진 모든 파일은 `Document`로 변환될 수 있습니다.
- text/text
- text/plain
- text/html
- text/csv
- text/markdown
- image/png
- image/jpeg
- application/epub+zip
- application/pdf
- application/rtf
- application/vnd.google-apps.document (GDoc)
- application/vnd.google-apps.presentation (GSlide)
- application/vnd.google-apps.spreadsheet (GSheet)
- application/vnd.google.colaboratory (Notebook colab)
- application/vnd.openxmlformats-officedocument.presentationml.presentation (PPTX)
- application/vnd.openxmlformats-officedocument.wordprocessingml.document (DOCX)

이를 업데이트하거나 사용자 정의하는 것이 가능합니다. `GoogleDriveAPIWrapper`의 문서를 참조하십시오.

하지만 해당 패키지는 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  unstructured
```


```python
from langchain_googledrive.tools.google_drive.tool import GoogleDriveSearchTool
from langchain_googledrive.utilities.google_drive import GoogleDriveAPIWrapper

# By default, search only in the filename.
tool = GoogleDriveSearchTool(
    api_wrapper=GoogleDriveAPIWrapper(
        folder_id=folder_id,
        num_results=2,
        template="gdrive-query-in-folder",  # Search in the body of documents
    )
)
```


```python
import logging

logging.basicConfig(level=logging.INFO)
```


```python
tool.run("machine learning")
```


```python
tool.description
```


```python
<!--IMPORTS:[{"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Google Drive"}]-->
from langchain.agents import load_tools

tools = load_tools(
    ["google-drive-search"],
    folder_id=folder_id,
    template="gdrive-query-in-folder",
)
```


## 에이전트 내에서 사용

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Google Drive"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Google Drive"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Google Drive"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)
agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent=AgentType.STRUCTURED_CHAT_ZERO_SHOT_REACT_DESCRIPTION,
)
```


```python
agent.run("Search in google drive, who is 'Yann LeCun' ?")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
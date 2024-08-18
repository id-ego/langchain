---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/notion.ipynb
description: 이 문서는 Notion 데이터베이스 덤프에서 문서를 로드하는 방법과 데이터 세트를 가져오는 지침을 제공합니다.
---

# Notion DB 1/2

> [Notion](https://www.notion.so/)은 칸반 보드, 작업, 위키 및 데이터베이스를 통합한 수정된 Markdown 지원을 갖춘 협업 플랫폼입니다. 이는 노트 작성, 지식 및 데이터 관리, 프로젝트 및 작업 관리를 위한 올인원 작업 공간입니다.

이 노트북은 Notion 데이터베이스 덤프에서 문서를 로드하는 방법을 다룹니다.

이 Notion 덤프를 얻으려면 다음 지침을 따르세요:

## 🧑 데이터셋 수집을 위한 지침

Notion에서 데이터셋을 내보내세요. 오른쪽 상단 모서리에 있는 세 개의 점을 클릭한 다음 `Export`를 클릭하면 됩니다.

내보낼 때 `Markdown & CSV` 형식 옵션을 선택하는 것을 잊지 마세요.

이렇게 하면 다운로드 폴더에 `.zip` 파일이 생성됩니다. `.zip` 파일을 이 저장소로 이동하세요.

다음 명령어를 실행하여 zip 파일의 압축을 풉니다 (필요에 따라 `Export...`를 자신의 파일 이름으로 교체하세요).

```shell
unzip Export-d3adfe0f-3131-4bf3-8987-a52017fc1bae.zip -d Notion_DB
```


다음 명령어를 실행하여 데이터를 수집합니다.

```python
<!--IMPORTS:[{"imported": "NotionDirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.notion.NotionDirectoryLoader.html", "title": "Notion DB 1/2"}]-->
from langchain_community.document_loaders import NotionDirectoryLoader
```


```python
loader = NotionDirectoryLoader("Notion_DB")
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
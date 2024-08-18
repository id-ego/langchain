---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/dropbox.ipynb
description: Dropbox에서 문서를 로드하는 방법을 다루며, 일반 파일과 Dropbox Paper 파일을 지원하는 방법을 설명합니다.
---

# 드롭박스

[드롭박스](https://en.wikipedia.org/wiki/Dropbox)는 전통적인 파일, 클라우드 콘텐츠 및 웹 바로가기를 한 곳에 모아주는 파일 호스팅 서비스입니다.

이 노트북에서는 *드롭박스*에서 문서를 로드하는 방법을 다룹니다. 텍스트 및 PDF 파일과 같은 일반 파일 외에도 *드롭박스 페이퍼* 파일도 지원합니다.

## 전제 조건

1. 드롭박스 앱을 만듭니다.
2. 앱에 다음 범위 권한을 부여합니다: `files.metadata.read` 및 `files.content.read`.
3. 액세스 토큰을 생성합니다: https://www.dropbox.com/developers/apps/create.
4. `pip install dropbox` (PDF 파일 형식의 경우 `pip install "unstructured[pdf]"`가 필요합니다).

## 지침

`DropboxLoader`는 드롭박스 앱을 만들고 액세스 토큰을 생성해야 합니다. 이는 https://www.dropbox.com/developers/apps/create에서 수행할 수 있습니다. 또한 드롭박스 Python SDK가 설치되어 있어야 합니다 (pip install dropbox).

DropboxLoader는 드롭박스 파일 경로 목록 또는 단일 드롭박스 폴더 경로에서 데이터를 로드할 수 있습니다. 두 경로는 액세스 토큰에 연결된 드롭박스 계정의 루트 디렉토리에 상대적이어야 합니다.

```python
pip install dropbox
```

```output
Requirement already satisfied: dropbox in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (11.36.2)
Requirement already satisfied: requests>=2.16.2 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from dropbox) (2.31.0)
Requirement already satisfied: six>=1.12.0 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from dropbox) (1.16.0)
Requirement already satisfied: stone>=2 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from dropbox) (3.3.1)
Requirement already satisfied: charset-normalizer<4,>=2 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from requests>=2.16.2->dropbox) (3.2.0)
Requirement already satisfied: idna<4,>=2.5 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from requests>=2.16.2->dropbox) (3.4)
Requirement already satisfied: urllib3<3,>=1.21.1 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from requests>=2.16.2->dropbox) (2.0.4)
Requirement already satisfied: certifi>=2017.4.17 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from requests>=2.16.2->dropbox) (2023.7.22)
Requirement already satisfied: ply>=3.4 in /Users/rbarragan/.local/share/virtualenvs/langchain-kv0dsrF5/lib/python3.11/site-packages (from stone>=2->dropbox) (3.11)
Note: you may need to restart the kernel to use updated packages.
```


```python
<!--IMPORTS:[{"imported": "DropboxLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dropbox.DropboxLoader.html", "title": "Dropbox"}]-->
from langchain_community.document_loaders import DropboxLoader
```


```python
# Generate access token: https://www.dropbox.com/developers/apps/create.
dropbox_access_token = "<DROPBOX_ACCESS_TOKEN>"
# Dropbox root folder
dropbox_folder_path = ""
```


```python
loader = DropboxLoader(
    dropbox_access_token=dropbox_access_token,
    dropbox_folder_path=dropbox_folder_path,
    recursive=False,
)
```


```python
documents = loader.load()
```

```output
File /JHSfLKn0.jpeg could not be decoded as text. Skipping.
File /A REPORT ON WILES’ CAMBRIDGE LECTURES.pdf could not be decoded as text. Skipping.
```


```python
for document in documents:
    print(document)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
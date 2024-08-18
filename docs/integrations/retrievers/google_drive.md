---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/google_drive.ipynb
description: 이 문서는 Google Drive에서 문서를 검색하는 방법을 다룹니다. API 설정 및 Python 라이브러리 설치 방법을
  안내합니다.
---

# 구글 드라이브

이 노트북은 `Google Drive`에서 문서를 검색하는 방법을 다룹니다.

## 전제 조건

1. 구글 클라우드 프로젝트를 생성하거나 기존 프로젝트를 사용합니다.
2. [Google Drive API](https://console.cloud.google.com/flows/enableapi?apiid=drive.googleapis.com)를 활성화합니다.
3. [데스크톱 앱에 대한 인증 자격 증명 승인](https://developers.google.com/drive/api/quickstart/python#authorize_credentials_for_a_desktop_application)합니다.
4. `pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib`를 실행합니다.

## 구글 문서 검색하기

기본적으로 `GoogleDriveRetriever`는 `credentials.json` 파일이 `~/.credentials/credentials.json`에 있기를 기대하지만, 이는 `GOOGLE_ACCOUNT_FILE` 환경 변수를 사용하여 구성할 수 있습니다.
`token.json`의 위치는 동일한 디렉토리를 사용합니다(또는 매개변수 `token_path`를 사용할 수 있습니다). `token.json`은 검색기를 처음 사용할 때 자동으로 생성됩니다.

`GoogleDriveRetriever`는 일부 요청으로 파일 선택을 검색할 수 있습니다.

기본적으로 `folder_id`를 사용하는 경우, 이 폴더 내의 모든 파일을 `Document`로 검색할 수 있습니다.

URL에서 폴더 및 문서 ID를 얻을 수 있습니다:

* 폴더: https://drive.google.com/drive/u/0/folders/1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5 -> 폴더 ID는 `"1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5"`입니다.
* 문서: https://docs.google.com/document/d/1bfaMQ18_i56204VaQDVeAFpqEijJTgvurupdEDiaUQw/edit -> 문서 ID는 `"1bfaMQ18_i56204VaQDVeAFpqEijJTgvurupdEDiaUQw"`입니다.

특별 값 `root`는 개인 홈을 의미합니다.

```python
from langchain_googledrive.retrievers import GoogleDriveRetriever

folder_id = "root"
# folder_id='1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5'

retriever = GoogleDriveRetriever(
    num_results=2,
)
```


기본적으로 이러한 MIME 유형을 가진 모든 파일은 `Document`로 변환될 수 있습니다.

- `text/text`
- `text/plain`
- `text/html`
- `text/csv`
- `text/markdown`
- `image/png`
- `image/jpeg`
- `application/epub+zip`
- `application/pdf`
- `application/rtf`
- `application/vnd.google-apps.document` (GDoc)
- `application/vnd.google-apps.presentation` (GSlide)
- `application/vnd.google-apps.spreadsheet` (GSheet)
- `application/vnd.google.colaboratory` (Notebook colab)
- `application/vnd.openxmlformats-officedocument.presentationml.presentation` (PPTX)
- `application/vnd.openxmlformats-officedocument.wordprocessingml.document` (DOCX)

이를 업데이트하거나 사용자 정의할 수 있습니다. `GoogleDriveRetriever`의 문서를 참조하십시오.

하지만, 해당 패키지가 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  unstructured
```


```python
retriever.invoke("machine learning")
```


파일 선택 기준을 사용자 정의할 수 있습니다. 미리 정의된 필터 세트가 제안됩니다:

| 템플릿                                  | 설명                                                               |
| --------------------------------------   | ------------------------------------------------------------------ |
| `gdrive-all-in-folder`                   | `folder_id`에서 모든 호환 파일 반환                                 |
| `gdrive-query`                           | 모든 드라이브에서 `query` 검색                                    |
| `gdrive-by-name`                         | 이름이 `query`인 파일 검색                                        |
| `gdrive-query-in-folder`                 | `folder_id`에서 `query` 검색 (및 `_recursive=true`에서 하위 폴더) |
| `gdrive-mime-type`                       | 특정 `mime_type` 검색                                             |
| `gdrive-mime-type-in-folder`             | `folder_id`에서 특정 `mime_type` 검색                             |
| `gdrive-query-with-mime-type`            | 특정 `mime_type`로 `query` 검색                                   |
| `gdrive-query-with-mime-type-and-folder` | 특정 `mime_type`와 `folder_id`에서 `query` 검색                   |

```python
retriever = GoogleDriveRetriever(
    template="gdrive-query",  # Search everywhere
    num_results=2,  # But take only 2 documents
)
for doc in retriever.invoke("machine learning"):
    print("---")
    print(doc.page_content.strip()[:60] + "...")
```


그 외에도 전문화된 `PromptTemplate`로 프롬프트를 사용자 정의할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Google Drive"}]-->
from langchain_core.prompts import PromptTemplate

retriever = GoogleDriveRetriever(
    template=PromptTemplate(
        input_variables=["query"],
        # See https://developers.google.com/drive/api/guides/search-files
        template="(fullText contains '{query}') "
        "and mimeType='application/vnd.google-apps.document' "
        "and modifiedTime > '2000-01-01T00:00:00' "
        "and trashed=false",
    ),
    num_results=2,
    # See https://developers.google.com/drive/api/v3/reference/files/list
    includeItemsFromAllDrives=False,
    supportsAllDrives=False,
)
for doc in retriever.invoke("machine learning"):
    print(f"{doc.metadata['name']}:")
    print("---")
    print(doc.page_content.strip()[:60] + "...")
```


## 구글 드라이브 '설명' 메타데이터 사용하기

각 구글 드라이브에는 메타데이터에 `description` 필드가 있습니다 (파일의 *세부정보* 참조).
선택한 파일의 설명을 반환하려면 `snippets` 모드를 사용합니다.

```python
retriever = GoogleDriveRetriever(
    template="gdrive-mime-type-in-folder",
    folder_id=folder_id,
    mime_type="application/vnd.google-apps.document",  # Only Google Docs
    num_results=2,
    mode="snippets",
    includeItemsFromAllDrives=False,
    supportsAllDrives=False,
)
retriever.invoke("machine learning")
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/lakefs.ipynb
description: lakeFS는 데이터 레이크에 대한 확장 가능한 버전 관리를 제공하며, Git과 유사한 방식으로 버전을 생성하고 접근할 수
  있습니다.
---

# lakeFS

> [lakeFS](https://docs.lakefs.io/)는 데이터 레이크에 대한 확장 가능한 버전 관리를 제공하며, Git과 유사한 의미를 사용하여 이러한 버전을 생성하고 액세스합니다.

이 노트북은 `lakeFS` 경로에서 문서 객체를 로드하는 방법을 다룹니다(객체이든 접두사이든 상관없이).

## lakeFS 로더 초기화

`ENDPOINT`, `LAKEFS_ACCESS_KEY`, 및 `LAKEFS_SECRET_KEY` 값을 자신의 값으로 교체하십시오.

```python
<!--IMPORTS:[{"imported": "LakeFSLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.lakefs.LakeFSLoader.html", "title": "lakeFS"}]-->
from langchain_community.document_loaders import LakeFSLoader
```


```python
ENDPOINT = ""
LAKEFS_ACCESS_KEY = ""
LAKEFS_SECRET_KEY = ""

lakefs_loader = LakeFSLoader(
    lakefs_access_key=LAKEFS_ACCESS_KEY,
    lakefs_secret_key=LAKEFS_SECRET_KEY,
    lakefs_endpoint=ENDPOINT,
)
```


## 경로 지정
로드할 파일을 제어하기 위해 접두사 또는 전체 객체 경로를 지정할 수 있습니다.

문서를 로드할 `REPO`, `REF`(브랜치, 커밋 ID 또는 태그), 및 경로를 해당하는 `PATH`에 지정하십시오:

```python
REPO = ""
REF = ""
PATH = ""

lakefs_loader.set_repo(REPO)
lakefs_loader.set_ref(REF)
lakefs_loader.set_path(PATH)

docs = lakefs_loader.load()
docs
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/roam.ipynb
description: 이 문서는 Roam Research에서 문서를 로드하는 방법을 설명하며, 개인 지식 기반을 구축하는 데 도움을 줍니다.
---

# Roam

> [ROAM](https://roamresearch.com/)은 개인 지식 기반을 생성하기 위해 설계된 네트워크 사고를 위한 노트 작성 도구입니다.

이 노트북은 Roam 데이터베이스에서 문서를 로드하는 방법을 다룹니다. 이는 [여기](https://github.com/JimmyLv/roam-qa) 있는 예제 저장소에서 많은 영감을 받았습니다.

## 🧑 자신의 데이터셋을 수집하는 방법

Roam Research에서 데이터셋을 내보내세요. 오른쪽 상단 모서리에 있는 세 개의 점을 클릭한 다음 `Export`를 클릭하면 됩니다.

내보낼 때 `Markdown & CSV` 형식 옵션을 선택해야 합니다.

이렇게 하면 다운로드 폴더에 `.zip` 파일이 생성됩니다. 이 `.zip` 파일을 이 저장소로 이동하세요.

다음 명령어를 실행하여 zip 파일의 압축을 풉니다(필요에 따라 `Export...`를 자신의 파일 이름으로 바꾸세요).

```shell
unzip Roam-Export-1675782732639.zip -d Roam_DB
```


```python
<!--IMPORTS:[{"imported": "RoamLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.roam.RoamLoader.html", "title": "Roam"}]-->
from langchain_community.document_loaders import RoamLoader
```


```python
loader = RoamLoader("Roam_DB")
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
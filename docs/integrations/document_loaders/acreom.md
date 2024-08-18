---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/acreom.ipynb
description: acreom은 로컬 마크다운 파일에서 실행되는 개발자 중심의 지식 기반으로, Langchain에 로컬 아크레옴 볼트를 로드하는
  방법을 설명합니다.
---

# acreom

[acreom](https://acreom.com)는 로컬 마크다운 파일에서 실행되는 작업을 가진 개발자 우선 지식 기반입니다.

아래는 로컬 acreom 금고를 Langchain에 로드하는 방법의 예입니다. acreom의 로컬 금고는 일반 텍스트 .md 파일의 폴더이므로 로더는 디렉토리 경로가 필요합니다.

금고 파일에는 YAML 헤더로 저장된 메타데이터가 포함될 수 있습니다. `collect_metadata`가 true로 설정되면 이러한 값이 문서의 메타데이터에 추가됩니다.

```python
<!--IMPORTS:[{"imported": "AcreomLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.acreom.AcreomLoader.html", "title": "acreom"}]-->
from langchain_community.document_loaders import AcreomLoader
```


```python
loader = AcreomLoader("<path-to-acreom-vault>", collect_metadata=False)
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
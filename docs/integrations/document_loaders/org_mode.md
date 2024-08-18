---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/org_mode.ipynb
description: Org-mode는 Emacs에서 메모, 계획 및 저작을 위한 문서 편집 및 조직 모드입니다. UnstructuredOrgModeLoader로
  데이터를 불러올 수 있습니다.
---

# Org-mode

> [Org Mode 문서](https://en.wikipedia.org/wiki/Org-mode)는 메모, 계획 및 저작을 위해 설계된 문서 편집, 형식 지정 및 조직 모드로, 무료 소프트웨어 텍스트 편집기 Emacs 내에서 사용됩니다.

## `UnstructuredOrgModeLoader`

다음 워크플로를 사용하여 `UnstructuredOrgModeLoader`로 Org-mode 파일에서 데이터를 로드할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredOrgModeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.org_mode.UnstructuredOrgModeLoader.html", "title": "Org-mode"}]-->
from langchain_community.document_loaders import UnstructuredOrgModeLoader

loader = UnstructuredOrgModeLoader(
    file_path="./example_data/README.org", mode="elements"
)
docs = loader.load()

print(docs[0])
```

```output
page_content='Example Docs' metadata={'source': './example_data/README.org', 'category_depth': 0, 'last_modified': '2023-12-19T13:42:18', 'languages': ['eng'], 'filetype': 'text/org', 'file_directory': './example_data', 'filename': 'README.org', 'category': 'Title'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
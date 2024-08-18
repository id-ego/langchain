---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/rst.ipynb
description: reStructured Text(RST) 파일은 주로 Python 프로그래밍 언어 커뮤니티에서 기술 문서화에 사용되는 텍스트
  데이터 형식입니다.
---

# RST

> [reStructured Text (RST)](https://en.wikipedia.org/wiki/ReStructuredText) 파일은 주로 Python 프로그래밍 언어 커뮤니티에서 기술 문서화에 사용되는 텍스트 데이터 파일 형식입니다.

## `UnstructuredRSTLoader`

다음 워크플로우를 사용하여 `UnstructuredRSTLoader`로 RST 파일에서 데이터를 로드할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredRSTLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.rst.UnstructuredRSTLoader.html", "title": "RST"}]-->
from langchain_community.document_loaders import UnstructuredRSTLoader

loader = UnstructuredRSTLoader(file_path="./example_data/README.rst", mode="elements")
docs = loader.load()

print(docs[0])
```

```output
page_content='Example Docs' metadata={'source': './example_data/README.rst', 'category_depth': 0, 'last_modified': '2023-12-19T13:42:18', 'languages': ['eng'], 'filetype': 'text/x-rst', 'file_directory': './example_data', 'filename': 'README.rst', 'category': 'Title'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
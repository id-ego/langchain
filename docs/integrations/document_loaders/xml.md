---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/xml.ipynb
description: '`UnstructuredXMLLoader`는 XML 파일을 로드하는 데 사용되며, XML 태그에서 추출한 텍스트를 페이지
  내용으로 제공합니다.'
---

# XML

`UnstructuredXMLLoader`는 `XML` 파일을 로드하는 데 사용됩니다. 로더는 `.xml` 파일과 함께 작동합니다. 페이지 콘텐츠는 XML 태그에서 추출된 텍스트가 됩니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredXMLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.xml.UnstructuredXMLLoader.html", "title": "XML"}]-->
from langchain_community.document_loaders import UnstructuredXMLLoader

loader = UnstructuredXMLLoader(
    "./example_data/factbook.xml",
)
docs = loader.load()
docs[0]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
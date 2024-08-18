---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/odt.ipynb
description: Open Document Format(ODT)는 오피스 애플리케이션을 위한 개방형 XML 기반 파일 형식으로, 문서, 스프레드시트,
  프레젠테이션을 지원합니다.
---

# 오픈 문서 형식 (ODT)

> [오픈 문서 형식(ODF)](https://en.wikipedia.org/wiki/OpenDocument), 또는 `OpenDocument`로 알려진 이 형식은 워드 프로세싱 문서, 스프레드시트, 프레젠테이션 및 그래픽을 위한 오픈 파일 형식으로, ZIP 압축 XML 파일을 사용합니다. 이는 오피스 애플리케이션을 위한 오픈 XML 기반 파일 형식 사양을 제공하기 위해 개발되었습니다.

> 이 표준은 구조화된 정보 표준의 발전을 위한 조직(`OASIS`) 컨소시엄의 기술 위원회에 의해 개발되고 유지 관리됩니다. 이는 `OpenOffice.org` 및 `LibreOffice`의 기본 형식인 Sun Microsystems의 OpenOffice.org XML 사양을 기반으로 하였습니다. 원래는 "오피스 문서에 대한 오픈 표준을 제공하기 위해" `StarOffice`를 위해 개발되었습니다.

`UnstructuredODTLoader`는 `Open Office ODT` 파일을 로드하는 데 사용됩니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredODTLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.odt.UnstructuredODTLoader.html", "title": "Open Document Format (ODT)"}]-->
from langchain_community.document_loaders import UnstructuredODTLoader

loader = UnstructuredODTLoader("example_data/fake.odt", mode="elements")
docs = loader.load()
docs[0]
```


```output
Document(page_content='Lorem ipsum dolor sit amet.', metadata={'source': 'example_data/fake.odt', 'category_depth': 0, 'file_directory': 'example_data', 'filename': 'fake.odt', 'last_modified': '2023-12-19T13:42:18', 'languages': ['por', 'cat'], 'filetype': 'application/vnd.oasis.opendocument.text', 'category': 'Title'})
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
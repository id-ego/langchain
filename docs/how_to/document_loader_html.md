---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/document_loader_html.ipynb
description: HTML 문서를 LangChain Document 객체로 로드하는 방법을 설명합니다. Unstructured 및 BeautifulSoup4를
  사용한 파싱 방법을 다룹니다.
---

# HTML 로드하는 방법

하이퍼텍스트 마크업 언어 또는 [HTML](https://en.wikipedia.org/wiki/HTML)은 웹 브라우저에 표시되도록 설계된 문서의 표준 마크업 언어입니다.

이 문서는 LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) 객체에 `HTML` 문서를 로드하는 방법을 다룹니다. 이 객체는 이후에 사용할 수 있습니다.

HTML 파일을 파싱하려면 종종 전문 도구가 필요합니다. 여기에서는 pip를 통해 설치할 수 있는 [Unstructured](https://unstructured-io.github.io/unstructured/)와 [BeautifulSoup4](https://beautiful-soup-4.readthedocs.io/en/latest/)를 사용하여 파싱하는 방법을 보여줍니다. 추가 서비스와의 통합을 찾으려면 통합 페이지로 이동하세요. 예를 들어 [Azure AI Document Intelligence](/docs/integrations/document_loaders/azure_document_intelligence) 또는 [FireCrawl](/docs/integrations/document_loaders/firecrawl)와의 통합이 있습니다.

## Unstructured로 HTML 로드하기

```python
%pip install unstructured
```


```python
<!--IMPORTS:[{"imported": "UnstructuredHTMLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html.UnstructuredHTMLLoader.html", "title": "How to load HTML"}]-->
from langchain_community.document_loaders import UnstructuredHTMLLoader

file_path = "../../docs/integrations/document_loaders/example_data/fake-content.html"

loader = UnstructuredHTMLLoader(file_path)
data = loader.load()

print(data)
```

```output
[Document(page_content='My First Heading\n\nMy first paragraph.', metadata={'source': '../../docs/integrations/document_loaders/example_data/fake-content.html'})]
```

## BeautifulSoup4로 HTML 로드하기

`BeautifulSoup4`를 사용하여 `BSHTMLLoader`로 HTML 문서를 로드할 수도 있습니다. 이렇게 하면 HTML에서 텍스트가 `page_content`로 추출되고, 페이지 제목이 `metadata`의 `title`로 저장됩니다.

```python
%pip install bs4
```


```python
<!--IMPORTS:[{"imported": "BSHTMLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html_bs.BSHTMLLoader.html", "title": "How to load HTML"}]-->
from langchain_community.document_loaders import BSHTMLLoader

loader = BSHTMLLoader(file_path)
data = loader.load()

print(data)
```

```output
[Document(page_content='\nTest Title\n\n\nMy First Heading\nMy first paragraph.\n\n\n', metadata={'source': '../../docs/integrations/document_loaders/example_data/fake-content.html', 'title': 'Test Title'})]
```
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/readthedocs_documentation.ipynb
description: Read the Docs는 Sphinx 문서 생성기를 사용하여 문서를 호스팅하는 오픈 소스 플랫폼입니다. HTML 콘텐츠 로드
  방법을 설명합니다.
---

# ReadTheDocs 문서

> [Read the Docs](https://readthedocs.org/)는 오픈 소스 무료 소프트웨어 문서 호스팅 플랫폼입니다. `Sphinx` 문서 생성기를 사용하여 작성된 문서를 생성합니다.

이 노트북은 `Read-The-Docs` 빌드의 일환으로 생성된 HTML에서 콘텐츠를 로드하는 방법을 다룹니다.

실제 사례는 [여기](https://github.com/langchain-ai/chat-langchain)를 참조하십시오.

이것은 HTML이 이미 폴더에 스크랩되었다고 가정합니다. 이는 다음 명령을 주석 해제하고 실행하여 수행할 수 있습니다.

```python
%pip install --upgrade --quiet  beautifulsoup4
```


```python
#!wget -r -A.html -P rtdocs https://python.langchain.com/en/latest/
```


```python
<!--IMPORTS:[{"imported": "ReadTheDocsLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.readthedocs.ReadTheDocsLoader.html", "title": "ReadTheDocs Documentation"}]-->
from langchain_community.document_loaders import ReadTheDocsLoader
```


```python
loader = ReadTheDocsLoader("rtdocs", features="html.parser")
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
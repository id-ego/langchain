---
description: PubMed는 3,500만 개 이상의 생물 의학 문헌 인용을 포함하며, MEDLINE, 생명 과학 저널 및 온라인 도서의 자료를
  제공합니다.
---

# PubMed

# PubMed

> [PubMed®](https://pubmed.ncbi.nlm.nih.gov/)는 `The National Center for Biotechnology Information, National Library of Medicine`에서 제공하며, `MEDLINE`, 생명 과학 저널 및 온라인 서적에서 3500만 개 이상의 생물 의학 문헌 인용을 포함합니다. 인용에는 `PubMed Central` 및 출판사 웹사이트의 전체 텍스트 콘텐츠에 대한 링크가 포함될 수 있습니다.

## Setup
파이썬 패키지를 설치해야 합니다.

```bash
pip install xmltodict
```


### Retriever

[사용 예제](/docs/integrations/retrievers/pubmed)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "PubMedRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.pubmed.PubMedRetriever.html", "title": "PubMed"}]-->
from langchain.retrievers import PubMedRetriever
```


### Document Loader

[사용 예제](/docs/integrations/document_loaders/pubmed)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "PubMedLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pubmed.PubMedLoader.html", "title": "PubMed"}]-->
from langchain_community.document_loaders import PubMedLoader
```
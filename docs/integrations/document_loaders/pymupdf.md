---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/pymupdf.ipynb
description: '`PyMuPDF`는 속도 최적화와 PDF 및 페이지에 대한 상세 메타데이터를 제공하며, 각 페이지마다 하나의 문서를 반환합니다.'
---

# PyMuPDF

`PyMuPDF`는 속도를 최적화하였으며, PDF 및 그 페이지에 대한 자세한 메타데이터를 포함하고 있습니다. 페이지당 하나의 문서를 반환합니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원|
| :--- | :--- | :---: | :---: |  :---: |
| [PyMuPDFLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyMuPDFLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| PyMuPDFLoader | ✅ | ❌ | 

## 설정

### 자격 증명

`PyMuPDFLoader`를 사용하기 위해서는 자격 증명이 필요하지 않습니다.

모델 호출에 대한 자동화된 최상의 추적을 원하신다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community**와 **pymupdf**를 설치합니다.

```python
%pip install -qU langchain-community pymupdf
```


## 초기화

이제 로더를 초기화하고 문서를 로드할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PyMuPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyMuPDFLoader.html", "title": "PyMuPDF"}]-->
from langchain_community.document_loaders import PyMuPDFLoader

loader = PyMuPDFLoader("./example_data/layout-parser-paper.pdf")
```


## 로드

`load` 호출에서 키워드 인수로 [PyMuPDF 문서](https://pymupdf.readthedocs.io/en/latest/app1.html#plain-text/)의 모든 옵션을 전달할 수 있으며, 이는 `get_text()` 호출로 전달됩니다.

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'file_path': './example_data/layout-parser-paper.pdf', 'page': 0, 'total_pages': 16, 'format': 'PDF 1.5', 'title': '', 'author': '', 'subject': '', 'keywords': '', 'creator': 'LaTeX with hyperref', 'producer': 'pdfTeX-1.40.21', 'creationDate': 'D:20210622012710Z', 'modDate': 'D:20210622012710Z', 'trapped': ''}, page_content='LayoutParser: A Uniﬁed Toolkit for Deep\nLearning Based Document Image Analysis\nZejiang Shen1 (\x00), Ruochen Zhang2, Melissa Dell3, Benjamin Charles Germain\nLee4, Jacob Carlson3, and Weining Li5\n1 Allen Institute for AI\nshannons@allenai.org\n2 Brown University\nruochen zhang@brown.edu\n3 Harvard University\n{melissadell,jacob carlson}@fas.harvard.edu\n4 University of Washington\nbcgl@cs.washington.edu\n5 University of Waterloo\nw422li@uwaterloo.ca\nAbstract. Recent advances in document image analysis (DIA) have been\nprimarily driven by the application of neural networks. Ideally, research\noutcomes could be easily deployed in production and extended for further\ninvestigation. However, various factors like loosely organized codebases\nand sophisticated model conﬁgurations complicate the easy reuse of im-\nportant innovations by a wide audience. Though there have been on-going\neﬀorts to improve reusability and simplify deep learning (DL) model\ndevelopment in disciplines like natural language processing and computer\nvision, none of them are optimized for challenges in the domain of DIA.\nThis represents a major gap in the existing toolkit, as DIA is central to\nacademic research across a wide range of disciplines in the social sciences\nand humanities. This paper introduces LayoutParser, an open-source\nlibrary for streamlining the usage of DL in DIA research and applica-\ntions. The core LayoutParser library comes with a set of simple and\nintuitive interfaces for applying and customizing DL models for layout de-\ntection, character recognition, and many other document processing tasks.\nTo promote extensibility, LayoutParser also incorporates a community\nplatform for sharing both pre-trained models and full document digiti-\nzation pipelines. We demonstrate that LayoutParser is helpful for both\nlightweight and large-scale digitization pipelines in real-word use cases.\nThe library is publicly available at https://layout-parser.github.io.\nKeywords: Document Image Analysis · Deep Learning · Layout Analysis\n· Character Recognition · Open Source library · Toolkit.\n1\nIntroduction\nDeep Learning(DL)-based approaches are the state-of-the-art for a wide range of\ndocument image analysis (DIA) tasks including document image classiﬁcation [11,\narXiv:2103.15348v2  [cs.CV]  21 Jun 2021\n')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/layout-parser-paper.pdf', 'file_path': './example_data/layout-parser-paper.pdf', 'page': 0, 'total_pages': 16, 'format': 'PDF 1.5', 'title': '', 'author': '', 'subject': '', 'keywords': '', 'creator': 'LaTeX with hyperref', 'producer': 'pdfTeX-1.40.21', 'creationDate': 'D:20210622012710Z', 'modDate': 'D:20210622012710Z', 'trapped': ''}
```

## 지연 로드

```python
page = []
for doc in loader.lazy_load():
    page.append(doc)
    if len(page) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        page = []
```


## API 참조

모든 PyMuPDFLoader 기능 및 구성에 대한 자세한 문서는 API 참조를 확인하세요: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyMuPDFLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
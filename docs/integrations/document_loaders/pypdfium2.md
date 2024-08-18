---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/pypdfium2.ipynb
description: PyPDFium2 문서 로더에 대한 시작 가이드를 제공하며, 주요 기능과 설정에 대한 통찰력을 제공합니다.
---

# PyPDFium2Loader

이 노트북은 PyPDFium2 [문서 로더](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 시작하는 데 필요한 간단한 개요를 제공합니다. 모든 __ModuleName__Loader 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFium2Loader.html)로 이동하십시오.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원|
| :--- | :--- | :---: | :---: |  :---: |
| [PyPDFium2Loader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFium2Loader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| PyPDFium2Loader | ✅ | ❌ | 

## 설정

PyPDFium2 문서 로더에 접근하려면 `langchain-community` 통합 패키지를 설치해야 합니다.

### 자격 증명

자격 증명이 필요하지 않습니다.

모델 호출의 자동 최상급 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community**를 설치합니다.

```python
%pip install -qU langchain_community
```


## 초기화

이제 모델 객체를 인스턴스화하고 문서를 로드할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "PyPDFium2Loader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFium2Loader.html", "title": "PyPDFium2Loader"}]-->
from langchain_community.document_loaders import PyPDFium2Loader

file_path = "./example_data/layout-parser-paper.pdf"
loader = PyPDFium2Loader(file_path)
```


## 로드

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'page': 0}, page_content='LayoutParser: A Unified Toolkit for Deep\r\nLearning Based Document Image Analysis\r\nZejiang Shen\r\n1\r\n(), Ruochen Zhang\r\n2\r\n, Melissa Dell\r\n3\r\n, Benjamin Charles Germain\r\nLee\r\n4\r\n, Jacob Carlson\r\n3\r\n, and Weining Li\r\n5\r\n1 Allen Institute for AI\r\nshannons@allenai.org 2 Brown University\r\nruochen zhang@brown.edu 3 Harvard University\r\n{melissadell,jacob carlson}@fas.harvard.edu\r\n4 University of Washington\r\nbcgl@cs.washington.edu 5 University of Waterloo\r\nw422li@uwaterloo.ca\r\nAbstract. Recent advances in document image analysis (DIA) have been\r\nprimarily driven by the application of neural networks. Ideally, research\r\noutcomes could be easily deployed in production and extended for further\r\ninvestigation. However, various factors like loosely organized codebases\r\nand sophisticated model configurations complicate the easy reuse of im\x02portant innovations by a wide audience. Though there have been on-going\r\nefforts to improve reusability and simplify deep learning (DL) model\r\ndevelopment in disciplines like natural language processing and computer\r\nvision, none of them are optimized for challenges in the domain of DIA.\r\nThis represents a major gap in the existing toolkit, as DIA is central to\r\nacademic research across a wide range of disciplines in the social sciences\r\nand humanities. This paper introduces LayoutParser, an open-source\r\nlibrary for streamlining the usage of DL in DIA research and applica\x02tions. The core LayoutParser library comes with a set of simple and\r\nintuitive interfaces for applying and customizing DL models for layout de\x02tection, character recognition, and many other document processing tasks.\r\nTo promote extensibility, LayoutParser also incorporates a community\r\nplatform for sharing both pre-trained models and full document digiti\x02zation pipelines. We demonstrate that LayoutParser is helpful for both\r\nlightweight and large-scale digitization pipelines in real-word use cases.\r\nThe library is publicly available at https://layout-parser.github.io.\r\nKeywords: Document Image Analysis· Deep Learning· Layout Analysis\r\n· Character Recognition· Open Source library· Toolkit.\r\n1 Introduction\r\nDeep Learning(DL)-based approaches are the state-of-the-art for a wide range of\r\ndocument image analysis (DIA) tasks including document image classification [11,\r\narXiv:2103.15348v2 [cs.CV] 21 Jun 2021\n')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/layout-parser-paper.pdf', 'page': 0}
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

모든 PyPDFium2Loader 기능 및 구성에 대한 자세한 문서는 API 참조로 이동하십시오: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFium2Loader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/pypdfloader.ipynb
description: '`PyPDFLoader`는 PDF 문서를 로드하는 간편한 도구로, Langchain의 문서 로더 기능을 활용하여 손쉽게 시작할
  수 있습니다.'
---

# PyPDFLoader

이 노트북은 `PyPDF` [문서 로더](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 시작하는 데 필요한 간단한 개요를 제공합니다. 모든 DocumentLoader 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html)에서 확인할 수 있습니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 |
| :--- | :--- | :---: | :---: |  :---: |
| [PyPDFLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원 |
| :---: | :---: | :---: |
| PyPDFLoader | ✅ | ❌ | 

## 설정

### 자격 증명

`PyPDFLoader`를 사용하기 위해 필요한 자격 증명은 없습니다.

### 설치

`PyPDFLoader`를 사용하려면 `langchain-community` 파이썬 패키지를 다운로드해야 합니다:

```python
%pip install -qU langchain_community pypdf
```


## 초기화

이제 모델 객체를 인스턴스화하고 문서를 로드할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "PyPDFLoader"}]-->
from langchain_community.document_loaders import PyPDFLoader

loader = PyPDFLoader(
    "./example_data/layout-parser-paper.pdf",
)
```


## 로드

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'page': 0}, page_content='LayoutParser : A Uniﬁed Toolkit for Deep\nLearning Based Document Image Analysis\nZejiang Shen1( \x00), Ruochen Zhang2, Melissa Dell3, Benjamin Charles Germain\nLee4, Jacob Carlson3, and Weining Li5\n1Allen Institute for AI\nshannons@allenai.org\n2Brown University\nruochen zhang@brown.edu\n3Harvard University\n{melissadell,jacob carlson }@fas.harvard.edu\n4University of Washington\nbcgl@cs.washington.edu\n5University of Waterloo\nw422li@uwaterloo.ca\nAbstract. Recent advances in document image analysis (DIA) have been\nprimarily driven by the application of neural networks. Ideally, research\noutcomes could be easily deployed in production and extended for further\ninvestigation. However, various factors like loosely organized codebases\nand sophisticated model conﬁgurations complicate the easy reuse of im-\nportant innovations by a wide audience. Though there have been on-going\neﬀorts to improve reusability and simplify deep learning (DL) model\ndevelopment in disciplines like natural language processing and computer\nvision, none of them are optimized for challenges in the domain of DIA.\nThis represents a major gap in the existing toolkit, as DIA is central to\nacademic research across a wide range of disciplines in the social sciences\nand humanities. This paper introduces LayoutParser , an open-source\nlibrary for streamlining the usage of DL in DIA research and applica-\ntions. The core LayoutParser library comes with a set of simple and\nintuitive interfaces for applying and customizing DL models for layout de-\ntection, character recognition, and many other document processing tasks.\nTo promote extensibility, LayoutParser also incorporates a community\nplatform for sharing both pre-trained models and full document digiti-\nzation pipelines. We demonstrate that LayoutParser is helpful for both\nlightweight and large-scale digitization pipelines in real-word use cases.\nThe library is publicly available at https://layout-parser.github.io .\nKeywords: Document Image Analysis ·Deep Learning ·Layout Analysis\n·Character Recognition ·Open Source library ·Toolkit.\n1 Introduction\nDeep Learning(DL)-based approaches are the state-of-the-art for a wide range of\ndocument image analysis (DIA) tasks including document image classiﬁcation [ 11,arXiv:2103.15348v2  [cs.CV]  21 Jun 2021')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/layout-parser-paper.pdf', 'page': 0}
```

## 지연 로드

```python
pages = []
for doc in loader.lazy_load():
    pages.append(doc)
    if len(pages) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        pages = []
len(pages)
```


```output
6
```


```python
print(pages[0].page_content[:100])
print(pages[0].metadata)
```

```output
LayoutParser : A Uniﬁed Toolkit for DL-Based DIA 11
focuses on precision, eﬃciency, and robustness. 
{'source': './example_data/layout-parser-paper.pdf', 'page': 10}
```

## API 참조

모든 `PyPDFLoader` 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
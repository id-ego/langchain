---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/pdfplumber.ipynb
description: PDFPlumber는 PDF 문서의 메타데이터를 포함하여 페이지별로 문서를 반환하는 로더입니다. 설치 및 사용이 간편합니다.
---

# PDFPlumber

PyMuPDF와 마찬가지로, 출력 문서에는 PDF 및 페이지에 대한 자세한 메타데이터가 포함되어 있으며, 페이지당 하나의 문서를 반환합니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 |
| :--- | :--- | :---: | :---: |  :---: |
| [PDFPlumberLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PDFPlumberLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원 |
| :---: | :---: | :---: |
| PDFPlumberLoader | ✅ | ❌ | 

## 설정

### 자격 증명

이 로더를 사용하기 위해서는 자격 증명이 필요하지 않습니다.

모델 호출에 대한 자동화된 최상의 추적을 원하신다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

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
<!--IMPORTS:[{"imported": "PDFPlumberLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PDFPlumberLoader.html", "title": "PDFPlumber"}]-->
from langchain_community.document_loaders import PDFPlumberLoader

loader = PDFPlumberLoader("./example_data/layout-parser-paper.pdf")
```


## 로드

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'file_path': './example_data/layout-parser-paper.pdf', 'page': 0, 'total_pages': 16, 'Author': '', 'CreationDate': 'D:20210622012710Z', 'Creator': 'LaTeX with hyperref', 'Keywords': '', 'ModDate': 'D:20210622012710Z', 'PTEX.Fullbanner': 'This is pdfTeX, Version 3.14159265-2.6-1.40.21 (TeX Live 2020) kpathsea version 6.3.2', 'Producer': 'pdfTeX-1.40.21', 'Subject': '', 'Title': '', 'Trapped': 'False'}, page_content='LayoutParser: A Unified Toolkit for Deep\nLearning Based Document Image Analysis\nZejiang Shen1 ((cid:0)), Ruochen Zhang2, Melissa Dell3, Benjamin Charles Germain\nLee4, Jacob Carlson3, and Weining Li5\n1 Allen Institute for AI\nshannons@allenai.org\n2 Brown University\nruochen zhang@brown.edu\n3 Harvard University\n{melissadell,jacob carlson}@fas.harvard.edu\n4 University of Washington\nbcgl@cs.washington.edu\n5 University of Waterloo\nw422li@uwaterloo.ca\nAbstract. Recentadvancesindocumentimageanalysis(DIA)havebeen\nprimarily driven by the application of neural networks. Ideally, research\noutcomescouldbeeasilydeployedinproductionandextendedforfurther\ninvestigation. However, various factors like loosely organized codebases\nand sophisticated model configurations complicate the easy reuse of im-\nportantinnovationsbyawideaudience.Thoughtherehavebeenon-going\nefforts to improve reusability and simplify deep learning (DL) model\ndevelopmentindisciplineslikenaturallanguageprocessingandcomputer\nvision, none of them are optimized for challenges in the domain of DIA.\nThis represents a major gap in the existing toolkit, as DIA is central to\nacademicresearchacross awiderangeof disciplinesinthesocialsciences\nand humanities. This paper introduces LayoutParser, an open-source\nlibrary for streamlining the usage of DL in DIA research and applica-\ntions. The core LayoutParser library comes with a set of simple and\nintuitiveinterfacesforapplyingandcustomizingDLmodelsforlayoutde-\ntection,characterrecognition,andmanyotherdocumentprocessingtasks.\nTo promote extensibility, LayoutParser also incorporates a community\nplatform for sharing both pre-trained models and full document digiti-\nzation pipelines. We demonstrate that LayoutParser is helpful for both\nlightweight and large-scale digitization pipelines in real-word use cases.\nThe library is publicly available at https://layout-parser.github.io.\nKeywords: DocumentImageAnalysis·DeepLearning·LayoutAnalysis\n· Character Recognition · Open Source library · Toolkit.\n1 Introduction\nDeep Learning(DL)-based approaches are the state-of-the-art for a wide range of\ndocumentimageanalysis(DIA)tasksincludingdocumentimageclassification[11,\n1202\nnuJ\n12\n]VC.sc[\n2v84351.3012:viXra\n')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/layout-parser-paper.pdf', 'file_path': './example_data/layout-parser-paper.pdf', 'page': 0, 'total_pages': 16, 'Author': '', 'CreationDate': 'D:20210622012710Z', 'Creator': 'LaTeX with hyperref', 'Keywords': '', 'ModDate': 'D:20210622012710Z', 'PTEX.Fullbanner': 'This is pdfTeX, Version 3.14159265-2.6-1.40.21 (TeX Live 2020) kpathsea version 6.3.2', 'Producer': 'pdfTeX-1.40.21', 'Subject': '', 'Title': '', 'Trapped': 'False'}
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

모든 PDFPlumberLoader 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PDFPlumberLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
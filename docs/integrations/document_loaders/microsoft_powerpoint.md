---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/microsoft_powerpoint.ipynb
description: Microsoft PowerPoint 문서를 다운스트림에서 사용할 수 있는 형식으로 로드하는 방법을 설명합니다. Unstructured
  설정 가이드도 포함되어 있습니다.
---

# 마이크로소프트 파워포인트

> [마이크로소프트 파워포인트](https://en.wikipedia.org/wiki/Microsoft_PowerPoint)는 마이크로소프트의 프레젠테이션 프로그램입니다.

이 문서는 `마이크로소프트 파워포인트` 문서를 우리가 사용할 수 있는 문서 형식으로 로드하는 방법을 다룹니다.

Unstructured를 로컬로 설정하는 방법에 대한 추가 지침은 [이 가이드](/docs/integrations/providers/unstructured/)를 참조하세요. 여기에는 필요한 시스템 종속성을 설정하는 방법도 포함되어 있습니다.

```python
# Install packages
%pip install unstructured
%pip install python-magic
%pip install python-pptx
```


```python
<!--IMPORTS:[{"imported": "UnstructuredPowerPointLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.powerpoint.UnstructuredPowerPointLoader.html", "title": "Microsoft PowerPoint"}]-->
from langchain_community.document_loaders import UnstructuredPowerPointLoader

loader = UnstructuredPowerPointLoader("./example_data/fake-power-point.pptx")

data = loader.load()

data
```


```output
[Document(page_content='Adding a Bullet Slide\n\nFind the bullet slide layout\n\nUse _TextFrame.text for first bullet\n\nUse _TextFrame.add_paragraph() for subsequent bullets\n\nHere is a lot of text!\n\nHere is some text in a text box!', metadata={'source': './example_data/fake-power-point.pptx'})]
```


### 요소 유지

내부적으로 `Unstructured`는 서로 다른 텍스트 조각에 대해 서로 다른 "요소"를 생성합니다. 기본적으로 우리는 이를 결합하지만, `mode="elements"`를 지정하여 쉽게 분리를 유지할 수 있습니다.

```python
loader = UnstructuredPowerPointLoader(
    "./example_data/fake-power-point.pptx", mode="elements"
)

data = loader.load()

data[0]
```


```output
Document(page_content='Adding a Bullet Slide', metadata={'source': './example_data/fake-power-point.pptx', 'category_depth': 0, 'file_directory': './example_data', 'filename': 'fake-power-point.pptx', 'last_modified': '2023-12-19T13:42:18', 'page_number': 1, 'languages': ['eng'], 'filetype': 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'category': 'Title'})
```


## Azure AI 문서 인텔리전스 사용하기

> [Azure AI 문서 인텔리전스](https://aka.ms/doc-intelligence) (이전 명칭: `Azure Form Recognizer`)는 디지털 또는 스캔한 PDF, 이미지, Office 및 HTML 파일에서 텍스트(손글씨 포함), 표, 문서 구조(예: 제목, 섹션 제목 등) 및 키-값 쌍을 추출하는 기계 학습 기반 서비스입니다.
> 
> 문서 인텔리전스는 `PDF`, `JPEG/JPG`, `PNG`, `BMP`, `TIFF`, `HEIF`, `DOCX`, `XLSX`, `PPTX` 및 `HTML`을 지원합니다.

현재 `문서 인텔리전스`를 사용한 로더 구현은 콘텐츠를 페이지별로 통합하고 이를 LangChain 문서로 변환할 수 있습니다. 기본 출력 형식은 마크다운이며, 이는 `MarkdownHeaderTextSplitter`와 쉽게 연결하여 의미론적 문서 청크를 생성할 수 있습니다. `mode="single"` 또는 `mode="page"`를 사용하여 단일 페이지 또는 페이지별로 분할된 순수 텍스트를 반환할 수도 있습니다.

## 전제 조건

3개의 미리보기 지역 중 하나에 Azure AI 문서 인텔리전스 리소스가 필요합니다: **동부 미국**, **서부 미국 2**, **서부 유럽** - 없다면 [이 문서](https://learn.microsoft.com/azure/ai-services/document-intelligence/create-document-intelligence-resource?view=doc-intel-4.0.0)를 따라 하나를 생성하세요. `<endpoint>`와 `<key>`를 로더의 매개변수로 전달해야 합니다.

```python
%pip install --upgrade --quiet  langchain langchain-community azure-ai-documentintelligence
```


```python
<!--IMPORTS:[{"imported": "AzureAIDocumentIntelligenceLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.doc_intelligence.AzureAIDocumentIntelligenceLoader.html", "title": "Microsoft PowerPoint"}]-->
from langchain_community.document_loaders import AzureAIDocumentIntelligenceLoader

file_path = "<filepath>"
endpoint = "<endpoint>"
key = "<key>"
loader = AzureAIDocumentIntelligenceLoader(
    api_endpoint=endpoint, api_key=key, file_path=file_path, api_model="prebuilt-layout"
)

documents = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
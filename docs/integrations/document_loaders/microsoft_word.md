---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/microsoft_word.ipynb
description: Microsoft Word 문서를 로드하여 후속 처리에 사용할 수 있는 형식으로 변환하는 방법에 대한 가이드를 제공합니다.
---

# 마이크로소프트 워드

> [마이크로소프트 워드](https://www.microsoft.com/en-us/microsoft-365/word)는 마이크로소프트에서 개발한 워드 프로세서입니다.

이 문서는 `Word` 문서를 우리가 하류에서 사용할 수 있는 문서 형식으로 로드하는 방법을 다룹니다.

## Docx2txt 사용하기

`Docx2txt`를 사용하여 .docx를 문서로 로드합니다.

```python
%pip install --upgrade --quiet  docx2txt
```


```python
<!--IMPORTS:[{"imported": "Docx2txtLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.word_document.Docx2txtLoader.html", "title": "Microsoft Word"}]-->
from langchain_community.document_loaders import Docx2txtLoader

loader = Docx2txtLoader("./example_data/fake.docx")

data = loader.load()

data
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', metadata={'source': './example_data/fake.docx'})]
```


## 비구조적 사용하기

필요한 시스템 종속성 설정을 포함하여 비구조적 로컬 설정에 대한 더 많은 지침은 [이 가이드](/docs/integrations/providers/unstructured/)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "UnstructuredWordDocumentLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.word_document.UnstructuredWordDocumentLoader.html", "title": "Microsoft Word"}]-->
from langchain_community.document_loaders import UnstructuredWordDocumentLoader

loader = UnstructuredWordDocumentLoader("example_data/fake.docx")

data = loader.load()

data
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', metadata={'source': 'example_data/fake.docx'})]
```


### 요소 유지

비구조적에서는 서로 다른 텍스트 조각에 대해 서로 다른 "요소"를 생성합니다. 기본적으로 우리는 그것들을 결합하지만, `mode="elements"`를 지정하여 쉽게 그 분리를 유지할 수 있습니다.

```python
loader = UnstructuredWordDocumentLoader("./example_data/fake.docx", mode="elements")

data = loader.load()

data[0]
```


```output
Document(page_content='Lorem ipsum dolor sit amet.', metadata={'source': './example_data/fake.docx', 'category_depth': 0, 'file_directory': './example_data', 'filename': 'fake.docx', 'last_modified': '2023-12-19T13:42:18', 'languages': ['por', 'cat'], 'filetype': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'category': 'Title'})
```


## Azure AI 문서 인텔리전스 사용하기

> [Azure AI 문서 인텔리전스](https://aka.ms/doc-intelligence) (이전 이름: `Azure Form Recognizer`)는 기계 학습 기반 서비스로, 디지털 또는 스캔된 PDF, 이미지, Office 및 HTML 파일에서 텍스트(손글씨 포함), 표, 문서 구조(예: 제목, 섹션 제목 등) 및 키-값 쌍을 추출합니다.
> 
> 문서 인텔리전스는 `PDF`, `JPEG/JPG`, `PNG`, `BMP`, `TIFF`, `HEIF`, `DOCX`, `XLSX`, `PPTX` 및 `HTML`을 지원합니다.

현재 `문서 인텔리전스`를 사용한 로더 구현은 페이지 단위로 내용을 통합하고 이를 LangChain 문서로 변환할 수 있습니다. 기본 출력 형식은 마크다운이며, 이는 의미론적 문서 청킹을 위해 `MarkdownHeaderTextSplitter`와 쉽게 연결될 수 있습니다. `mode="single"` 또는 `mode="page"`를 사용하여 단일 페이지의 순수 텍스트 또는 페이지별로 분할된 문서를 반환할 수도 있습니다.

## 전제 조건

**동부 미국**, **서부 미국 2**, **서부 유럽**의 3개 미리보기 지역 중 하나에 Azure AI 문서 인텔리전스 리소스가 필요합니다. 없다면 [이 문서](https://learn.microsoft.com/azure/ai-services/document-intelligence/create-document-intelligence-resource?view=doc-intel-4.0.0)를 따라 생성하십시오. `<endpoint>` 및 `<key>`를 로더의 매개변수로 전달해야 합니다.

%pip install --upgrade --quiet  langchain langchain-community azure-ai-documentintelligence

```python
<!--IMPORTS:[{"imported": "AzureAIDocumentIntelligenceLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.doc_intelligence.AzureAIDocumentIntelligenceLoader.html", "title": "Microsoft Word"}]-->
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
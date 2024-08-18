---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/microsoft_excel.ipynb
description: Microsoft Excel 파일을 로드하는 `UnstructuredExcelLoader`에 대한 설명과 Azure AI 문서
  인텔리전스 사용법을 안내합니다.
---

# 마이크로소프트 엑셀

`UnstructuredExcelLoader`는 `Microsoft Excel` 파일을 로드하는 데 사용됩니다. 로더는 `.xlsx` 및 `.xls` 파일 모두에서 작동합니다. 페이지 콘텐츠는 Excel 파일의 원시 텍스트가 됩니다. 로더를 `"elements"` 모드로 사용하면 Excel 파일의 HTML 표현이 문서 메타데이터의 `text_as_html` 키 아래에서 사용할 수 있습니다.

Unstructured를 로컬에서 설정하는 방법에 대한 추가 지침은 [이 가이드](/docs/integrations/providers/unstructured/)를 참조하십시오. 여기에는 필요한 시스템 종속성 설정이 포함됩니다.

```python
%pip install --upgrade --quiet langchain-community unstructured openpyxl
```


```python
<!--IMPORTS:[{"imported": "UnstructuredExcelLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.excel.UnstructuredExcelLoader.html", "title": "Microsoft Excel"}]-->
from langchain_community.document_loaders import UnstructuredExcelLoader

loader = UnstructuredExcelLoader("./example_data/stanley-cups.xlsx", mode="elements")
docs = loader.load()

print(len(docs))

docs
```

```output
4
```


```output
[Document(page_content='Stanley Cups', metadata={'source': './example_data/stanley-cups.xlsx', 'file_directory': './example_data', 'filename': 'stanley-cups.xlsx', 'last_modified': '2023-12-19T13:42:18', 'page_name': 'Stanley Cups', 'page_number': 1, 'languages': ['eng'], 'filetype': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'category': 'Title'}),
 Document(page_content='\n\n\nTeam\nLocation\nStanley Cups\n\n\nBlues\nSTL\n1\n\n\nFlyers\nPHI\n2\n\n\nMaple Leafs\nTOR\n13\n\n\n', metadata={'source': './example_data/stanley-cups.xlsx', 'file_directory': './example_data', 'filename': 'stanley-cups.xlsx', 'last_modified': '2023-12-19T13:42:18', 'page_name': 'Stanley Cups', 'page_number': 1, 'text_as_html': '<table border="1" class="dataframe">\n  <tbody>\n    <tr>\n      <td>Team</td>\n      <td>Location</td>\n      <td>Stanley Cups</td>\n    </tr>\n    <tr>\n      <td>Blues</td>\n      <td>STL</td>\n      <td>1</td>\n    </tr>\n    <tr>\n      <td>Flyers</td>\n      <td>PHI</td>\n      <td>2</td>\n    </tr>\n    <tr>\n      <td>Maple Leafs</td>\n      <td>TOR</td>\n      <td>13</td>\n    </tr>\n  </tbody>\n</table>', 'languages': ['eng'], 'parent_id': '17e9a90f9616f2abed8cf32b5bd3810d', 'filetype': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'category': 'Table'}),
 Document(page_content='Stanley Cups Since 67', metadata={'source': './example_data/stanley-cups.xlsx', 'file_directory': './example_data', 'filename': 'stanley-cups.xlsx', 'last_modified': '2023-12-19T13:42:18', 'page_name': 'Stanley Cups Since 67', 'page_number': 2, 'languages': ['eng'], 'filetype': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'category': 'Title'}),
 Document(page_content='\n\n\nTeam\nLocation\nStanley Cups\n\n\nBlues\nSTL\n1\n\n\nFlyers\nPHI\n2\n\n\nMaple Leafs\nTOR\n0\n\n\n', metadata={'source': './example_data/stanley-cups.xlsx', 'file_directory': './example_data', 'filename': 'stanley-cups.xlsx', 'last_modified': '2023-12-19T13:42:18', 'page_name': 'Stanley Cups Since 67', 'page_number': 2, 'text_as_html': '<table border="1" class="dataframe">\n  <tbody>\n    <tr>\n      <td>Team</td>\n      <td>Location</td>\n      <td>Stanley Cups</td>\n    </tr>\n    <tr>\n      <td>Blues</td>\n      <td>STL</td>\n      <td>1</td>\n    </tr>\n    <tr>\n      <td>Flyers</td>\n      <td>PHI</td>\n      <td>2</td>\n    </tr>\n    <tr>\n      <td>Maple Leafs</td>\n      <td>TOR</td>\n      <td>0</td>\n    </tr>\n  </tbody>\n</table>', 'languages': ['eng'], 'parent_id': 'ee34bd8c186b57e3530d5443ffa58122', 'filetype': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'category': 'Table'})]
```


## Azure AI 문서 인텔리전스 사용하기

> [Azure AI 문서 인텔리전스](https://aka.ms/doc-intelligence) (이전 이름: `Azure Form Recognizer`)는 기계 학습 기반 서비스로, 디지털 또는 스캔된 PDF, 이미지, Office 및 HTML 파일에서 텍스트(손글씨 포함), 표, 문서 구조(예: 제목, 섹션 제목 등) 및 키-값 쌍을 추출합니다.
> 
> 문서 인텔리전스는 `PDF`, `JPEG/JPG`, `PNG`, `BMP`, `TIFF`, `HEIF`, `DOCX`, `XLSX`, `PPTX` 및 `HTML`을 지원합니다.

현재 `Document Intelligence`를 사용하는 로더 구현은 콘텐츠를 페이지별로 통합하고 이를 LangChain 문서로 변환할 수 있습니다. 기본 출력 형식은 마크다운이며, 이는 `MarkdownHeaderTextSplitter`와 쉽게 연결되어 의미론적 문서 청크로 나눌 수 있습니다. `mode="single"` 또는 `mode="page"`를 사용하여 단일 페이지의 순수 텍스트 또는 페이지별로 나누어진 문서를 반환할 수 있습니다.

### 전제 조건

3개의 미리 보기 지역 중 하나에 Azure AI 문서 인텔리전스 리소스가 필요합니다: **East US**, **West US2**, **West Europe** - 리소스가 없는 경우 [이 문서](https://learn.microsoft.com/azure/ai-services/document-intelligence/create-document-intelligence-resource?view=doc-intel-4.0.0)를 따라 생성하십시오. `<endpoint>` 및 `<key>`를 로더에 대한 매개변수로 전달해야 합니다.

```python
%pip install --upgrade --quiet langchain langchain-community azure-ai-documentintelligence
```


```python
<!--IMPORTS:[{"imported": "AzureAIDocumentIntelligenceLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.doc_intelligence.AzureAIDocumentIntelligenceLoader.html", "title": "Microsoft Excel"}]-->
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
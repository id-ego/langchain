---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/unstructured_file.ipynb
description: 이 노트북은 다양한 파일 유형을 로드하는 `Unstructured` 문서 로더 사용법을 다룹니다. 텍스트, 파워포인트, PDF
  등 지원.
---

# 비구조적

이 노트북에서는 다양한 유형의 파일을 로드하기 위해 `Unstructured` [문서 로더](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 사용하는 방법을 다룹니다. `Unstructured`는 현재 텍스트 파일, 파워포인트, HTML, PDF, 이미지 등을 로드하는 것을 지원합니다.

로컬에서 Unstructured를 설정하는 방법에 대한 추가 지침은 [이 가이드](../../integrations/providers/unstructured.mdx)를 참조하세요. 여기에는 필요한 시스템 종속성 설정이 포함되어 있습니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/document_loaders/file_loaders/unstructured/)|
| :--- | :--- | :---: | :---: |  :---: |
| [UnstructuredLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/unstructured_api_reference.html) | ✅ | ❌ | ✅ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| UnstructuredLoader | ✅ | ❌ | 

## 설정

### 자격 증명

기본적으로 `langchain-unstructured`는 파티셔닝 로직을 Unstructured API에 오프로드해야 하는 작은 풋프린트를 설치하며, 이는 API 키가 필요합니다. 로컬 설치를 사용하는 경우 API 키가 필요하지 않습니다. API 키를 얻으려면 [이 사이트](https://unstructured.io)로 이동하여 API 키를 얻고, 아래 셀에 설정하세요:

```python
import getpass
import os

os.environ["UNSTRUCTURED_API_KEY"] = getpass.getpass(
    "Enter your Unstructured API key: "
)
```


### 설치

#### 일반 설치

이 노트북의 나머지를 실행하려면 다음 패키지가 필요합니다.

```python
# Install package, compatible with API partitioning
%pip install --upgrade --quiet langchain-unstructured unstructured-client unstructured "unstructured[pdf]" python-magic
```


#### 로컬 설치

파티셔닝 로직을 로컬에서 실행하려면, [Unstructured 문서 여기](https://docs.unstructured.io/open-source/installation/full-installation)에 설명된 시스템 종속성 조합을 설치해야 합니다.

예를 들어, Mac에서는 다음과 같이 필요한 종속성을 설치할 수 있습니다:

```bash
# base dependencies
brew install libmagic poppler tesseract

# If parsing xml / html documents:
brew install libxml2 libxslt
```


로컬에 필요한 `pip` 종속성을 설치하려면:

```bash
pip install "langchain-unstructured[local]"
```


## 초기화

`UnstructuredLoader`는 다양한 파일 유형에서 로드를 허용합니다. `unstructured` 패키지에 대한 모든 내용을 읽으려면 그들의 [문서](https://docs.unstructured.io/open-source/introduction/overview)/를 참조하세요. 이 예제에서는 텍스트 파일과 PDF 파일에서 로드하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredLoader", "source": "langchain_unstructured", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html", "title": "Unstructured"}]-->
from langchain_unstructured import UnstructuredLoader

file_paths = [
    "./example_data/layout-parser-paper.pdf",
    "./example_data/state_of_the_union.txt",
]


loader = UnstructuredLoader(file_paths)
```


## 로드

```python
docs = loader.load()

docs[0]
```

```output
INFO: NumExpr defaulting to 12 threads.
INFO: pikepdf C++ to Python logger bridge initialized
```


```output
Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((16.34, 213.36), (16.34, 253.36), (36.34, 253.36), (36.34, 213.36)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-07-25T21:28:58', 'page_number': 1, 'filetype': 'application/pdf', 'category': 'UncategorizedText', 'element_id': 'd3ce55f220dfb75891b4394a18bcb973'}, page_content='1 2 0 2')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((16.34, 213.36), (16.34, 253.36), (36.34, 253.36), (36.34, 213.36)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-07-25T21:28:58', 'page_number': 1, 'filetype': 'application/pdf', 'category': 'UncategorizedText', 'element_id': 'd3ce55f220dfb75891b4394a18bcb973'}
```

## 지연 로드

```python
pages = []
for doc in loader.lazy_load():
    pages.append(doc)

pages[0]
```


```output
Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((16.34, 213.36), (16.34, 253.36), (36.34, 253.36), (36.34, 213.36)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-07-25T21:28:58', 'page_number': 1, 'filetype': 'application/pdf', 'category': 'UncategorizedText', 'element_id': 'd3ce55f220dfb75891b4394a18bcb973'}, page_content='1 2 0 2')
```


## 후처리

추출 후 `unstructured` 요소를 후처리해야 하는 경우, `UnstructuredLoader`를 인스턴스화할 때 `post_processors` kwarg에 `str` -> `str` 함수 목록을 전달할 수 있습니다. 이는 다른 Unstructured 로더에도 적용됩니다. 아래는 예시입니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredLoader", "source": "langchain_unstructured", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html", "title": "Unstructured"}]-->
from langchain_unstructured import UnstructuredLoader
from unstructured.cleaners.core import clean_extra_whitespace

loader = UnstructuredLoader(
    "./example_data/layout-parser-paper.pdf",
    post_processors=[clean_extra_whitespace],
)

docs = loader.load()

docs[5:10]
```


```output
[Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((16.34, 393.9), (16.34, 560.0), (36.34, 560.0), (36.34, 393.9)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-02-27T15:49:27', 'page_number': 1, 'parent_id': '89565df026a24279aaea20dc08cedbec', 'filetype': 'application/pdf', 'category': 'UncategorizedText', 'element_id': 'e9fa370aef7ee5c05744eb7bb7d9981b'}, page_content='2 v 8 4 3 5 1 . 3 0 1 2 : v i X r a'),
 Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((157.62199999999999, 114.23496279999995), (157.62199999999999, 146.5141628), (457.7358962799999, 146.5141628), (457.7358962799999, 114.23496279999995)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-02-27T15:49:27', 'page_number': 1, 'filetype': 'application/pdf', 'category': 'Title', 'element_id': 'bde0b230a1aa488e3ce837d33015181b'}, page_content='LayoutParser: A Uniﬁed Toolkit for Deep Learning Based Document Image Analysis'),
 Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((134.809, 168.64029940800003), (134.809, 192.2517444), (480.5464199080001, 192.2517444), (480.5464199080001, 168.64029940800003)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-02-27T15:49:27', 'page_number': 1, 'parent_id': 'bde0b230a1aa488e3ce837d33015181b', 'filetype': 'application/pdf', 'category': 'UncategorizedText', 'element_id': '54700f902899f0c8c90488fa8d825bce'}, page_content='Zejiang Shen1 ((cid:0)), Ruochen Zhang2, Melissa Dell3, Benjamin Charles Germain Lee4, Jacob Carlson3, and Weining Li5'),
 Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((207.23000000000002, 202.57205439999996), (207.23000000000002, 311.8195408), (408.12676, 311.8195408), (408.12676, 202.57205439999996)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-02-27T15:49:27', 'page_number': 1, 'parent_id': 'bde0b230a1aa488e3ce837d33015181b', 'filetype': 'application/pdf', 'category': 'UncategorizedText', 'element_id': 'b650f5867bad9bb4e30384282c79bcfe'}, page_content='1 Allen Institute for AI shannons@allenai.org 2 Brown University ruochen zhang@brown.edu 3 Harvard University {melissadell,jacob carlson}@fas.harvard.edu 4 University of Washington bcgl@cs.washington.edu 5 University of Waterloo w422li@uwaterloo.ca'),
 Document(metadata={'source': './example_data/layout-parser-paper.pdf', 'coordinates': {'points': ((162.779, 338.45008160000003), (162.779, 566.8455408), (454.0372021523199, 566.8455408), (454.0372021523199, 338.45008160000003)), 'system': 'PixelSpace', 'layout_width': 612, 'layout_height': 792}, 'file_directory': './example_data', 'filename': 'layout-parser-paper.pdf', 'languages': ['eng'], 'last_modified': '2024-02-27T15:49:27', 'links': [{'text': ':// layout - parser . github . io', 'url': 'https://layout-parser.github.io', 'start_index': 1477}], 'page_number': 1, 'parent_id': 'bde0b230a1aa488e3ce837d33015181b', 'filetype': 'application/pdf', 'category': 'NarrativeText', 'element_id': 'cfc957c94fe63c8fd7c7f4bcb56e75a7'}, page_content='Abstract. Recent advances in document image analysis (DIA) have been primarily driven by the application of neural networks. Ideally, research outcomes could be easily deployed in production and extended for further investigation. However, various factors like loosely organized codebases and sophisticated model conﬁgurations complicate the easy reuse of im- portant innovations by a wide audience. Though there have been on-going eﬀorts to improve reusability and simplify deep learning (DL) model development in disciplines like natural language processing and computer vision, none of them are optimized for challenges in the domain of DIA. This represents a major gap in the existing toolkit, as DIA is central to academic research across a wide range of disciplines in the social sciences and humanities. This paper introduces LayoutParser, an open-source library for streamlining the usage of DL in DIA research and applica- tions. The core LayoutParser library comes with a set of simple and intuitive interfaces for applying and customizing DL models for layout de- tection, character recognition, and many other document processing tasks. To promote extensibility, LayoutParser also incorporates a community platform for sharing both pre-trained models and full document digiti- zation pipelines. We demonstrate that LayoutParser is helpful for both lightweight and large-scale digitization pipelines in real-word use cases. The library is publicly available at https://layout-parser.github.io.')]
```


## Unstructured API

더 작은 패키지로 시작하고 최신 파티셔닝을 얻으려면 `pip install unstructured-client` 및 `pip install langchain-unstructured`를 실행할 수 있습니다. `UnstructuredLoader`에 대한 더 많은 정보는
[Unstructured 제공자 페이지](https://python.langchain.com/v0.1/docs/integrations/document_loaders/unstructured_file/)를 참조하세요.

로더는 `api_key`를 전달하고 `partition_via_api=True`로 설정할 때 호스팅된 Unstructured 서버리스 API를 사용하여 문서를 처리합니다. 무료 Unstructured API 키를 [여기](https://unstructured.io/api-key/)에서 생성할 수 있습니다.

Unstructured API를 자체 호스팅하거나 로컬에서 실행하려면 [여기](https://github.com/Unstructured-IO/unstructured-api#dizzy-instructions-for-using-the-docker-image)에서 지침을 확인하세요.

```python
<!--IMPORTS:[{"imported": "UnstructuredLoader", "source": "langchain_unstructured", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html", "title": "Unstructured"}]-->
from langchain_unstructured import UnstructuredLoader

loader = UnstructuredLoader(
    file_path="example_data/fake.docx",
    api_key=os.getenv("UNSTRUCTURED_API_KEY"),
    partition_via_api=True,
)

docs = loader.load()
docs[0]
```

```output
INFO: Preparing to split document for partition.
INFO: Given file doesn't have '.pdf' extension, so splitting is not enabled.
INFO: Partitioning without split.
INFO: Successfully partitioned the document.
```


```output
Document(metadata={'source': 'example_data/fake.docx', 'category_depth': 0, 'filename': 'fake.docx', 'languages': ['por', 'cat'], 'filetype': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'category': 'Title', 'element_id': '56d531394823d81787d77a04462ed096'}, page_content='Lorem ipsum dolor sit amet.')
```


`UnstructuredLoader`를 사용하여 단일 API에서 여러 파일을 배치로 처리할 수도 있습니다.

```python
loader = UnstructuredLoader(
    file_path=["example_data/fake.docx", "example_data/fake-email.eml"],
    api_key=os.getenv("UNSTRUCTURED_API_KEY"),
    partition_via_api=True,
)

docs = loader.load()

print(docs[0].metadata["filename"], ": ", docs[0].page_content[:100])
print(docs[-1].metadata["filename"], ": ", docs[-1].page_content[:100])
```

```output
INFO: Preparing to split document for partition.
INFO: Given file doesn't have '.pdf' extension, so splitting is not enabled.
INFO: Partitioning without split.
INFO: Successfully partitioned the document.
INFO: Preparing to split document for partition.
INFO: Given file doesn't have '.pdf' extension, so splitting is not enabled.
INFO: Partitioning without split.
INFO: Successfully partitioned the document.
``````output
fake.docx :  Lorem ipsum dolor sit amet.
fake-email.eml :  Violets are blue
```

### Unstructured SDK 클라이언트

Unstructured API로의 파티셔닝은 [Unstructured SDK
Client](https://docs.unstructured.io/api-reference/api-services/sdk)에 의존합니다.

아래는 클라이언트의 일부 기능을 사용자 정의하고 자신의 `requests.Session()`을 사용하거나 대체 `server_url`을 전달하거나 실패한 요청 처리에 대한 더 많은 제어를 위해 `RetryConfig` 객체를 사용자 정의하는 방법을 보여주는 예입니다.

아래 예제는 최신 버전의 UnstructuredClient를 사용하지 않을 수 있으며 향후 릴리스에서 중단된 변경 사항이 있을 수 있습니다. 최신 예제는 [Unstructured Python SDK](https://docs.unstructured.io/api-reference/api-services/sdk-python) 문서를 참조하세요.

```python
<!--IMPORTS:[{"imported": "UnstructuredLoader", "source": "langchain_unstructured", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html", "title": "Unstructured"}]-->
import requests
from langchain_unstructured import UnstructuredLoader
from unstructured_client import UnstructuredClient
from unstructured_client.utils import BackoffStrategy, RetryConfig

client = UnstructuredClient(
    api_key_auth=os.getenv(
        "UNSTRUCTURED_API_KEY"
    ),  # Note: the client API param is "api_key_auth" instead of "api_key"
    client=requests.Session(),
    server_url="https://api.unstructuredapp.io/general/v0/general",
    retry_config=RetryConfig(
        strategy="backoff",
        retry_connection_errors=True,
        backoff=BackoffStrategy(
            initial_interval=500,
            max_interval=60000,
            exponent=1.5,
            max_elapsed_time=900000,
        ),
    ),
)

loader = UnstructuredLoader(
    "./example_data/layout-parser-paper.pdf",
    partition_via_api=True,
    client=client,
)

docs = loader.load()

print(docs[0].metadata["filename"], ": ", docs[0].page_content[:100])
```

```output
INFO: Preparing to split document for partition.
INFO: Concurrency level set to 5
INFO: Splitting pages 1 to 16 (16 total)
INFO: Determined optimal split size of 4 pages.
INFO: Partitioning 4 files with 4 page(s) each.
INFO: Partitioning set #1 (pages 1-4).
INFO: Partitioning set #2 (pages 5-8).
INFO: Partitioning set #3 (pages 9-12).
INFO: Partitioning set #4 (pages 13-16).
INFO: HTTP Request: POST https://api.unstructuredapp.io/general/v0/general "HTTP/1.1 200 OK"
INFO: HTTP Request: POST https://api.unstructuredapp.io/general/v0/general "HTTP/1.1 200 OK"
INFO: HTTP Request: POST https://api.unstructuredapp.io/general/v0/general "HTTP/1.1 200 OK"
INFO: Successfully partitioned set #1, elements added to the final result.
INFO: Successfully partitioned set #2, elements added to the final result.
INFO: Successfully partitioned set #3, elements added to the final result.
INFO: Successfully partitioned set #4, elements added to the final result.
INFO: Successfully partitioned the document.
``````output
layout-parser-paper.pdf :  LayoutParser: A Uniﬁed Toolkit for Deep Learning Based Document Image Analysis
```

## 청킹

`UnstructuredLoader`는 이전 로더인 `UnstructuredFileLoader`와 다른 로더들이 했던 것처럼 텍스트 그룹화를 위한 `mode` 매개변수를 지원하지 않습니다. 대신 "청킹"을 지원합니다. 비구조적 청킹은 일반적으로 알고 있는 다른 청킹 메커니즘과 다르며, 일반적으로 "\n\n" 또는 "\n"과 같은 문장 경계나 목록 항목 경계를 나타낼 수 있는 일반 텍스트 기능을 기반으로 청크를 형성합니다. 대신 모든 문서는 각 문서 형식에 대한 특정 지식을 사용하여 문서를 의미 단위(문서 요소)로 파티셔닝하기 위해 분할되며, 단일 요소가 원하는 최대 청크 크기를 초과할 때만 텍스트 분할에 의존해야 합니다. 일반적으로 청킹은 최대 청크 크기를 초과하지 않도록 가능한 한 큰 청크를 형성하기 위해 연속 요소를 결합합니다. 청킹은 CompositeElement, Table 또는 TableChunk 요소의 시퀀스를 생성합니다. 각 “청크”는 이 세 가지 유형 중 하나의 인스턴스입니다.

청킹 옵션에 대한 자세한 내용은 [이 페이지](https://docs.unstructured.io/open-source/core-functionality/chunking)를 참조하세요. 그러나 `mode="single"`과 동일한 동작을 재현하려면 `chunking_strategy="basic"`, `max_characters=<some-really-big-number>`, 및 `include_orig_elements=False`를 설정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredLoader", "source": "langchain_unstructured", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html", "title": "Unstructured"}]-->
from langchain_unstructured import UnstructuredLoader

loader = UnstructuredLoader(
    "./example_data/layout-parser-paper.pdf",
    chunking_strategy="basic",
    max_characters=1000000,
    include_orig_elements=False,
)

docs = loader.load()

print("Number of LangChain documents:", len(docs))
print("Length of text in the document:", len(docs[0].page_content))
```

```output
WARNING: Partitioning locally even though api_key is defined since partition_via_api=False.
``````output
Number of LangChain documents: 1
Length of text in the document: 42772
```

## API 참조

모든 `UnstructuredLoader` 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/document_loaders/langchain_unstructured.document_loaders.UnstructuredLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
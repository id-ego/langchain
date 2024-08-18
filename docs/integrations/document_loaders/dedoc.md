---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/dedoc.ipynb
description: 이 문서는 `Dedoc`와 `LangChain`을 결합하여 다양한 형식의 문서에서 텍스트와 구조를 추출하는 방법을 보여줍니다.
---

# Dedoc

이 샘플은 `LangChain`과 함께 `DocumentLoader`로서 `Dedoc`의 사용을 보여줍니다.

## 개요

[Dedoc](https://dedoc.readthedocs.io)는 다양한 형식의 파일에서 텍스트, 표, 첨부 파일 및 문서 구조(예: 제목, 목록 항목 등)를 추출하는 [오픈 소스](https://github.com/ispras/dedoc) 라이브러리/서비스입니다.

`Dedoc`는 `DOCX`, `XLSX`, `PPTX`, `EML`, `HTML`, `PDF`, 이미지 등을 지원합니다. 지원되는 형식의 전체 목록은 [여기](https://dedoc.readthedocs.io/en/latest/#id1)에서 확인할 수 있습니다.

### 통합 세부정보

| 클래스                                                                                                                                               | 패키지                                                                                         | 로컬 | 직렬화 가능 | JS 지원 |
|:---------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------|:-----:|:----------:|:------:|
| [DedocFileLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocFileLoader.html)       | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) |   ❌   |    beta    |   ❌   |
| [DedocPDFLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.DedocPDFLoader.html)           | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) |   ❌   |    beta    |   ❌   |
| [DedocAPIFileLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocAPIFileLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) |   ❌   |    beta    |   ❌   | 

### 로더 기능

지연 로딩 및 비동기 로딩을 위한 메서드가 제공되지만, 실제로 문서 로딩은 동기적으로 실행됩니다.

|       소스       | 문서 지연 로딩 | 비동기 지원 |
|:----------------:|:--------------:|:-----------:|
|  DedocFileLoader |       ❌       |     ❌      |
|   DedocPDFLoader |       ❌       |     ❌      |
| DedocAPIFileLoader |     ❌       |     ❌      | 

## 설정

* `DedocFileLoader` 및 `DedocPDFLoader` 문서 로더에 접근하려면 `dedoc` 통합 패키지를 설치해야 합니다.
* `DedocAPIFileLoader`에 접근하려면 `Dedoc` 서비스를 실행해야 하며, 예를 들어 `Docker` 컨테이너를 사용할 수 있습니다 (자세한 내용은 [문서](https://dedoc.readthedocs.io/en/latest/getting_started/installation.html#install-and-run-dedoc-using-docker)를 참조하십시오):

```bash
docker pull dedocproject/dedoc
docker run -p 1231:1231
```


`Dedoc` 설치 지침은 [여기](https://dedoc.readthedocs.io/en/latest/getting_started/installation.html)에 있습니다.

```python
# Install package
%pip install --quiet "dedoc[torch]"
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

```python
<!--IMPORTS:[{"imported": "DedocFileLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocFileLoader.html", "title": "Dedoc"}]-->
from langchain_community.document_loaders import DedocFileLoader

loader = DedocFileLoader("./example_data/state_of_the_union.txt")
```


## 로드

```python
docs = loader.load()
docs[0].page_content[:100]
```


```output
'\nMadam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and t'
```


## 지연 로드

```python
docs = loader.lazy_load()

for doc in docs:
    print(doc.page_content[:100])
    break
```

```output

Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and t
```

## API 참조

`Dedoc` 로더 구성 및 호출에 대한 자세한 정보는 API 참조를 참조하십시오: 

* https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocFileLoader.html
* https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.DedocPDFLoader.html
* https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocAPIFileLoader.html

## 모든 파일 로딩

[지원되는 형식](https://dedoc.readthedocs.io/en/latest/#id1)의 파일을 자동으로 처리하려면 `DedocFileLoader`가 유용할 수 있습니다. 파일 로더는 올바른 확장자로 파일 유형을 자동으로 감지합니다.

파일 파싱 프로세스는 `DedocFileLoader` 클래스 초기화 중에 `dedoc_kwargs`를 통해 구성할 수 있습니다. 여기에는 몇 가지 옵션 사용의 기본 예가 제공되며, `DedocFileLoader` 문서 및 [dedoc 문서](https://dedoc.readthedocs.io/en/latest/parameters/parameters.html)를 참조하여 구성 매개변수에 대한 자세한 내용을 확인하십시오.

### 기본 예

```python
<!--IMPORTS:[{"imported": "DedocFileLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocFileLoader.html", "title": "Dedoc"}]-->
from langchain_community.document_loaders import DedocFileLoader

loader = DedocFileLoader("./example_data/state_of_the_union.txt")

docs = loader.load()

docs[0].page_content[:400]
```


```output
'\nMadam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\n\n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\n\n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\n\n\nWith a duty to one another to the American people to '
```


### 분할 모드

`DedocFileLoader`는 문서를 여러 부분으로 분할하는 다양한 유형을 지원합니다(각 부분은 별도로 반환됨). 이를 위해 `split` 매개변수가 다음 옵션과 함께 사용됩니다:
* `document` (기본값): 문서 텍스트가 단일 langchain `Document` 객체로 반환됨 (분할하지 않음);
* `page`: 문서 텍스트를 페이지로 분할 (PDF, DJVU, PPTX, PPT, ODP에 대해 작동);
* `node`: 문서 텍스트를 `Dedoc` 트리 노드로 분할 (제목 노드, 목록 항목 노드, 원시 텍스트 노드);
* `line`: 문서 텍스트를 텍스트 줄로 분할.

```python
loader = DedocFileLoader(
    "./example_data/layout-parser-paper.pdf",
    split="page",
    pages=":2",
)

docs = loader.load()

len(docs)
```


```output
2
```


### 표 처리

`DedocFileLoader`는 로더 초기화 중에 `with_tables` 매개변수가 `True`로 설정될 때 표 처리를 지원합니다 (`with_tables=True`가 기본값). 

표는 분할되지 않으며 각 표는 하나의 langchain `Document` 객체에 해당합니다. 표의 경우, `Document` 객체는 추가 `metadata` 필드 `type="table"` 및 표의 `HTML` 표현을 가진 `text_as_html`을 가집니다.

```python
loader = DedocFileLoader("./example_data/mlb_teams_2012.csv")

docs = loader.load()

docs[1].metadata["type"], docs[1].metadata["text_as_html"][:200]
```


```output
('table',
 '<table border="1" style="border-collapse: collapse; width: 100%;">\n<tbody>\n<tr>\n<td colspan="1" rowspan="1">Team</td>\n<td colspan="1" rowspan="1"> &quot;Payroll (millions)&quot;</td>\n<td colspan="1" r')
```


### 첨부 파일 처리

`DedocFileLoader`는 로더 초기화 중에 `with_attachments`가 `True`로 설정될 때 첨부 파일 처리를 지원합니다 (`with_attachments=False`가 기본값). 

첨부 파일은 `split` 매개변수에 따라 분할됩니다. 첨부 파일의 경우, langchain `Document` 객체는 추가 메타데이터 필드 `type="attachment"`를 가집니다.

```python
loader = DedocFileLoader(
    "./example_data/fake-email-attachment.eml",
    with_attachments=True,
)

docs = loader.load()

docs[1].metadata["type"], docs[1].page_content
```


```output
('attachment',
 '\nContent-Type\nmultipart/mixed; boundary="0000000000005d654405f082adb7"\nDate\nFri, 23 Dec 2022 12:08:48 -0600\nFrom\nMallori Harrell <mallori@unstructured.io>\nMIME-Version\n1.0\nMessage-ID\n<CAPgNNXSzLVJ-d1OCX_TjFgJU7ugtQrjFybPtAMmmYZzphxNFYg@mail.gmail.com>\nSubject\nFake email with attachment\nTo\nMallori Harrell <mallori@unstructured.io>')
```


## PDF 파일 로딩

`PDF` 문서만 처리하려면 `DedocPDFLoader`를 사용할 수 있으며, 이는 오직 `PDF` 지원만 제공합니다. 로더는 문서 분할, 표 및 첨부 파일 추출을 위한 동일한 매개변수를 지원합니다.

`Dedoc`는 텍스트 레이어가 있거나 없는 `PDF`를 추출할 수 있으며, 그 존재 및 정확성을 자동으로 감지할 수 있습니다. 여러 `PDF` 핸들러가 제공되며, `pdf_with_text_layer` 매개변수를 사용하여 그 중 하나를 선택할 수 있습니다. 자세한 내용은 [매개변수 설명](https://dedoc.readthedocs.io/en/latest/parameters/pdf_handling.html)을 참조하십시오.

텍스트 레이어가 없는 `PDF`의 경우, `Tesseract OCR` 및 해당 언어 패키지를 설치해야 합니다. 이 경우, [지침](https://dedoc.readthedocs.io/en/latest/tutorials/add_new_language.html)이 유용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "DedocPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.DedocPDFLoader.html", "title": "Dedoc"}]-->
from langchain_community.document_loaders import DedocPDFLoader

loader = DedocPDFLoader(
    "./example_data/layout-parser-paper.pdf", pdf_with_text_layer="true", pages="2:2"
)

docs = loader.load()

docs[0].page_content[:400]
```


```output
'\n2\n\nZ. Shen et al.\n\n37], layout detection [38, 22], table detection [26], and scene text detection [4].\n\nA generalized learning-based framework dramatically reduces the need for the\n\nmanual speciﬁcation of complicated rules, which is the status quo with traditional\n\nmethods. DL has the potential to transform DIA pipelines and beneﬁt a broad\n\nspectrum of large-scale document digitization projects.\n'
```


## Dedoc API

설정이 덜 필요하게 시작하려면 `Dedoc`를 서비스로 사용할 수 있습니다.
**`DedocAPIFileLoader`는 `dedoc` 라이브러리를 설치하지 않고도 사용할 수 있습니다.**
로더는 `DedocFileLoader`와 동일한 매개변수를 지원하며, 입력 파일 유형을 자동으로 감지합니다.

`DedocAPIFileLoader`를 사용하려면 `Dedoc` 서비스를 실행해야 하며, 예를 들어 `Docker` 컨테이너를 사용할 수 있습니다 (자세한 내용은 [문서](https://dedoc.readthedocs.io/en/latest/getting_started/installation.html#install-and-run-dedoc-using-docker)를 참조하십시오):

```bash
docker pull dedocproject/dedoc
docker run -p 1231:1231
```


코드에서 우리의 데모 URL `https://dedoc-readme.hf.space`를 사용하지 마십시오.

```python
<!--IMPORTS:[{"imported": "DedocAPIFileLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.dedoc.DedocAPIFileLoader.html", "title": "Dedoc"}]-->
from langchain_community.document_loaders import DedocAPIFileLoader

loader = DedocAPIFileLoader(
    "./example_data/state_of_the_union.txt",
    url="https://dedoc-readme.hf.space",
)

docs = loader.load()

docs[0].page_content[:400]
```


```output
'\nMadam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\n\n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\n\n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\n\n\nWith a duty to one another to the American people to '
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
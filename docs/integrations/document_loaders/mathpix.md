---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/mathpix.ipynb
description: MathPixPDFLoader는 Mathpix API를 사용하여 PDF 문서를 로드하고 처리하는 기능을 제공하는 Langchain의
  커뮤니티 패키지입니다.
---

# MathPixPDFLoader

Daniel Gross의 스니펫에서 영감을 받았습니다: [https://gist.github.com/danielgross/3ab4104e14faccc12b49200843adab21](https://gist.github.com/danielgross/3ab4104e14faccc12b49200843adab21)

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 |
| :--- | :--- | :---: | :---: |  :---: |
| [MathPixPDFLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.MathpixPDFLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원 |
| :---: | :---: | :---: |
| MathPixPDFLoader | ✅ | ❌ | 

## 설정

### 자격 증명

Mathpix에 가입하고 [API 키 생성](https://mathpix.com/docs/ocr/creating-an-api-key)하여 환경에 `MATHPIX_API_KEY` 변수를 설정하세요.

```python
import getpass
import os

if "MATHPIX_API_KEY" not in os.environ:
    os.environ["MATHPIX_API_KEY"] = getpass.getpass("Enter your Mathpix API key: ")
```


모델 호출의 자동 최적 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community**를 설치하세요.

```python
%pip install -qU langchain_community
```


## 초기화

이제 로더를 초기화할 준비가 되었습니다:

```python
<!--IMPORTS:[{"imported": "MathpixPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.MathpixPDFLoader.html", "title": "MathPixPDFLoader"}]-->
from langchain_community.document_loaders import MathpixPDFLoader

file_path = "./example_data/layout-parser-paper.pdf"
loader = MathpixPDFLoader(file_path)
```


## 로드

```python
docs = loader.load()
docs[0]
```


```python
print(docs[0].metadata)
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

MathpixPDFLoader의 모든 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.MathpixPDFLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
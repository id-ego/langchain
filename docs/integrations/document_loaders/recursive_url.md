---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/recursive_url.ipynb
description: '`RecursiveUrlLoader`는 루트 URL에서 모든 자식 링크를 재귀적으로 스크랩하고 이를 문서로 파싱하는 기능을
  제공합니다.'
---

# 재귀 URL

`RecursiveUrlLoader`는 루트 URL에서 모든 자식 링크를 재귀적으로 스크랩하고 이를 문서로 파싱할 수 있게 해줍니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/document_loaders/web_loaders/recursive_url_loader/)|
| :--- | :--- | :---: | :---: |  :---: |
| [RecursiveUrlLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ✅ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| RecursiveUrlLoader | ✅ | ❌ | 

## 설정

### 자격 증명

`RecursiveUrlLoader`를 사용하기 위해서는 자격 증명이 필요하지 않습니다.

### 설치

`RecursiveUrlLoader`는 `langchain-community` 패키지에 포함되어 있습니다. 다른 필수 패키지는 없지만, `beautifulsoup4`를 설치하면 더 풍부한 기본 문서 메타데이터를 얻을 수 있습니다.

```python
%pip install -qU langchain-community beautifulsoup4
```


## 인스턴스화

이제 문서 로더 객체를 인스턴스화하고 문서를 로드할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "RecursiveUrlLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html", "title": "Recursive URL"}]-->
from langchain_community.document_loaders import RecursiveUrlLoader

loader = RecursiveUrlLoader(
    "https://docs.python.org/3.9/",
    # max_depth=2,
    # use_async=False,
    # extractor=None,
    # metadata_extractor=None,
    # exclude_dirs=(),
    # timeout=10,
    # check_response_status=True,
    # continue_on_failure=True,
    # prevent_outside=True,
    # base_url=None,
    # ...
)
```


## 로드

`.load()`를 사용하여 메모리에 모든 문서를 동기적으로 로드합니다. 방문한 URL당 하나의 문서가 생성됩니다. 초기 URL에서 시작하여 지정된 max_depth까지 모든 링크된 URL을 재귀적으로 탐색합니다.

[Python 3.9 Documentation](https://docs.python.org/3.9/)에서 `RecursiveUrlLoader`를 사용하는 기본 예제를 살펴보겠습니다.

```python
docs = loader.load()
docs[0].metadata
```

```output
/Users/bagatur/.pyenv/versions/3.9.1/lib/python3.9/html/parser.py:170: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  k = self.parse_starttag(i)
```


```output
{'source': 'https://docs.python.org/3.9/',
 'content_type': 'text/html',
 'title': '3.9.19 Documentation',
 'language': None}
```


좋습니다! 첫 번째 문서는 우리가 시작한 루트 페이지처럼 보입니다. 다음 문서의 메타데이터를 살펴보겠습니다.

```python
docs[1].metadata
```


```output
{'source': 'https://docs.python.org/3.9/using/index.html',
 'content_type': 'text/html',
 'title': 'Python Setup and Usage — Python 3.9.19 documentation',
 'language': None}
```


해당 URL은 우리의 루트 페이지의 자식처럼 보입니다. 좋습니다! 메타데이터에서 콘텐츠를 살펴보겠습니다.

```python
print(docs[0].page_content[:300])
```

```output

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="utf-8" /><title>3.9.19 Documentation</title><meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link rel="stylesheet" href="_static/pydoctheme.css" type="text/css" />
    <link rel=
```

확실히 https://docs.python.org/3.9/에서 온 HTML처럼 보입니다. 우리가 예상했던 대로입니다. 이제 다양한 상황에서 유용할 수 있는 기본 예제에 대한 몇 가지 변형을 살펴보겠습니다.

## 지연 로딩

많은 수의 문서를 로드하고 하위 작업이 로드된 모든 문서의 하위 집합에서 수행될 수 있는 경우, 메모리 사용량을 최소화하기 위해 문서를 하나씩 지연 로드할 수 있습니다:

```python
pages = []
for doc in loader.lazy_load():
    pages.append(doc)
    if len(pages) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        pages = []
```

```output
/var/folders/4j/2rz3865x6qg07tx43146py8h0000gn/T/ipykernel_73962/2110507528.py:6: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  soup = BeautifulSoup(html, "lxml")
```

이 예제에서는 한 번에 10개 이상의 문서가 메모리에 로드되지 않습니다.

## 추출기 추가

기본적으로 로더는 각 링크의 원시 HTML을 문서 페이지 콘텐츠로 설정합니다. 이 HTML을 더 인간/LLM 친화적인 형식으로 파싱하려면 사용자 정의 `extractor` 메서드를 전달할 수 있습니다:

```python
import re

from bs4 import BeautifulSoup


def bs4_extractor(html: str) -> str:
    soup = BeautifulSoup(html, "lxml")
    return re.sub(r"\n\n+", "\n\n", soup.text).strip()


loader = RecursiveUrlLoader("https://docs.python.org/3.9/", extractor=bs4_extractor)
docs = loader.load()
print(docs[0].page_content[:200])
```

```output
/var/folders/td/vzm913rx77x21csd90g63_7c0000gn/T/ipykernel_10935/1083427287.py:6: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  soup = BeautifulSoup(html, "lxml")
/Users/isaachershenson/.pyenv/versions/3.11.9/lib/python3.11/html/parser.py:170: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  k = self.parse_starttag(i)
``````output
3.9.19 Documentation

Download
Download these documents
Docs by version

Python 3.13 (in development)
Python 3.12 (stable)
Python 3.11 (security-fixes)
Python 3.10 (security-fixes)
Python 3.9 (securit
```

훨씬 더 보기 좋습니다!

유사하게 `metadata_extractor`를 전달하여 HTTP 응답에서 문서 메타데이터가 추출되는 방식을 사용자 정의할 수 있습니다. 이에 대한 자세한 내용은 [API 참조](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html)를 참조하십시오.

## API 참조

이 예제들은 기본 `RecursiveUrlLoader`를 수정할 수 있는 몇 가지 방법만 보여주지만, 사용 사례에 가장 적합하게 만들기 위해 더 많은 수정이 가능합니다. `link_regex` 및 `exclude_dirs` 매개변수를 사용하면 원하지 않는 URL을 필터링할 수 있으며, `aload()` 및 `alazy_load()`는 비동기 로딩에 사용할 수 있습니다.

`RecursiveUrlLoader`를 구성하고 호출하는 방법에 대한 자세한 정보는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
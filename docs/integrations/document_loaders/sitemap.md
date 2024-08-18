---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/sitemap.ipynb
description: '`SitemapLoader`는 주어진 URL의 사이트맵을 로드하고, 모든 페이지를 스크랩하여 문서로 반환하는 기능을 제공합니다.'
---

# 사이트맵

`WebBaseLoader`에서 확장된 `SitemapLoader`는 주어진 URL에서 사이트맵을 로드한 다음, 사이트맵의 모든 페이지를 스크랩하고 로드하여 각 페이지를 문서로 반환합니다.

스크래핑은 동시에 수행됩니다. 동시 요청에 대한 합리적인 제한이 있으며, 기본적으로 초당 2개로 설정되어 있습니다. 좋은 시민이 되는 것에 대해 걱정하지 않거나, 스크랩된 서버를 제어하거나, 부하에 신경 쓰지 않는 경우 이 제한을 늘릴 수 있습니다. 이로 인해 스크래핑 프로세스가 빨라지지만, 서버가 당신을 차단할 수 있습니다. 주의하세요!

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/document_loaders/web_loaders/sitemap/)|
| :--- | :--- | :---: | :---: |  :---: |
| [SiteMapLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sitemap.SitemapLoader.html#langchain_community.document_loaders.sitemap.SitemapLoader) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ✅ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| SiteMapLoader | ✅ | ❌ | 

## 설정

SiteMap 문서 로더에 접근하려면 `langchain-community` 통합 패키지를 설치해야 합니다.

### 자격 증명

이를 실행하는 데 자격 증명이 필요하지 않습니다.

모델 호출의 자동 최상급 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community**를 설치합니다.

```python
%pip install -qU langchain-community
```


### 노트북 asyncio 버그 수정

```python
import nest_asyncio

nest_asyncio.apply()
```


## 초기화

이제 모델 객체를 인스턴스화하고 문서를 로드할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SitemapLoader", "source": "langchain_community.document_loaders.sitemap", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sitemap.SitemapLoader.html", "title": "Sitemap"}]-->
from langchain_community.document_loaders.sitemap import SitemapLoader
```


```python
sitemap_loader = SitemapLoader(web_path="https://api.python.langchain.com/sitemap.xml")
```


## 로드

```python
docs = sitemap_loader.load()
docs[0]
```

```output
Fetching pages: 100%|##########| 28/28 [00:04<00:00,  6.83it/s]
```


```output
Document(metadata={'source': 'https://api.python.langchain.com/en/stable/', 'loc': 'https://api.python.langchain.com/en/stable/', 'lastmod': '2024-05-15T00:29:42.163001+00:00', 'changefreq': 'weekly', 'priority': '1'}, page_content='\n\n\n\n\n\n\n\n\n\nLangChain Python API Reference Documentation.\n\n\nYou will be automatically redirected to the new location of this page.\n\n')
```


```python
print(docs[0].metadata)
```

```output
{'source': 'https://api.python.langchain.com/en/stable/', 'loc': 'https://api.python.langchain.com/en/stable/', 'lastmod': '2024-05-15T00:29:42.163001+00:00', 'changefreq': 'weekly', 'priority': '1'}
```

`requests_per_second` 매개변수를 변경하여 최대 동시 요청을 늘릴 수 있으며, 요청을 보낼 때 `requests_kwargs`를 사용하여 kwargs를 전달할 수 있습니다.

```python
sitemap_loader.requests_per_second = 2
# Optional: avoid `[SSL: CERTIFICATE_VERIFY_FAILED]` issue
sitemap_loader.requests_kwargs = {"verify": False}
```


## 지연 로드

메모리 부하를 최소화하기 위해 페이지를 지연 로드할 수도 있습니다.

```python
page = []
for doc in sitemap_loader.lazy_load():
    page.append(doc)
    if len(page) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        page = []
```

```output
Fetching pages: 100%|##########| 28/28 [00:01<00:00, 19.06it/s]
```

## 사이트맵 URL 필터링

사이트맵은 수천 개의 URL을 포함하는 방대한 파일일 수 있습니다. 종종 모든 URL이 필요하지 않습니다. `filter_urls` 매개변수에 문자열 목록이나 정규 표현식을 전달하여 URL을 필터링할 수 있습니다. 패턴 중 하나와 일치하는 URL만 로드됩니다.

```python
loader = SitemapLoader(
    web_path="https://api.python.langchain.com/sitemap.xml",
    filter_urls=["https://api.python.langchain.com/en/latest"],
)
documents = loader.load()
```


```python
documents[0]
```


```output
Document(page_content='\n\n\n\n\n\n\n\n\n\nLangChain Python API Reference Documentation.\n\n\nYou will be automatically redirected to the new location of this page.\n\n', metadata={'source': 'https://api.python.langchain.com/en/latest/', 'loc': 'https://api.python.langchain.com/en/latest/', 'lastmod': '2024-02-12T05:26:10.971077+00:00', 'changefreq': 'daily', 'priority': '0.9'})
```


## 사용자 정의 스크래핑 규칙 추가

`SitemapLoader`는 스크래핑 프로세스에 `beautifulsoup4`를 사용하며, 기본적으로 페이지의 모든 요소를 스크랩합니다. `SitemapLoader` 생성자는 사용자 정의 스크래핑 함수를 허용합니다. 이 기능은 스크래핑 프로세스를 특정 요구에 맞게 조정하는 데 유용할 수 있습니다. 예를 들어, 헤더나 탐색 요소의 스크래핑을 피하고 싶을 수 있습니다.

다음 예제는 탐색 및 헤더 요소를 피하기 위해 사용자 정의 함수를 개발하고 사용하는 방법을 보여줍니다.

`beautifulsoup4` 라이브러리를 가져오고 사용자 정의 함수를 정의합니다.

```python
pip install beautifulsoup4
```


```python
from bs4 import BeautifulSoup


def remove_nav_and_header_elements(content: BeautifulSoup) -> str:
    # Find all 'nav' and 'header' elements in the BeautifulSoup object
    nav_elements = content.find_all("nav")
    header_elements = content.find_all("header")

    # Remove each 'nav' and 'header' element from the BeautifulSoup object
    for element in nav_elements + header_elements:
        element.decompose()

    return str(content.get_text())
```


사용자 정의 함수를 `SitemapLoader` 객체에 추가합니다.

```python
loader = SitemapLoader(
    "https://api.python.langchain.com/sitemap.xml",
    filter_urls=["https://api.python.langchain.com/en/latest/"],
    parsing_function=remove_nav_and_header_elements,
)
```


## 로컬 사이트맵

사이트맵 로더는 로컬 파일을 로드하는 데에도 사용할 수 있습니다.

```python
sitemap_loader = SitemapLoader(web_path="example_data/sitemap.xml", is_local=True)

docs = sitemap_loader.load()
```


## API 참조

모든 SiteMapLoader 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sitemap.SitemapLoader.html#langchain_community.document_loaders.sitemap.SitemapLoader

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [방법 가이드](/docs/how_to/#document-loaders)
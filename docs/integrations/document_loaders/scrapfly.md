---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/scrapfly.ipynb
description: ScrapFly는 웹 페이지 데이터를 추출할 수 있는 웹 스크래핑 API로, 헤드리스 브라우저, 프록시 및 봇 우회 기능을
  제공합니다.
---

## ScrapFly
[ScrapFly](https://scrapfly.io/)는 헤드리스 브라우저 기능, 프록시 및 안티봇 우회를 갖춘 웹 스크래핑 API입니다. 웹 페이지 데이터를 접근 가능한 LLM 마크다운 또는 텍스트로 추출할 수 있습니다.

#### 설치
ScrapFly Python SDK와 필요한 Langchain 패키지를 pip를 사용하여 설치합니다:
```shell
pip install scrapfly-sdk langchain langchain-community
```


#### 사용법

```python
<!--IMPORTS:[{"imported": "ScrapflyLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.scrapfly.ScrapflyLoader.html", "title": "# ScrapFly"}]-->
from langchain_community.document_loaders import ScrapflyLoader

scrapfly_loader = ScrapflyLoader(
    ["https://web-scraping.dev/products"],
    api_key="Your ScrapFly API key",  # Get your API key from https://www.scrapfly.io/
    continue_on_failure=True,  # Ignore unprocessable web pages and log their exceptions
)

# Load documents from URLs as markdown
documents = scrapfly_loader.load()
print(documents)
```


ScrapflyLoader는 스크랩 요청을 사용자 정의하기 위해 ScrapeConfig 객체를 전달할 수도 있습니다. 전체 기능 세부정보 및 API 매개변수는 문서를 참조하십시오: https://scrapfly.io/docs/scrape-api/getting-started

```python
<!--IMPORTS:[{"imported": "ScrapflyLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.scrapfly.ScrapflyLoader.html", "title": "# ScrapFly"}]-->
from langchain_community.document_loaders import ScrapflyLoader

scrapfly_scrape_config = {
    "asp": True,  # Bypass scraping blocking and antibot solutions, like Cloudflare
    "render_js": True,  # Enable JavaScript rendering with a cloud headless browser
    "proxy_pool": "public_residential_pool",  # Select a proxy pool (datacenter or residnetial)
    "country": "us",  # Select a proxy location
    "auto_scroll": True,  # Auto scroll the page
    "js": "",  # Execute custom JavaScript code by the headless browser
}

scrapfly_loader = ScrapflyLoader(
    ["https://web-scraping.dev/products"],
    api_key="Your ScrapFly API key",  # Get your API key from https://www.scrapfly.io/
    continue_on_failure=True,  # Ignore unprocessable web pages and log their exceptions
    scrape_config=scrapfly_scrape_config,  # Pass the scrape_config object
    scrape_format="markdown",  # The scrape result format, either `markdown`(default) or `text`
)

# Load documents from URLs as markdown
documents = scrapfly_loader.load()
print(documents)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
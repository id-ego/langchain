---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/scrapfly/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/scrapfly.ipynb
---

## ScrapFly
[ScrapFly](https://scrapfly.io/) is a web scraping API with headless browser capabilities, proxies, and anti-bot bypass. It allows for extracting web page data into accessible LLM markdown or text.

#### Installation
Install ScrapFly Python SDK and he required Langchain packages using pip:
```shell
pip install scrapfly-sdk langchain langchain-community
```

#### Usage

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

The ScrapflyLoader also allows passigng ScrapeConfig object for customizing the scrape request. See the documentation for the full feature details and their API params: https://scrapfly.io/docs/scrape-api/getting-started

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

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)
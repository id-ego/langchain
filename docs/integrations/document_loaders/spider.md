---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/spider.ipynb
description: Spider는 LLM 준비 데이터를 반환하는 가장 빠르고 저렴한 크롤러 및 스크래퍼입니다. API 키로 쉽게 사용할 수 있습니다.
---

# 스파이더
[스파이더](https://spider.cloud/)는 LLM 준비 데이터로 반환하는 [가장 빠르고](https://github.com/spider-rs/spider/blob/main/benches/BENCHMARKS.md) 가장 저렴한 크롤러 및 스크래퍼입니다.

## 설정

```python
pip install spider-client
```


## 사용법
스파이더를 사용하려면 [spider.cloud](https://spider.cloud/)에서 API 키를 받아야 합니다.

```python
<!--IMPORTS:[{"imported": "SpiderLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.spider.SpiderLoader.html", "title": "Spider"}]-->
from langchain_community.document_loaders import SpiderLoader

loader = SpiderLoader(
    api_key="YOUR_API_KEY",
    url="https://spider.cloud",
    mode="scrape",  # if no API key is provided it looks for SPIDER_API_KEY in env
)

data = loader.load()
print(data)
```

```output
[Document(page_content='Spider - Fastest Web Crawler built for AI Agents and Large Language Models[Spider v1 Logo Spider ](/)The World\'s Fastest and Cheapest Crawler API==========View Demo* Basic* StreamingExample requestPythonCopy```import requests, osheaders = {    \'Authorization\': os.environ["SPIDER_API_KEY"],    \'Content-Type\': \'application/json\',}json_data = {"limit":50,"url":"http://www.example.com"}response = requests.post(\'https://api.spider.cloud/crawl\',  headers=headers,  json=json_data)print(response.json())```Example ResponseScrape with no headaches----------* Proxy rotations* Agent headers* Avoid anti-bot detections* Headless chrome* Markdown LLM ResponsesThe Fastest Web Crawler----------* Powered by [spider-rs](https://github.com/spider-rs/spider)* Do 20,000 pages in seconds* Full concurrency* Powerful and simple API* Cost effectiveScrape Anything with AI----------* Custom scripting browser* Custom data extraction* Data pipelines* Detailed insights* Advanced labeling[API](/docs/api) [Price](/credits/new) [Guides](/guides) [About](/about) [Docs](https://docs.rs/spider/latest/spider/) [Privacy](/privacy) [Terms](/eula)© 2024 Spider from A11yWatchTheme Light Dark Toggle Theme [GitHubGithub](https://github.com/spider-rs/spider)', metadata={'description': 'Collect data rapidly from any website. Seamlessly scrape websites and get data tailored for LLM workloads.', 'domain': 'spider.cloud', 'extracted_data': None, 'file_size': 33743, 'keywords': None, 'pathname': '/', 'resource_type': 'html', 'title': 'Spider - Fastest Web Crawler built for AI Agents and Large Language Models', 'url': '48f1bc3c-3fbb-408a-865b-c191a1bb1f48/spider.cloud/index.html', 'user_id': '48f1bc3c-3fbb-408a-865b-c191a1bb1f48'})]
```

## 모드
- `scrape`: 단일 URL을 스크랩하는 기본 모드
- `crawl`: 제공된 도메인 URL의 모든 하위 페이지를 크롤링

## 크롤러 옵션
`params` 매개변수는 로더에 전달할 수 있는 사전입니다. 사용 가능한 모든 매개변수를 보려면 [스파이더 문서](https://spider.cloud/docs/api)를 참조하십시오.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
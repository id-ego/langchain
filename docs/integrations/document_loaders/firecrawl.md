---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/firecrawl.ipynb
description: FireCrawl은 웹사이트를 LLM 준비 데이터로 변환하며, 복잡한 작업을 처리하고 모든 접근 가능한 하위 페이지를 크롤링합니다.
---

# FireCrawl

[FireCrawl](https://firecrawl.dev/?ref=langchain)은 모든 웹사이트를 LLM 준비 데이터로 크롤링하고 변환합니다. 접근 가능한 모든 하위 페이지를 크롤링하고 각 페이지에 대한 깔끔한 마크다운과 메타데이터를 제공합니다. 사이트맵이 필요 없습니다.

FireCrawl은 리버스 프록시, 캐싱, 속도 제한 및 JavaScript에 의해 차단된 콘텐츠와 같은 복잡한 작업을 처리합니다. [mendable.ai](https://mendable.ai) 팀에 의해 구축되었습니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/document_loaders/web_loaders/firecrawl/)|
| :--- | :--- | :---: | :---: |  :---: |
| [FireCrawlLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.firecrawl.FireCrawlLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ✅ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| FireCrawlLoader | ✅ | ❌ | 

## 설정

### 자격 증명

자신의 API 키를 받아야 합니다. [이 페이지](https://firecrawl.dev)로 가서 자세히 알아보세요.

```python
import getpass
import os

if "FIRECRAWL_API_KEY" not in os.environ:
    os.environ["FIRECRAWL_API_KEY"] = getpass.getpass("Enter your Firecrawl API key: ")
```


### 설치

`langchain_community`와 `firecrawl-py` 패키지를 모두 설치해야 합니다:

```python
%pip install -qU firecrawl-py langchain_community
```


## 초기화

### 모드

- `scrape`: 단일 URL을 스크랩하고 마크다운을 반환합니다.
- `crawl`: URL과 모든 접근 가능한 하위 페이지를 크롤링하고 각 페이지에 대한 마크다운을 반환합니다.

```python
<!--IMPORTS:[{"imported": "FireCrawlLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.firecrawl.FireCrawlLoader.html", "title": "FireCrawl"}]-->
from langchain_community.document_loaders import FireCrawlLoader

loader = FireCrawlLoader(url="https://firecrawl.dev", mode="crawl")
```


## 로드

```python
docs = loader.load()

docs[0]
```


```output
Document(metadata={'ogUrl': 'https://www.firecrawl.dev/', 'title': 'Home - Firecrawl', 'robots': 'follow, index', 'ogImage': 'https://www.firecrawl.dev/og.png?123', 'ogTitle': 'Firecrawl', 'sitemap': {'lastmod': '2024-08-12T00:28:16.681Z', 'changefreq': 'weekly'}, 'keywords': 'Firecrawl,Markdown,Data,Mendable,Langchain', 'sourceURL': 'https://www.firecrawl.dev/', 'ogSiteName': 'Firecrawl', 'description': 'Firecrawl crawls and converts any website into clean markdown.', 'ogDescription': 'Turn any website into LLM-ready data.', 'pageStatusCode': 200, 'ogLocaleAlternate': []}, page_content='Introducing [Smart Crawl!](https://www.firecrawl.dev/smart-crawl)\n Join the waitlist to turn any website into an API with AI\n\n\n\n[🔥 Firecrawl](/)\n\n*   [Playground](/playground)\n    \n*   [Docs](https://docs.firecrawl.dev)\n    \n*   [Pricing](/pricing)\n    \n*   [Blog](/blog)\n    \n*   Beta Features\n\n[Log In](/signin)\n[Log In](/signin)\n[Sign Up](/signin/signup)\n 8.9k\n\n[💥 Get 2 months free with yearly plan](/pricing)\n\nTurn websites into  \n_LLM-ready_ data\n=====================================\n\nPower your AI apps with clean data crawled from any website. It\'s also open-source.\n\nStart for free (500 credits)Start for free[Talk to us](https://calendly.com/d/cj83-ngq-knk/meet-firecrawl)\n\nA product by\n\n[![Mendable Logo](https://www.firecrawl.dev/images/mendable_logo_transparent.png)Mendable](https://mendable.ai)\n\n![Example Webpage](https://www.firecrawl.dev/multiple-websites.png)\n\nCrawl, Scrape, Clean\n--------------------\n\nWe crawl all accessible subpages and give you clean markdown for each. No sitemap required.\n\n    \n      [\\\n        {\\\n          "url": "https://www.firecrawl.dev/",\\\n          "markdown": "## Welcome to Firecrawl\\\n            Firecrawl is a web scraper that allows you to extract the content of a webpage."\\\n        },\\\n        {\\\n          "url": "https://www.firecrawl.dev/features",\\\n          "markdown": "## Features\\\n            Discover how Firecrawl\'s cutting-edge features can \\\n            transform your data operations."\\\n        },\\\n        {\\\n          "url": "https://www.firecrawl.dev/pricing",\\\n          "markdown": "## Pricing Plans\\\n            Choose the perfect plan that fits your needs."\\\n        },\\\n        {\\\n          "url": "https://www.firecrawl.dev/about",\\\n          "markdown": "## About Us\\\n            Learn more about Firecrawl\'s mission and the \\\n            team behind our innovative platform."\\\n        }\\\n      ]\n      \n\nNote: The markdown has been edited for display purposes.\n\nTrusted by Top Companies\n------------------------\n\n[![Customer Logo](https://www.firecrawl.dev/logos/zapier.png)](https://www.zapier.com)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/gamma.svg)](https://gamma.app)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/nvidia-com.png)](https://www.nvidia.com)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/teller-io.svg)](https://www.teller.io)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/stackai.svg)](https://www.stack-ai.com)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/palladiumdigital-co-uk.svg)](https://www.palladiumdigital.co.uk)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/worldwide-casting-com.svg)](https://www.worldwide-casting.com)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/open-gov-sg.png)](https://www.open.gov.sg)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/bain-com.svg)](https://www.bain.com)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/demand-io.svg)](https://www.demand.io)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/nocodegarden-io.png)](https://www.nocodegarden.io)\n\n[![Customer Logo](https://www.firecrawl.dev/logos/cyberagent-co-jp.svg)](https://www.cyberagent.co.jp)\n\nIntegrate today\n---------------\n\nEnhance your applications with top-tier web scraping and crawling capabilities.\n\n#### Scrape\n\nExtract markdown or structured data from websites quickly and efficiently.\n\n#### Crawling\n\nNavigate and retrieve data from all accessible subpages, even without a sitemap.\n\nNode.js\n\nPython\n\ncURL\n\n1\n\n2\n\n3\n\n4\n\n5\n\n6\n\n7\n\n8\n\n9\n\n10\n\n// npm install @mendable/firecrawl-js  \n  \nimport FirecrawlApp from \'@mendable/firecrawl-js\';  \n  \nconst app \\= new FirecrawlApp({ apiKey: "fc-YOUR\\_API\\_KEY" });  \n  \n// Scrape a website:  \nconst scrapeResult \\= await app.scrapeUrl(\'firecrawl.dev\');  \n  \nconsole.log(scrapeResult.data.markdown)\n\n#### Use well-known tools\n\nAlready fully integrated with the greatest existing tools and workflows.\n\n[![LlamaIndex](https://www.firecrawl.dev/logos/llamaindex.svg)](https://docs.llamaindex.ai/en/stable/examples/data_connectors/WebPageDemo/#using-firecrawl-reader/)\n[![Langchain](https://www.firecrawl.dev/integrations/langchain.png)](https://python.langchain.com/v0.2/docs/integrations/document_loaders/firecrawl/)\n[![Dify](https://www.firecrawl.dev/logos/dify.png)](https://dify.ai/blog/dify-ai-blog-integrated-with-firecrawl/)\n[![Dify](https://www.firecrawl.dev/integrations/langflow_2.png)](https://www.langflow.org/)\n[![Flowise](https://www.firecrawl.dev/integrations/flowise.png)](https://flowiseai.com/)\n[![CrewAI](https://www.firecrawl.dev/integrations/crewai.png)](https://crewai.com/)\n\n#### Start for free, scale easily\n\nKick off your journey for free and scale seamlessly as your project expands.\n\n[Try it out](/signin/signup)\n\n#### Open-source\n\nDeveloped transparently and collaboratively. Join our community of contributors.\n\n[Check out our repo](https://github.com/mendableai/firecrawl)\n\nWe handle the hard stuff\n------------------------\n\nRotating proxies, caching, rate limits, js-blocked content and more\n\n#### Crawling\n\nFirecrawl crawls all accessible subpages, even without a sitemap.\n\n#### Dynamic content\n\nFirecrawl gathers data even if a website uses javascript to render content.\n\n#### To Markdown\n\nFirecrawl returns clean, well formatted markdown - ready for use in LLM applications\n\n#### Crawling Orchestration\n\nFirecrawl orchestrates the crawling process in parallel for the fastest results.\n\n#### Caching\n\nFirecrawl caches content, so you don\'t have to wait for a full scrape unless new content exists.\n\n#### Built for AI\n\nBuilt by LLM engineers, for LLM engineers. Giving you clean data the way you want it.\n\nOur wall of love\n\nDon\'t take our word for it\n--------------------------\n\n![Greg Kamradt](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-02.0afeb750.jpg&w=96&q=75)\n\nGreg Kamradt\n\n[@GregKamradt](https://twitter.com/GregKamradt/status/1780300642197840307)\n\nLLM structured data via API, handling requests, cleaning, and crawling. Enjoyed the early preview.\n\n![Amit Naik](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-03.ff5dbe11.jpg&w=96&q=75)\n\nAmit Naik\n\n[@suprgeek](https://twitter.com/suprgeek/status/1780338213351035254)\n\n#llm success with RAG relies on Retrieval. Firecrawl by @mendableai structures web content for processing. 👏\n\n![Jerry Liu](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-04.76bef0df.jpg&w=96&q=75)\n\nJerry Liu\n\n[@jerryjliu0](https://twitter.com/jerryjliu0/status/1781122933349572772)\n\nFirecrawl is awesome 🔥 Turns web pages into structured markdown for LLM apps, thanks to @mendableai.\n\n![Bardia Pourvakil](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-01.025350bc.jpeg&w=96&q=75)\n\nBardia Pourvakil\n\n[@thepericulum](https://twitter.com/thepericulum/status/1781397799487078874)\n\nThese guys ship. I wanted types for their node SDK, and less than an hour later, I got them. Can\'t recommend them enough.\n\n![latentsauce 🧘🏽](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-07.c2285d35.jpeg&w=96&q=75)\n\nlatentsauce 🧘🏽\n\n[@latentsauce](https://twitter.com/latentsauce/status/1781738253927735331)\n\nFirecrawl simplifies data preparation significantly, exactly what I was hoping for. Thank you for creating Firecrawl ❤️❤️❤️\n\n![Greg Kamradt](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-02.0afeb750.jpg&w=96&q=75)\n\nGreg Kamradt\n\n[@GregKamradt](https://twitter.com/GregKamradt/status/1780300642197840307)\n\nLLM structured data via API, handling requests, cleaning, and crawling. Enjoyed the early preview.\n\n![Amit Naik](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-03.ff5dbe11.jpg&w=96&q=75)\n\nAmit Naik\n\n[@suprgeek](https://twitter.com/suprgeek/status/1780338213351035254)\n\n#llm success with RAG relies on Retrieval. Firecrawl by @mendableai structures web content for processing. 👏\n\n![Jerry Liu](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-04.76bef0df.jpg&w=96&q=75)\n\nJerry Liu\n\n[@jerryjliu0](https://twitter.com/jerryjliu0/status/1781122933349572772)\n\nFirecrawl is awesome 🔥 Turns web pages into structured markdown for LLM apps, thanks to @mendableai.\n\n![Bardia Pourvakil](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-01.025350bc.jpeg&w=96&q=75)\n\nBardia Pourvakil\n\n[@thepericulum](https://twitter.com/thepericulum/status/1781397799487078874)\n\nThese guys ship. I wanted types for their node SDK, and less than an hour later, I got them. Can\'t recommend them enough.\n\n![latentsauce 🧘🏽](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-07.c2285d35.jpeg&w=96&q=75)\n\nlatentsauce 🧘🏽\n\n[@latentsauce](https://twitter.com/latentsauce/status/1781738253927735331)\n\nFirecrawl simplifies data preparation significantly, exactly what I was hoping for. Thank you for creating Firecrawl ❤️❤️❤️\n\n![Michael Ning](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-05.76d7cd3e.png&w=96&q=75)\n\nMichael Ning\n\n[](#)\n\nFirecrawl is impressive, saving us 2/3 the tokens and allowing gpt3.5turbo use over gpt4. Major savings in time and money.\n\n![Alex Reibman 🖇️](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-06.4ee7cf5a.jpeg&w=96&q=75)\n\nAlex Reibman 🖇️\n\n[@AlexReibman](https://twitter.com/AlexReibman/status/1780299595484131836)\n\nMoved our internal agent\'s web scraping tool from Apify to Firecrawl because it benchmarked 50x faster with AgentOps.\n\n![Michael](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-08.0bed40be.jpeg&w=96&q=75)\n\nMichael\n\n[@michael\\_chomsky](#)\n\nI really like some of the design decisions Firecrawl made, so I really want to share with others.\n\n![Paul Scott](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-09.d303b5b4.png&w=96&q=75)\n\nPaul Scott\n\n[@palebluepaul](https://twitter.com/palebluepaul)\n\nAppreciating your lean approach, Firecrawl ticks off everything on our list without the cost prohibitive overkill.\n\n![Michael Ning](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-05.76d7cd3e.png&w=96&q=75)\n\nMichael Ning\n\n[](#)\n\nFirecrawl is impressive, saving us 2/3 the tokens and allowing gpt3.5turbo use over gpt4. Major savings in time and money.\n\n![Alex Reibman 🖇️](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-06.4ee7cf5a.jpeg&w=96&q=75)\n\nAlex Reibman 🖇️\n\n[@AlexReibman](https://twitter.com/AlexReibman/status/1780299595484131836)\n\nMoved our internal agent\'s web scraping tool from Apify to Firecrawl because it benchmarked 50x faster with AgentOps.\n\n![Michael](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-08.0bed40be.jpeg&w=96&q=75)\n\nMichael\n\n[@michael\\_chomsky](#)\n\nI really like some of the design decisions Firecrawl made, so I really want to share with others.\n\n![Paul Scott](https://www.firecrawl.dev/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftestimonial-09.d303b5b4.png&w=96&q=75)\n\nPaul Scott\n\n[@palebluepaul](https://twitter.com/palebluepaul)\n\nAppreciating your lean approach, Firecrawl ticks off everything on our list without the cost prohibitive overkill.\n\nFlexible Pricing\n----------------\n\nStart for free, then scale as you grow\n\nYearly (17% off)Yearly (2 months free)Monthly\n\nFree Plan\n---------\n\n500 credits\n\n$0/month\n\n*   Scrape 500 pages\n*   5 /scrape per min\n*   1 /crawl per min\n\nGet Started\n\nHobby\n-----\n\n3,000 credits\n\n$16/month\n\n*   Scrape 3,000 pages\n*   10 /scrape per min\n*   3 /crawl per min\n\nSubscribe\n\nStandardMost Popular\n--------------------\n\n100,000 credits\n\n$83/month\n\n*   Scrape 100,000 pages\n*   50 /scrape per min\n*   10 /crawl per min\n\nSubscribe\n\nGrowth\n------\n\n500,000 credits\n\n$333/month\n\n*   Scrape 500,000 pages\n*   500 /scrape per min\n*   50 /crawl per min\n*   Priority Support\n\nSubscribe\n\nEnterprise Plan\n---------------\n\nUnlimited credits. Custom RPMs.\n\nTalk to us\n\n*   Top priority support\n*   Feature Acceleration\n*   SLAs\n*   Account Manager\n*   Custom rate limits volume\n*   Custom concurrency limits\n*   Beta features access\n*   CEO\'s number\n\n\\* a /scrape refers to the [scrape](https://docs.firecrawl.dev/api-reference/endpoint/scrape)\n API endpoint.\n\n\\* a /crawl refers to the [crawl](https://docs.firecrawl.dev/api-reference/endpoint/crawl)\n API endpoint.\n\nScrape Credits\n--------------\n\nScrape credits are consumed for each API request, varying by endpoint and feature.\n\n| Features | Credits per page |\n| --- | --- |\n| Scrape(/scrape) | 1   |\n| Crawl(/crawl) | 1   |\n| Search(/search) | 1   |\n| Scrape + LLM extraction (/scrape) | 50  |\n\n[🔥](/)\n\nReady to _Build?_\n-----------------\n\nStart scraping web data for your AI apps today.  \nNo credit card needed.\n\n[Get Started](/signin)\n\n[Talk to us](https://calendly.com/d/cj83-ngq-knk/meet-firecrawl)\n\nFAQ\n---\n\nFrequently asked questions about Firecrawl\n\n#### General\n\nWhat is Firecrawl?\n\nFirecrawl turns entire websites into clean, LLM-ready markdown or structured data. Scrape, crawl and extract the web with a single API. Ideal for AI companies looking to empower their LLM applications with web data.\n\nWhat sites work?\n\nFirecrawl is best suited for business websites, docs and help centers. We currently don\'t support social media platforms.\n\nWho can benefit from using Firecrawl?\n\nFirecrawl is tailored for LLM engineers, data scientists, AI researchers, and developers looking to harness web data for training machine learning models, market research, content aggregation, and more. It simplifies the data preparation process, allowing professionals to focus on insights and model development.\n\nIs Firecrawl open-source?\n\nYes, it is. You can check out the repository on GitHub. Keep in mind that this repository is currently in its early stages of development. We are in the process of merging custom modules into this mono repository.\n\n#### Scraping & Crawling\n\nHow does Firecrawl handle dynamic content on websites?\n\nUnlike traditional web scrapers, Firecrawl is equipped to handle dynamic content rendered with JavaScript. It ensures comprehensive data collection from all accessible subpages, making it a reliable tool for scraping websites that rely heavily on JS for content delivery.\n\nWhy is it not crawling all the pages?\n\nThere are a few reasons why Firecrawl may not be able to crawl all the pages of a website. Some common reasons include rate limiting, and anti-scraping mechanisms, disallowing the crawler from accessing certain pages. If you\'re experiencing issues with the crawler, please reach out to our support team at hello@firecrawl.com.\n\nCan Firecrawl crawl websites without a sitemap?\n\nYes, Firecrawl can access and crawl all accessible subpages of a website, even in the absence of a sitemap. This feature enables users to gather data from a wide array of web sources with minimal setup.\n\nWhat formats can Firecrawl convert web data into?\n\nFirecrawl specializes in converting web data into clean, well-formatted markdown. This format is particularly suited for LLM applications, offering a structured yet flexible way to represent web content.\n\nHow does Firecrawl ensure the cleanliness of the data?\n\nFirecrawl employs advanced algorithms to clean and structure the scraped data, removing unnecessary elements and formatting the content into readable markdown. This process ensures that the data is ready for use in LLM applications without further preprocessing.\n\nIs Firecrawl suitable for large-scale data scraping projects?\n\nAbsolutely. Firecrawl offers various pricing plans, including a Scale plan that supports scraping of millions of pages. With features like caching and scheduled syncs, it\'s designed to efficiently handle large-scale data scraping and continuous updates, making it ideal for enterprises and large projects.\n\nDoes it respect robots.txt?\n\nYes, Firecrawl crawler respects the rules set in a website\'s robots.txt file. If you notice any issues with the way Firecrawl interacts with your website, you can adjust the robots.txt file to control the crawler\'s behavior. Firecrawl user agent name is \'FirecrawlAgent\'. If you notice any behavior that is not expected, please let us know at hello@firecrawl.com.\n\nWhat measures does Firecrawl take to handle web scraping challenges like rate limits and caching?\n\nFirecrawl is built to navigate common web scraping challenges, including reverse proxies, rate limits, and caching. It smartly manages requests and employs caching techniques to minimize bandwidth usage and avoid triggering anti-scraping mechanisms, ensuring reliable data collection.\n\nDoes Firecrawl handle captcha or authentication?\n\nFirecrawl avoids captcha by using stealth proxyies. When it encounters captcha, it attempts to solve it automatically, but this is not always possible. We are working to add support for more captcha solving methods. Firecrawl can handle authentication by providing auth headers to the API.\n\n#### API Related\n\nWhere can I find my API key?\n\nClick on the dashboard button on the top navigation menu when logged in and you will find your API key in the main screen and under API Keys.\n\n#### Billing\n\nIs Firecrawl free?\n\nFirecrawl is free for the first 500 scraped pages (500 free credits). After that, you can upgrade to our Standard or Scale plans for more credits.\n\nIs there a pay per use plan instead of monthly?\n\nNo we do not currently offer a pay per use plan, instead you can upgrade to our Standard or Growth plans for more credits and higher rate limits.\n\nHow many credit does scraping, crawling, and extraction cost?\n\nScraping costs 1 credit per page. Crawling costs 1 credit per page.\n\nDo you charge for failed requests (scrape, crawl, extract)?\n\nWe do not charge for any failed requests (scrape, crawl, extract). Please contact support at help@firecrawl.dev if you have any questions.\n\nWhat payment methods do you accept?\n\nWe accept payments through Stripe which accepts most major credit cards, debit cards, and PayPal.\n\n[🔥](/)\n\n© A product by Mendable.ai - All rights reserved.\n\n[StatusStatus](https://firecrawl.betteruptime.com)\n[Terms of ServiceTerms of Service](/terms-of-service)\n[Privacy PolicyPrivacy Policy](/privacy-policy)\n\n[Twitter](https://twitter.com/mendableai)\n[GitHub](https://github.com/mendableai)\n[Discord](https://discord.gg/gSmWdAkdwd)\n\n###### Helpful Links\n\n*   [Status](https://firecrawl.betteruptime.com/)\n    \n*   [Pricing](/pricing)\n    \n*   [Blog](https://www.firecrawl.dev/blog)\n    \n*   [Docs](https://docs.firecrawl.dev)\n    \n\nBacked by![Y Combinator Logo](https://www.firecrawl.dev/images/yc.svg)\n\n![SOC 2 Type II](https://www.firecrawl.dev/soc2type2badge.png)\n\n###### Resources\n\n*   [Community](#0)\n    \n*   [Terms of service](#0)\n    \n*   [Collaboration features](#0)\n    \n\n###### Legals\n\n*   [Refund policy](#0)\n    \n*   [Terms & Conditions](#0)\n    \n*   [Privacy policy](#0)\n    \n*   [Brand Kit](#0)')
```


```python
print(docs[0].metadata)
```

```output
{'ogUrl': 'https://www.firecrawl.dev/', 'title': 'Home - Firecrawl', 'robots': 'follow, index', 'ogImage': 'https://www.firecrawl.dev/og.png?123', 'ogTitle': 'Firecrawl', 'sitemap': {'lastmod': '2024-08-12T00:28:16.681Z', 'changefreq': 'weekly'}, 'keywords': 'Firecrawl,Markdown,Data,Mendable,Langchain', 'sourceURL': 'https://www.firecrawl.dev/', 'ogSiteName': 'Firecrawl', 'description': 'Firecrawl crawls and converts any website into clean markdown.', 'ogDescription': 'Turn any website into LLM-ready data.', 'pageStatusCode': 200, 'ogLocaleAlternate': []}
```

## 지연 로드

메모리 요구 사항을 최소화하기 위해 지연 로딩을 사용할 수 있습니다.

```python
pages = []
for doc in loader.lazy_load():
    pages.append(doc)
    if len(pages) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        pages = []
```


```python
len(pages)
```


```output
8
```


```python
print(pages[0].page_content[:100])
print(pages[0].metadata)
```

```output
Introducing [Smart Crawl!](https://www.firecrawl.dev/smart-crawl)
 Join the waitlist to turn any web
{'ogUrl': 'https://www.firecrawl.dev/blog/introducing-fire-engine-for-firecrawl', 'title': 'Introducing Fire Engine for Firecrawl', 'robots': 'follow, index', 'ogImage': 'https://www.firecrawl.dev/images/blog/fire-engine-launch.png', 'ogTitle': 'Introducing Fire Engine for Firecrawl', 'sitemap': {'lastmod': '2024-08-06T00:00:00.000Z', 'changefreq': 'weekly'}, 'keywords': 'firecrawl,fireengine,web crawling,dashboard,web scraping,LLM,data extraction', 'sourceURL': 'https://www.firecrawl.dev/blog/introducing-fire-engine-for-firecrawl', 'ogSiteName': 'Firecrawl', 'description': 'The most scalable, reliable, and fast way to get web data for Firecrawl.', 'ogDescription': 'The most scalable, reliable, and fast way to get web data for Firecrawl.', 'pageStatusCode': 200, 'ogLocaleAlternate': []}
```

## 크롤러 옵션

로더에 `params`를 전달할 수도 있습니다. 이는 크롤러에 전달할 옵션의 사전입니다. 자세한 내용은 [FireCrawl API 문서](https://github.com/mendableai/firecrawl-py)를 참조하세요.

## API 참조

모든 `FireCrawlLoader` 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.firecrawl.FireCrawlLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
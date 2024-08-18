---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/chaindesk.ipynb
description: Chaindesk 플랫폼은 다양한 데이터 소스를 데이터 저장소로 통합하여 ChatGPT 및 LLM과 연결할 수 있는 기능을
  제공합니다.
---

# Chaindesk

> [Chaindesk 플랫폼](https://docs.chaindesk.ai/introduction)은 데이터 소스(텍스트, PDF, Word, PowerPoint, Excel, Notion, Airtable, Google Sheets 등)에서 데이터를 가져와 데이터 저장소(여러 데이터 소스의 컨테이너)로 전송합니다. 그런 다음 데이터 저장소는 `Chaindesk API`를 통해 ChatGPT 또는 기타 대형 언어 모델(LLM)에 연결될 수 있습니다.

이 노트북은 [Chaindesk의](https://www.chaindesk.ai/) 검색기를 사용하는 방법을 보여줍니다.

먼저, Chaindesk에 가입하고, 데이터 저장소를 생성하고, 데이터를 추가한 후 데이터 저장소 API 엔드포인트 URL을 가져와야 합니다. [API 키](https://docs.chaindesk.ai/api-reference/authentication)가 필요합니다.

## 쿼리

이제 인덱스가 설정되었으므로 검색기를 설정하고 쿼리를 시작할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChaindeskRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.chaindesk.ChaindeskRetriever.html", "title": "Chaindesk"}]-->
from langchain_community.retrievers import ChaindeskRetriever
```


```python
retriever = ChaindeskRetriever(
    datastore_url="https://clg1xg2h80000l708dymr0fxc.chaindesk.ai/query",
    # api_key="CHAINDESK_API_KEY", # optional if datastore is public
    # top_k=10 # optional
)
```


```python
retriever.invoke("What is Daftpage?")
```


```output
[Document(page_content='✨ Made with DaftpageOpen main menuPricingTemplatesLoginSearchHelpGetting StartedFeaturesAffiliate ProgramGetting StartedDaftpage is a new type of website builder that works like a doc.It makes website building easy, fun and offers tons of powerful features for free. Just type / in your page to get started!DaftpageCopyright © 2022 Daftpage, Inc.All rights reserved.ProductPricingTemplatesHelp & SupportHelp CenterGetting startedBlogCompanyAboutRoadmapTwitterAffiliate Program👾 Discord', metadata={'source': 'https:/daftpage.com/help/getting-started', 'score': 0.8697265}),
 Document(page_content="✨ Made with DaftpageOpen main menuPricingTemplatesLoginSearchHelpGetting StartedFeaturesAffiliate ProgramHelp CenterWelcome to Daftpage’s help center—the one-stop shop for learning everything about building websites with Daftpage.Daftpage is the simplest way to create websites for all purposes in seconds. Without knowing how to code, and for free!Get StartedDaftpage is a new type of website builder that works like a doc.It makes website building easy, fun and offers tons of powerful features for free. Just type / in your page to get started!Start here✨ Create your first site🧱 Add blocks🚀 PublishGuides🔖 Add a custom domainFeatures🔥 Drops🎨 Drawings👻 Ghost mode💀 Skeleton modeCant find the answer you're looking for?mail us at support@daftpage.comJoin the awesome Daftpage community on: 👾 DiscordDaftpageCopyright © 2022 Daftpage, Inc.All rights reserved.ProductPricingTemplatesHelp & SupportHelp CenterGetting startedBlogCompanyAboutRoadmapTwitterAffiliate Program👾 Discord", metadata={'source': 'https:/daftpage.com/help', 'score': 0.86570895}),
 Document(page_content=" is the simplest way to create websites for all purposes in seconds. Without knowing how to code, and for free!Get StartedDaftpage is a new type of website builder that works like a doc.It makes website building easy, fun and offers tons of powerful features for free. Just type / in your page to get started!Start here✨ Create your first site🧱 Add blocks🚀 PublishGuides🔖 Add a custom domainFeatures🔥 Drops🎨 Drawings👻 Ghost mode💀 Skeleton modeCant find the answer you're looking for?mail us at support@daftpage.comJoin the awesome Daftpage community on: 👾 DiscordDaftpageCopyright © 2022 Daftpage, Inc.All rights reserved.ProductPricingTemplatesHelp & SupportHelp CenterGetting startedBlogCompanyAboutRoadmapTwitterAffiliate Program👾 Discord", metadata={'source': 'https:/daftpage.com/help', 'score': 0.8645384})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
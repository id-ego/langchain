---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/kay.ipynb
description: Kay.ai는 AI 에이전트가 즉시 컨텍스트를 검색할 수 있도록 고품질 임베딩으로 세계 최대 데이터셋을 큐레이션합니다.
---

# Kay.ai

> [Kai Data API](https://www.kay.ai/) RAG를 위해 구축됨 🕵️ 우리는 AI 에이전트가 즉시 컨텍스트를 검색할 수 있도록 세계에서 가장 큰 데이터 세트를 고품질 임베딩으로 선별하고 있습니다. 최신 모델, 빠른 검색, 그리고 제로 인프라.

이 노트북은 [Kay](https://kay.ai/)에서 지원하는 데이터 세트를 검색하는 방법을 보여줍니다. 현재 `SEC Filings` 및 `미국 기업의 보도 자료`를 검색할 수 있습니다. 최신 데이터 업데이트는 [kay.ai](https://kay.ai)에서 확인하세요. 질문이 있는 경우, [discord](https://discord.gg/hAnE4e5T6M)에 참여하거나 [우리에게 트윗하세요](https://twitter.com/vishalrohra_).

## 설치

먼저, [`kay` 패키지](https://pypi.org/project/kay/)를 설치하세요.

```python
!pip install kay
```


API 키도 필요합니다: [https://kay.ai](https://kay.ai/)에서 무료로 받을 수 있습니다. API 키를 받으면 환경 변수 `KAY_API_KEY`로 설정해야 합니다.

`KayAiRetriever`는 다음 인수를 사용하는 정적 `.create()` 팩토리 메서드를 가지고 있습니다:

* `dataset_id: string` 필수 -- Kay 데이터 세트 ID입니다. 이는 기업, 사람 또는 장소와 같은 특정 엔티티에 대한 데이터 모음입니다. 예를 들어, `"company"`를 시도해 보세요.
* `data_type: List[string]` 선택 사항 -- 이는 데이터 세트의 출처 또는 형식에 따라 ‘SEC Filings’, ‘Press Releases’, 또는 “company” 데이터 세트 내의 ‘Reports’와 같은 카테고리입니다. 예를 들어, “company” 데이터 세트에서 ["10-K", "10-Q", "PressRelease"]를 시도해 보세요. 비워두면 Kay가 모든 유형에서 가장 관련성 높은 컨텍스트를 검색합니다.
* `num_contexts: int` 선택 사항, 기본값 6 -- `get_relevant_documents()` 호출 시 검색할 문서 조각의 수입니다.

## 예제

### 기본 검색기 사용법

```python
# Setup API key
from getpass import getpass

KAY_API_KEY = getpass()
```

```output
 ········
```


```python
<!--IMPORTS:[{"imported": "KayAiRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.kay.KayAiRetriever.html", "title": "Kay.ai"}]-->
import os

from langchain_community.retrievers import KayAiRetriever

os.environ["KAY_API_KEY"] = KAY_API_KEY
retriever = KayAiRetriever.create(
    dataset_id="company", data_types=["10-K", "10-Q", "PressRelease"], num_contexts=3
)
docs = retriever.invoke(
    "What were the biggest strategy changes and partnerships made by Roku in 2023??"
)
```


```python
docs
```


```output
[Document(page_content='Company Name: ROKU INC\nCompany Industry: CABLE & OTHER PAY TELEVISION SERVICES\nArticle Title: Roku Is One of Fast Company\'s Most Innovative Companies for 2023\nText: The company launched several new devices, including the Roku Voice Remote Pro; upgraded its most premium player, the Roku Ultra; and expanded its products with a new line of smart home devices such as video doorbells, lights, and plugs integrated into the Roku ecosystem. Recently, the company announced it will launch Roku-branded TVs this spring to offer more choice and innovation to both consumers and Roku TV partners. Throughout 2022, Roku also updated its operating system (OS), the only OS purpose-built for TV, with more personalization features and enhancements across search, audio, and content discovery, launching The Buzz, Sports, and What to Watch, which provides tailored movie and TV recommendations on the Home Screen Menu. The company also released a new feature for streamers, Photo Streams, that allows customers to display and share photo albums through Roku streaming devices. Additionally, Roku unveiled Shoppable Ads, a new ad innovation that makes shopping on TV streaming as easy as it is on social media. Viewers simply press "OK" with their Roku remote on a shoppable ad and proceed to check out with their shipping and payment details pre-populated from Roku Pay, its proprietary payments platform. Walmart was the exclusive retailer for the launch, a first-of-its-kind partnership.', metadata={'chunk_type': 'text', 'chunk_years_mentioned': [2022, 2023], 'company_name': 'ROKU INC', 'company_sic_code_description': 'CABLE & OTHER PAY TELEVISION SERVICES', 'data_source': 'PressRelease', 'data_source_link': 'https://newsroom.roku.com/press-releases', 'data_source_publish_date': '2023-03-02T09:30:00-04:00', 'data_source_uid': '963d4a81-f58e-3093-af68-987fb1758c15', 'title': "ROKU INC |  Roku Is One of Fast Company's Most Innovative Companies for 2023"}),
 Document(page_content='Company Name: ROKU INC\nCompany Industry: CABLE & OTHER PAY TELEVISION SERVICES\nArticle Title: Roku Is One of Fast Company\'s Most Innovative Companies for 2023\nText: Finally, Roku grew its content offering with thousands of apps and watching options for users, including content on The Roku Channel, a top five app by reach and engagement on the Roku platform in the U.S. in 2022. In November, Roku released its first feature film, "WEIRD: The Weird Al\' Yankovic Story," a biopic starring Daniel Radcliffe. Throughout the year, The Roku Channel added FAST channels from NBCUniversal and the National Hockey League, as well as an exclusive AMC channel featuring its signature drama "Mad Men." This year, the company announced a deal with Warner Bros. Discovery, launching new channels that will include "Westworld" and "The Bachelor," in addition to 2,000 hours of on-demand content. Read more about Roku\'s journey here . Fast Company\'s Most Innovative Companies issue (March/April 2023) is available online here , as well as in-app via iTunes and on newsstands beginning March 14. About Roku, Inc.\nRoku pioneered streaming to the TV. We connect users to the streaming content they love, enable content publishers to build and monetize large audiences, and provide advertisers with unique capabilities to engage consumers. Roku streaming players and TV-related audio devices are available in the U.S. and in select countries through direct retail sales and licensing arrangements with service operators. Roku TV models are available in the U.S. and select countries through licensing arrangements with TV OEM brands.', metadata={'chunk_type': 'text', 'chunk_years_mentioned': [2022, 2023], 'company_name': 'ROKU INC', 'company_sic_code_description': 'CABLE & OTHER PAY TELEVISION SERVICES', 'data_source': 'PressRelease', 'data_source_link': 'https://newsroom.roku.com/press-releases', 'data_source_publish_date': '2023-03-02T09:30:00-04:00', 'data_source_uid': '963d4a81-f58e-3093-af68-987fb1758c15', 'title': "ROKU INC |  Roku Is One of Fast Company's Most Innovative Companies for 2023"}),
 Document(page_content='Company Name: ROKU INC\nCompany Industry: CABLE & OTHER PAY TELEVISION SERVICES\nArticle Title: Roku\'s New NFL Zone Gives Fans Easy Access to NFL Games Right On Time for 2023 Season\nText: In partnership with the NFL, the new NFL Zone offers viewers an easy way to find where to watch NFL live games Today, Roku (NASDAQ: ROKU ) and the National Football League (NFL) announced the recently launched NFL Zone within the Roku Sports experience to kick off the 2023 NFL season. This strategic partnership between Roku and the NFL marks the first official league-branded zone within Roku\'s Sports experience. Available now, the NFL Zone offers football fans a centralized location to find live and upcoming games, so they can spend less time figuring out where to watch the game and more time rooting for their favorite teams. Users can also tune in for weekly game previews, League highlights, and additional NFL content, all within the zone. This press release features multimedia. View the full release here: In partnership with the NFL, Roku\'s new NFL Zone offers viewers an easy way to find where to watch NFL live games (Photo: Business Wire) "Last year we introduced the Sports experience for our highly engaged sports audience, making it simpler for Roku users to watch sports programming," said Gidon Katz, President, Consumer Experience, at Roku. "As we start the biggest sports season of the year, providing easy access to NFL games and content to our millions of users is a top priority for us. We look forward to fans immersing themselves within the NFL Zone and making it their destination to find NFL games.', metadata={'chunk_type': 'text', 'chunk_years_mentioned': [2023], 'company_name': 'ROKU INC', 'company_sic_code_description': 'CABLE & OTHER PAY TELEVISION SERVICES', 'data_source': 'PressRelease', 'data_source_link': 'https://newsroom.roku.com/press-releases', 'data_source_publish_date': '2023-09-12T09:00:00-04:00', 'data_source_uid': '963d4a81-f58e-3093-af68-987fb1758c15', 'title': "ROKU INC |  Roku's New NFL Zone Gives Fans Easy Access to NFL Games Right On Time for 2023 Season"})]
```


### 체인에서의 사용법

```python
OPENAI_API_KEY = getpass()
```

```output
 ········
```


```python
os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY
```


```python
<!--IMPORTS:[{"imported": "ConversationalRetrievalChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.conversational_retrieval.base.ConversationalRetrievalChain.html", "title": "Kay.ai"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Kay.ai"}]-->
from langchain.chains import ConversationalRetrievalChain
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-3.5-turbo")
qa = ConversationalRetrievalChain.from_llm(model, retriever=retriever)
```


```python
questions = [
    "What were the biggest strategy changes and partnerships made by Roku in 2023?"
    # "Where is Wex making the most money in 2023?",
]
chat_history = []

for question in questions:
    result = qa({"question": question, "chat_history": chat_history})
    chat_history.append((question, result["answer"]))
    print(f"-> **Question**: {question} \n")
    print(f"**Answer**: {result['answer']} \n")
```

```output
-> **Question**: What were the biggest strategy changes and partnerships made by Roku in 2023? 

**Answer**: In 2023, Roku made a strategic partnership with FreeWheel to bring Roku's leading ad tech to FreeWheel customers. This partnership aimed to drive greater interoperability and automation in the advertising-based video on demand (AVOD) space. Key highlights of this collaboration include streamlined integration of Roku's demand application programming interface (dAPI) with FreeWheel's TV platform, allowing for better inventory quality control and improved publisher yield and revenue. Additionally, publishers can now use Roku platform signals to enable advertisers to target audiences and measure campaign performance without relying on cookies. This partnership also involves the use of data clean room technology to enable the activation of additional data sets for better measurement and monetization for publishers and agencies. These partnerships and strategies aim to support Roku's growth in the AVOD market.
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
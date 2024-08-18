---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/tavily.ipynb
description: Tavily의 검색 API는 AI 에이전트를 위해 설계된 검색 엔진으로, 실시간으로 정확하고 사실적인 결과를 빠르게 제공합니다.
sidebar_label: TavilySearchAPI
---

# TavilySearchAPIRetriever

> [Tavily의 검색 API](https://tavily.com)는 AI 에이전트(LLMs)를 위해 특별히 구축된 검색 엔진으로, 실시간으로 정확하고 사실적인 결과를 빠르게 제공합니다.

우리는 이를 [retriever](/docs/how_to#retrievers)로 사용할 수 있습니다. 이 통합에 특정한 기능을 보여줄 것입니다. 살펴본 후, 이 벡터 저장소를 더 큰 체인의 일부로 사용하는 방법을 배우기 위해 [관련 사용 사례 페이지](/docs/how_to#qa-with-rag)를 탐색하는 것이 유용할 수 있습니다.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="external_retrievers" item="TavilySearchAPIRetriever" />


## 설정

개별 쿼리에서 자동 추적을 받으려면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

통합은 `langchain-community` 패키지에 있습니다. 우리는 또한 `tavily-python` 패키지 자체를 설치해야 합니다.

```python
%pip install -qU langchain-community tavily-python
```


우리는 또한 Tavily API 키를 설정해야 합니다.

```python
import getpass
import os

os.environ["TAVILY_API_KEY"] = getpass.getpass()
```


## 인스턴스화

이제 우리의 retriever를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "TavilySearchAPIRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.tavily_search_api.TavilySearchAPIRetriever.html", "title": "TavilySearchAPIRetriever"}]-->
from langchain_community.retrievers import TavilySearchAPIRetriever

retriever = TavilySearchAPIRetriever(k=3)
```


## 사용법

```python
query = "what year was breath of the wild released?"

retriever.invoke(query)
```


```output
[Document(metadata={'title': 'The Legend of Zelda: Breath of the Wild - Nintendo Switch Wiki', 'source': 'https://nintendo-switch.fandom.com/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild', 'score': 0.9961155, 'images': []}, page_content='The Legend of Zelda: Breath of the Wild is an open world action-adventure game published by Nintendo for the Wii U and as a launch title for the Nintendo Switch, and was released worldwide on March 3, 2017. It is the nineteenth installment of the The Legend of Zelda series and the first to be developed with a HD resolution. The game features a gigantic open world, with the player being able to ...'),
 Document(metadata={'title': 'The Legend of Zelda: Breath of the Wild - Zelda Wiki', 'source': 'https://zelda.fandom.com/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild', 'score': 0.9804313, 'images': []}, page_content='[]\nReferences\nThe Legend of Zelda \xa0·\nThe Adventure of Link \xa0·\nA Link to the Past (& Four Swords) \xa0·\nLink\'s Awakening (DX; Nintendo Switch) \xa0·\nOcarina of Time (Master Quest; 3D) \xa0·\nMajora\'s Mask (3D) \xa0·\nOracle of Ages \xa0·\nOracle of Seasons \xa0·\nFour Swords (Anniversary Edition) \xa0·\nThe Wind Waker (HD) \xa0·\nFour Swords Adventures \xa0·\nThe Minish Cap \xa0·\nTwilight Princess (HD) \xa0·\nPhantom Hourglass \xa0·\nSpirit Tracks \xa0·\nSkyward Sword (HD) \xa0·\nA Link Between Worlds \xa0·\nTri Force Heroes \xa0·\nBreath of the Wild \xa0·\nTears of the Kingdom\nZelda (Game & Watch) \xa0·\nThe Legend of Zelda Game Watch \xa0·\nLink\'s Crossbow Training \xa0·\nMy Nintendo Picross: Twilight Princess \xa0·\nCadence of Hyrule \xa0·\nGame & Watch: The Legend of Zelda\nCD-i Games\n Listings[]\nCharacters[]\nBosses[]\nEnemies[]\nDungeons[]\nLocations[]\nItems[]\nTranslations[]\nCredits[]\nReception[]\nSales[]\nEiji Aonuma and Hidemaro Fujibayashi accepting the "Game of the Year" award for Breath of the Wild at The Game Awards 2017\nBreath of the Wild was estimated to have sold approximately 1.3 million copies in its first three weeks and around 89% of Switch owners were estimated to have also purchased the game.[52] Sales of the game have remained strong and as of June 30, 2022, the Switch version has sold 27.14 million copies worldwide while the Wii U version has sold 1.69 million copies worldwide as of December 31, 2019,[53][54] giving Breath of the Wild a cumulative total of 28.83 million copies sold.\n It also earned a Metacritic score of 97 from more than 100 critics, placing it among the highest-rated games of all time.[59][60] Notably, the game received the most perfect review scores for any game listed on Metacritic up to that point.[61]\nIn 2022, Breath of the Wild was chosen as the best Legend of Zelda game of all time in their "Top 10 Best Zelda Games" list countdown; but was then placed as the "second" best Zelda game in their new revamped version of their "Top 10 Best Zelda Games" list in 2023, right behind it\'s successor Tears of Video Game Canon ranks Breath of the Wild as one of the best video games of all time.[74] Metacritic ranked Breath of the Wild as the single best game of the 2010s.[75]\nFan Reception[]\nWatchMojo placed Breath of the Wild at the #2 spot in their "Top 10 Legend of Zelda Games of All Time" list countdown, right behind Ocarina of Time.[76] The Faces of Evil \xa0·\nThe Wand of Gamelon \xa0·\nZelda\'s Adventure\nHyrule Warriors Series\nHyrule Warriors (Legends; Definitive Edition) \xa0·\nHyrule Warriors: Age of Calamity\nSatellaview Games\nBS The Legend of Zelda \xa0·\nAncient Stone Tablets\nTingle Series\nFreshly-Picked Tingle\'s Rosy Rupeeland \xa0·\nTingle\'s Balloon Fight DS \xa0·\n'),
 Document(metadata={'title': 'The Legend of Zelda: Breath of the Wild - Zelda Wiki', 'source': 'https://zeldawiki.wiki/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild', 'score': 0.9627432, 'images': []}, page_content='The Legend of Zelda\xa0•\nThe Adventure of Link\xa0•\nA Link to the Past (& Four Swords)\xa0•\nLink\'s Awakening (DX; Nintendo Switch)\xa0•\nOcarina of Time (Master Quest; 3D)\xa0•\nMajora\'s Mask (3D)\xa0•\nOracle of Ages\xa0•\nOracle of Seasons\xa0•\nFour Swords (Anniversary Edition)\xa0•\nThe Wind Waker (HD)\xa0•\nFour Swords Adventures\xa0•\nThe Minish Cap\xa0•\nTwilight Princess (HD)\xa0•\nPhantom Hourglass\xa0•\nSpirit Tracks\xa0•\nSkyward Sword (HD)\xa0•\nA Link Between Worlds\xa0•\nTri Force Heroes\xa0•\nBreath of the Wild\xa0•\nTears of the Kingdom\nZelda (Game & Watch)\xa0•\nThe Legend of Zelda Game Watch\xa0•\nHeroes of Hyrule\xa0•\nLink\'s Crossbow Training\xa0•\nMy Nintendo Picross: Twilight Princess\xa0•\nCadence of Hyrule\xa0•\nVermin\nThe Faces of Evil\xa0•\nThe Wand of Gamelon\xa0•\nZelda\'s Adventure\nHyrule Warriors (Legends; Definitive Edition)\xa0•\nHyrule Warriors: Age of Calamity\nBS The Legend of Zelda\xa0•\nAncient Stone Tablets\nFreshly-Picked Tingle\'s Rosy Rupeeland\xa0•\nTingle\'s Balloon Fight DS\xa0•\nToo Much Tingle Pack\xa0•\nRipened Tingle\'s Balloon Trip of Love\nSoulcalibur II\xa0•\nWarioWare Series\xa0•\nCaptain Rainbow\xa0•\nNintendo Land\xa0•\nScribblenauts Unlimited\xa0•\nMario Kart 8\xa0•\nSplatoon 3\nSuper Smash Bros (Series)\nSuper Smash Bros.\xa0•\nSuper Smash Bros. Melee\xa0•\nSuper Smash Bros. Brawl\xa0•\nSuper Smash Bros. for Nintendo 3DS / Wii U\xa0•\n It also earned a Metacritic score of 97 from more than 100 critics, placing it among the highest-rated games of all time.[60][61] Notably, the game received the most perfect review scores for any game listed on Metacritic up to that point.[62]\nAwards\nThroughout 2016, Breath of the Wild won several awards as a highly anticipated game, including IGN\'s and Destructoid\'s Best of E3,[63][64] at the Game Critic Awards 2016,[65] and at The Game Awards 2016.[66] Following its release, Breath of the Wild received the title of "Game of the Year" from the Japan Game Awards 2017,[67] the Golden Joystick Awards 2017,<ref"Our final award is for the Ultimate Game of the Year. Official website(s)\nOfficial website(s)\nCanonicity\nCanonicity\nCanon[citation needed]\nPredecessor\nPredecessor\nTri Force Heroes\nSuccessor\nSuccessor\nTears of the Kingdom\nThe Legend of Zelda: Breath of the Wild guide at StrategyWiki\nBreath of the Wild Guide at Zelda Universe\nThe Legend of Zelda: Breath of the Wild is the nineteenth main installment of The Legend of Zelda series. Listings\nCharacters\nBosses\nEnemies\nDungeons\nLocations\nItems\nTranslations\nCredits\nReception\nSales\nBreath of the Wild was estimated to have sold approximately 1.3 million copies in its first three weeks and around 89% of Switch owners were estimated to have also purchased the game.[53] Sales of the game have remained strong and as of September 30, 2023, the Switch version has sold 31.15 million copies worldwide while the Wii U version has sold 1.7 million copies worldwide as of December 31, 2021,[54][55] giving Breath of the Wild a cumulative total of 32.85 million copies sold.\n The Legend of Zelda: Breath of the Wild\nThe Legend of Zelda: Breath of the Wild\nThe Legend of Zelda: Breath of the Wild\nDeveloper(s)\nDeveloper(s)\nPublisher(s)\nPublisher(s)\nNintendo\nDesigner(s)\nDesigner(s)\n')]
```


## 체인 내에서 사용

이 retriever를 체인에 쉽게 결합할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "TavilySearchAPIRetriever"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "TavilySearchAPIRetriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "TavilySearchAPIRetriever"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "TavilySearchAPIRetriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_template(
    """Answer the question based only on the context provided.

Context: {context}

Question: {question}"""
)

llm = ChatOpenAI(model="gpt-3.5-turbo-0125")


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```


```python
chain.invoke("how many units did bretch of the wild sell in 2020")
```


```output
'As of August 2020, The Legend of Zelda: Breath of the Wild had sold over 20.1 million copies worldwide on Nintendo Switch and Wii U.'
```


## API 참조

모든 `TavilySearchAPIRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.tavily_search_api.TavilySearchAPIRetriever.html)에서 확인할 수 있습니다.

## 관련

- Retriever [개념 가이드](/docs/concepts/#retrievers)
- Retriever [사용 방법 가이드](/docs/how_to/#retrievers)
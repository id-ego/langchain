---
canonical: https://python.langchain.com/v0.2/docs/integrations/retrievers/tavily/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/tavily.ipynb
sidebar_label: TavilySearchAPI
---

# TavilySearchAPIRetriever

> [Tavily's Search API](https://tavily.com) is a search engine built specifically for AI agents (LLMs), delivering real-time, accurate, and factual results at speed.

We can use this as a [retriever](/docs/how_to#retrievers). It will show functionality specific to this integration. After going through, it may be useful to explore [relevant use-case pages](/docs/how_to#qa-with-rag) to learn how to use this vectorstore as part of a larger chain.

### Integration details

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="external_retrievers" item="TavilySearchAPIRetriever" />


## Setup

If you want to get automated tracing from individual queries, you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

The integration lives in the `langchain-community` package. We also need to install the `tavily-python` package itself.

```python
%pip install -qU langchain-community tavily-python
```

We also need to set our Tavily API key.

```python
import getpass
import os

os.environ["TAVILY_API_KEY"] = getpass.getpass()
```

## Instantiation

Now we can instantiate our retriever:

```python
<!--IMPORTS:[{"imported": "TavilySearchAPIRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.tavily_search_api.TavilySearchAPIRetriever.html", "title": "TavilySearchAPIRetriever"}]-->
from langchain_community.retrievers import TavilySearchAPIRetriever

retriever = TavilySearchAPIRetriever(k=3)
```

## Usage

```python
query = "what year was breath of the wild released?"

retriever.invoke(query)
```

```output
[Document(metadata={'title': 'The Legend of Zelda: Breath of the Wild - Nintendo Switch Wiki', 'source': 'https://nintendo-switch.fandom.com/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild', 'score': 0.9961155, 'images': []}, page_content='The Legend of Zelda: Breath of the Wild is an open world action-adventure game published by Nintendo for the Wii U and as a launch title for the Nintendo Switch, and was released worldwide on March 3, 2017. It is the nineteenth installment of the The Legend of Zelda series and the first to be developed with a HD resolution. The game features a gigantic open world, with the player being able to ...'),
 Document(metadata={'title': 'The Legend of Zelda: Breath of the Wild - Zelda Wiki', 'source': 'https://zelda.fandom.com/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild', 'score': 0.9804313, 'images': []}, page_content='[]\nReferences\nThe Legend of Zelda \xa0·\nThe Adventure of Link \xa0·\nA Link to the Past (& Four Swords) \xa0·\nLink\'s Awakening (DX; Nintendo Switch) \xa0·\nOcarina of Time (Master Quest; 3D) \xa0·\nMajora\'s Mask (3D) \xa0·\nOracle of Ages \xa0·\nOracle of Seasons \xa0·\nFour Swords (Anniversary Edition) \xa0·\nThe Wind Waker (HD) \xa0·\nFour Swords Adventures \xa0·\nThe Minish Cap \xa0·\nTwilight Princess (HD) \xa0·\nPhantom Hourglass \xa0·\nSpirit Tracks \xa0·\nSkyward Sword (HD) \xa0·\nA Link Between Worlds \xa0·\nTri Force Heroes \xa0·\nBreath of the Wild \xa0·\nTears of the Kingdom\nZelda (Game & Watch) \xa0·\nThe Legend of Zelda Game Watch \xa0·\nLink\'s Crossbow Training \xa0·\nMy Nintendo Picross: Twilight Princess \xa0·\nCadence of Hyrule \xa0·\nGame & Watch: The Legend of Zelda\nCD-i Games\n Listings[]\nCharacters[]\nBosses[]\nEnemies[]\nDungeons[]\nLocations[]\nItems[]\nTranslations[]\nCredits[]\nReception[]\nSales[]\nEiji Aonuma and Hidemaro Fujibayashi accepting the "Game of the Year" award for Breath of the Wild at The Game Awards 2017\nBreath of the Wild was estimated to have sold approximately 1.3 million copies in its first three weeks and around 89% of Switch owners were estimated to have also purchased the game.[52] Sales of the game have remained strong and as of June 30, 2022, the Switch version has sold 27.14 million copies worldwide while the Wii U version has sold 1.69 million copies worldwide as of December 31, 2019,[53][54] giving Breath of the Wild a cumulative total of 28.83 million copies sold.\n It also earned a Metacritic score of 97 from more than 100 critics, placing it among the highest-rated games of all time.[59][60] Notably, the game received the most perfect review scores for any game listed on Metacritic up to that point.[61]\nIn 2022, Breath of the Wild was chosen as the best Legend of Zelda game of all time in their "Top 10 Best Zelda Games" list countdown; but was then placed as the "second" best Zelda game in their new revamped version of their "Top 10 Best Zelda Games" list in 2023, right behind it\'s successor Tears of Video Game Canon ranks Breath of the Wild as one of the best video games of all time.[74] Metacritic ranked Breath of the Wild as the single best game of the 2010s.[75]\nFan Reception[]\nWatchMojo placed Breath of the Wild at the #2 spot in their "Top 10 Legend of Zelda Games of All Time" list countdown, right behind Ocarina of Time.[76] The Faces of Evil \xa0·\nThe Wand of Gamelon \xa0·\nZelda\'s Adventure\nHyrule Warriors Series\nHyrule Warriors (Legends; Definitive Edition) \xa0·\nHyrule Warriors: Age of Calamity\nSatellaview Games\nBS The Legend of Zelda \xa0·\nAncient Stone Tablets\nTingle Series\nFreshly-Picked Tingle\'s Rosy Rupeeland \xa0·\nTingle\'s Balloon Fight DS \xa0·\n'),
 Document(metadata={'title': 'The Legend of Zelda: Breath of the Wild - Zelda Wiki', 'source': 'https://zeldawiki.wiki/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild', 'score': 0.9627432, 'images': []}, page_content='The Legend of Zelda\xa0•\nThe Adventure of Link\xa0•\nA Link to the Past (& Four Swords)\xa0•\nLink\'s Awakening (DX; Nintendo Switch)\xa0•\nOcarina of Time (Master Quest; 3D)\xa0•\nMajora\'s Mask (3D)\xa0•\nOracle of Ages\xa0•\nOracle of Seasons\xa0•\nFour Swords (Anniversary Edition)\xa0•\nThe Wind Waker (HD)\xa0•\nFour Swords Adventures\xa0•\nThe Minish Cap\xa0•\nTwilight Princess (HD)\xa0•\nPhantom Hourglass\xa0•\nSpirit Tracks\xa0•\nSkyward Sword (HD)\xa0•\nA Link Between Worlds\xa0•\nTri Force Heroes\xa0•\nBreath of the Wild\xa0•\nTears of the Kingdom\nZelda (Game & Watch)\xa0•\nThe Legend of Zelda Game Watch\xa0•\nHeroes of Hyrule\xa0•\nLink\'s Crossbow Training\xa0•\nMy Nintendo Picross: Twilight Princess\xa0•\nCadence of Hyrule\xa0•\nVermin\nThe Faces of Evil\xa0•\nThe Wand of Gamelon\xa0•\nZelda\'s Adventure\nHyrule Warriors (Legends; Definitive Edition)\xa0•\nHyrule Warriors: Age of Calamity\nBS The Legend of Zelda\xa0•\nAncient Stone Tablets\nFreshly-Picked Tingle\'s Rosy Rupeeland\xa0•\nTingle\'s Balloon Fight DS\xa0•\nToo Much Tingle Pack\xa0•\nRipened Tingle\'s Balloon Trip of Love\nSoulcalibur II\xa0•\nWarioWare Series\xa0•\nCaptain Rainbow\xa0•\nNintendo Land\xa0•\nScribblenauts Unlimited\xa0•\nMario Kart 8\xa0•\nSplatoon 3\nSuper Smash Bros (Series)\nSuper Smash Bros.\xa0•\nSuper Smash Bros. Melee\xa0•\nSuper Smash Bros. Brawl\xa0•\nSuper Smash Bros. for Nintendo 3DS / Wii U\xa0•\n It also earned a Metacritic score of 97 from more than 100 critics, placing it among the highest-rated games of all time.[60][61] Notably, the game received the most perfect review scores for any game listed on Metacritic up to that point.[62]\nAwards\nThroughout 2016, Breath of the Wild won several awards as a highly anticipated game, including IGN\'s and Destructoid\'s Best of E3,[63][64] at the Game Critic Awards 2016,[65] and at The Game Awards 2016.[66] Following its release, Breath of the Wild received the title of "Game of the Year" from the Japan Game Awards 2017,[67] the Golden Joystick Awards 2017,<ref"Our final award is for the Ultimate Game of the Year. Official website(s)\nOfficial website(s)\nCanonicity\nCanonicity\nCanon[citation needed]\nPredecessor\nPredecessor\nTri Force Heroes\nSuccessor\nSuccessor\nTears of the Kingdom\nThe Legend of Zelda: Breath of the Wild guide at StrategyWiki\nBreath of the Wild Guide at Zelda Universe\nThe Legend of Zelda: Breath of the Wild is the nineteenth main installment of The Legend of Zelda series. Listings\nCharacters\nBosses\nEnemies\nDungeons\nLocations\nItems\nTranslations\nCredits\nReception\nSales\nBreath of the Wild was estimated to have sold approximately 1.3 million copies in its first three weeks and around 89% of Switch owners were estimated to have also purchased the game.[53] Sales of the game have remained strong and as of September 30, 2023, the Switch version has sold 31.15 million copies worldwide while the Wii U version has sold 1.7 million copies worldwide as of December 31, 2021,[54][55] giving Breath of the Wild a cumulative total of 32.85 million copies sold.\n The Legend of Zelda: Breath of the Wild\nThe Legend of Zelda: Breath of the Wild\nThe Legend of Zelda: Breath of the Wild\nDeveloper(s)\nDeveloper(s)\nPublisher(s)\nPublisher(s)\nNintendo\nDesigner(s)\nDesigner(s)\n')]
```

## Use within a chain

We can easily combine this retriever in to a chain.

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

## API reference

For detailed documentation of all `TavilySearchAPIRetriever` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.tavily_search_api.TavilySearchAPIRetriever.html).

## Related

- Retriever [conceptual guide](/docs/concepts/#retrievers)
- Retriever [how-to guides](/docs/how_to/#retrievers)
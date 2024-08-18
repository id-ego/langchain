---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_transformers/dashscope_rerank.ipynb
description: DashScope Reranker를 사용하여 문서 압축 및 검색 방법을 보여주는 노트북입니다. 다양한 언어를 지원하는 AI
  서비스입니다.
---

# DashScope Reranker

이 노트북은 문서 압축 및 검색을 위한 DashScope Reranker 사용 방법을 보여줍니다. [DashScope](https://dashscope.aliyun.com/)는 Alibaba Cloud (Aliyun)의 생성 AI 서비스입니다.

DashScope의 [Text ReRank Model](https://help.aliyun.com/document_detail/2780058.html?spm=a2c4g.2780059.0.0.6d995024FlrJ12)은 최대 4000 토큰으로 문서의 재순위를 지원합니다. 또한, 중국어, 영어, 일본어, 한국어, 태국어, 스페인어, 프랑스어, 포르투갈어, 인도네시아어, 아랍어 및 50개 이상의 언어를 지원합니다. 자세한 내용은 [여기](https://help.aliyun.com/document_detail/2780059.html?spm=a2c4g.2780058.0.0.3a9e5b1dWeOQjI)에서 확인하세요.

```python
%pip install --upgrade --quiet  dashscope
```


```python
%pip install --upgrade --quiet  faiss

# OR  (depending on Python version)

%pip install --upgrade --quiet  faiss-cpu
```


```python
# To create api key: https://bailian.console.aliyun.com/?apiKey=1#/api-key

import getpass
import os

os.environ["DASHSCOPE_API_KEY"] = getpass.getpass("DashScope API Key:")
```


```python
# Helper function for printing docs
def pretty_print_docs(docs):
    print(
        f"\n{'-' * 100}\n".join(
            [f"Document {i+1}:\n\n" + d.page_content for i, d in enumerate(docs)]
        )
    )
```


## 기본 벡터 저장소 검색기 설정
2023년 국정 연설을 (청크로) 저장하여 간단한 벡터 저장소 검색기를 초기화하는 것부터 시작하겠습니다. 검색기를 설정하여 많은 수(20)의 문서를 검색할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DashScope Reranker"}, {"imported": "DashScopeEmbeddings", "source": "langchain_community.embeddings.dashscope", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.dashscope.DashScopeEmbeddings.html", "title": "DashScope Reranker"}, {"imported": "FAISS", "source": "langchain_community.vectorstores.faiss", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "DashScope Reranker"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "DashScope Reranker"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.dashscope import DashScopeEmbeddings
from langchain_community.vectorstores.faiss import FAISS
from langchain_text_splitters import RecursiveCharacterTextSplitter

documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=100)
texts = text_splitter.split_documents(documents)
retriever = FAISS.from_documents(texts, DashScopeEmbeddings()).as_retriever(  # type: ignore
    search_kwargs={"k": 20}
)

query = "What did the president say about Ketanji Brown Jackson"
docs = retriever.invoke(query)
pretty_print_docs(docs)
```

```output
Document 1:

I understand. 

I remember when my Dad had to leave our home in Scranton, Pennsylvania to find work. I grew up in a family where if the price of food went up, you felt it. 

That’s why one of the first things I did as President was fight to pass the American Rescue Plan.  

Because people were hurting. We needed to act, and we did. 

Few pieces of legislation have done more in a critical moment in our history to lift us out of crisis.
----------------------------------------------------------------------------------------------------
Document 2:

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
----------------------------------------------------------------------------------------------------
Document 3:

To all Americans, I will be honest with you, as I’ve always promised. A Russian dictator, invading a foreign country, has costs around the world. 

And I’m taking robust action to make sure the pain of our sanctions  is targeted at Russia’s economy. And I will use every tool at our disposal to protect American businesses and consumers. 

Tonight, I can announce that the United States has worked with 30 other countries to release 60 Million barrels of oil from reserves around the world.
----------------------------------------------------------------------------------------------------
Document 4:

We cannot let this happen. 

Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service.
----------------------------------------------------------------------------------------------------
Document 5:

Tonight I say to the Russian oligarchs and corrupt leaders who have bilked billions of dollars off this violent regime no more. 

The U.S. Department of Justice is assembling a dedicated task force to go after the crimes of Russian oligarchs.  

We are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains.
----------------------------------------------------------------------------------------------------
Document 6:

Every Administration says they’ll do it, but we are actually doing it. 

We will buy American to make sure everything from the deck of an aircraft carrier to the steel on highway guardrails are made in America. 

But to compete for the best jobs of the future, we also need to level the playing field with China and other competitors.
----------------------------------------------------------------------------------------------------
Document 7:

When we invest in our workers, when we build the economy from the bottom up and the middle out together, we can do something we haven’t done in a long time: build a better America. 

For more than two years, COVID-19 has impacted every decision in our lives and the life of the nation. 

And I know you’re tired, frustrated, and exhausted. 

But I also know this.
----------------------------------------------------------------------------------------------------
Document 8:

A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system.
----------------------------------------------------------------------------------------------------
Document 9:

My plan will not only lower costs to give families a fair shot, it will lower the deficit. 

The previous Administration not only ballooned the deficit with tax cuts for the very wealthy and corporations, it undermined the watchdogs whose job was to keep pandemic relief funds from being wasted. 

But in my administration, the watchdogs have been welcomed back. 

We’re going after the criminals who stole billions in relief money meant for small businesses and millions of Americans.
----------------------------------------------------------------------------------------------------
Document 10:

He will never extinguish their love of freedom. He will never weaken the resolve of the free world. 

We meet tonight in an America that has lived through two of the hardest years this nation has ever faced. 

The pandemic has been punishing. 

And so many families are living paycheck to paycheck, struggling to keep up with the rising cost of food, gas, housing, and so much more. 

I understand.
----------------------------------------------------------------------------------------------------
Document 11:

And tonight, I’m announcing that the Justice Department will name a chief prosecutor for pandemic fraud. 

By the end of this year, the deficit will be down to less than half what it was before I took office.  

The only president ever to cut the deficit by more than one trillion dollars in a single year. 

Lowering your costs also means demanding more competition. 

I’m a capitalist, but capitalism without competition isn’t capitalism. 

It’s exploitation—and it drives up prices.
----------------------------------------------------------------------------------------------------
Document 12:

Let each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. 

Please rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. 

Throughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos.   

They keep moving.   

And the costs and the threats to America and the world keep rising.
----------------------------------------------------------------------------------------------------
Document 13:

Cancer is the #2 cause of death in America–second only to heart disease. 

Last month, I announced our plan to supercharge  
the Cancer Moonshot that President Obama asked me to lead six years ago. 

Our goal is to cut the cancer death rate by at least 50% over the next 25 years, turn more cancers from death sentences into treatable diseases.  

More support for patients and families. 

To get there, I call on Congress to fund ARPA-H, the Advanced Research Projects Agency for Health.
----------------------------------------------------------------------------------------------------
Document 14:

It fueled our efforts to vaccinate the nation and combat COVID-19. It delivered immediate economic relief for tens of millions of Americans.  

Helped put food on their table, keep a roof over their heads, and cut the cost of health insurance. 

And as my Dad used to say, it gave people a little breathing room.
----------------------------------------------------------------------------------------------------
Document 15:

America will lead that effort, releasing 30 Million barrels from our own Strategic Petroleum Reserve. And we stand ready to do more if necessary, unified with our allies.  

These steps will help blunt gas prices here at home. And I know the news about what’s happening can seem alarming. 

But I want you to know that we are going to be okay. 

When the history of this era is written Putin’s war on Ukraine will have left Russia weaker and the rest of the world stronger.
----------------------------------------------------------------------------------------------------
Document 16:

So that’s my plan. It will grow the economy and lower costs for families. 

So what are we waiting for? Let’s get this done. And while you’re at it, confirm my nominees to the Federal Reserve, which plays a critical role in fighting inflation.  

My plan will not only lower costs to give families a fair shot, it will lower the deficit.
----------------------------------------------------------------------------------------------------
Document 17:

And we will, as one people. 

One America. 

The United States of America. 

May God bless you all. May God protect our troops.
----------------------------------------------------------------------------------------------------
Document 18:

As I’ve told Xi Jinping, it is never a good bet to bet against the American people. 

We’ll create good jobs for millions of Americans, modernizing roads, airports, ports, and waterways all across America. 

And we’ll do it all to withstand the devastating effects of the climate crisis and promote environmental justice.
----------------------------------------------------------------------------------------------------
Document 19:

And I know you’re tired, frustrated, and exhausted. 

But I also know this. 

Because of the progress we’ve made, because of your resilience and the tools we have, tonight I can say  
we are moving forward safely, back to more normal routines.  

We’ve reached a new moment in the fight against COVID-19, with severe cases down to a level not seen since last July.  

Just a few days ago, the Centers for Disease Control and Prevention—the CDC—issued new mask guidelines.
----------------------------------------------------------------------------------------------------
Document 20:

Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  

Last year COVID-19 kept us apart. This year we are finally together again. 

Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. 

With a duty to one another to the American people to the Constitution. 

And with an unwavering resolve that freedom will always triumph over tyranny.
```

## DashScopeRerank로 재순위 지정
이제 기본 검색기를 `ContextualCompressionRetriever`로 감싸겠습니다. 반환된 결과의 재순위를 지정하기 위해 `DashScopeRerank`를 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "DashScope Reranker"}, {"imported": "DashScopeRerank", "source": "langchain_community.document_compressors.dashscope_rerank", "docs": "https://api.python.langchain.com/en/latest/document_compressors/langchain_community.document_compressors.dashscope_rerank.DashScopeRerank.html", "title": "DashScope Reranker"}]-->
from langchain.retrievers import ContextualCompressionRetriever
from langchain_community.document_compressors.dashscope_rerank import DashScopeRerank

compressor = DashScopeRerank()
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What did the president say about Ketanji Jackson Brown"
)
pretty_print_docs(compressed_docs)
```

```output
Document 1:

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
----------------------------------------------------------------------------------------------------
Document 2:

Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  

Last year COVID-19 kept us apart. This year we are finally together again. 

Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. 

With a duty to one another to the American people to the Constitution. 

And with an unwavering resolve that freedom will always triumph over tyranny.
----------------------------------------------------------------------------------------------------
Document 3:

Tonight I say to the Russian oligarchs and corrupt leaders who have bilked billions of dollars off this violent regime no more. 

The U.S. Department of Justice is assembling a dedicated task force to go after the crimes of Russian oligarchs.  

We are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains.
```
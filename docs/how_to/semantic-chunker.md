---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/semantic-chunker.ipynb
description: 텍스트를 의미적 유사성에 따라 분할하는 방법을 다룹니다. 임베딩 간 거리에 따라 문장을 그룹화하고 병합합니다.
---

# 텍스트를 의미적 유사성에 따라 분할하는 방법

그렉 카므라트의 멋진 노트북에서 가져왔습니다:
[5_Levels_Of_Text_Splitting](https://github.com/FullStackRetrieval-com/RetrievalTutorials/blob/main/tutorials/LevelsOfTextSplitting/5_Levels_Of_Text_Splitting.ipynb)

모든 공로는 그에게 있습니다.

이 가이드는 의미적 유사성에 따라 청크를 분할하는 방법을 다룹니다. 임베딩이 충분히 멀리 떨어져 있으면 청크가 분할됩니다.

높은 수준에서, 이는 문장으로 분할한 다음 3개의 문장 그룹으로 그룹화하고, 임베딩 공간에서 유사한 것을 병합합니다.

## 종속성 설치

```python
!pip install --quiet langchain_experimental langchain_openai
```


## 예제 데이터 로드

```python
# This is a long document we can split up.
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
```


## 텍스트 분할기 생성

[SemanticChunker](https://api.python.langchain.com/en/latest/text_splitter/langchain_experimental.text_splitter.SemanticChunker.html)를 인스턴스화하려면 임베딩 모델을 지정해야 합니다. 아래에서는 [OpenAIEmbeddings](https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.openai.OpenAIEmbeddings.html)를 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "SemanticChunker", "source": "langchain_experimental.text_splitter", "docs": "https://api.python.langchain.com/en/latest/text_splitter/langchain_experimental.text_splitter.SemanticChunker.html", "title": "How to split text based on semantic similarity"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to split text based on semantic similarity"}]-->
from langchain_experimental.text_splitter import SemanticChunker
from langchain_openai.embeddings import OpenAIEmbeddings

text_splitter = SemanticChunker(OpenAIEmbeddings())
```


## 텍스트 분할

우리는 일반적인 방법으로 텍스트를 분할합니다. 예를 들어, `.create_documents`를 호출하여 LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체를 생성합니다:

```python
docs = text_splitter.create_documents([state_of_the_union])
print(docs[0].page_content)
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans. Last year COVID-19 kept us apart. This year we are finally together again. Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. With a duty to one another to the American people to the Constitution. And with an unwavering resolve that freedom will always triumph over tyranny. Six days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. He thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. He met the Ukrainian people. From President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world. Groups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. In this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. Let each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. Please rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. Throughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos. They keep moving.
```


## 중단점

이 청커는 문장을 "분리"할 시점을 결정하여 작동합니다. 이는 두 문장 간의 임베딩 차이를 살펴보는 방식으로 이루어집니다. 그 차이가 특정 임계값을 초과하면 분할됩니다.

임계값을 결정하는 몇 가지 방법이 있으며, 이는 `breakpoint_threshold_type` kwarg에 의해 제어됩니다.

### 백분위수

기본적으로 분할하는 방법은 백분위수를 기반으로 합니다. 이 방법에서는 문장 간의 모든 차이를 계산한 다음, X 백분위수보다 큰 차이를 분할합니다.

```python
text_splitter = SemanticChunker(
    OpenAIEmbeddings(), breakpoint_threshold_type="percentile"
)
```


```python
docs = text_splitter.create_documents([state_of_the_union])
print(docs[0].page_content)
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans. Last year COVID-19 kept us apart. This year we are finally together again. Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. With a duty to one another to the American people to the Constitution. And with an unwavering resolve that freedom will always triumph over tyranny. Six days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. He thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. He met the Ukrainian people. From President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world. Groups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. In this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. Let each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. Please rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. Throughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos. They keep moving.
```


```python
print(len(docs))
```

```output
26
```


### 표준 편차

이 방법에서는 X 표준 편차보다 큰 차이를 분할합니다.

```python
text_splitter = SemanticChunker(
    OpenAIEmbeddings(), breakpoint_threshold_type="standard_deviation"
)
```


```python
docs = text_splitter.create_documents([state_of_the_union])
print(docs[0].page_content)
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans. Last year COVID-19 kept us apart. This year we are finally together again. Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. With a duty to one another to the American people to the Constitution. And with an unwavering resolve that freedom will always triumph over tyranny. Six days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. He thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. He met the Ukrainian people. From President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world. Groups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. In this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. Let each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. Please rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. Throughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos. They keep moving. And the costs and the threats to America and the world keep rising. That’s why the NATO Alliance was created to secure peace and stability in Europe after World War 2. The United States is a member along with 29 other nations. It matters. American diplomacy matters. American resolve matters. Putin’s latest attack on Ukraine was premeditated and unprovoked. He rejected repeated efforts at diplomacy. He thought the West and NATO wouldn’t respond. And he thought he could divide us at home. Putin was wrong. We were ready. Here is what we did. We prepared extensively and carefully. We spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin. I spent countless hours unifying our European allies. We shared with the world in advance what we knew Putin was planning and precisely how he would try to falsely justify his aggression. We countered Russia’s lies with truth. And now that he has acted the free world is holding him accountable. Along with twenty-seven members of the European Union including France, Germany, Italy, as well as countries like the United Kingdom, Canada, Japan, Korea, Australia, New Zealand, and many others, even Switzerland. We are inflicting pain on Russia and supporting the people of Ukraine. Putin is now isolated from the world more than ever. Together with our allies –we are right now enforcing powerful economic sanctions. We are cutting off Russia’s largest banks from the international financial system. Preventing Russia’s central bank from defending the Russian Ruble making Putin’s $630 Billion “war fund” worthless. We are choking off Russia’s access to technology that will sap its economic strength and weaken its military for years to come. Tonight I say to the Russian oligarchs and corrupt leaders who have bilked billions of dollars off this violent regime no more. The U.S. Department of Justice is assembling a dedicated task force to go after the crimes of Russian oligarchs. We are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains. And tonight I am announcing that we will join our allies in closing off American air space to all Russian flights – further isolating Russia – and adding an additional squeeze –on their economy. The Ruble has lost 30% of its value. The Russian stock market has lost 40% of its value and trading remains suspended. Russia’s economy is reeling and Putin alone is to blame. Together with our allies we are providing support to the Ukrainians in their fight for freedom. Military assistance. Economic assistance. Humanitarian assistance. We are giving more than $1 Billion in direct assistance to Ukraine. And we will continue to aid the Ukrainian people as they defend their country and to help ease their suffering. Let me be clear, our forces are not engaged and will not engage in conflict with Russian forces in Ukraine. Our forces are not going to Europe to fight in Ukraine, but to defend our NATO Allies – in the event that Putin decides to keep moving west. For that purpose we’ve mobilized American ground forces, air squadrons, and ship deployments to protect NATO countries including Poland, Romania, Latvia, Lithuania, and Estonia. As I have made crystal clear the United States and our Allies will defend every inch of territory of NATO countries with the full force of our collective power. And we remain clear-eyed. The Ukrainians are fighting back with pure courage. But the next few days weeks, months, will be hard on them. Putin has unleashed violence and chaos. But while he may make gains on the battlefield – he will pay a continuing high price over the long run. And a proud Ukrainian people, who have known 30 years  of independence, have repeatedly shown that they will not tolerate anyone who tries to take their country backwards. To all Americans, I will be honest with you, as I’ve always promised. A Russian dictator, invading a foreign country, has costs around the world. And I’m taking robust action to make sure the pain of our sanctions  is targeted at Russia’s economy. And I will use every tool at our disposal to protect American businesses and consumers. Tonight, I can announce that the United States has worked with 30 other countries to release 60 Million barrels of oil from reserves around the world. America will lead that effort, releasing 30 Million barrels from our own Strategic Petroleum Reserve. And we stand ready to do more if necessary, unified with our allies. These steps will help blunt gas prices here at home. And I know the news about what’s happening can seem alarming.
```


```python
print(len(docs))
```

```output
4
```


### 사분위수

이 방법에서는 사분위수 거리를 사용하여 청크를 분할합니다.

```python
text_splitter = SemanticChunker(
    OpenAIEmbeddings(), breakpoint_threshold_type="interquartile"
)
```


```python
docs = text_splitter.create_documents([state_of_the_union])
print(docs[0].page_content)
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans. Last year COVID-19 kept us apart. This year we are finally together again. Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. With a duty to one another to the American people to the Constitution. And with an unwavering resolve that freedom will always triumph over tyranny. Six days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. He thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. He met the Ukrainian people. From President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world. Groups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. In this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. Let each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. Please rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. Throughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos. They keep moving.
```


```python
print(len(docs))
```

```output
25
```


### 기울기

이 방법에서는 거리의 기울기를 사용하여 청크를 분할하며, 백분위수 방법과 함께 사용됩니다. 이 방법은 청크가 서로 높은 상관관계를 가지거나 특정 도메인(예: 법률 또는 의료)에 특화되어 있을 때 유용합니다. 아이디어는 기울기 배열에서 이상 탐지를 적용하여 분포가 넓어지고 고도로 의미적 데이터에서 경계를 쉽게 식별할 수 있도록 하는 것입니다.

```python
text_splitter = SemanticChunker(
    OpenAIEmbeddings(), breakpoint_threshold_type="gradient"
)
```


```python
docs = text_splitter.create_documents([state_of_the_union])
print(docs[0].page_content)
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman.
```


```python
print(len(docs))
```

```output
26
```
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/weaviate.ipynb
description: 이 문서는 LangChain에서 Weaviate 벡터 저장소를 시작하는 방법과 `langchain-weaviate` 패키지
  사용법을 다룹니다.
sidebar_label: Weaviate
---

# Weaviate

이 노트북은 `langchain-weaviate` 패키지를 사용하여 LangChain에서 Weaviate 벡터 저장소를 시작하는 방법을 다룹니다.

> [Weaviate](https://weaviate.io/)는 오픈 소스 벡터 데이터베이스입니다. 이를 통해 좋아하는 ML 모델에서 데이터 객체와 벡터 임베딩을 저장하고 수십억 개의 데이터 객체로 원활하게 확장할 수 있습니다.

이 통합을 사용하려면 실행 중인 Weaviate 데이터베이스 인스턴스가 필요합니다.

## 최소 버전

이 모듈은 Weaviate `1.23.7` 이상이 필요합니다. 그러나 최신 버전의 Weaviate를 사용하는 것이 좋습니다.

## Weaviate에 연결하기

이 노트북에서는 `http://localhost:8080`에서 로컬 Weaviate 인스턴스가 실행되고 있으며 포트 50051이 [gRPC 트래픽](https://weaviate.io/blog/grpc-performance-improvements)을 위해 열려 있다고 가정합니다. 따라서 다음과 같이 Weaviate에 연결합니다:

```python
weaviate_client = weaviate.connect_to_local()
```


### 기타 배포 옵션

Weaviate는 [Weaviate Cloud Services (WCS)](https://console.weaviate.cloud), [Docker](https://weaviate.io/developers/weaviate/installation/docker-compose) 또는 [Kubernetes](https://weaviate.io/developers/weaviate/installation/kubernetes)와 같은 다양한 방법으로 [배포될 수 있습니다](https://weaviate.io/developers/weaviate/starter-guides/which-weaviate).

다른 방법으로 Weaviate 인스턴스가 배포된 경우, Weaviate에 연결하는 다양한 방법에 대해 [여기에서 더 읽어보세요](https://weaviate.io/developers/weaviate/client-libraries/python#instantiate-a-client). 다양한 [도움 함수](https://weaviate.io/developers/weaviate/client-libraries/python#python-client-v4-helper-functions)를 사용하거나 [사용자 정의 인스턴스를 생성](https://weaviate.io/developers/weaviate/client-libraries/python#python-client-v4-explicit-connection)할 수 있습니다.

> `v4` 클라이언트 API가 필요하며, 이는 `weaviate.WeaviateClient` 객체를 생성합니다.

### 인증

WCS에서 실행되는 일부 Weaviate 인스턴스는 API 키 및/또는 사용자 이름+비밀번호 인증과 같은 인증이 활성화되어 있습니다.

자세한 정보는 [클라이언트 인증 가이드](https://weaviate.io/developers/weaviate/client-libraries/python#authentication)와 [상세 인증 구성 페이지](https://weaviate.io/developers/weaviate/configuration/authentication)를 참조하세요.

## 설치

```python
# install package
# %pip install -Uqq langchain-weaviate
# %pip install openai tiktoken langchain
```


## 환경 설정

이 노트북은 `OpenAIEmbeddings`를 통해 OpenAI API를 사용합니다. OpenAI API 키를 얻고 이를 `OPENAI_API_KEY`라는 이름의 환경 변수로 내보내는 것을 권장합니다.

이 작업이 완료되면 OpenAI API 키가 자동으로 읽혀집니다. 환경 변수에 익숙하지 않은 경우 [여기](https://docs.python.org/3/library/os.html#os.environ) 또는 [이 가이드](https://www.twilio.com/en-us/blog/environment-variables-python)에서 더 읽어보세요.

# 사용법

## 유사성으로 객체 찾기

다음은 쿼리에 대한 유사성을 기반으로 객체를 찾는 방법의 예입니다. 데이터 가져오기에서 Weaviate 인스턴스 쿼리까지입니다.

### 1단계: 데이터 가져오기

먼저 긴 텍스트 파일의 내용을 로드하고 청크로 나누어 `Weaviate`에 추가할 데이터를 생성합니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Weaviate"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Weaviate"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Weaviate"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
loader = TextLoader("state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```

```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/langchain_core/_api/deprecation.py:117: LangChainDeprecationWarning: The class `langchain_community.embeddings.openai.OpenAIEmbeddings` was deprecated in langchain-community 0.1.0 and will be removed in 0.2.0. An updated version of the class exists in the langchain-openai package and should be used instead. To use it run `pip install -U langchain-openai` and import as `from langchain_openai import OpenAIEmbeddings`.
  warn_deprecated(
```

이제 데이터를 가져올 수 있습니다.

이를 위해 Weaviate 인스턴스에 연결하고 결과로 생성된 `weaviate_client` 객체를 사용합니다. 예를 들어, 아래와 같이 문서를 가져올 수 있습니다:

```python
import weaviate
from langchain_weaviate.vectorstores import WeaviateVectorStore
```


```python
weaviate_client = weaviate.connect_to_local()
db = WeaviateVectorStore.from_documents(docs, embeddings, client=weaviate_client)
```

```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
```

### 2단계: 검색 수행

이제 유사성 검색을 수행할 수 있습니다. 이는 Weaviate에 저장된 임베딩과 쿼리 텍스트에서 생성된 동등한 임베딩을 기반으로 쿼리 텍스트와 가장 유사한 문서를 반환합니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)

# Print the first 100 characters of each result
for i, doc in enumerate(docs):
    print(f"\nDocument {i+1}:")
    print(doc.page_content[:100] + "...")
```

```output

Document 1:
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Ac...

Document 2:
And so many families are living paycheck to paycheck, struggling to keep up with the rising cost of ...

Document 3:
Vice President Harris and I ran for office with a new economic vision for America. 

Invest in Ameri...

Document 4:
A former top litigator in private practice. A former federal public defender. And from a family of p...
```

필터를 추가할 수도 있으며, 이는 필터 조건에 따라 결과를 포함하거나 제외합니다. (자세한 [필터 예제](https://weaviate.io/developers/weaviate/search/filters)를 참조하세요.)

```python
from weaviate.classes.query import Filter

for filter_str in ["blah.txt", "state_of_the_union.txt"]:
    search_filter = Filter.by_property("source").equal(filter_str)
    filtered_search_results = db.similarity_search(query, filters=search_filter)
    print(len(filtered_search_results))
    if filter_str == "state_of_the_union.txt":
        assert len(filtered_search_results) > 0  # There should be at least one result
    else:
        assert len(filtered_search_results) == 0  # There should be no results
```

```output
0
4
```

`k`를 제공할 수도 있으며, 이는 반환할 결과 수의 상한선입니다.

```python
search_filter = Filter.by_property("source").equal("state_of_the_union.txt")
filtered_search_results = db.similarity_search(query, filters=search_filter, k=3)
assert len(filtered_search_results) <= 3
```


### 결과 유사성 정량화

선택적으로 관련성 "점수"를 검색할 수 있습니다. 이는 특정 검색 결과가 검색 결과 풀에서 얼마나 좋은지를 나타내는 상대 점수입니다.

이는 상대 점수이므로 관련성을 결정하기 위한 임계값을 설정하는 데 사용해서는 안 됩니다. 그러나 전체 검색 결과 집합 내에서 서로 다른 검색 결과의 관련성을 비교하는 데 사용할 수 있습니다.

```python
docs = db.similarity_search_with_score("country", k=5)

for doc in docs:
    print(f"{doc[1]:.3f}", ":", doc[0].page_content[:100] + "...")
```

```output
0.935 : For that purpose we’ve mobilized American ground forces, air squadrons, and ship deployments to prot...
0.500 : And built the strongest, freest, and most prosperous nation the world has ever known. 

Now is the h...
0.462 : If you travel 20 miles east of Columbus, Ohio, you’ll find 1,000 empty acres of land. 

It won’t loo...
0.450 : And my report is this: the State of the Union is strong—because you, the American people, are strong...
0.442 : Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Ac...
```

## 검색 메커니즘

`similarity_search`는 Weaviate의 [하이브리드 검색](https://weaviate.io/developers/weaviate/api/graphql/search-operators#hybrid)을 사용합니다.

하이브리드 검색은 벡터 검색과 키워드 검색을 결합하며, `alpha`는 벡터 검색의 가중치입니다. `similarity_search` 함수는 추가 인수를 kwargs로 전달할 수 있습니다. 사용 가능한 인수에 대한 [참조 문서](https://weaviate.io/developers/weaviate/api/graphql/search-operators#hybrid)를 참조하세요.

따라서 아래와 같이 `alpha=0`을 추가하여 순수 키워드 검색을 수행할 수 있습니다:

```python
docs = db.similarity_search(query, alpha=0)
docs[0]
```


```output
Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': 'state_of_the_union.txt'})
```


## 지속성

`langchain-weaviate`를 통해 추가된 모든 데이터는 Weaviate의 구성에 따라 지속됩니다.

예를 들어, WCS 인스턴스는 데이터를 무기한 지속하도록 구성되어 있으며, Docker 인스턴스는 볼륨에 데이터를 지속하도록 설정할 수 있습니다. [Weaviate의 지속성](https://weaviate.io/developers/weaviate/configuration/persistence)에 대해 더 읽어보세요.

## 다중 테넌시

[다중 테넌시](https://weaviate.io/developers/weaviate/concepts/data#multi-tenancy)는 단일 Weaviate 인스턴스에서 동일한 컬렉션 구성을 가진 고립된 데이터 컬렉션을 많이 가질 수 있게 해줍니다. 이는 각 최종 사용자가 자신의 고립된 데이터 컬렉션을 가질 수 있는 SaaS 앱 구축과 같은 다중 사용자 환경에 적합합니다.

다중 테넌시를 사용하려면 벡터 저장소가 `tenant` 매개변수를 인식해야 합니다.

따라서 데이터를 추가할 때 아래와 같이 `tenant` 매개변수를 제공하세요.

```python
db_with_mt = WeaviateVectorStore.from_documents(
    docs, embeddings, client=weaviate_client, tenant="Foo"
)
```

```output
2024-Mar-26 03:40 PM - langchain_weaviate.vectorstores - INFO - Tenant Foo does not exist in index LangChain_30b9273d43b3492db4fb2aba2e0d6871. Creating tenant.
```

쿼리를 수행할 때도 `tenant` 매개변수를 제공하세요.

```python
db_with_mt.similarity_search(query, tenant="Foo")
```


```output
[Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': 'state_of_the_union.txt'}),
 Document(page_content='And so many families are living paycheck to paycheck, struggling to keep up with the rising cost of food, gas, housing, and so much more. \n\nI understand. \n\nI remember when my Dad had to leave our home in Scranton, Pennsylvania to find work. I grew up in a family where if the price of food went up, you felt it. \n\nThat’s why one of the first things I did as President was fight to pass the American Rescue Plan.  \n\nBecause people were hurting. We needed to act, and we did. \n\nFew pieces of legislation have done more in a critical moment in our history to lift us out of crisis. \n\nIt fueled our efforts to vaccinate the nation and combat COVID-19. It delivered immediate economic relief for tens of millions of Americans.  \n\nHelped put food on their table, keep a roof over their heads, and cut the cost of health insurance. \n\nAnd as my Dad used to say, it gave people a little breathing room.', metadata={'source': 'state_of_the_union.txt'}),
 Document(page_content='He and his Dad both have Type 1 diabetes, which means they need insulin every day. Insulin costs about $10 a vial to make.  \n\nBut drug companies charge families like Joshua and his Dad up to 30 times more. I spoke with Joshua’s mom. \n\nImagine what it’s like to look at your child who needs insulin and have no idea how you’re going to pay for it.  \n\nWhat it does to your dignity, your ability to look your child in the eye, to be the parent you expect to be. \n\nJoshua is here with us tonight. Yesterday was his birthday. Happy birthday, buddy.  \n\nFor Joshua, and for the 200,000 other young people with Type 1 diabetes, let’s cap the cost of insulin at $35 a month so everyone can afford it.  \n\nDrug companies will still do very well. And while we’re at it let Medicare negotiate lower prices for prescription drugs, like the VA already does.', metadata={'source': 'state_of_the_union.txt'}),
 Document(page_content='Putin’s latest attack on Ukraine was premeditated and unprovoked. \n\nHe rejected repeated efforts at diplomacy. \n\nHe thought the West and NATO wouldn’t respond. And he thought he could divide us at home. Putin was wrong. We were ready.  Here is what we did.   \n\nWe prepared extensively and carefully. \n\nWe spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin. \n\nI spent countless hours unifying our European allies. We shared with the world in advance what we knew Putin was planning and precisely how he would try to falsely justify his aggression.  \n\nWe countered Russia’s lies with truth.   \n\nAnd now that he has acted the free world is holding him accountable. \n\nAlong with twenty-seven members of the European Union including France, Germany, Italy, as well as countries like the United Kingdom, Canada, Japan, Korea, Australia, New Zealand, and many others, even Switzerland.', metadata={'source': 'state_of_the_union.txt'})]
```


## 검색기 옵션

Weaviate는 검색기로도 사용할 수 있습니다.

### 최대 한계 관련성 검색 (MMR)

검색기 객체에서 similaritysearch를 사용하는 것 외에도 `mmr`을 사용할 수 있습니다.

```python
retriever = db.as_retriever(search_type="mmr")
retriever.invoke(query)[0]
```

```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
```


```output
Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': 'state_of_the_union.txt'})
```


# LangChain과 함께 사용하기

대형 언어 모델(LLM)의 알려진 한계 중 하나는 훈련 데이터가 오래되었거나 필요한 특정 도메인 지식을 포함하지 않을 수 있다는 것입니다.

아래 예제를 살펴보세요:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Weaviate"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
llm.predict("What did the president say about Justice Breyer")
```


```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/langchain_core/_api/deprecation.py:117: LangChainDeprecationWarning: The class `langchain_community.chat_models.openai.ChatOpenAI` was deprecated in langchain-community 0.0.10 and will be removed in 0.2.0. An updated version of the class exists in the langchain-openai package and should be used instead. To use it run `pip install -U langchain-openai` and import as `from langchain_openai import ChatOpenAI`.
  warn_deprecated(
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/langchain_core/_api/deprecation.py:117: LangChainDeprecationWarning: The function `predict` was deprecated in LangChain 0.1.7 and will be removed in 0.2.0. Use invoke instead.
  warn_deprecated(
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
```


```output
"I'm sorry, I cannot provide real-time information as my responses are generated based on a mixture of licensed data, data created by human trainers, and publicly available data. The last update was in October 2021."
```


벡터 저장소는 관련 정보를 저장하고 검색하는 방법을 제공하여 LLM을 보완합니다. 이를 통해 LLM의 추론 및 언어 능력과 벡터 저장소의 관련 정보 검색 능력을 결합할 수 있습니다.

LLM과 벡터 저장소를 결합한 두 가지 잘 알려진 응용 프로그램은 다음과 같습니다:
- 질문 응답
- 검색 보강 생성(RAG)

### 출처가 있는 질문 응답

LangChain에서 질문 응답은 벡터 저장소를 사용하여 향상될 수 있습니다. 이를 수행하는 방법을 살펴보겠습니다.

이 섹션에서는 문서를 인덱스에서 조회하는 `RetrievalQAWithSourcesChain`을 사용합니다.

먼저 텍스트를 다시 청크로 나누고 Weaviate 벡터 저장소에 가져옵니다.

```python
<!--IMPORTS:[{"imported": "RetrievalQAWithSourcesChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.qa_with_sources.retrieval.RetrievalQAWithSourcesChain.html", "title": "Weaviate"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Weaviate"}]-->
from langchain.chains import RetrievalQAWithSourcesChain
from langchain_openai import OpenAI
```


```python
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_text(state_of_the_union)
```


```python
docsearch = WeaviateVectorStore.from_texts(
    texts,
    embeddings,
    client=weaviate_client,
    metadatas=[{"source": f"{i}-pl"} for i in range(len(texts))],
)
```


이제 검색기를 지정하여 체인을 구성할 수 있습니다:

```python
chain = RetrievalQAWithSourcesChain.from_chain_type(
    OpenAI(temperature=0), chain_type="stuff", retriever=docsearch.as_retriever()
)
```

```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/langchain_core/_api/deprecation.py:117: LangChainDeprecationWarning: The class `langchain_community.llms.openai.OpenAI` was deprecated in langchain-community 0.0.10 and will be removed in 0.2.0. An updated version of the class exists in the langchain-openai package and should be used instead. To use it run `pip install -U langchain-openai` and import as `from langchain_openai import OpenAI`.
  warn_deprecated(
```

체인을 실행하여 질문을 합니다:

```python
chain(
    {"question": "What did the president say about Justice Breyer"},
    return_only_outputs=True,
)
```

```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/langchain_core/_api/deprecation.py:117: LangChainDeprecationWarning: The function `__call__` was deprecated in LangChain 0.1.0 and will be removed in 0.2.0. Use invoke instead.
  warn_deprecated(
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
```


```output
{'answer': ' The president thanked Justice Stephen Breyer for his service and announced his nomination of Judge Ketanji Brown Jackson to the Supreme Court.\n',
 'sources': '31-pl'}
```


### 검색 보강 생성

LLM과 벡터 저장소를 결합한 또 다른 매우 인기 있는 응용 프로그램은 검색 보강 생성(RAG)입니다. 이는 검색기를 사용하여 벡터 저장소에서 관련 정보를 찾고, 그런 다음 LLM을 사용하여 검색된 데이터와 프롬프트를 기반으로 출력을 제공하는 기술입니다.

유사한 설정으로 시작합니다:

```python
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_text(state_of_the_union)
```


```python
docsearch = WeaviateVectorStore.from_texts(
    texts,
    embeddings,
    client=weaviate_client,
    metadatas=[{"source": f"{i}-pl"} for i in range(len(texts))],
)

retriever = docsearch.as_retriever()
```


검색된 정보가 템플릿에 채워지도록 RAG 모델을 위한 템플릿을 구성해야 합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Weaviate"}]-->
from langchain_core.prompts import ChatPromptTemplate

template = """You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.
Question: {question}
Context: {context}
Answer:
"""
prompt = ChatPromptTemplate.from_template(template)

print(prompt)
```

```output
input_variables=['context', 'question'] messages=[HumanMessagePromptTemplate(prompt=PromptTemplate(input_variables=['context', 'question'], template="You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.\nQuestion: {question}\nContext: {context}\nAnswer:\n"))]
```


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Weaviate"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
```


셀을 실행하면 매우 유사한 출력을 얻습니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Weaviate"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Weaviate"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

rag_chain.invoke("What did the president say about Justice Breyer")
```

```output
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
/workspaces/langchain-weaviate/.venv/lib/python3.12/site-packages/pydantic/main.py:1024: PydanticDeprecatedSince20: The `dict` method is deprecated; use `model_dump` instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.6/migration/
  warnings.warn('The `dict` method is deprecated; use `model_dump` instead.', category=PydanticDeprecatedSince20)
```


```output
"The president honored Justice Stephen Breyer for his service to the country as an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. The president also mentioned nominating Circuit Court of Appeals Judge Ketanji Brown Jackson to continue Justice Breyer's legacy of excellence. The president expressed gratitude towards Justice Breyer and highlighted the importance of nominating someone to serve on the United States Supreme Court."
```


그러나 템플릿은 사용자에 따라 구성할 수 있으므로 필요에 맞게 사용자 정의할 수 있습니다.

### 마무리 및 리소스

Weaviate는 확장 가능하고 생산 준비가 된 벡터 저장소입니다.

이 통합을 통해 Weaviate를 LangChain과 함께 사용하여 대형 언어 모델의 기능을 강력한 데이터 저장소로 향상시킬 수 있습니다. 그 확장성과 생산 준비 상태는 LangChain 애플리케이션을 위한 벡터 저장소로서 훌륭한 선택이 되며, 생산 시간도 단축시킬 수 있습니다.

## 관련 자료

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
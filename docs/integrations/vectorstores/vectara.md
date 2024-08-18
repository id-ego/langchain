---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/vectara.ipynb
description: Vectara는 조직이 데이터에 기반한 AI 어시스턴트를 신속하게 생성할 수 있도록 지원하는 신뢰할 수 있는 생성 AI 플랫폼입니다.
---

# Vectara

[Vectara](https://vectara.com/)는 조직이 보유한 데이터, 문서 및 지식에 기반하여 ChatGPT와 유사한 경험(인공지능 비서)을 신속하게 생성할 수 있도록 하는 신뢰할 수 있는 생성 AI 플랫폼을 제공합니다(기술적으로는 Retrieval-Augmented-Generation-as-a-service입니다).

Vectara의 서버리스 RAG-as-a-service는 사용하기 쉬운 API 뒤에 RAG의 모든 구성 요소를 제공합니다. 여기에는 다음이 포함됩니다:
1. 파일(PDF, PPT, DOCX 등)에서 텍스트를 추출하는 방법
2. 최첨단 성능을 제공하는 ML 기반 청크화
3. [Boomerang](https://vectara.com/how-boomerang-takes-retrieval-augmented-generation-to-the-next-level-via-grounded-generation/) 임베딩 모델
4. 텍스트 청크와 임베딩 벡터가 저장되는 자체 내부 벡터 데이터베이스
5. 쿼리를 자동으로 임베딩으로 인코딩하고 가장 관련성 높은 텍스트 세그먼트를 검색하는 쿼리 서비스(여기에는 [Hybrid Search](https://docs.vectara.com/docs/api-reference/search-apis/lexical-matching) 및 [MMR](https://vectara.com/get-diverse-results-and-comprehensive-summaries-with-vectaras-mmr-reranker/) 지원 포함)
6. 검색된 문서(맥락)를 기반으로 [생성 요약](https://docs.vectara.com/docs/learn/grounded-generation/grounded-generation-overview)을 생성하는 LLM, 인용 포함

API 사용 방법에 대한 자세한 정보는 [Vectara API 문서](https://docs.vectara.com/docs/)를 참조하세요.

이 노트북은 Vectara를 벡터 저장소로 사용할 때 기본 검색 기능을 사용하는 방법을 보여줍니다(요약 없이), 여기에는 `similarity_search` 및 `similarity_search_with_score`와 LangChain의 `as_retriever` 기능 사용이 포함됩니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

# 시작하기

시작하려면 다음 단계를 따르세요:
1. 아직 계정이 없다면, [가입](https://www.vectara.com/integrations/langchain)하여 무료 Vectara 계정을 만드세요. 가입을 완료하면 Vectara 고객 ID를 받게 됩니다. Vectara 콘솔 창의 오른쪽 상단에서 이름을 클릭하여 고객 ID를 찾을 수 있습니다.
2. 계정 내에서 하나 이상의 코퍼스를 생성할 수 있습니다. 각 코퍼스는 입력 문서에서 수집된 텍스트 데이터를 저장하는 영역을 나타냅니다. 코퍼스를 생성하려면 **"Create Corpus"** 버튼을 사용하세요. 그런 다음 코퍼스에 이름과 설명을 제공하세요. 선택적으로 필터링 속성을 정의하고 일부 고급 옵션을 적용할 수 있습니다. 생성한 코퍼스를 클릭하면 이름과 코퍼스 ID를 맨 위에서 확인할 수 있습니다.
3. 다음으로 코퍼스에 접근하기 위한 API 키를 생성해야 합니다. 코퍼스 보기에서 **"Access Control"** 탭을 클릭한 다음 **"Create API Key"** 버튼을 클릭하세요. 키에 이름을 부여하고, 쿼리 전용 또는 쿼리+인덱스를 선택하세요. "Create"를 클릭하면 활성 API 키가 생성됩니다. 이 키는 비밀로 유지하세요.

Vectara와 LangChain을 사용하려면 다음 세 가지 값이 필요합니다: `customer ID`, `corpus ID` 및 `api_key`.
이 값을 LangChain에 제공하는 방법은 두 가지입니다:

1. 환경에 이 세 가지 변수를 포함하세요: `VECTARA_CUSTOMER_ID`, `VECTARA_CORPUS_ID` 및 `VECTARA_API_KEY`.
   
   예를 들어, 다음과 같이 os.environ 및 getpass를 사용하여 이러한 변수를 설정할 수 있습니다:

```python
import os
import getpass

os.environ["VECTARA_CUSTOMER_ID"] = getpass.getpass("Vectara Customer ID:")
os.environ["VECTARA_CORPUS_ID"] = getpass.getpass("Vectara Corpus ID:")
os.environ["VECTARA_API_KEY"] = getpass.getpass("Vectara API Key:")
```


2. `Vectara` 벡터 저장소 생성자에 추가하세요:

```python
vectara = Vectara(
                vectara_customer_id=vectara_customer_id,
                vectara_corpus_id=vectara_corpus_id,
                vectara_api_key=vectara_api_key
            )
```


이 노트북에서는 환경에서 제공된 것으로 가정합니다.

```python
<!--IMPORTS:[{"imported": "Vectara", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.Vectara.html", "title": "Vectara"}, {"imported": "RerankConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.RerankConfig.html", "title": "Vectara"}, {"imported": "SummaryConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.SummaryConfig.html", "title": "Vectara"}, {"imported": "VectaraQueryConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.VectaraQueryConfig.html", "title": "Vectara"}]-->
import os

os.environ["VECTARA_API_KEY"] = "<YOUR_VECTARA_API_KEY>"
os.environ["VECTARA_CORPUS_ID"] = "<YOUR_VECTARA_CORPUS_ID>"
os.environ["VECTARA_CUSTOMER_ID"] = "<YOUR_VECTARA_CUSTOMER_ID>"

from langchain_community.vectorstores import Vectara
from langchain_community.vectorstores.vectara import (
    RerankConfig,
    SummaryConfig,
    VectaraQueryConfig,
)
```


먼저 Vectara에 국가 연합 상태 텍스트를 로드합니다.

`from_files` 인터페이스를 사용하여 로컬 처리나 청크화가 필요하지 않음을 주의하세요 - Vectara는 파일 내용을 수신하고 필요한 모든 전처리, 청크화 및 임베딩을 지식 저장소에 수행합니다.

이 경우 `.txt` 파일을 사용하지만, 많은 다른 [파일 유형](https://docs.vectara.com/docs/api-reference/indexing-apis/file-upload/file-upload-filetypes)에서도 동일하게 작동합니다.

```python
vectara = Vectara.from_files(["state_of_the_union.txt"])
```


## 기본 Vectara RAG (검색 증강 생성)

이제 검색 및 요약 옵션을 제어하기 위해 `VectaraQueryConfig` 객체를 생성합니다:
* 요약을 활성화하고 LLM이 상위 7개의 일치하는 청크를 선택하고 영어로 응답하도록 지정합니다.
* 검색 과정에서 MMR(최대 한계 관련성)을 활성화하고, 0.2의 다양성 편향 계수를 설정합니다.
* 상위 10개의 결과를 원하며, 하이브리드 검색을 0.025의 값으로 구성합니다.

이 구성을 사용하여 전체 Vectara RAG 파이프라인을 캡슐화하는 LangChain `Runnable` 객체를 생성합시다. `as_rag` 메서드를 사용합니다:

```python
summary_config = SummaryConfig(is_enabled=True, max_results=7, response_lang="eng")
rerank_config = RerankConfig(reranker="mmr", rerank_k=50, mmr_diversity_bias=0.2)
config = VectaraQueryConfig(
    k=10, lambda_val=0.005, rerank_config=rerank_config, summary_config=summary_config
)

query_str = "what did Biden say?"

rag = vectara.as_rag(config)
rag.invoke(query_str)["answer"]
```


```output
"Biden addressed various topics in his statements. He highlighted the need to confront Putin by building a coalition of nations[1]. He also expressed commitment to investigating the impact of burn pits on soldiers' health, including his son's case[2]. Additionally, Biden outlined a plan to fight inflation by cutting prescription drug costs[3]. He emphasized the importance of continuing to combat COVID-19 and not just accepting living with it[4]. Furthermore, he discussed measures to weaken Russia economically and target Russian oligarchs[6]. Biden also advocated for passing the Equality Act to support LGBTQ+ Americans and condemned state laws targeting transgender individuals[7]."
```


다음과 같이 스트리밍 인터페이스를 사용할 수도 있습니다:

```python
output = {}
curr_key = None
for chunk in rag.stream(query_str):
    for key in chunk:
        if key not in output:
            output[key] = chunk[key]
        else:
            output[key] += chunk[key]
        if key == "answer":
            print(chunk[key], end="", flush=True)
        curr_key = key
```

```output
Biden addressed various topics in his statements. He highlighted the importance of building coalitions to confront global challenges [1]. He also expressed commitment to investigating the impact of burn pits on soldiers' health, including his son's case [2, 4]. Additionally, Biden outlined his plan to combat inflation by cutting prescription drug costs and reducing the deficit, with support from Nobel laureates and business leaders [3]. He emphasized the ongoing fight against COVID-19 and the need to continue combating the virus [5]. Furthermore, Biden discussed measures taken to weaken Russia's economic and military strength, targeting Russian oligarchs and corrupt leaders [6]. He also advocated for passing the Equality Act to support LGBTQ+ Americans and address discriminatory state laws [7].
```


## 환각 감지 및 사실 일관성 점수

Vectara는 RAG 응답의 사실 일관성을 평가하는 데 사용할 수 있는 오픈 소스 모델인 [HHEM](https://huggingface.co/vectara/hallucination_evaluation_model)을 만들었습니다.

Vectara RAG의 일환으로 "사실 일관성 점수"(FCS)가 제공되며, 이는 오픈 소스 HHEM의 개선된 버전입니다. 이는 RAG 파이프라인의 출력에 자동으로 포함됩니다.

```python
summary_config = SummaryConfig(is_enabled=True, max_results=5, response_lang="eng")
rerank_config = RerankConfig(reranker="mmr", rerank_k=50, mmr_diversity_bias=0.1)
config = VectaraQueryConfig(
    k=10, lambda_val=0.005, rerank_config=rerank_config, summary_config=summary_config
)

rag = vectara.as_rag(config)
resp = rag.invoke(query_str)
print(resp["answer"])
print(f"Vectara FCS = {resp['fcs']}")
```

```output
Biden addressed various topics in his statements. He highlighted the need to confront Putin by building a coalition of nations[1]. He also expressed his commitment to investigating the impact of burn pits on soldiers' health, referencing his son's experience[2]. Additionally, Biden discussed his plan to fight inflation by cutting prescription drug costs and garnering support from Nobel laureates and business leaders[4]. Furthermore, he emphasized the importance of continuing to combat COVID-19 and not merely accepting living with the virus[5]. Biden's remarks encompassed international relations, healthcare challenges faced by soldiers, economic strategies, and the ongoing battle against the pandemic.
Vectara FCS = 0.41796625
```


## Vectara를 LangChain 검색기로 사용하기

Vectara 구성 요소는 검색기로만 사용할 수도 있습니다.

이 경우, 다른 LangChain 검색기처럼 동작합니다. 이 모드의 주요 용도는 의미 검색이며, 이 경우 요약을 비활성화합니다:

```python
config.summary_config.is_enabled = False
config.k = 3
retriever = vectara.as_retriever(config=config)
retriever.invoke(query_str)
```


```output
[Document(page_content='He thought the West and NATO wouldn’t respond. And he thought he could divide us at home. We were ready.  Here is what we did. We prepared extensively and carefully. We spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin.', metadata={'lang': 'eng', 'section': '1', 'offset': '2160', 'len': '36', 'X-TIKA:Parsed-By': 'org.apache.tika.parser.csv.TextAndCSVParser', 'Content-Encoding': 'UTF-8', 'Content-Type': 'text/plain; charset=UTF-8', 'source': 'vectara'}),
 Document(page_content='When they came home, many of the world’s fittest and best trained warriors were never the same. Dizziness. \n\nA cancer that would put them in a flag-draped coffin. I know. \n\nOne of those soldiers was my son Major Beau Biden. We don’t know for sure if a burn pit was the cause of his brain cancer, or the diseases of so many of our troops. But I’m committed to finding out everything we can.', metadata={'lang': 'eng', 'section': '1', 'offset': '34652', 'len': '60', 'X-TIKA:Parsed-By': 'org.apache.tika.parser.csv.TextAndCSVParser', 'Content-Encoding': 'UTF-8', 'Content-Type': 'text/plain; charset=UTF-8', 'source': 'vectara'}),
 Document(page_content='But cancer from prolonged exposure to burn pits ravaged Heath’s lungs and body. Danielle says Heath was a fighter to the very end. He didn’t know how to stop fighting, and neither did she. Through her pain she found purpose to demand we do better. Tonight, Danielle—we are.', metadata={'lang': 'eng', 'section': '1', 'offset': '35442', 'len': '57', 'X-TIKA:Parsed-By': 'org.apache.tika.parser.csv.TextAndCSVParser', 'Content-Encoding': 'UTF-8', 'Content-Type': 'text/plain; charset=UTF-8', 'source': 'vectara'})]
```


하위 호환성을 위해 검색기에서 요약을 활성화할 수도 있으며, 이 경우 요약이 추가 Document 객체로 추가됩니다:

```python
config.summary_config.is_enabled = True
config.k = 3
retriever = vectara.as_retriever(config=config)
retriever.invoke(query_str)
```


```output
[Document(page_content='He thought the West and NATO wouldn’t respond. And he thought he could divide us at home. We were ready.  Here is what we did. We prepared extensively and carefully. We spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin.', metadata={'lang': 'eng', 'section': '1', 'offset': '2160', 'len': '36', 'X-TIKA:Parsed-By': 'org.apache.tika.parser.csv.TextAndCSVParser', 'Content-Encoding': 'UTF-8', 'Content-Type': 'text/plain; charset=UTF-8', 'source': 'vectara'}),
 Document(page_content='When they came home, many of the world’s fittest and best trained warriors were never the same. Dizziness. \n\nA cancer that would put them in a flag-draped coffin. I know. \n\nOne of those soldiers was my son Major Beau Biden. We don’t know for sure if a burn pit was the cause of his brain cancer, or the diseases of so many of our troops. But I’m committed to finding out everything we can.', metadata={'lang': 'eng', 'section': '1', 'offset': '34652', 'len': '60', 'X-TIKA:Parsed-By': 'org.apache.tika.parser.csv.TextAndCSVParser', 'Content-Encoding': 'UTF-8', 'Content-Type': 'text/plain; charset=UTF-8', 'source': 'vectara'}),
 Document(page_content='But cancer from prolonged exposure to burn pits ravaged Heath’s lungs and body. Danielle says Heath was a fighter to the very end. He didn’t know how to stop fighting, and neither did she. Through her pain she found purpose to demand we do better. Tonight, Danielle—we are.', metadata={'lang': 'eng', 'section': '1', 'offset': '35442', 'len': '57', 'X-TIKA:Parsed-By': 'org.apache.tika.parser.csv.TextAndCSVParser', 'Content-Encoding': 'UTF-8', 'Content-Type': 'text/plain; charset=UTF-8', 'source': 'vectara'}),
 Document(page_content="Biden discussed various topics in his statements. He highlighted the importance of unity and preparation to confront challenges, such as building coalitions to address global issues [1]. Additionally, he shared personal stories about the impact of health issues on soldiers, including his son's experience with brain cancer possibly linked to burn pits [2]. Biden also outlined his plans to combat inflation by cutting prescription drug costs and emphasized the ongoing efforts to combat COVID-19, rejecting the idea of merely living with the virus [4, 5]. Overall, Biden's messages revolved around unity, healthcare challenges faced by soldiers, economic plans, and the ongoing fight against COVID-19.", metadata={'summary': True, 'fcs': 0.54751414})]
```


## Vectara와 함께하는 고급 LangChain 쿼리 전처리

Vectara의 "RAG as a service"는 질문 응답 또는 챗봇 체인을 생성하는 데 많은 작업을 수행합니다. LangChain과의 통합은 `SelfQueryRetriever` 또는 `MultiQueryRetriever`와 같은 추가 기능을 사용할 수 있는 옵션을 제공합니다. [MultiQueryRetriever](https://python.langchain.com/docs/modules/data_connection/retrievers/MultiQueryRetriever)를 사용하는 예제를 살펴보겠습니다.

MQR은 LLM을 사용하므로 이를 설정해야 합니다 - 여기서는 `ChatOpenAI`를 선택합니다:

```python
<!--IMPORTS:[{"imported": "MultiQueryRetriever", "source": "langchain.retrievers.multi_query", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_query.MultiQueryRetriever.html", "title": "Vectara"}, {"imported": "ChatOpenAI", "source": "langchain_openai.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Vectara"}]-->
from langchain.retrievers.multi_query import MultiQueryRetriever
from langchain_openai.chat_models import ChatOpenAI

llm = ChatOpenAI(temperature=0)
mqr = MultiQueryRetriever.from_llm(retriever=retriever, llm=llm)


def get_summary(documents):
    return documents[-1].page_content


(mqr | get_summary).invoke(query_str)
```


```output
"Biden's statement highlighted his efforts to unite freedom-loving nations against Putin's aggression, sharing information in advance to counter Russian lies and hold Putin accountable[1]. Additionally, he emphasized his commitment to military families, like Danielle Robinson, and outlined plans for more affordable housing, Pre-K for 3- and 4-year-olds, and ensuring no additional taxes for those earning less than $400,000 a year[2][3]. The statement also touched on the readiness of the West and NATO to respond to Putin's actions, showcasing extensive preparation and coalition-building efforts[4]. Heath Robinson's story, a combat medic who succumbed to cancer from burn pits, was used to illustrate the resilience and fight for better conditions[5]."
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)
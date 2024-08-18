---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/vectara/vectara_chat.ipynb
description: Vectara는 데이터에 기반한 AI 어시스턴트를 신속하게 생성할 수 있는 신뢰할 수 있는 생성 AI 플랫폼을 제공합니다.
---

# 벡타라 채팅

[벡타라](https://vectara.com/)는 조직이 보유한 데이터, 문서 및 지식에 기반하여 ChatGPT와 유사한 경험(인공지능 비서)을 신속하게 생성할 수 있도록 하는 신뢰할 수 있는 생성적 AI 플랫폼을 제공합니다(기술적으로는 Retrieval-Augmented-Generation-as-a-service입니다).

벡타라의 서버리스 RAG-as-a-service는 사용하기 쉬운 API 뒤에 RAG의 모든 구성 요소를 제공합니다. 여기에는 다음이 포함됩니다:
1. 파일(PDF, PPT, DOCX 등)에서 텍스트를 추출하는 방법
2. 최첨단 성능을 제공하는 ML 기반 청크화
3. [부메랑](https://vectara.com/how-boomerang-takes-retrieval-augmented-generation-to-the-next-level-via-grounded-generation/) 임베딩 모델
4. 텍스트 청크와 임베딩 벡터가 저장되는 자체 내부 벡터 데이터베이스
5. 쿼리를 자동으로 임베딩으로 인코딩하고 가장 관련성 높은 텍스트 세그먼트를 검색하는 쿼리 서비스(여기에는 [하이브리드 검색](https://docs.vectara.com/docs/api-reference/search-apis/lexical-matching) 및 [MMR](https://vectara.com/get-diverse-results-and-comprehensive-summaries-with-vectaras-mmr-reranker/) 지원 포함)
6. 검색된 문서(맥락)를 기반으로 [생성 요약](https://docs.vectara.com/docs/learn/grounded-generation/grounded-generation-overview)을 생성하는 LLM, 인용 포함

API 사용 방법에 대한 자세한 내용은 [벡타라 API 문서](https://docs.vectara.com/docs/)를 참조하세요.

이 노트북은 벡타라의 [채팅](https://docs.vectara.com/docs/api-reference/chat-apis/chat-apis-overview) 기능을 사용하는 방법을 보여줍니다.

# 시작하기

시작하려면 다음 단계를 따르세요:
1. 아직 계정이 없다면, [가입](https://www.vectara.com/integrations/langchain)하여 무료 벡타라 계정을 만드세요. 가입을 완료하면 벡타라 고객 ID를 받게 됩니다. 벡타라 콘솔 창의 오른쪽 상단에서 이름을 클릭하여 고객 ID를 찾을 수 있습니다.
2. 계정 내에서 하나 이상의 코퍼스를 생성할 수 있습니다. 각 코퍼스는 입력 문서에서 수집된 텍스트 데이터를 저장하는 영역을 나타냅니다. 코퍼스를 생성하려면 **"코퍼스 생성"** 버튼을 사용하세요. 그런 다음 코퍼스에 이름과 설명을 제공합니다. 선택적으로 필터링 속성을 정의하고 일부 고급 옵션을 적용할 수 있습니다. 생성한 코퍼스를 클릭하면 상단에서 이름과 코퍼스 ID를 확인할 수 있습니다.
3. 다음으로 코퍼스에 접근하기 위한 API 키를 생성해야 합니다. 코퍼스 보기에서 **"접근 제어"** 탭을 클릭한 다음 **"API 키 생성"** 버튼을 클릭하세요. 키에 이름을 부여하고, 쿼리 전용 또는 쿼리+인덱스를 선택하세요. "생성"을 클릭하면 활성 API 키가 생성됩니다. 이 키는 기밀로 유지하세요.

벡타라와 함께 LangChain을 사용하려면 다음 세 가지 값이 필요합니다: `customer ID`, `corpus ID` 및 `api_key`.
이 값을 LangChain에 제공하는 방법은 두 가지입니다:

1. 환경 변수에 다음 세 가지 변수를 포함하세요: `VECTARA_CUSTOMER_ID`, `VECTARA_CORPUS_ID` 및 `VECTARA_API_KEY`.
   
   예를 들어, 다음과 같이 os.environ 및 getpass를 사용하여 이러한 변수를 설정할 수 있습니다:

```python
import os
import getpass

os.environ["VECTARA_CUSTOMER_ID"] = getpass.getpass("Vectara Customer ID:")
os.environ["VECTARA_CORPUS_ID"] = getpass.getpass("Vectara Corpus ID:")
os.environ["VECTARA_API_KEY"] = getpass.getpass("Vectara API Key:")
```


2. `Vectara` 벡터스토어 생성자에 추가하세요:

```python
vectara = Vectara(
                vectara_customer_id=vectara_customer_id,
                vectara_corpus_id=vectara_corpus_id,
                vectara_api_key=vectara_api_key
            )
```

이 노트북에서는 환경에서 제공된 것으로 가정합니다.

```python
<!--IMPORTS:[{"imported": "Vectara", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.Vectara.html", "title": "Vectara Chat"}, {"imported": "RerankConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.RerankConfig.html", "title": "Vectara Chat"}, {"imported": "SummaryConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.SummaryConfig.html", "title": "Vectara Chat"}, {"imported": "VectaraQueryConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.VectaraQueryConfig.html", "title": "Vectara Chat"}]-->
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


## 벡타라 채팅 설명

LangChain을 사용하여 챗봇을 생성할 때 대부분의 경우 대화 세션의 기록을 유지하고 그 기록을 사용하여 챗봇이 대화 이력을 인식하도록 하는 특별한 `memory` 구성 요소를 통합해야 합니다.

벡타라 채팅을 사용하면 모든 것이 백엔드에서 벡타라에 의해 자동으로 수행됩니다. 이 구현의 내부에 대해 더 알고 싶다면 [채팅](https://docs.vectara.com/docs/api-reference/chat-apis/chat-apis-overview) 문서를 참조하세요. 그러나 LangChain을 사용하면 벡타라 벡터스토어에서 해당 기능을 활성화하기만 하면 됩니다.

예를 살펴보겠습니다. 먼저 SOTU 문서를 로드합니다(텍스트 추출 및 청크화가 벡타라 플랫폼에서 자동으로 발생함을 기억하세요):

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Vectara Chat"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("state_of_the_union.txt")
documents = loader.load()

vectara = Vectara.from_documents(documents, embedding=None)
```


이제 `as_chat` 메서드를 사용하여 채팅 실행 가능 객체를 생성합니다:

```python
summary_config = SummaryConfig(is_enabled=True, max_results=7, response_lang="eng")
rerank_config = RerankConfig(reranker="mmr", rerank_k=50, mmr_diversity_bias=0.2)
config = VectaraQueryConfig(
    k=10, lambda_val=0.005, rerank_config=rerank_config, summary_config=summary_config
)

bot = vectara.as_chat(config)
```


대화 기록 없이 질문을 하는 예시입니다

```python
bot.invoke("What did the president say about Ketanji Brown Jackson?")["answer"]
```


```output
'The President expressed gratitude to Justice Breyer and highlighted the significance of nominating Ketanji Brown Jackson to the Supreme Court, praising her legal expertise and commitment to upholding excellence [1]. The President also reassured the public about the situation with gas prices and the conflict in Ukraine, emphasizing unity with allies and the belief that the world will emerge stronger from these challenges [2][4]. Additionally, the President shared personal experiences related to economic struggles and the importance of passing the American Rescue Plan to support those in need [3]. The focus was also on job creation and economic growth, acknowledging the impact of inflation on families [5]. While addressing cancer as a significant issue, the President discussed plans to enhance cancer research and support for patients and families [7].'
```


일부 대화 기록과 함께 질문을 하는 예시입니다

```python
bot.invoke("Did he mention who she suceeded?")["answer"]
```


```output
"In his remarks, the President specified that Ketanji Brown Jackson is succeeding Justice Breyer on the United States Supreme Court[1]. The President praised Jackson as a top legal mind who will continue Justice Breyer's legacy of excellence. The nomination of Jackson was highlighted as a significant constitutional responsibility of the President[1]. The President emphasized the importance of this nomination and the qualities that Jackson brings to the role. The focus was on the transition from Justice Breyer to Judge Ketanji Brown Jackson on the Supreme Court[1]."
```


## 스트리밍과 함께하는 채팅

물론 챗봇 인터페이스는 스트리밍도 지원합니다.
`invoke` 메서드 대신 `stream`을 사용하면 됩니다:

```python
output = {}
curr_key = None
for chunk in bot.stream("what about her accopmlishments?"):
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
Judge Ketanji Brown Jackson is a nominee for the United States Supreme Court, known for her legal expertise and experience as a former litigator. She is praised for her potential to continue the legacy of excellence on the Court[1]. While the search results provide information on various topics like innovation, economic growth, and healthcare initiatives, they do not directly address Judge Ketanji Brown Jackson's specific accomplishments. Therefore, I do not have enough information to answer this question.
```
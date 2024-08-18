---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/zep_memorystore.ipynb
description: Zep은 AI 비서 앱을 위한 장기 기억 서비스로, 과거 대화를 기억하고 개인화된 AI 경험을 제공합니다.
---

# Zep 오픈 소스
## [Zep](https://docs.getzep.com/)을 위한 검색기 예제

> 채팅 기록에서 데이터를 기억하고 이해하며 추출합니다. 개인화된 AI 경험을 강화합니다.

> [Zep](https://www.getzep.com)은 AI 어시스턴트 앱을 위한 장기 기억 서비스입니다.
Zep을 사용하면 AI 어시스턴트가 과거의 대화를 기억할 수 있는 능력을 제공하며,
환각, 지연 및 비용을 줄일 수 있습니다.

> Zep Cloud에 관심이 있으신가요? [Zep Cloud 설치 가이드](https://help.getzep.com/sdks) 및 [Zep Cloud 검색기 예제](https://help.getzep.com/langchain/examples/rag-message-history-example)를 참조하세요.

## 오픈 소스 설치 및 설정

> Zep 오픈 소스 프로젝트: [https://github.com/getzep/zep](https://github.com/getzep/zep)
Zep 오픈 소스 문서: [https://docs.getzep.com/](https://docs.getzep.com/)

## 검색기 예제

이 노트북은 [Zep 장기 기억 저장소](https://getzep.github.io/)를 사용하여 과거 채팅 메시지 기록을 검색하는 방법을 보여줍니다.

다음과 같은 내용을 시연할 것입니다:

1. Zep 메모리 저장소에 대화 기록 추가.
2. 대화 기록에 대한 벡터 검색:
   1. 채팅 메시지에 대한 유사성 검색
   2. 채팅 메시지 검색의 최대 한계 관련성 재순위 지정
   3. 메타데이터 필터를 사용한 검색 필터링
   4. 채팅 메시지 요약에 대한 유사성 검색
   5. 요약 검색의 최대 한계 관련성 재순위 지정

```python
<!--IMPORTS:[{"imported": "ZepMemory", "source": "langchain_community.memory.zep_memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain_community.memory.zep_memory.ZepMemory.html", "title": "Zep Open Source"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Zep Open Source"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Zep Open Source"}]-->
import getpass
import time
from uuid import uuid4

from langchain_community.memory.zep_memory import ZepMemory
from langchain_core.messages import AIMessage, HumanMessage

# Set this to your Zep server URL
ZEP_API_URL = "http://localhost:8000"
```


### Zep 채팅 메시지 기록 클래스를 초기화하고 메모리 저장소에 채팅 메시지 기록 추가

**참고:** 다른 검색기와 달리, Zep 검색기가 반환하는 콘텐츠는 세션/사용자 특정입니다. 검색기를 인스턴스화할 때 `session_id`가 필요합니다.

```python
# Provide your Zep API key. Note that this is optional. See https://docs.getzep.com/deployment/auth
AUTHENTICATE = False

zep_api_key = None
if AUTHENTICATE:
    zep_api_key = getpass.getpass()
```


```python
session_id = str(uuid4())  # This is a unique identifier for the user/session

# Initialize the Zep Memory Class
zep_memory = ZepMemory(session_id=session_id, url=ZEP_API_URL, api_key=zep_api_key)
```


```python
# Preload some messages into the memory. The default message window is 12 messages. We want to push beyond this to demonstrate auto-summarization.
test_history = [
    {"role": "human", "content": "Who was Octavia Butler?"},
    {
        "role": "ai",
        "content": (
            "Octavia Estelle Butler (June 22, 1947 – February 24, 2006) was an American"
            " science fiction author."
        ),
    },
    {"role": "human", "content": "Which books of hers were made into movies?"},
    {
        "role": "ai",
        "content": (
            "The most well-known adaptation of Octavia Butler's work is the FX series"
            " Kindred, based on her novel of the same name."
        ),
    },
    {"role": "human", "content": "Who were her contemporaries?"},
    {
        "role": "ai",
        "content": (
            "Octavia Butler's contemporaries included Ursula K. Le Guin, Samuel R."
            " Delany, and Joanna Russ."
        ),
    },
    {"role": "human", "content": "What awards did she win?"},
    {
        "role": "ai",
        "content": (
            "Octavia Butler won the Hugo Award, the Nebula Award, and the MacArthur"
            " Fellowship."
        ),
    },
    {
        "role": "human",
        "content": "Which other women sci-fi writers might I want to read?",
    },
    {
        "role": "ai",
        "content": "You might want to read Ursula K. Le Guin or Joanna Russ.",
    },
    {
        "role": "human",
        "content": (
            "Write a short synopsis of Butler's book, Parable of the Sower. What is it"
            " about?"
        ),
    },
    {
        "role": "ai",
        "content": (
            "Parable of the Sower is a science fiction novel by Octavia Butler,"
            " published in 1993. It follows the story of Lauren Olamina, a young woman"
            " living in a dystopian future where society has collapsed due to"
            " environmental disasters, poverty, and violence."
        ),
    },
    {"role": "human", "content": "What is the setting of the book?"},
    {
        "role": "ai",
        "content": (
            "The book is set in a dystopian future in the 2020s, where society has"
            " collapsed due to climate change and economic crises."
        ),
    },
    {"role": "human", "content": "Who is the protagonist?"},
    {
        "role": "ai",
        "content": (
            "The protagonist of the book is Lauren Olamina, a young woman who possesses"
            " 'hyperempathy', the ability to feel pain and other sensations she"
            " witnesses."
        ),
    },
    {"role": "human", "content": "What is the main theme of the book?"},
    {
        "role": "ai",
        "content": (
            "The main theme of the book is survival in the face of drastic societal"
            " change and collapse. It also explores themes of adaptability, community,"
            " and the human capacity for change."
        ),
    },
    {"role": "human", "content": "What is the 'Parable of the Sower'?"},
    {
        "role": "ai",
        "content": (
            "The 'Parable of the Sower' is a biblical parable that Butler uses as a"
            " metaphor in the book. In the parable, a sower scatters seeds, some of"
            " which fall on fertile ground and grow, while others fall on rocky ground"
            " or among thorns and fail to grow. The parable is used to illustrate the"
            " importance of receptivity and preparedness in the face of change."
        ),
    },
    {"role": "human", "content": "What is Butler's writing style like?"},
    {
        "role": "ai",
        "content": (
            "Butler's writing style is known for its clarity, directness, and"
            " psychological insight. Her narratives often involve complex, diverse"
            " characters and explore themes of race, gender, and power."
        ),
    },
    {"role": "human", "content": "What other books has she written?"},
    {
        "role": "ai",
        "content": (
            "In addition to 'Parable of the Sower', Butler has written several other"
            " notable works, including 'Kindred', 'Dawn', and 'Parable of the Talents'."
        ),
    },
]

for msg in test_history:
    zep_memory.chat_memory.add_message(
        HumanMessage(content=msg["content"])
        if msg["role"] == "human"
        else AIMessage(content=msg["content"])
    )

time.sleep(
    10
)  # Wait for the messages to be embedded and summarized. Speed depends on OpenAI API latency and your rate limits.
```


### Zep 메모리에서 벡터 검색을 위한 Zep 검색기 사용

Zep은 역사적인 대화 기억에 대한 기본 벡터 검색을 제공합니다. 임베딩은 자동으로 발생합니다.

참고: 메시지의 임베딩은 비동기적으로 발생하므로 첫 번째 쿼리는 결과를 반환하지 않을 수 있습니다. 이후 쿼리는 임베딩이 생성됨에 따라 결과를 반환합니다.

```python
<!--IMPORTS:[{"imported": "SearchScope", "source": "langchain_community.retrievers.zep", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.zep.SearchScope.html", "title": "Zep Open Source"}, {"imported": "SearchType", "source": "langchain_community.retrievers.zep", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.zep.SearchType.html", "title": "Zep Open Source"}, {"imported": "ZepRetriever", "source": "langchain_community.retrievers.zep", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.zep.ZepRetriever.html", "title": "Zep Open Source"}]-->
from langchain_community.retrievers.zep import SearchScope, SearchType, ZepRetriever

zep_retriever = ZepRetriever(
    session_id=session_id,  # Ensure that you provide the session_id when instantiating the Retriever
    url=ZEP_API_URL,
    top_k=5,
    api_key=zep_api_key,
)

await zep_retriever.ainvoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content="What is the 'Parable of the Sower'?", metadata={'score': 0.9250216484069824, 'uuid': '4cbfb1c0-6027-4678-af43-1e18acb224bb', 'created_at': '2023-11-01T00:32:40.224256Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 34, 'Start': 13, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}]}}, 'token_count': 13}),
 Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler, published in 1993. It follows the story of Lauren Olamina, a young woman living in a dystopian future where society has collapsed due to environmental disasters, poverty, and violence.', metadata={'score': 0.8897348046302795, 'uuid': '3dd9f5ed-9dc9-4427-9da6-aba1b8278a5c', 'created_at': '2023-11-01T00:32:40.192527Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'GPE', 'Matches': [{'End': 20, 'Start': 15, 'Text': 'Sower'}], 'Name': 'Sower'}, {'Label': 'PERSON', 'Matches': [{'End': 65, 'Start': 51, 'Text': 'Octavia Butler'}], 'Name': 'Octavia Butler'}, {'Label': 'DATE', 'Matches': [{'End': 84, 'Start': 80, 'Text': '1993'}], 'Name': '1993'}, {'Label': 'PERSON', 'Matches': [{'End': 124, 'Start': 110, 'Text': 'Lauren Olamina'}], 'Name': 'Lauren Olamina'}], 'intent': 'Providing information'}}, 'token_count': 56}),
 Document(page_content="Write a short synopsis of Butler's book, Parable of the Sower. What is it about?", metadata={'score': 0.8856019973754883, 'uuid': '81761dcb-38f3-4686-a4f5-6cb1007eaf29', 'created_at': '2023-11-01T00:32:40.187543Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'entities': [{'Label': 'ORG', 'Matches': [{'End': 32, 'Start': 26, 'Text': 'Butler'}], 'Name': 'Butler'}, {'Label': 'WORK_OF_ART', 'Matches': [{'End': 61, 'Start': 41, 'Text': 'Parable of the Sower'}], 'Name': 'Parable of the Sower'}], 'intent': "The subject is asking for a brief summary of Butler's book, Parable of the Sower, and what it is about."}}, 'token_count': 23}),
 Document(page_content="The 'Parable of the Sower' is a biblical parable that Butler uses as a metaphor in the book. In the parable, a sower scatters seeds, some of which fall on fertile ground and grow, while others fall on rocky ground or among thorns and fail to grow. The parable is used to illustrate the importance of receptivity and preparedness in the face of change.", metadata={'score': 0.8781436681747437, 'uuid': '1a8c5f99-2fec-425d-bc37-176ab91e7080', 'created_at': '2023-11-01T00:32:40.22836Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 26, 'Start': 5, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}, {'Label': 'ORG', 'Matches': [{'End': 60, 'Start': 54, 'Text': 'Butler'}], 'Name': 'Butler'}]}}, 'token_count': 84}),
 Document(page_content="In addition to 'Parable of the Sower', Butler has written several other notable works, including 'Kindred', 'Dawn', and 'Parable of the Talents'.", metadata={'score': 0.8745182752609253, 'uuid': '45d8aa08-85ab-432f-8902-81712fe363b9', 'created_at': '2023-11-01T00:32:40.245081Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 37, 'Start': 16, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}, {'Label': 'ORG', 'Matches': [{'End': 45, 'Start': 39, 'Text': 'Butler'}], 'Name': 'Butler'}, {'Label': 'GPE', 'Matches': [{'End': 105, 'Start': 98, 'Text': 'Kindred'}], 'Name': 'Kindred'}, {'Label': 'WORK_OF_ART', 'Matches': [{'End': 144, 'Start': 121, 'Text': "Parable of the Talents'"}], 'Name': "Parable of the Talents'"}]}}, 'token_count': 39})]
```


Zep 동기 API를 사용하여 결과를 검색할 수도 있습니다:

```python
zep_retriever.invoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content="What is the 'Parable of the Sower'?", metadata={'score': 0.9250596761703491, 'uuid': '4cbfb1c0-6027-4678-af43-1e18acb224bb', 'created_at': '2023-11-01T00:32:40.224256Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 34, 'Start': 13, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}]}}, 'token_count': 13}),
 Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler, published in 1993. It follows the story of Lauren Olamina, a young woman living in a dystopian future where society has collapsed due to environmental disasters, poverty, and violence.', metadata={'score': 0.8897120952606201, 'uuid': '3dd9f5ed-9dc9-4427-9da6-aba1b8278a5c', 'created_at': '2023-11-01T00:32:40.192527Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'GPE', 'Matches': [{'End': 20, 'Start': 15, 'Text': 'Sower'}], 'Name': 'Sower'}, {'Label': 'PERSON', 'Matches': [{'End': 65, 'Start': 51, 'Text': 'Octavia Butler'}], 'Name': 'Octavia Butler'}, {'Label': 'DATE', 'Matches': [{'End': 84, 'Start': 80, 'Text': '1993'}], 'Name': '1993'}, {'Label': 'PERSON', 'Matches': [{'End': 124, 'Start': 110, 'Text': 'Lauren Olamina'}], 'Name': 'Lauren Olamina'}], 'intent': 'Providing information'}}, 'token_count': 56}),
 Document(page_content="Write a short synopsis of Butler's book, Parable of the Sower. What is it about?", metadata={'score': 0.885666012763977, 'uuid': '81761dcb-38f3-4686-a4f5-6cb1007eaf29', 'created_at': '2023-11-01T00:32:40.187543Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'entities': [{'Label': 'ORG', 'Matches': [{'End': 32, 'Start': 26, 'Text': 'Butler'}], 'Name': 'Butler'}, {'Label': 'WORK_OF_ART', 'Matches': [{'End': 61, 'Start': 41, 'Text': 'Parable of the Sower'}], 'Name': 'Parable of the Sower'}], 'intent': "The subject is asking for a brief summary of Butler's book, Parable of the Sower, and what it is about."}}, 'token_count': 23}),
 Document(page_content="The 'Parable of the Sower' is a biblical parable that Butler uses as a metaphor in the book. In the parable, a sower scatters seeds, some of which fall on fertile ground and grow, while others fall on rocky ground or among thorns and fail to grow. The parable is used to illustrate the importance of receptivity and preparedness in the face of change.", metadata={'score': 0.878172755241394, 'uuid': '1a8c5f99-2fec-425d-bc37-176ab91e7080', 'created_at': '2023-11-01T00:32:40.22836Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 26, 'Start': 5, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}, {'Label': 'ORG', 'Matches': [{'End': 60, 'Start': 54, 'Text': 'Butler'}], 'Name': 'Butler'}]}}, 'token_count': 84}),
 Document(page_content="In addition to 'Parable of the Sower', Butler has written several other notable works, including 'Kindred', 'Dawn', and 'Parable of the Talents'.", metadata={'score': 0.8745154142379761, 'uuid': '45d8aa08-85ab-432f-8902-81712fe363b9', 'created_at': '2023-11-01T00:32:40.245081Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 37, 'Start': 16, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}, {'Label': 'ORG', 'Matches': [{'End': 45, 'Start': 39, 'Text': 'Butler'}], 'Name': 'Butler'}, {'Label': 'GPE', 'Matches': [{'End': 105, 'Start': 98, 'Text': 'Kindred'}], 'Name': 'Kindred'}, {'Label': 'WORK_OF_ART', 'Matches': [{'End': 144, 'Start': 121, 'Text': "Parable of the Talents'"}], 'Name': "Parable of the Talents'"}]}}, 'token_count': 39})]
```


### MMR(최대 한계 관련성)을 사용한 재순위 지정

Zep은 MMR을 사용하여 결과를 재순위 지정하는 기본 SIMD 가속 지원을 제공합니다. 이는 결과의 중복성을 제거하는 데 유용합니다.

```python
zep_retriever = ZepRetriever(
    session_id=session_id,  # Ensure that you provide the session_id when instantiating the Retriever
    url=ZEP_API_URL,
    top_k=5,
    api_key=zep_api_key,
    search_type=SearchType.mmr,
    mmr_lambda=0.5,
)

await zep_retriever.ainvoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content="What is the 'Parable of the Sower'?", metadata={'score': 0.9250596761703491, 'uuid': '4cbfb1c0-6027-4678-af43-1e18acb224bb', 'created_at': '2023-11-01T00:32:40.224256Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 34, 'Start': 13, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}]}}, 'token_count': 13}),
 Document(page_content='What other books has she written?', metadata={'score': 0.77488774061203, 'uuid': '1b3c5079-9cab-46f3-beae-fb56c572e0fd', 'created_at': '2023-11-01T00:32:40.240135Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'token_count': 9}),
 Document(page_content="In addition to 'Parable of the Sower', Butler has written several other notable works, including 'Kindred', 'Dawn', and 'Parable of the Talents'.", metadata={'score': 0.8745154142379761, 'uuid': '45d8aa08-85ab-432f-8902-81712fe363b9', 'created_at': '2023-11-01T00:32:40.245081Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 37, 'Start': 16, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}, {'Label': 'ORG', 'Matches': [{'End': 45, 'Start': 39, 'Text': 'Butler'}], 'Name': 'Butler'}, {'Label': 'GPE', 'Matches': [{'End': 105, 'Start': 98, 'Text': 'Kindred'}], 'Name': 'Kindred'}, {'Label': 'WORK_OF_ART', 'Matches': [{'End': 144, 'Start': 121, 'Text': "Parable of the Talents'"}], 'Name': "Parable of the Talents'"}]}}, 'token_count': 39}),
 Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler, published in 1993. It follows the story of Lauren Olamina, a young woman living in a dystopian future where society has collapsed due to environmental disasters, poverty, and violence.', metadata={'score': 0.8897120952606201, 'uuid': '3dd9f5ed-9dc9-4427-9da6-aba1b8278a5c', 'created_at': '2023-11-01T00:32:40.192527Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'GPE', 'Matches': [{'End': 20, 'Start': 15, 'Text': 'Sower'}], 'Name': 'Sower'}, {'Label': 'PERSON', 'Matches': [{'End': 65, 'Start': 51, 'Text': 'Octavia Butler'}], 'Name': 'Octavia Butler'}, {'Label': 'DATE', 'Matches': [{'End': 84, 'Start': 80, 'Text': '1993'}], 'Name': '1993'}, {'Label': 'PERSON', 'Matches': [{'End': 124, 'Start': 110, 'Text': 'Lauren Olamina'}], 'Name': 'Lauren Olamina'}], 'intent': 'Providing information'}}, 'token_count': 56}),
 Document(page_content='Who is the protagonist?', metadata={'score': 0.7858647704124451, 'uuid': 'ee514b37-a0b0-4d24-b0c9-3e9f8ad9d52d', 'created_at': '2023-11-01T00:32:40.203891Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'intent': 'The subject is asking about the identity of the protagonist in a specific context, such as a story, movie, or game.'}}, 'token_count': 7})]
```


### 검색 결과를 정제하기 위한 메타데이터 필터 사용

Zep은 메타데이터로 결과를 필터링하는 것을 지원합니다. 이는 엔터티 유형 또는 기타 메타데이터에 따라 결과를 필터링하는 데 유용합니다.

자세한 정보는 여기에서 확인하세요: https://docs.getzep.com/sdk/search_query/

```python
filter = {"where": {"jsonpath": '$[*] ? (@.Label == "WORK_OF_ART")'}}

await zep_retriever.ainvoke("Who wrote Parable of the Sower?", metadata=filter)
```


```output
[Document(page_content="What is the 'Parable of the Sower'?", metadata={'score': 0.9251098036766052, 'uuid': '4cbfb1c0-6027-4678-af43-1e18acb224bb', 'created_at': '2023-11-01T00:32:40.224256Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 34, 'Start': 13, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}]}}, 'token_count': 13}),
 Document(page_content='What other books has she written?', metadata={'score': 0.7747920155525208, 'uuid': '1b3c5079-9cab-46f3-beae-fb56c572e0fd', 'created_at': '2023-11-01T00:32:40.240135Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'token_count': 9}),
 Document(page_content="In addition to 'Parable of the Sower', Butler has written several other notable works, including 'Kindred', 'Dawn', and 'Parable of the Talents'.", metadata={'score': 0.8745266795158386, 'uuid': '45d8aa08-85ab-432f-8902-81712fe363b9', 'created_at': '2023-11-01T00:32:40.245081Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'WORK_OF_ART', 'Matches': [{'End': 37, 'Start': 16, 'Text': "Parable of the Sower'"}], 'Name': "Parable of the Sower'"}, {'Label': 'ORG', 'Matches': [{'End': 45, 'Start': 39, 'Text': 'Butler'}], 'Name': 'Butler'}, {'Label': 'GPE', 'Matches': [{'End': 105, 'Start': 98, 'Text': 'Kindred'}], 'Name': 'Kindred'}, {'Label': 'WORK_OF_ART', 'Matches': [{'End': 144, 'Start': 121, 'Text': "Parable of the Talents'"}], 'Name': "Parable of the Talents'"}]}}, 'token_count': 39}),
 Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler, published in 1993. It follows the story of Lauren Olamina, a young woman living in a dystopian future where society has collapsed due to environmental disasters, poverty, and violence.', metadata={'score': 0.8897372484207153, 'uuid': '3dd9f5ed-9dc9-4427-9da6-aba1b8278a5c', 'created_at': '2023-11-01T00:32:40.192527Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'ai', 'metadata': {'system': {'entities': [{'Label': 'GPE', 'Matches': [{'End': 20, 'Start': 15, 'Text': 'Sower'}], 'Name': 'Sower'}, {'Label': 'PERSON', 'Matches': [{'End': 65, 'Start': 51, 'Text': 'Octavia Butler'}], 'Name': 'Octavia Butler'}, {'Label': 'DATE', 'Matches': [{'End': 84, 'Start': 80, 'Text': '1993'}], 'Name': '1993'}, {'Label': 'PERSON', 'Matches': [{'End': 124, 'Start': 110, 'Text': 'Lauren Olamina'}], 'Name': 'Lauren Olamina'}], 'intent': 'Providing information'}}, 'token_count': 56}),
 Document(page_content='Who is the protagonist?', metadata={'score': 0.7858127355575562, 'uuid': 'ee514b37-a0b0-4d24-b0c9-3e9f8ad9d52d', 'created_at': '2023-11-01T00:32:40.203891Z', 'updated_at': '0001-01-01T00:00:00Z', 'role': 'human', 'metadata': {'system': {'intent': 'The subject is asking about the identity of the protagonist in a specific context, such as a story, movie, or game.'}}, 'token_count': 7})]
```


### MMR 재순위 지정을 통한 요약 검색

Zep은 채팅 메시지의 요약을 자동으로 생성합니다. 이러한 요약은 Zep 검색기를 사용하여 검색할 수 있습니다. 요약은 대화의 정제된 형태이므로, 검색 쿼리와 더 잘 일치하고 LLM에 풍부하고 간결한 맥락을 제공합니다.

연속적인 요약은 유사한 내용을 포함할 수 있으며, Zep의 유사성 검색은 가장 높은 일치 결과를 반환하지만 다양성은 적습니다.
MMR은 결과를 재순위 지정하여 프롬프트에 채워 넣는 요약이 모두 관련성이 있고 LLM에 추가 정보를 제공하도록 보장합니다.

```python
zep_retriever = ZepRetriever(
    session_id=session_id,  # Ensure that you provide the session_id when instantiating the Retriever
    url=ZEP_API_URL,
    top_k=3,
    api_key=zep_api_key,
    search_scope=SearchScope.summary,
    search_type=SearchType.mmr,
    mmr_lambda=0.5,
)

await zep_retriever.ainvoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content='The human asks about Octavia Butler and the AI informs them that she was an American science fiction author. The human\nasks which of her books were made into movies and the AI mentions the FX series Kindred. The human then asks about her\ncontemporaries and the AI lists Ursula K. Le Guin, Samuel R. Delany, and Joanna Russ. The human also asks about the awards\nshe won and the AI mentions the Hugo Award, the Nebula Award, and the MacArthur Fellowship. The human asks about other women sci-fi writers to read and the AI suggests Ursula K. Le Guin and Joanna Russ. The human then asks for a synopsis of Butler\'s book "Parable of the Sower" and the AI describes it.', metadata={'score': 0.7882999777793884, 'uuid': '3c95a29a-52dc-4112-b8a7-e6b1dc414d45', 'created_at': '2023-11-01T00:32:47.76449Z', 'token_count': 155}),
 Document(page_content='The human asks about Octavia Butler. The AI informs the human that Octavia Estelle Butler was an American science \nfiction author. The human then asks which books of hers were made into movies and the AI mentions the FX series Kindred, \nbased on her novel of the same name.', metadata={'score': 0.7407922744750977, 'uuid': '0e027f4d-d71f-42ae-977f-696b8948b8bf', 'created_at': '2023-11-01T00:32:41.637098Z', 'token_count': 59}),
 Document(page_content='The human asks about Octavia Butler and the AI informs them that she was an American science fiction author. The human\nasks which of her books were made into movies and the AI mentions the FX series Kindred. The human then asks about her\ncontemporaries and the AI lists Ursula K. Le Guin, Samuel R. Delany, and Joanna Russ. The human also asks about the awards\nshe won and the AI mentions the Hugo Award, the Nebula Award, and the MacArthur Fellowship.', metadata={'score': 0.7436535358428955, 'uuid': 'b3500d1b-1a78-4aef-9e24-6b196cfa83cb', 'created_at': '2023-11-01T00:32:44.24744Z', 'token_count': 104})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
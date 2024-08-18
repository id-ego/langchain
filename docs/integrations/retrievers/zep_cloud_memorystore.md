---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/zep_cloud_memorystore.ipynb
description: Zep Cloud는 AI 어시스턴트 앱을 위한 장기 기억 서비스로, 과거 대화를 기억하고 개인화된 AI 경험을 제공합니다.
---

# Zep Cloud
## [Zep Cloud](https://docs.getzep.com/)을 위한 검색기 예제

> 대화 기록에서 데이터를 기억하고 이해하며 추출합니다. 개인화된 AI 경험을 제공합니다.

> [Zep](https://www.getzep.com)은 AI 어시스턴트 앱을 위한 장기 기억 서비스입니다.
Zep을 사용하면 AI 어시스턴트가 과거의 대화를 기억할 수 있는 능력을 제공하며, 
환각, 지연 및 비용을 줄일 수 있습니다.

> [Zep Cloud 설치 가이드](https://help.getzep.com/sdks) 및 더 많은 [Zep Cloud Langchain 예제](https://github.com/getzep/zep-python/tree/main/examples)를 참조하세요.

## 검색기 예제

이 노트북은 [Zep 장기 기억 저장소](https://www.getzep.com/)를 사용하여 역사적인 채팅 메시지 기록을 검색하는 방법을 보여줍니다.

다음과 같은 내용을 시연합니다:

1. Zep 기억 저장소에 대화 기록 추가하기.
2. 대화 기록에 대한 벡터 검색:
   1. 채팅 메시지에 대한 유사성 검색
   2. 채팅 메시지 검색의 최대 한계 관련성 재순위 매기기
   3. 메타데이터 필터를 사용한 검색 필터링
   4. 채팅 메시지 요약에 대한 유사성 검색
   5. 요약 검색의 최대 한계 관련성 재순위 매기기

```python
<!--IMPORTS:[{"imported": "ZepCloudMemory", "source": "langchain_community.memory.zep_cloud_memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain_community.memory.zep_cloud_memory.ZepCloudMemory.html", "title": "Zep Cloud"}, {"imported": "ZepCloudRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.zep_cloud.ZepCloudRetriever.html", "title": "Zep Cloud"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Zep Cloud"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Zep Cloud"}]-->
import getpass
import time
from uuid import uuid4

from langchain_community.memory.zep_cloud_memory import ZepCloudMemory
from langchain_community.retrievers import ZepCloudRetriever
from langchain_core.messages import AIMessage, HumanMessage

# Provide your Zep API key.
zep_api_key = getpass.getpass()
```


### Zep 채팅 메시지 기록 클래스를 초기화하고 기억 저장소에 채팅 메시지 기록 추가하기

**참고:** 다른 검색기와 달리, Zep 검색기가 반환하는 콘텐츠는 세션/사용자 특정입니다. 검색기를 인스턴스화할 때 `session_id`가 필요합니다.

```python
session_id = str(uuid4())  # This is a unique identifier for the user/session

# Initialize the Zep Memory Class
zep_memory = ZepCloudMemory(session_id=session_id, api_key=zep_api_key)
```


```python
# Preload some messages into the memory. The default message window is 4 messages. We want to push beyond this to demonstrate auto-summarization.
test_history = [
    {"role": "human", "role_type": "user", "content": "Who was Octavia Butler?"},
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "Octavia Estelle Butler (June 22, 1947 – February 24, 2006) was an American"
            " science fiction author."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "Which books of hers were made into movies?",
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "The most well-known adaptation of Octavia Butler's work is the FX series"
            " Kindred, based on her novel of the same name."
        ),
    },
    {"role": "human", "role_type": "user", "content": "Who were her contemporaries?"},
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "Octavia Butler's contemporaries included Ursula K. Le Guin, Samuel R."
            " Delany, and Joanna Russ."
        ),
    },
    {"role": "human", "role_type": "user", "content": "What awards did she win?"},
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "Octavia Butler won the Hugo Award, the Nebula Award, and the MacArthur"
            " Fellowship."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "Which other women sci-fi writers might I want to read?",
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": "You might want to read Ursula K. Le Guin or Joanna Russ.",
    },
    {
        "role": "human",
        "role_type": "user",
        "content": (
            "Write a short synopsis of Butler's book, Parable of the Sower. What is it"
            " about?"
        ),
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "Parable of the Sower is a science fiction novel by Octavia Butler,"
            " published in 1993. It follows the story of Lauren Olamina, a young woman"
            " living in a dystopian future where society has collapsed due to"
            " environmental disasters, poverty, and violence."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "What is the setting of the book?",
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "The book is set in a dystopian future in the 2020s, where society has"
            " collapsed due to climate change and economic crises."
        ),
    },
    {"role": "human", "role_type": "user", "content": "Who is the protagonist?"},
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "The protagonist of the book is Lauren Olamina, a young woman who possesses"
            " 'hyperempathy', the ability to feel pain and other sensations she"
            " witnesses."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "What is the main theme of the book?",
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "The main theme of the book is survival in the face of drastic societal"
            " change and collapse. It also explores themes of adaptability, community,"
            " and the human capacity for change."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "What is the 'Parable of the Sower'?",
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "The 'Parable of the Sower' is a biblical parable that Butler uses as a"
            " metaphor in the book. In the parable, a sower scatters seeds, some of"
            " which fall on fertile ground and grow, while others fall on rocky ground"
            " or among thorns and fail to grow. The parable is used to illustrate the"
            " importance of receptivity and preparedness in the face of change."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "What is Butler's writing style like?",
    },
    {
        "role": "ai",
        "role_type": "assistant",
        "content": (
            "Butler's writing style is known for its clarity, directness, and"
            " psychological insight. Her narratives often involve complex, diverse"
            " characters and explore themes of race, gender, and power."
        ),
    },
    {
        "role": "human",
        "role_type": "user",
        "content": "What other books has she written?",
    },
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
)  # Wait for the messages to be embedded and summarized, this happens asynchronously.
```


### Zep 기억에 대해 Zep 검색기를 사용하여 벡터 검색하기

Zep은 역사적인 대화 기억에 대한 네이티브 벡터 검색을 제공합니다. 임베딩은 자동으로 발생합니다.

참고: 메시지의 임베딩은 비동기적으로 발생하므로 첫 번째 쿼리는 결과를 반환하지 않을 수 있습니다. 이후 쿼리는 임베딩이 생성됨에 따라 결과를 반환합니다.

```python
zep_retriever = ZepCloudRetriever(
    api_key=zep_api_key,
    session_id=session_id,  # Ensure that you provide the session_id when instantiating the Retriever
    top_k=5,
)

await zep_retriever.ainvoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content="What is the 'Parable of the Sower'?", metadata={'score': 0.9333381652832031, 'uuid': 'bebc441c-a32d-44a1-ae61-968e7b3d4956', 'created_at': '2024-05-10T05:02:01.857627Z', 'token_count': 11, 'role': 'human'}),
 Document(page_content="The 'Parable of the Sower' is a biblical parable that Butler uses as a metaphor in the book. In the parable, a sower scatters seeds, some of which fall on fertile ground and grow, while others fall on rocky ground or among thorns and fail to grow. The parable is used to illustrate the importance of receptivity and preparedness in the face of change.", metadata={'score': 0.8757256865501404, 'uuid': '193c60d8-2b7b-4eb1-a4be-c2d8afd92991', 'created_at': '2024-05-10T05:02:01.97174Z', 'token_count': 82, 'role': 'ai'}),
 Document(page_content="Write a short synopsis of Butler's book, Parable of the Sower. What is it about?", metadata={'score': 0.8641344904899597, 'uuid': 'fc78901d-a625-4530-ba63-1ae3e3b11683', 'created_at': '2024-05-10T05:02:00.942994Z', 'token_count': 21, 'role': 'human'}),
 Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler, published in 1993. It follows the story of Lauren Olamina, a young woman living in a dystopian future where society has collapsed due to environmental disasters, poverty, and violence.', metadata={'score': 0.8581685125827789, 'uuid': '91f2cda4-276e-446d-96bf-07d34e5af616', 'created_at': '2024-05-10T05:02:01.05577Z', 'token_count': 54, 'role': 'ai'}),
 Document(page_content="In addition to 'Parable of the Sower', Butler has written several other notable works, including 'Kindred', 'Dawn', and 'Parable of the Talents'.", metadata={'score': 0.8076582252979279, 'uuid': 'e3994519-9a90-410c-b14c-2c652f6d184f', 'created_at': '2024-05-10T05:02:02.401682Z', 'token_count': 37, 'role': 'ai'})]
```


Zep 동기 API를 사용하여 결과를 검색할 수도 있습니다:

```python
zep_retriever.invoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler set in a dystopian future in the 2020s. The story follows Lauren Olamina, a young woman living in a society that has collapsed due to environmental disasters, poverty, and violence. The novel explores themes of societal breakdown, the struggle for survival, and the search for a better future.', metadata={'score': 0.8473024368286133, 'uuid': 'e4689f8e-33be-4a59-a9c2-e5ef5dd70f74', 'created_at': '2024-05-10T05:02:02.713123Z', 'token_count': 76})]
```


### MMR(최대 한계 관련성)을 사용한 재순위 매기기

Zep은 MMR을 사용하여 결과를 재순위 매기기 위한 네이티브 SIMD 가속 지원을 제공합니다. 이는 결과의 중복성을 제거하는 데 유용합니다.

```python
zep_retriever = ZepCloudRetriever(
    api_key=zep_api_key,
    session_id=session_id,  # Ensure that you provide the session_id when instantiating the Retriever
    top_k=5,
    search_type="mmr",
    mmr_lambda=0.5,
)

await zep_retriever.ainvoke("Who wrote Parable of the Sower?")
```


### 메타데이터 필터를 사용하여 검색 결과 정제하기

Zep은 메타데이터로 결과를 필터링하는 것을 지원합니다. 이는 엔티티 유형 또는 기타 메타데이터로 결과를 필터링하는 데 유용합니다.

자세한 정보는 여기에서 확인하세요: https://help.getzep.com/document-collections#searching-a-collection-with-hybrid-vector-search

```python
filter = {"where": {"jsonpath": '$[*] ? (@.baz == "qux")'}}

await zep_retriever.ainvoke(
    "Who wrote Parable of the Sower?", config={"metadata": filter}
)
```


### MMR 재순위 매기기를 통한 요약 검색

Zep은 채팅 메시지의 요약을 자동으로 생성합니다. 이러한 요약은 Zep 검색기를 사용하여 검색할 수 있습니다. 요약은 대화의 정제이므로 검색 쿼리와 더 잘 일치하고 LLM에 풍부하고 간결한 맥락을 제공합니다.

연속적인 요약은 유사한 내용을 포함할 수 있으며, Zep의 유사성 검색은 가장 높은 일치 결과를 반환하지만 다양성이 적습니다. 
MMR은 결과를 재순위 매겨 프롬프트에 채워 넣는 요약이 관련성이 있고 각각 LLM에 추가 정보를 제공하도록 보장합니다.

```python
zep_retriever = ZepCloudRetriever(
    api_key=zep_api_key,
    session_id=session_id,  # Ensure that you provide the session_id when instantiating the Retriever
    top_k=3,
    search_scope="summary",
    search_type="mmr",
    mmr_lambda=0.5,
)

await zep_retriever.ainvoke("Who wrote Parable of the Sower?")
```


```output
[Document(page_content='Parable of the Sower is a science fiction novel by Octavia Butler set in a dystopian future in the 2020s. The story follows Lauren Olamina, a young woman living in a society that has collapsed due to environmental disasters, poverty, and violence. The novel explores themes of societal breakdown, the struggle for survival, and the search for a better future.', metadata={'score': 0.8473024368286133, 'uuid': 'e4689f8e-33be-4a59-a9c2-e5ef5dd70f74', 'created_at': '2024-05-10T05:02:02.713123Z', 'token_count': 76}),
 Document(page_content='The \'Parable of the Sower\' refers to a new religious belief system that the protagonist, Lauren Olamina, develops over the course of the novel. As her community disintegrates due to climate change, economic collapse, and social unrest, Lauren comes to believe that humanity must adapt and "shape God" in order to survive. The \'Parable of the Sower\' is the foundational text of this new religion, which Lauren calls "Earthseed", that emphasizes the inevitability of change and the need for humanity to take an active role in shaping its own future. This parable is a central thematic element of the novel, representing the protagonist\'s search for meaning and purpose in the face of societal upheaval.', metadata={'score': 0.8466987311840057, 'uuid': '1f1a44eb-ebd8-4617-ac14-0281099bd770', 'created_at': '2024-05-10T05:02:07.541073Z', 'token_count': 146}),
 Document(page_content='The dialog discusses the central themes of Octavia Butler\'s acclaimed science fiction novel "Parable of the Sower." The main theme is survival in the face of drastic societal collapse, and the importance of adaptability, community, and the human capacity for change. The "Parable of the Sower," a biblical parable, serves as a metaphorical framework for the novel, illustrating the need for receptivity and preparedness when confronting transformative upheaval.', metadata={'score': 0.8283970355987549, 'uuid': '4158a750-3ccd-45ce-ab88-fed5ba68b755', 'created_at': '2024-05-10T05:02:06.510068Z', 'token_count': 91})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
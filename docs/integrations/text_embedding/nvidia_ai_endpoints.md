---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/nvidia_ai_endpoints.ipynb
description: NVIDIA NIM은 NVIDIA 가속 인프라에서 모델을 배포하는 간편한 컨테이너로, 다양한 AI 애플리케이션을 지원합니다.
---

# NVIDIA NIMs

`langchain-nvidia-ai-endpoints` 패키지는 NVIDIA NIM 추론 마이크로서비스에서 모델을 사용하여 애플리케이션을 구축하는 LangChain 통합을 포함합니다. NIM은 커뮤니티와 NVIDIA의 채팅, 임베딩 및 재순위 모델과 같은 다양한 도메인에서 모델을 지원합니다. 이러한 모델은 NVIDIA에 의해 최적화되어 NVIDIA 가속 인프라에서 최고의 성능을 제공하며, 단일 명령으로 어디서나 배포할 수 있는 사용하기 쉬운 미리 구축된 컨테이너인 NIM으로 배포됩니다.

NVIDIA에서 호스팅하는 NIM 배포는 [NVIDIA API 카탈로그](https://build.nvidia.com/)에서 테스트할 수 있습니다. 테스트 후, NIM은 NVIDIA AI Enterprise 라이센스를 사용하여 NVIDIA의 API 카탈로그에서 내보낼 수 있으며, 온프레미스 또는 클라우드에서 실행할 수 있어 기업이 자신의 IP와 AI 애플리케이션에 대한 소유권과 완전한 제어를 가질 수 있습니다.

NIM은 모델별로 컨테이너 이미지로 패키징되며, NVIDIA NGC 카탈로그를 통해 NGC 컨테이너 이미지로 배포됩니다. NIM의 핵심은 AI 모델에 대한 추론을 실행하기 위한 쉽고 일관되며 친숙한 API를 제공하는 것입니다.

이 예제는 `NVIDIAEmbeddings` 클래스를 통해 지원되는 [NVIDIA Retrieval QA Embedding Model](https://build.nvidia.com/nvidia/embed-qa-4)과 상호작용하여 [검색 증강 생성](https://developer.nvidia.com/blog/build-enterprise-retrieval-augmented-generation-apps-with-nvidia-retrieval-qa-embedding-model/)을 수행하는 방법을 설명합니다.

이 API를 통해 채팅 모델에 접근하는 방법에 대한 자세한 내용은 [ChatNVIDIA](https://python.langchain.com/docs/integrations/chat/nvidia_ai_endpoints/) 문서를 확인하십시오.

## 설치

```python
%pip install --upgrade --quiet  langchain-nvidia-ai-endpoints
```


## 설정

**시작하려면:**

1. NVIDIA AI Foundation 모델을 호스팅하는 [NVIDIA](https://build.nvidia.com/)에 무료 계정을 생성합니다.
2. `Retrieval` 탭을 선택한 다음 원하는 모델을 선택합니다.
3. `Input`에서 `Python` 탭을 선택하고 `Get API Key`를 클릭합니다. 그런 다음 `Generate Key`를 클릭합니다.
4. 생성된 키를 `NVIDIA_API_KEY`로 복사하여 저장합니다. 그 이후로 엔드포인트에 접근할 수 있어야 합니다.

```python
import getpass
import os

# del os.environ['NVIDIA_API_KEY']  ## delete key and reset
if os.environ.get("NVIDIA_API_KEY", "").startswith("nvapi-"):
    print("Valid NVIDIA_API_KEY already in environment. Delete to reset")
else:
    nvapi_key = getpass.getpass("NVAPI Key (starts with nvapi-): ")
    assert nvapi_key.startswith("nvapi-"), f"{nvapi_key[:5]}... is not a valid key"
    os.environ["NVIDIA_API_KEY"] = nvapi_key
```


우리는 효과적인 RAG 솔루션을 위해 LLM과 함께 사용할 수 있는 임베딩 모델 목록에서 임베딩 모델을 확인할 수 있어야 합니다. 우리는 `NVIDIAEmbeddings` 클래스를 통해 이 모델과 NIM에서 지원하는 다른 임베딩 모델과 인터페이스할 수 있습니다.

## NVIDIA API 카탈로그에서 NIM 작업하기

임베딩 모델을 초기화할 때, 예를 들어 아래의 `NV-Embed-QA`와 같이 모델을 전달하여 선택하거나, 인수를 전달하지 않고 기본값을 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "NVIDIAEmbeddings", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_nvidia_ai_endpoints.embeddings.NVIDIAEmbeddings.html", "title": "NVIDIA NIMs "}]-->
from langchain_nvidia_ai_endpoints import NVIDIAEmbeddings

embedder = NVIDIAEmbeddings(model="NV-Embed-QA")
```


이 모델은 예상되는 `Embeddings` 메서드를 지원하는 세밀하게 조정된 E5-large 모델입니다:

- `embed_query`: 쿼리 샘플에 대한 쿼리 임베딩을 생성합니다.
- `embed_documents`: 검색할 문서 목록에 대한 패시지 임베딩을 생성합니다.
- `aembed_query`/`aembed_documents`: 위의 비동기 버전입니다.

## 자체 호스팅된 NVIDIA NIM 작업하기
배포할 준비가 되면, NVIDIA NIM을 사용하여 모델을 자체 호스팅할 수 있으며, 이는 NVIDIA AI Enterprise 소프트웨어 라이센스에 포함되어 있으며, 어디서나 실행할 수 있어 사용자 정의에 대한 소유권과 지적 재산(IP) 및 AI 애플리케이션에 대한 완전한 제어를 제공합니다.

[NIM에 대해 더 알아보기](https://developer.nvidia.com/blog/nvidia-nim-offers-optimized-inference-microservices-for-deploying-ai-models-at-scale/)

```python
<!--IMPORTS:[{"imported": "NVIDIAEmbeddings", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_nvidia_ai_endpoints.embeddings.NVIDIAEmbeddings.html", "title": "NVIDIA NIMs "}]-->
from langchain_nvidia_ai_endpoints import NVIDIAEmbeddings

# connect to an embedding NIM running at localhost:8080
embedder = NVIDIAEmbeddings(base_url="http://localhost:8080/v1")
```


### **유사성**

다음은 이러한 데이터 포인트의 유사성을 빠르게 테스트한 것입니다:

**쿼리:**

- 코미차카의 날씨는 어떤가요?
- 이탈리아는 어떤 종류의 음식으로 유명한가요?
- 내 이름이 뭐죠? 기억 못하겠죠...
- 인생의 의미는 무엇인가요?
- 인생의 의미는 즐기는 것입니다 :D

**문서:**

- 코미차카의 날씨는 춥고, 길고 혹독한 겨울이 있습니다.
- 이탈리아는 파스타, 피자, 젤라토, 에스프레소로 유명합니다.
- 개인 이름은 기억할 수 없고, 정보만 제공합니다.
- 인생의 목적은 다양하며, 종종 개인적 성취로 여겨집니다.
- 인생의 순간을 즐기는 것은 정말 멋진 접근 방식입니다.

### 임베딩 런타임

```python
print("\nSequential Embedding: ")
q_embeddings = [
    embedder.embed_query("What's the weather like in Komchatka?"),
    embedder.embed_query("What kinds of food is Italy known for?"),
    embedder.embed_query("What's my name? I bet you don't remember..."),
    embedder.embed_query("What's the point of life anyways?"),
    embedder.embed_query("The point of life is to have fun :D"),
]
print("Shape:", (len(q_embeddings), len(q_embeddings[0])))
```


### 문서 임베딩

```python
print("\nBatch Document Embedding: ")
d_embeddings = embedder.embed_documents(
    [
        "Komchatka's weather is cold, with long, severe winters.",
        "Italy is famous for pasta, pizza, gelato, and espresso.",
        "I can't recall personal names, only provide information.",
        "Life's purpose varies, often seen as personal fulfillment.",
        "Enjoying life's moments is indeed a wonderful approach.",
    ]
)
print("Shape:", (len(q_embeddings), len(q_embeddings[0])))
```


이제 임베딩을 생성했으므로, 검색 작업에서 합리적인 답변으로 트리거될 문서를 확인하기 위해 결과에 대한 간단한 유사성 검사를 수행할 수 있습니다:

```python
%pip install --upgrade --quiet  matplotlib scikit-learn
```


```python
import matplotlib.pyplot as plt
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

# Compute the similarity matrix between q_embeddings and d_embeddings
cross_similarity_matrix = cosine_similarity(
    np.array(q_embeddings),
    np.array(d_embeddings),
)

# Plotting the cross-similarity matrix
plt.figure(figsize=(8, 6))
plt.imshow(cross_similarity_matrix, cmap="Greens", interpolation="nearest")
plt.colorbar()
plt.title("Cross-Similarity Matrix")
plt.xlabel("Query Embeddings")
plt.ylabel("Document Embeddings")
plt.grid(True)
plt.show()
```


다시 말해, 시스템에 전송된 쿼리와 문서는 다음과 같습니다:

**쿼리:**

- 코미차카의 날씨는 어떤가요?
- 이탈리아는 어떤 종류의 음식으로 유명한가요?
- 내 이름이 뭐죠? 기억 못하겠죠...
- 인생의 의미는 무엇인가요?
- 인생의 의미는 즐기는 것입니다 :D

**문서:**

- 코미차카의 날씨는 춥고, 길고 혹독한 겨울이 있습니다.
- 이탈리아는 파스타, 피자, 젤라토, 에스프레소로 유명합니다.
- 개인 이름은 기억할 수 없고, 정보만 제공합니다.
- 인생의 목적은 다양하며, 종종 개인적 성취로 여겨집니다.
- 인생의 순간을 즐기는 것은 정말 멋진 접근 방식입니다.

## 잘림

임베딩 모델은 일반적으로 최대 입력 토큰 수를 결정하는 고정된 컨텍스트 창을 가지고 있습니다. 이 제한은 모델의 최대 입력 토큰 길이와 동일한 하드 제한일 수도 있고, 임베딩의 정확도가 감소하는 효과적인 제한일 수도 있습니다.

모델은 토큰을 기반으로 작동하고 애플리케이션은 일반적으로 텍스트로 작업하므로, 애플리케이션이 입력이 모델의 토큰 제한 내에 유지되도록 보장하는 것은 어려울 수 있습니다. 기본적으로 입력이 너무 크면 예외가 발생합니다.

이를 돕기 위해 NVIDIA의 NIM(API 카탈로그 또는 로컬)은 입력이 너무 큰 경우 서버 측에서 입력을 잘라내는 `truncate` 매개변수를 제공합니다.

`truncate` 매개변수에는 세 가지 옵션이 있습니다:
- "NONE": 기본 옵션입니다. 입력이 너무 크면 예외가 발생합니다.
- "START": 서버가 입력을 시작(왼쪽)에서 잘라내며, 필요한 경우 토큰을 폐기합니다.
- "END": 서버가 입력을 끝(오른쪽)에서 잘라내며, 필요한 경우 토큰을 폐기합니다.

```python
long_text = "AI is amazing, amazing is " * 100
```


```python
strict_embedder = NVIDIAEmbeddings()
try:
    strict_embedder.embed_query(long_text)
except Exception as e:
    print("Error:", e)
```


```python
truncating_embedder = NVIDIAEmbeddings(truncate="END")
truncating_embedder.embed_query(long_text)[:5]
```


## RAG 검색:

다음은 [LangChain 표현 언어 검색 요리책 항목](https://python.langchain.com/docs/expression_language/cookbook/retrieval)의 초기 예제를 재사용한 것이지만, AI Foundation Models의 [Mixtral 8x7B Instruct](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/ai-foundation/models/mixtral-8x7b) 및 [NVIDIA Retrieval QA Embedding](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/ai-foundation/models/nvolve-40k) 모델을 사용하여 실행되었습니다. 요리책의 후속 예제도 예상대로 실행되며, 이러한 옵션으로 탐색할 것을 권장합니다.

**팁:** 내부 추론(즉, 데이터 추출, 도구 선택 등을 위한 지침 따르기)에는 Mixtral을 사용하고, 단일 최종 "사용자의 역사와 맥락에 기반하여 간단한 응답을 만드는" 응답에는 Llama-Chat을 사용하는 것이 좋습니다.

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "NVIDIA NIMs "}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "NVIDIA NIMs "}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "NVIDIA NIMs "}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "NVIDIA NIMs "}, {"imported": "ChatNVIDIA", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html", "title": "NVIDIA NIMs "}]-->
%pip install --upgrade --quiet  langchain faiss-cpu tiktoken langchain_community

from operator import itemgetter

from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_nvidia_ai_endpoints import ChatNVIDIA
```


```python
vectorstore = FAISS.from_texts(
    ["harrison worked at kensho"],
    embedding=NVIDIAEmbeddings(model="NV-Embed-QA"),
)
retriever = vectorstore.as_retriever()

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Answer solely based on the following context:\n<Documents>\n{context}\n</Documents>",
        ),
        ("user", "{question}"),
    ]
)

model = ChatNVIDIA(model="ai-mixtral-8x7b-instruct")

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)

chain.invoke("where did harrison work?")
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Answer using information solely based on the following context:\n<Documents>\n{context}\n</Documents>"
            "\nSpeak only in the following language: {language}",
        ),
        ("user", "{question}"),
    ]
)

chain = (
    {
        "context": itemgetter("question") | retriever,
        "question": itemgetter("question"),
        "language": itemgetter("language"),
    }
    | prompt
    | model
    | StrOutputParser()
)

chain.invoke({"question": "where did harrison work", "language": "italian"})
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/upstage.ipynb
description: Upstage는 영어와 한국어에 최적화된 고급 대화형 AI 모델인 Solar Mini Chat을 제공하는 인공지능 전문 기업입니다.
---

# 업스테이지

[업스테이지](https://upstage.ai)는 인간 이상의 성능을 제공하는 LLM 컴포넌트를 전문으로 하는 선도적인 인공지능(AI) 회사입니다.

## 솔라 LLM

**솔라 미니 챗**은 영어와 한국어에 중점을 둔 빠르고 강력한 고급 대형 언어 모델입니다. 이 모델은 다중 턴 채팅 목적을 위해 특별히 미세 조정되어, 유사한 크기의 다른 모델에 비해 다중 턴 대화나 RAG(검색 증강 생성)과 같은 긴 맥락 이해가 필요한 작업에서 자연어 처리 작업의 성능이 향상되었습니다. 이 미세 조정은 긴 대화를 보다 효과적으로 처리할 수 있는 능력을 부여하여, 특히 상호작용 애플리케이션에 적합합니다.

솔라 외에도 업스테이지는 **그라운드니스 체크** 및 **레이아웃 분석**과 같은 실제 RAG(검색 증강 생성)를 위한 기능도 제공합니다.

## 설치 및 설정

`langchain-upstage` 패키지를 설치합니다:

```bash
pip install -qU langchain-core langchain-upstage
```


[API 키](https://console.upstage.ai)를 얻고 환경 변수 `UPSTAGE_API_KEY`를 설정합니다.

## 업스테이지 LangChain 통합

| API | 설명 | 가져오기 | 사용 예 |
| --- | --- | --- | --- |
| 채팅 | 솔라 미니 챗을 사용하여 어시스턴트 구축 | `from langchain_upstage import ChatUpstage` | [이동](../../chat/upstage) |
| 텍스트 임베딩 | 문자열을 벡터로 임베드 | `from langchain_upstage import UpstageEmbeddings` | [이동](../../text_embedding/upstage) |
| 그라운드니스 체크 | 어시스턴트의 응답의 그라운드니스 확인 | `from langchain_upstage import UpstageGroundednessCheck` | [이동](../../tools/upstage_groundedness_check) |
| 레이아웃 분석 | 테이블 및 그림이 포함된 문서 직렬화 | `from langchain_upstage import UpstageLayoutAnalysisLoader` | [이동](../../document_loaders/upstage) |

기능에 대한 자세한 내용은 [문서](https://developers.upstage.ai/)를 참조하세요.

## 빠른 예제

### 환경 설정

```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```


### 채팅

```python
from langchain_upstage import ChatUpstage

chat = ChatUpstage()
response = chat.invoke("Hello, how are you?")
print(response)
```


### 텍스트 임베딩

```python
from langchain_upstage import UpstageEmbeddings

embeddings = UpstageEmbeddings(model="solar-embedding-1-large")
doc_result = embeddings.embed_documents(
    ["Sung is a professor.", "This is another document"]
)
print(doc_result)

query_result = embeddings.embed_query("What does Sung do?")
print(query_result)
```


### 그라운드니스 체크

```python
from langchain_upstage import UpstageGroundednessCheck

groundedness_check = UpstageGroundednessCheck()

request_input = {
    "context": "Mauna Kea is an inactive volcano on the island of Hawaii. Its peak is 4,207.3 m above sea level, making it the highest point in Hawaii and second-highest peak of an island on Earth.",
    "answer": "Mauna Kea is 5,207.3 meters tall.",
}
response = groundedness_check.invoke(request_input)
print(response)
```


### 레이아웃 분석

```python
from langchain_upstage import UpstageLayoutAnalysisLoader

file_path = "/PATH/TO/YOUR/FILE.pdf"
layzer = UpstageLayoutAnalysisLoader(file_path, split="page")

# For improved memory efficiency, consider using the lazy_load method to load documents page by page.
docs = layzer.load()  # or layzer.lazy_load()

for doc in docs[:3]:
    print(doc)
```
---
description: Breebs는 Google Drive에 저장된 PDF를 기반으로 지식을 생성하고 LLM/chatbot의 전문성을 향상시키는
  협업 지식 플랫폼입니다.
---

# Breebs (오픈 지식)

> [Breebs](https://www.breebs.com/)는 오픈 협업 지식 플랫폼입니다.
누구나 Google Drive 폴더에 저장된 PDF를 기반으로 한 지식 캡슐인 `Breeb`를 생성할 수 있습니다.
`Breeb`는 모든 LLM/챗봇이 전문성을 향상시키고, 환각을 줄이며, 출처에 접근할 수 있도록 사용될 수 있습니다.
비하인드에서는 `Breebs`가 여러 개의 `Retrieval Augmented Generation (RAG)` 모델을 구현하여
각 반복에서 유용한 컨텍스트를 원활하게 제공합니다.  

## 검색기

```python
from langchain.retrievers import BreebsRetriever
```


[사용 예시 보기 (Retrieval & ConversationalRetrievalChain)](/docs/integrations/retrievers/breebs)
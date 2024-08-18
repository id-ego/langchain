---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/bedrock.ipynb
description: 아마존 베드록은 고성능 기초 모델을 제공하는 완전 관리형 서비스로, 보안과 개인 정보 보호를 고려한 생성 AI 애플리케이션
  구축을 지원합니다.
---

# 베드록

> [아마존 베드록](https://aws.amazon.com/bedrock/)은 `AI21 Labs`, `Anthropic`, `Cohere`, `Meta`, `Stability AI`, `Amazon`과 같은 주요 AI 회사의 고성능 기초 모델(FMs)을 단일 API를 통해 제공하는 완전 관리형 서비스로, 보안, 개인 정보 보호 및 책임 있는 AI를 갖춘 생성 AI 애플리케이션을 구축하는 데 필요한 광범위한 기능을 제공합니다. `Amazon Bedrock`을 사용하면 사용 사례에 맞는 최고의 FMs을 쉽게 실험하고 평가할 수 있으며, 미세 조정 및 `Retrieval Augmented Generation`(`RAG`)과 같은 기술을 사용하여 데이터로 개인화할 수 있고, 기업 시스템 및 데이터 소스를 사용하여 작업을 실행하는 에이전트를 구축할 수 있습니다. `Amazon Bedrock`은 서버리스이므로 인프라를 관리할 필요가 없으며, 이미 익숙한 AWS 서비스를 사용하여 생성 AI 기능을 안전하게 통합하고 배포할 수 있습니다.

```python
%pip install --upgrade --quiet  boto3
```


```python
<!--IMPORTS:[{"imported": "BedrockEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.bedrock.BedrockEmbeddings.html", "title": "Bedrock"}]-->
from langchain_community.embeddings import BedrockEmbeddings

embeddings = BedrockEmbeddings(
    credentials_profile_name="bedrock-admin", region_name="us-east-1"
)
```


```python
embeddings.embed_query("This is a content of the document")
```


```python
embeddings.embed_documents(
    ["This is a content of the document", "This is another document"]
)
```


```python
# async embed query
await embeddings.aembed_query("This is a content of the document")
```


```python
# async embed documents
await embeddings.aembed_documents(
    ["This is a content of the document", "This is another document"]
)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/nomic.ipynb
description: Nomic은 Atlas와 GPT4All 두 가지 제품을 제공하며, Langchain과의 통합을 통해 데이터 엔진과 언어 모델
  생태계를 지원합니다.
---

# Nomic

Nomic은 현재 두 가지 제품을 제공합니다:

- Atlas: 그들의 시각적 데이터 엔진
- GPT4All: 그들의 오픈 소스 엣지 언어 모델 생태계

Nomic 통합은 자체 [파트너 패키지](https://pypi.org/project/langchain-nomic/)에 존재합니다. 다음과 같이 설치할 수 있습니다:

```python
%pip install -qU langchain-nomic
```


현재, 다음과 같이 그들의 호스팅된 [임베딩 모델](/docs/integrations/text_embedding/nomic)을 가져올 수 있습니다:

```python
<!--IMPORTS:[{"imported": "NomicEmbeddings", "source": "langchain_nomic", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_nomic.embeddings.NomicEmbeddings.html", "title": "Nomic"}]-->
from langchain_nomic import NomicEmbeddings
```
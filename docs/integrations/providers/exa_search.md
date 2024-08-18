---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/exa_search.ipynb
description: Exa의 검색 통합은 파트너 패키지로 제공되며, API 키 설정 및 검색 리트리버 사용 방법을 안내합니다.
---

# Exa 검색

Exa의 검색 통합은 자체 [파트너 패키지](https://pypi.org/project/langchain-exa/)에 존재합니다. 다음과 같이 설치할 수 있습니다:

```python
%pip install -qU langchain-exa
```


패키지를 사용하려면 `EXA_API_KEY` 환경 변수를 Exa API 키로 설정해야 합니다.

## 검색기

표준 검색 파이프라인에서 [`ExaSearchRetriever`](/docs/integrations/tools/exa_search#using-exasearchretriever)를 사용할 수 있습니다. 다음과 같이 가져올 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ExaSearchRetriever", "source": "langchain_exa", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_exa.retrievers.ExaSearchRetriever.html", "title": "Exa Search"}]-->
from langchain_exa import ExaSearchRetriever
```


## 도구

[Exa 도구 호출 문서](/docs/integrations/tools/exa_search#using-the-exa-sdk-as-langchain-agent-tools)에서 설명한 대로 Exa를 에이전트 도구로 사용할 수 있습니다.
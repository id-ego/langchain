---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/vespa.ipynb
description: Vespa는 벡터 검색, 어휘 검색 및 구조화된 데이터 검색을 지원하는 완전한 기능의 검색 엔진이자 벡터 데이터베이스입니다.
---

# 베스파

> [Vespa](https://vespa.ai/)는 완전한 기능을 갖춘 검색 엔진 및 벡터 데이터베이스입니다. 벡터 검색(ANN), 어휘 검색 및 구조화된 데이터 검색을 모두 동일한 쿼리에서 지원합니다.

이 노트북은 `Vespa.ai`를 LangChain 검색자로 사용하는 방법을 보여줍니다.

검색자를 생성하기 위해 [pyvespa](https://pyvespa.readthedocs.io/en/latest/index.html)를 사용하여 `Vespa` 서비스에 연결을 생성합니다.

```python
%pip install --upgrade --quiet  pyvespa
```


```python
from vespa.application import Vespa

vespa_app = Vespa(url="https://doc-search.vespa.oath.cloud")
```


이것은 `Vespa` 서비스에 대한 연결을 생성하며, 여기서는 Vespa 문서 검색 서비스입니다. `pyvespa` 패키지를 사용하면
[Vespa Cloud 인스턴스](https://pyvespa.readthedocs.io/en/latest/deploy-vespa-cloud.html) 또는 로컬
[Docker 인스턴스](https://pyvespa.readthedocs.io/en/latest/deploy-docker.html)에 연결할 수도 있습니다.

서비스에 연결한 후, 검색자를 설정할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "VespaRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.vespa_retriever.VespaRetriever.html", "title": "Vespa"}]-->
from langchain_community.retrievers import VespaRetriever

vespa_query_body = {
    "yql": "select content from paragraph where userQuery()",
    "hits": 5,
    "ranking": "documentation",
    "locale": "en-us",
}
vespa_content_field = "content"
retriever = VespaRetriever(vespa_app, vespa_query_body, vespa_content_field)
```


이것은 Vespa 애플리케이션에서 문서를 가져오는 LangChain 검색자를 설정합니다. 여기서는 `paragraph` 문서 유형의 `content` 필드에서 최대 5개의 결과를 검색하며, `documentation`을 순위 매기는 방법으로 사용합니다. `userQuery()`는 LangChain에서 전달된 실제 쿼리로 대체됩니다.

자세한 내용은 [pyvespa 문서](https://pyvespa.readthedocs.io/en/latest/getting-started-pyvespa.html#Query)를 참조하십시오.

이제 결과를 반환하고 LangChain에서 결과를 계속 사용할 수 있습니다.

```python
retriever.invoke("what is vespa?")
```


## 관련

- 검색자 [개념 가이드](/docs/concepts/#retrievers)
- 검색자 [사용 방법 가이드](/docs/how_to/#retrievers)
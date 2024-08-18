---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/stripe.ipynb
description: 이 문서는 Stripe REST API에서 데이터를 로드하여 LangChain에 적합한 형식으로 변환하는 방법과 벡터화 예제를
  다룹니다.
---

# Stripe

> [Stripe](https://stripe.com/en-ca)는 아일랜드-미국의 금융 서비스 및 소프트웨어 서비스(SaaS) 회사입니다. 전자 상거래 웹사이트 및 모바일 애플리케이션을 위한 결제 처리 소프트웨어와 애플리케이션 프로그래밍 인터페이스를 제공합니다.

이 노트북은 `Stripe REST API`에서 데이터를 로드하여 LangChain에 적합한 형식으로 변환하는 방법과 벡터화에 대한 예제 사용법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "VectorstoreIndexCreator", "source": "langchain.indexes", "docs": "https://api.python.langchain.com/en/latest/indexes/langchain.indexes.vectorstore.VectorstoreIndexCreator.html", "title": "Stripe"}, {"imported": "StripeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.stripe.StripeLoader.html", "title": "Stripe"}]-->
from langchain.indexes import VectorstoreIndexCreator
from langchain_community.document_loaders import StripeLoader
```


Stripe API는 액세스 토큰을 요구하며, 이는 Stripe 대시보드 내에서 찾을 수 있습니다.

이 문서 로더는 로드할 데이터를 정의하는 `resource` 옵션도 필요합니다.

다음 리소스를 사용할 수 있습니다:

`balance_transations` [문서](https://stripe.com/docs/api/balance_transactions/list)

`charges` [문서](https://stripe.com/docs/api/charges/list)

`customers` [문서](https://stripe.com/docs/api/customers/list)

`events` [문서](https://stripe.com/docs/api/events/list)

`refunds` [문서](https://stripe.com/docs/api/refunds/list)

`disputes` [문서](https://stripe.com/docs/api/disputes/list)

```python
stripe_loader = StripeLoader("charges")
```


```python
# Create a vectorstore retriever from the loader
# see https://python.langchain.com/en/latest/modules/data_connection/getting_started.html for more details

index = VectorstoreIndexCreator().from_loaders([stripe_loader])
stripe_doc_retriever = index.vectorstore.as_retriever()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
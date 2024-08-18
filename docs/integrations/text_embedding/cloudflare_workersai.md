---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/cloudflare_workersai.ipynb
description: Cloudflare Workers AI를 사용하여 Cloudflare 네트워크에서 REST API를 통해 머신러닝 모델을 실행하는
  방법을 안내합니다.
---

# Cloudflare Workers AI

> [Cloudflare, Inc. (위키백과)](https://en.wikipedia.org/wiki/Cloudflare)은 콘텐츠 전송 네트워크 서비스, 클라우드 사이버 보안, DDoS 완화 및 ICANN 인증 도메인 등록 서비스를 제공하는 미국 회사입니다.

> [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/)는 코드에서 REST API를 통해 `Cloudflare` 네트워크에서 머신 러닝 모델을 실행할 수 있게 해줍니다.

> [Cloudflare AI 문서](https://developers.cloudflare.com/workers-ai/models/text-embeddings/)에는 사용 가능한 모든 텍스트 임베딩 모델이 나열되어 있습니다.

## 설정

Cloudflare 계정 ID와 API 토큰이 필요합니다. 이들을 얻는 방법은 [이 문서](https://developers.cloudflare.com/workers-ai/get-started/rest-api/)에서 확인하세요.

```python
import getpass

my_account_id = getpass.getpass("Enter your Cloudflare account ID:\n\n")
my_api_token = getpass.getpass("Enter your Cloudflare API token:\n\n")
```


## 예시

```python
<!--IMPORTS:[{"imported": "CloudflareWorkersAIEmbeddings", "source": "langchain_community.embeddings.cloudflare_workersai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.cloudflare_workersai.CloudflareWorkersAIEmbeddings.html", "title": "Cloudflare Workers AI"}]-->
from langchain_community.embeddings.cloudflare_workersai import (
    CloudflareWorkersAIEmbeddings,
)
```


```python
embeddings = CloudflareWorkersAIEmbeddings(
    account_id=my_account_id,
    api_token=my_api_token,
    model_name="@cf/baai/bge-small-en-v1.5",
)
# single string embeddings
query_result = embeddings.embed_query("test")
len(query_result), query_result[:3]
```


```output
(384, [-0.033627357333898544, 0.03982774540781975, 0.03559349477291107])
```


```python
# string embeddings in batches
batch_query_result = embeddings.embed_documents(["test1", "test2", "test3"])
len(batch_query_result), len(batch_query_result[0])
```


```output
(3, 384)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
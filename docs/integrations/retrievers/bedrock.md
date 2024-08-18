---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/bedrock.ipynb
description: AWS Knowledge Bases를 사용하여 RAG 애플리케이션을 쉽게 구축하고, Amazon S3의 데이터를 벡터 데이터베이스로
  자동으로 처리합니다.
sidebar_label: Bedrock (Knowledge Bases)
---

# Bedrock (지식 베이스) 검색기

이 가이드는 AWS 지식 베이스 [검색기](/docs/concepts/#retrievers)를 시작하는 데 도움을 줄 것입니다.

[Amazon Bedrock을 위한 지식 베이스](https://aws.amazon.com/bedrock/knowledge-bases/)는 개인 데이터를 사용하여 FM 응답을 사용자화하여 RAG 애플리케이션을 신속하게 구축할 수 있게 해주는 Amazon Web Services (AWS) 제공 서비스입니다.

`RAG`를 구현하려면 조직이 데이터를 임베딩(벡터)으로 변환하고, 임베딩을 전문 벡터 데이터베이스에 저장하며, 사용자 쿼리와 관련된 텍스트를 검색하고 검색하기 위해 데이터베이스에 맞춤형 통합을 구축하는 여러 번거로운 단계를 수행해야 합니다. 이는 시간 소모적이고 비효율적일 수 있습니다.

`Amazon Bedrock을 위한 지식 베이스`를 사용하면 `Amazon S3`에 있는 데이터의 위치를 간단히 지정하면 `Amazon Bedrock을 위한 지식 베이스`가 벡터 데이터베이스로의 전체 수집 워크플로를 처리합니다. 기존 벡터 데이터베이스가 없는 경우 Amazon Bedrock이 Amazon OpenSearch Serverless 벡터 저장소를 생성합니다. 검색을 위해 Langchain - Amazon Bedrock 통합을 Retrieve API를 통해 사용하여 지식 베이스에서 사용자 쿼리에 대한 관련 결과를 검색합니다.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="document_retrievers" item="AmazonKnowledgeBasesRetriever" />


## 설정

지식 베이스는 [AWS 콘솔](https://aws.amazon.com/console/) 또는 [AWS SDK](https://aws.amazon.com/developer/tools/)를 사용하여 구성할 수 있습니다. 검색기를 인스턴스화하려면 `knowledge_base_id`가 필요합니다.

개별 쿼리에서 자동 추적을 받고 싶다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 검색기는 `langchain-aws` 패키지에 포함되어 있습니다:

```python
%pip install -qU langchain-aws
```


## 인스턴스화

이제 검색기를 인스턴스화할 수 있습니다:

```python
from langchain_aws.retrievers import AmazonKnowledgeBasesRetriever

retriever = AmazonKnowledgeBasesRetriever(
    knowledge_base_id="PUIJP4EQUA",
    retrieval_config={"vectorSearchConfiguration": {"numberOfResults": 4}},
)
```


## 사용법

```python
query = "What did the president say about Ketanji Brown?"

retriever.invoke(query)
```


## 체인 내에서 사용

```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Bedrock (Knowledge Bases) Retriever"}]-->
from botocore.client import Config
from langchain.chains import RetrievalQA
from langchain_aws import Bedrock

model_kwargs_claude = {"temperature": 0, "top_k": 10, "max_tokens_to_sample": 3000}

llm = Bedrock(model_id="anthropic.claude-v2", model_kwargs=model_kwargs_claude)

qa = RetrievalQA.from_chain_type(
    llm=llm, retriever=retriever, return_source_documents=True
)

qa(query)
```


## API 참조

모든 `AmazonKnowledgeBasesRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_aws.retrievers.bedrock.AmazonKnowledgeBasesRetriever.html)에서 확인하세요.

## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
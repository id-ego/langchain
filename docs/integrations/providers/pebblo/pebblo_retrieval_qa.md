---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/pebblo/pebblo_retrieval_qa.ipynb
description: 이 문서는 PebbloRetrievalQA를 사용하여 벡터 데이터베이스에서 질문-답변을 위한 문서 검색 방법을 다룹니다.
---

# 신원 기반 RAG 사용하기 PebbloRetrievalQA

> PebbloRetrievalQA는 벡터 데이터베이스에 대한 질문-응답을 위한 신원 및 의미 강화를 갖춘 검색 체인입니다.

이 노트북에서는 신원 및 의미 강화를 사용하여 문서를 검색하는 방법(Deny Topics/Entities)을 다룹니다. Pebblo 및 SafeRetriever 기능에 대한 자세한 내용은 [Pebblo 문서](https://daxa-ai.github.io/pebblo/retrieval_chain/)를 방문하세요.

### 단계:

1. **문서 로딩:**
우리는 권한 및 의미 메타데이터와 함께 문서를 메모리 내 Qdrant 벡터 저장소에 로드할 것입니다. 이 벡터 저장소는 PebbloRetrievalQA에서 검색기로 사용됩니다.

> **참고:** 인증 및 의미 메타데이터와 함께 문서를 로드하기 위해 [PebbloSafeLoader](https://daxa-ai.github.io/pebblo/rag)를 사용하는 것이 권장됩니다. `PebbloSafeLoader`는 메타데이터의 무결성을 유지하면서 문서를 안전하고 효율적으로 로드하는 것을 보장합니다.

2. **강제 메커니즘 테스트:**
우리는 신원 및 의미 강제를 별도로 테스트할 것입니다. 각 사용 사례에 대해 필요한 컨텍스트(*auth_context* 및 *semantic_context*)와 함께 특정 "질문" 함수를 정의한 다음 질문을 제기합니다.

## 설정

### 종속성

이번 워크스루에서는 OpenAI LLM, OpenAI 임베딩 및 Qdrant 벡터 저장소를 사용할 것입니다.

```python
%pip install --upgrade --quiet langchain langchain_core langchain-community langchain-openai qdrant_client
```


### 신원 인식 데이터 수집

여기에서는 Qdrant를 벡터 데이터베이스로 사용하고 있지만, 지원되는 벡터 데이터베이스 중 어떤 것이든 사용할 수 있습니다.

**PebbloRetrievalQA 체인은 다음 벡터 데이터베이스를 지원합니다:**
- Qdrant
- Pinecone
- Postgres( pgvector 확장 사용)

**권한 및 의미 정보를 메타데이터에 포함하여 벡터 데이터베이스 로드:**

이 단계에서는 각 청크에 대한 VectorDB 항목의 메타데이터 내에서 소스 문서의 권한 및 의미 정보를 `authorized_identities`, `pebblo_semantic_topics`, 및 `pebblo_semantic_entities` 필드에 캡처합니다.

*참고: PebbloRetrievalQA 체인을 사용하려면 항상 지정된 필드에 권한 및 의미 메타데이터를 배치해야 합니다. 이 필드는 문자열 목록을 포함해야 합니다.*

```python
<!--IMPORTS:[{"imported": "Qdrant", "source": "langchain_community.vectorstores.qdrant", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.qdrant.Qdrant.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "OpenAI", "source": "langchain_openai.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}]-->
from langchain_community.vectorstores.qdrant import Qdrant
from langchain_core.documents import Document
from langchain_openai.embeddings import OpenAIEmbeddings
from langchain_openai.llms import OpenAI

llm = OpenAI()
embeddings = OpenAIEmbeddings()
collection_name = "pebblo-identity-and-semantic-rag"

page_content = """
**ACME Corp Financial Report**

**Overview:**
ACME Corp, a leading player in the merger and acquisition industry, presents its financial report for the fiscal year ending December 31, 2020. 
Despite a challenging economic landscape, ACME Corp demonstrated robust performance and strategic growth.

**Financial Highlights:**
Revenue soared to $50 million, marking a 15% increase from the previous year, driven by successful deal closures and expansion into new markets. 
Net profit reached $12 million, showcasing a healthy margin of 24%.

**Key Metrics:**
Total assets surged to $80 million, reflecting a 20% growth, highlighting ACME Corp's strong financial position and asset base. 
Additionally, the company maintained a conservative debt-to-equity ratio of 0.5, ensuring sustainable financial stability.

**Future Outlook:**
ACME Corp remains optimistic about the future, with plans to capitalize on emerging opportunities in the global M&A landscape. 
The company is committed to delivering value to shareholders while maintaining ethical business practices.

**Bank Account Details:**
For inquiries or transactions, please refer to ACME Corp's US bank account:
Account Number: 123456789012
Bank Name: Fictitious Bank of America
"""

documents = [
    Document(
        **{
            "page_content": page_content,
            "metadata": {
                "pebblo_semantic_topics": ["financial-report"],
                "pebblo_semantic_entities": ["us-bank-account-number"],
                "authorized_identities": ["finance-team", "exec-leadership"],
                "page": 0,
                "source": "https://drive.google.com/file/d/xxxxxxxxxxxxx/view",
                "title": "ACME Corp Financial Report.pdf",
            },
        }
    )
]

vectordb = Qdrant.from_documents(
    documents,
    embeddings,
    location=":memory:",
    collection_name=collection_name,
)

print("Vectordb loaded.")
```

```output
Vectordb loaded.
```

## 신원 강제를 통한 검색

PebbloRetrievalQA 체인은 SafeRetrieval을 사용하여 컨텍스트에 사용되는 스니펫이 사용자에게 권한이 부여된 문서에서만 검색되도록 강제합니다. 이를 위해 Gen-AI 애플리케이션은 이 검색 체인을 위한 권한 컨텍스트를 제공해야 합니다. 이 *auth_context*는 Gen-AI 앱에 접근하는 사용자의 신원 및 권한 그룹으로 채워져야 합니다.

다음은 RAG 애플리케이션에 접근하는 사용자로부터 `user_auth`(사용자 ID 및 그들이 속한 그룹을 포함할 수 있는 사용자 권한 목록)를 전달받아 `PebbloRetrievalQA`의 샘플 코드입니다.

```python
<!--IMPORTS:[{"imported": "PebbloRetrievalQA", "source": "langchain_community.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.pebblo_retrieval.base.PebbloRetrievalQA.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "AuthContext", "source": "langchain_community.chains.pebblo_retrieval.models", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.pebblo_retrieval.models.AuthContext.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "ChainInput", "source": "langchain_community.chains.pebblo_retrieval.models", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.pebblo_retrieval.models.ChainInput.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}]-->
from langchain_community.chains import PebbloRetrievalQA
from langchain_community.chains.pebblo_retrieval.models import AuthContext, ChainInput

# Initialize PebbloRetrievalQA chain
qa_chain = PebbloRetrievalQA.from_chain_type(
    llm=llm,
    retriever=vectordb.as_retriever(),
    app_name="pebblo-identity-rag",
    description="Identity Enforcement app using PebbloRetrievalQA",
    owner="ACME Corp",
)


def ask(question: str, auth_context: dict):
    """
    Ask a question to the PebbloRetrievalQA chain
    """
    auth_context_obj = AuthContext(**auth_context) if auth_context else None
    chain_input_obj = ChainInput(query=question, auth_context=auth_context_obj)
    return qa_chain.invoke(chain_input_obj.dict())
```


### 1. 권한이 있는 사용자의 질문

우리는 권한이 있는 신원 `["finance-team", "exec-leadership"]`에 대한 데이터를 수집했으므로, 권한이 있는 신원/그룹 `finance-team`을 가진 사용자는 올바른 답변을 받아야 합니다.

```python
auth = {
    "user_id": "finance-user@acme.org",
    "user_auth": [
        "finance-team",
    ],
}

question = "Share the financial performance of ACME Corp for the year 2020"
resp = ask(question, auth)
print(f"Question: {question}\n\nAnswer: {resp['result']}")
```

```output
Question: Share the financial performance of ACME Corp for the year 2020

Answer: 
Revenue: $50 million (15% increase from previous year)
Net profit: $12 million (24% margin)
Total assets: $80 million (20% growth)
Debt-to-equity ratio: 0.5
```

### 2. 권한이 없는 사용자의 질문

사용자의 권한 신원/그룹 `eng-support`가 권한이 있는 신원 `["finance-team", "exec-leadership"]`에 포함되지 않으므로, 우리는 답변을 받지 않아야 합니다.

```python
auth = {
    "user_id": "eng-user@acme.org",
    "user_auth": [
        "eng-support",
    ],
}

question = "Share the financial performance of ACME Corp for the year 2020"
resp = ask(question, auth)
print(f"Question: {question}\n\nAnswer: {resp['result']}")
```

```output
Question: Share the financial performance of ACME Corp for the year 2020

Answer:  I don't know.
```

### 3. 추가 지침 제공을 위한 PromptTemplate 사용
PromptTemplate을 사용하여 LLM에 맞춤형 응답 생성을 위한 추가 지침을 제공할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}]-->
from langchain_core.prompts import PromptTemplate

prompt_template = PromptTemplate.from_template(
    """
Answer the question using the provided context. 
If no context is provided, just say "I'm sorry, but that information is unavailable, or Access to it is restricted.".

Question: {question}
"""
)

question = "Share the financial performance of ACME Corp for the year 2020"
prompt = prompt_template.format(question=question)
```


#### 3.1 권한이 있는 사용자의 질문

```python
auth = {
    "user_id": "finance-user@acme.org",
    "user_auth": [
        "finance-team",
    ],
}
resp = ask(prompt, auth)
print(f"Question: {question}\n\nAnswer: {resp['result']}")
```

```output
Question: Share the financial performance of ACME Corp for the year 2020

Answer: 
Revenue soared to $50 million, marking a 15% increase from the previous year, and net profit reached $12 million, showcasing a healthy margin of 24%. Total assets also grew by 20% to $80 million, and the company maintained a conservative debt-to-equity ratio of 0.5.
```

#### 3.2 권한이 없는 사용자의 질문

```python
auth = {
    "user_id": "eng-user@acme.org",
    "user_auth": [
        "eng-support",
    ],
}
resp = ask(prompt, auth)
print(f"Question: {question}\n\nAnswer: {resp['result']}")
```

```output
Question: Share the financial performance of ACME Corp for the year 2020

Answer: 
I'm sorry, but that information is unavailable, or Access to it is restricted.
```

## 의미 강제를 통한 검색

PebbloRetrievalQA 체인은 SafeRetrieval을 사용하여 컨텍스트에 사용되는 스니펫이 제공된 의미 컨텍스트를 준수하는 문서에서만 검색되도록 보장합니다. 이를 위해 Gen-AI 애플리케이션은 이 검색 체인을 위한 의미 컨텍스트를 제공해야 합니다. 이 `semantic_context`는 Gen-AI 앱에 접근하는 사용자가 거부해야 하는 주제 및 엔티티를 포함해야 합니다.

아래는 `topics_to_deny` 및 `entities_to_deny`와 함께 PebbloRetrievalQA의 샘플 코드입니다. 이들은 체인 입력에 `semantic_context`로 전달됩니다.

```python
<!--IMPORTS:[{"imported": "PebbloRetrievalQA", "source": "langchain_community.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.pebblo_retrieval.base.PebbloRetrievalQA.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "ChainInput", "source": "langchain_community.chains.pebblo_retrieval.models", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.pebblo_retrieval.models.ChainInput.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}, {"imported": "SemanticContext", "source": "langchain_community.chains.pebblo_retrieval.models", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.pebblo_retrieval.models.SemanticContext.html", "title": "Identity-enabled RAG using PebbloRetrievalQA"}]-->
from typing import List, Optional

from langchain_community.chains import PebbloRetrievalQA
from langchain_community.chains.pebblo_retrieval.models import (
    ChainInput,
    SemanticContext,
)

# Initialize PebbloRetrievalQA chain
qa_chain = PebbloRetrievalQA.from_chain_type(
    llm=llm,
    retriever=vectordb.as_retriever(),
    app_name="pebblo-semantic-rag",
    description="Semantic Enforcement app using PebbloRetrievalQA",
    owner="ACME Corp",
)


def ask(
    question: str,
    topics_to_deny: Optional[List[str]] = None,
    entities_to_deny: Optional[List[str]] = None,
):
    """
    Ask a question to the PebbloRetrievalQA chain
    """
    semantic_context = dict()
    if topics_to_deny:
        semantic_context["pebblo_semantic_topics"] = {"deny": topics_to_deny}
    if entities_to_deny:
        semantic_context["pebblo_semantic_entities"] = {"deny": entities_to_deny}

    semantic_context_obj = (
        SemanticContext(**semantic_context) if semantic_context else None
    )
    chain_input_obj = ChainInput(query=question, semantic_context=semantic_context_obj)
    return qa_chain.invoke(chain_input_obj.dict())
```


### 1. 의미 강제가 없는 경우

의미 강제가 적용되지 않으므로, 시스템은 의미 레이블과 관련된 컨텍스트로 인해 어떤 컨텍스트도 제외하지 않고 답변을 반환해야 합니다.

```python
topic_to_deny = []
entities_to_deny = []
question = "Share the financial performance of ACME Corp for the year 2020"
resp = ask(question, topics_to_deny=topic_to_deny, entities_to_deny=entities_to_deny)
print(
    f"Topics to deny: {topic_to_deny}\nEntities to deny: {entities_to_deny}\n"
    f"Question: {question}\nAnswer: {resp['result']}"
)
```

```output
Topics to deny: []
Entities to deny: []
Question: Share the financial performance of ACME Corp for the year 2020
Answer: 
Revenue for ACME Corp increased by 15% to $50 million in 2020, with a net profit of $12 million and a strong asset base of $80 million. The company also maintained a conservative debt-to-equity ratio of 0.5.
```

### 2. 재무 보고 주제 거부

데이터는 주제 `["financial-report"]`와 함께 수집되었습니다. 따라서 `financial-report` 주제를 거부하는 앱은 답변을 받지 않아야 합니다.

```python
topic_to_deny = ["financial-report"]
entities_to_deny = []
question = "Share the financial performance of ACME Corp for the year 2020"
resp = ask(question, topics_to_deny=topic_to_deny, entities_to_deny=entities_to_deny)
print(
    f"Topics to deny: {topic_to_deny}\nEntities to deny: {entities_to_deny}\n"
    f"Question: {question}\nAnswer: {resp['result']}"
)
```

```output
Topics to deny: ['financial-report']
Entities to deny: []
Question: Share the financial performance of ACME Corp for the year 2020
Answer: 

Unfortunately, I do not have access to the financial performance of ACME Corp for the year 2020.
```

### 3. 미국 은행 계좌 번호 엔티티 거부
엔티티 `us-bank-account-number`가 거부되었으므로, 시스템은 답변을 반환하지 않아야 합니다.

```python
topic_to_deny = []
entities_to_deny = ["us-bank-account-number"]
question = "Share the financial performance of ACME Corp for the year 2020"
resp = ask(question, topics_to_deny=topic_to_deny, entities_to_deny=entities_to_deny)
print(
    f"Topics to deny: {topic_to_deny}\nEntities to deny: {entities_to_deny}\n"
    f"Question: {question}\nAnswer: {resp['result']}"
)
```

```output
Topics to deny: []
Entities to deny: ['us-bank-account-number']
Question: Share the financial performance of ACME Corp for the year 2020
Answer:  I don't have information about ACME Corp's financial performance for 2020.
```
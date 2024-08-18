---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/oracleai.ipynb
description: Oracle AI 벡터 검색은 비즈니스 데이터와 비구조적 데이터를 결합하여 의미 기반 쿼리를 지원하는 강력한 AI 워크로드
  솔루션입니다.
---

# 오라클 AI 벡터 검색: 임베딩 생성
오라클 AI 벡터 검색은 키워드가 아닌 의미에 기반하여 데이터를 쿼리할 수 있도록 설계된 인공지능(AI) 워크로드를 위한 시스템입니다.  
오라클 AI 벡터 검색의 가장 큰 장점 중 하나는 비구조적 데이터에 대한 의미 검색을 비즈니스 데이터에 대한 관계형 검색과 하나의 시스템에서 결합할 수 있다는 것입니다.  
이는 강력할 뿐만 아니라 여러 시스템 간의 데이터 단편화 문제를 없애주기 때문에 훨씬 더 효과적입니다.

또한, 귀하의 벡터는 다음과 같은 오라클 데이터베이스의 가장 강력한 기능을 활용할 수 있습니다:

* [파티셔닝 지원](https://www.oracle.com/database/technologies/partitioning.html)
* [실제 애플리케이션 클러스터 확장성](https://www.oracle.com/database/real-application-clusters/)
* [엑사데이터 스마트 스캔](https://www.oracle.com/database/technologies/exadata/software/smartscan/)
* [지리적으로 분산된 데이터베이스 간 샤드 처리](https://www.oracle.com/database/distributed-database/)
* [트랜잭션](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/transactions.html)
* [병렬 SQL](https://docs.oracle.com/en/database/oracle/oracle-database/21/vldbg/parallel-exec-intro.html#GUID-D28717E4-0F77-44F5-BB4E-234C31D4E4BA)
* [재해 복구](https://www.oracle.com/database/data-guard/)
* [보안](https://www.oracle.com/security/database-security/)
* [오라클 머신 러닝](https://www.oracle.com/artificial-intelligence/database-machine-learning/)
* [오라클 그래프 데이터베이스](https://www.oracle.com/database/integrated-graph-database/)
* [오라클 공간 및 그래프](https://www.oracle.com/database/spatial/)
* [오라클 블록체인](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html#GUID-B469E277-978E-4378-A8C1-26D3FF96C9A6)
* [JSON](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/json-in-oracle-database.html)

이 가이드는 오라클 임베딩을 사용하여 문서에 대한 임베딩을 생성하는 방법을 보여줍니다.

오라클 데이터베이스를 처음 시작하는 경우, 데이터베이스 환경 설정에 대한 훌륭한 소개를 제공하는 [무료 오라클 23 AI](https://www.oracle.com/database/free/#resources)를 탐색하는 것을 고려해 보십시오. 데이터베이스 작업 시 기본적으로 시스템 사용자를 사용하지 않는 것이 좋습니다. 대신 보안 및 사용자 정의를 강화하기 위해 자신의 사용자를 생성할 수 있습니다. 사용자 생성에 대한 자세한 단계는 오라클에서 사용자를 설정하는 방법도 보여주는 [종합 가이드](https://github.com/langchain-ai/langchain/blob/master/cookbook/oracleai_demo.ipynb)를 참조하십시오. 또한 사용자 권한을 이해하는 것은 데이터베이스 보안을 효과적으로 관리하는 데 중요합니다. 이 주제에 대한 자세한 내용은 사용자 계정 및 보안 관리에 대한 공식 [오라클 가이드](https://docs.oracle.com/en/database/oracle/oracle-database/19/admqs/administering-user-accounts-and-security.html#GUID-36B21D72-1BBB-46C9-A0C9-F0D2A8591B8D)를 참조하십시오.

### 필수 조건

Langchain과 오라클 AI 벡터 검색의 통합을 용이하게 하기 위해 오라클 파이썬 클라이언트 드라이버가 설치되어 있는지 확인하십시오.

```python
# pip install oracledb
```


### 오라클 데이터베이스에 연결
다음 샘플 코드는 오라클 데이터베이스에 연결하는 방법을 보여줍니다. 기본적으로 python-oracledb는 오라클 데이터베이스에 직접 연결하는 'Thin' 모드에서 실행됩니다. 이 모드는 오라클 클라이언트 라이브러리가 필요하지 않습니다. 그러나 python-oracledb가 이를 사용할 때 추가 기능이 제공됩니다. 오라클 클라이언트 라이브러리가 사용될 때 python-oracledb는 'Thick' 모드에 있다고 합니다. 두 모드 모두 Python 데이터베이스 API v2.0 사양을 지원하는 포괄적인 기능을 가지고 있습니다. 각 모드에서 지원되는 기능에 대해 설명하는 [가이드](https://python-oracledb.readthedocs.io/en/latest/user_guide/appendix_a.html#featuresummary)를 참조하십시오. 얇은 모드를 사용할 수 없는 경우 두꺼운 모드로 전환하는 것이 좋습니다.

```python
import sys

import oracledb

# Update the following variables with your Oracle database credentials and connection details
username = "<username>"
password = "<password>"
dsn = "<hostname>/<service_name>"

try:
    conn = oracledb.connect(user=username, password=password, dsn=dsn)
    print("Connection successful!")
except Exception as e:
    print("Connection failed!")
    sys.exit(1)
```


임베딩 생성을 위해 여러 공급자 옵션이 사용자에게 제공되며, 데이터베이스 내에서의 임베딩 생성 및 OcigenAI, Hugging Face, OpenAI와 같은 제3자 서비스가 포함됩니다. 제3자 공급자를 선택하는 사용자는 필수 인증 정보를 포함하는 자격 증명을 설정해야 합니다. 또는 사용자가 공급자로 '데이터베이스'를 선택하는 경우, 임베딩을 용이하게 하기 위해 ONNX 모델을 오라클 데이터베이스에 로드해야 합니다.

### ONNX 모델 로드

오라클은 다양한 임베딩 공급자를 수용하여 사용자가 독점 데이터베이스 솔루션과 OCIGENAI 및 HuggingFace와 같은 제3자 서비스 간에 선택할 수 있도록 합니다. 이 선택은 임베딩 생성 및 관리 방법론을 결정합니다.

***중요***: 사용자가 데이터베이스 옵션을 선택하는 경우, ONNX 모델을 오라클 데이터베이스에 업로드해야 합니다. 반대로, 임베딩 생성을 위해 제3자 공급자를 선택하는 경우, 오라클 데이터베이스에 ONNX 모델을 업로드할 필요가 없습니다.

오라클 내에서 ONNX 모델을 직접 활용하는 주요 이점은 외부 당사자에게 데이터를 전송할 필요가 없어 보안성과 성능이 향상된다는 것입니다. 또한 이 방법은 일반적으로 네트워크 또는 REST API 호출과 관련된 지연 시간을 피할 수 있습니다.

아래는 오라클 데이터베이스에 ONNX 모델을 업로드하는 예제 코드입니다:

```python
<!--IMPORTS:[{"imported": "OracleEmbeddings", "source": "langchain_community.embeddings.oracleai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.oracleai.OracleEmbeddings.html", "title": "Oracle AI Vector Search: Generate Embeddings"}]-->
from langchain_community.embeddings.oracleai import OracleEmbeddings

# Update the directory and file names for your ONNX model
# make sure that you have onnx file in the system
onnx_dir = "DEMO_DIR"
onnx_file = "tinybert.onnx"
model_name = "demo_model"

try:
    OracleEmbeddings.load_onnx_model(conn, onnx_dir, onnx_file, model_name)
    print("ONNX model loaded.")
except Exception as e:
    print("ONNX model loading failed!")
    sys.exit(1)
```


### 자격 증명 생성

임베딩 생성을 위해 제3자 공급자를 선택할 때, 사용자는 공급자의 엔드포인트에 안전하게 접근하기 위해 자격 증명을 설정해야 합니다.

***중요:*** '데이터베이스' 공급자를 선택하여 임베딩을 생성할 때는 자격 증명이 필요하지 않습니다. 그러나 사용자가 제3자 공급자를 이용하기로 결정하면 선택한 공급자에 특정한 자격 증명을 생성해야 합니다.

아래는 설명적인 예입니다:

```python
try:
    cursor = conn.cursor()
    cursor.execute(
        """
       declare
           jo json_object_t;
       begin
           -- HuggingFace
           dbms_vector_chain.drop_credential(credential_name  => 'HF_CRED');
           jo := json_object_t();
           jo.put('access_token', '<access_token>');
           dbms_vector_chain.create_credential(
               credential_name   =>  'HF_CRED',
               params            => json(jo.to_string));

           -- OCIGENAI
           dbms_vector_chain.drop_credential(credential_name  => 'OCI_CRED');
           jo := json_object_t();
           jo.put('user_ocid','<user_ocid>');
           jo.put('tenancy_ocid','<tenancy_ocid>');
           jo.put('compartment_ocid','<compartment_ocid>');
           jo.put('private_key','<private_key>');
           jo.put('fingerprint','<fingerprint>');
           dbms_vector_chain.create_credential(
               credential_name   => 'OCI_CRED',
               params            => json(jo.to_string));
       end;
       """
    )
    cursor.close()
    print("Credentials created.")
except Exception as ex:
    cursor.close()
    raise
```


### 임베딩 생성

오라클 AI 벡터 검색은 로컬 호스팅된 ONNX 모델 또는 제3자 API를 활용하여 임베딩을 생성하는 여러 방법을 제공합니다. 이러한 대안 구성에 대한 포괄적인 지침은 [오라클 AI 벡터 검색 가이드](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_vector_chain1.html#GUID-C6439E94-4E86-4ECD-954E-4B73D53579DE)를 참조하십시오.

***참고:*** 사용자는 ONNX 모델을 사용하는 '데이터베이스' 공급자를 제외하고 제3자 임베딩 생성 공급자를 활용하기 위해 프록시를 구성해야 할 수 있습니다.

다음 샘플 코드는 임베딩을 생성하는 방법을 보여줍니다:

```python
<!--IMPORTS:[{"imported": "OracleEmbeddings", "source": "langchain_community.embeddings.oracleai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.oracleai.OracleEmbeddings.html", "title": "Oracle AI Vector Search: Generate Embeddings"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Oracle AI Vector Search: Generate Embeddings"}]-->
from langchain_community.embeddings.oracleai import OracleEmbeddings
from langchain_core.documents import Document

"""
# using ocigenai
embedder_params = {
    "provider": "ocigenai",
    "credential_name": "OCI_CRED",
    "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
    "model": "cohere.embed-english-light-v3.0",
}

# using huggingface
embedder_params = {
    "provider": "huggingface", 
    "credential_name": "HF_CRED", 
    "url": "https://api-inference.huggingface.co/pipeline/feature-extraction/", 
    "model": "sentence-transformers/all-MiniLM-L6-v2", 
    "wait_for_model": "true"
}
"""

# using ONNX model loaded to Oracle Database
embedder_params = {"provider": "database", "model": "demo_model"}

# If a proxy is not required for your environment, you can omit the 'proxy' parameter below
embedder = OracleEmbeddings(conn=conn, params=embedder_params, proxy=proxy)
embed = embedder.embed_query("Hello World!")

""" verify """
print(f"Embedding generated by OracleEmbeddings: {embed}")
```


### 엔드 투 엔드 데모
오라클 AI 벡터 검색의 도움으로 엔드 투 엔드 RAG 파이프라인을 구축하기 위해 [오라클 AI 벡터 검색 엔드 투 엔드 데모 가이드](https://github.com/langchain-ai/langchain/tree/master/cookbook/oracleai_demo.ipynb)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/oracleai.ipynb
description: Oracle AI 벡터 검색은 비즈니스 데이터와 비구조적 데이터를 통합하여 의미 기반 쿼리를 지원하는 강력한 AI 솔루션입니다.
---

# 오라클 AI 벡터 검색: 요약 생성

오라클 AI 벡터 검색은 키워드가 아닌 의미에 기반하여 데이터를 쿼리할 수 있는 인공지능(AI) 작업을 위해 설계되었습니다.  
오라클 AI 벡터 검색의 가장 큰 장점 중 하나는 비구조화된 데이터에 대한 의미 검색을 비즈니스 데이터에 대한 관계형 검색과 하나의 시스템에서 결합할 수 있다는 것입니다.  
이는 강력할 뿐만 아니라 여러 시스템 간의 데이터 단편화 문제를 없애줌으로써 훨씬 더 효과적입니다.

또한, 귀하의 벡터는 다음과 같은 오라클 데이터베이스의 가장 강력한 기능의 혜택을 받을 수 있습니다:

* [파티셔닝 지원](https://www.oracle.com/database/technologies/partitioning.html)
* [실제 애플리케이션 클러스터 확장성](https://www.oracle.com/database/real-application-clusters/)
* [엑사데이터 스마트 스캔](https://www.oracle.com/database/technologies/exadata/software/smartscan/)
* [지리적으로 분산된 데이터베이스 간의 샤드 처리](https://www.oracle.com/database/distributed-database/)
* [트랜잭션](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/transactions.html)
* [병렬 SQL](https://docs.oracle.com/en/database/oracle/oracle-database/21/vldbg/parallel-exec-intro.html#GUID-D28717E4-0F77-44F5-BB4E-234C31D4E4BA)
* [재해 복구](https://www.oracle.com/database/data-guard/)
* [보안](https://www.oracle.com/security/database-security/)
* [오라클 머신 러닝](https://www.oracle.com/artificial-intelligence/database-machine-learning/)
* [오라클 그래프 데이터베이스](https://www.oracle.com/database/integrated-graph-database/)
* [오라클 공간 및 그래프](https://www.oracle.com/database/spatial/)
* [오라클 블록체인](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html#GUID-B469E277-978E-4378-A8C1-26D3FF96C9A6)
* [JSON](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/json-in-oracle-database.html)

이 가이드는 오라클 AI 벡터 검색 내에서 요약 기능을 사용하여 OracleSummary를 사용하여 문서 요약을 생성하는 방법을 보여줍니다.

오라클 데이터베이스를 처음 사용하신다면, 데이터베이스 환경 설정에 대한 훌륭한 소개를 제공하는 [무료 오라클 23 AI](https://www.oracle.com/database/free/#resources)를 탐색해 보시기 바랍니다. 데이터베이스 작업 시 기본적으로 시스템 사용자를 사용하는 것을 피하는 것이 좋습니다. 대신 보안 및 사용자 정의를 강화하기 위해 자신의 사용자를 생성할 수 있습니다. 사용자 생성에 대한 자세한 단계는 오라클에서 사용자를 설정하는 방법을 보여주는 [엔드 투 엔드 가이드](https://github.com/langchain-ai/langchain/blob/master/cookbook/oracleai_demo.ipynb)를 참조하십시오. 또한 사용자 권한을 이해하는 것은 데이터베이스 보안을 효과적으로 관리하는 데 중요합니다. 사용자 계정 및 보안 관리에 대한 공식 [오라클 가이드](https://docs.oracle.com/en/database/oracle/oracle-database/19/admqs/administering-user-accounts-and-security.html#GUID-36B21D72-1BBB-46C9-A0C9-F0D2A8591B8D)에서 이 주제에 대해 더 알아볼 수 있습니다.

### 필수 조건

오라클 AI 벡터 검색과 함께 Langchain을 사용하려면 오라클 파이썬 클라이언트 드라이버를 설치하십시오.

```python
# pip install oracledb
```


### 오라클 데이터베이스에 연결
다음 샘플 코드는 오라클 데이터베이스에 연결하는 방법을 보여줍니다. 기본적으로 python-oracledb는 오라클 데이터베이스에 직접 연결되는 'Thin' 모드에서 실행됩니다. 이 모드는 오라클 클라이언트 라이브러리를 필요로 하지 않습니다. 그러나 python-oracledb가 이를 사용할 때 추가 기능이 제공됩니다. 오라클 클라이언트 라이브러리를 사용할 때 python-oracledb는 'Thick' 모드에 있다고 합니다. 두 모드 모두 Python 데이터베이스 API v2.0 사양을 지원하는 포괄적인 기능을 가지고 있습니다. 각 모드에서 지원되는 기능에 대해 설명하는 다음 [가이드](https://python-oracledb.readthedocs.io/en/latest/user_guide/appendix_a.html#featuresummary)를 참조하십시오. Thin 모드를 사용할 수 없는 경우 Thick 모드로 전환할 수 있습니다.

```python
import sys

import oracledb

# please update with your username, password, hostname and service_name
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


### 요약 생성
오라클 AI 벡터 검색 Langchain 라이브러리는 문서 요약을 위해 설계된 API 모음을 제공합니다. 데이터베이스, OCIGENAI, HuggingFace 등과 같은 여러 요약 제공자를 지원하여 사용자가 자신의 필요에 가장 적합한 제공자를 선택할 수 있습니다. 이러한 기능을 활용하려면 사용자가 지정된 요약 매개변수를 구성해야 합니다. 이러한 매개변수에 대한 자세한 정보는 [오라클 AI 벡터 검색 가이드북](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_vector_chain1.html#GUID-EC9DDB58-6A15-4B36-BA66-ECBA20D2CE57)을 참조하십시오.

***참고:*** 사용자는 오라클의 사내 기본 제공자 'database' 이외의 제3자 요약 생성 제공자를 사용하려는 경우 프록시를 설정해야 할 수 있습니다. 프록시가 없는 경우 OracleSummary를 인스턴스화할 때 프록시 매개변수를 제거하십시오.

```python
# proxy to be used when we instantiate summary and embedder object
proxy = "<proxy>"
```


다음 샘플 코드는 요약을 생성하는 방법을 보여줍니다:

```python
<!--IMPORTS:[{"imported": "OracleSummary", "source": "langchain_community.utilities.oracleai", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.oracleai.OracleSummary.html", "title": "Oracle AI Vector Search: Generate Summary"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Oracle AI Vector Search: Generate Summary"}]-->
from langchain_community.utilities.oracleai import OracleSummary
from langchain_core.documents import Document

"""
# using 'ocigenai' provider
summary_params = {
    "provider": "ocigenai",
    "credential_name": "OCI_CRED",
    "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/summarizeText",
    "model": "cohere.command",
}

# using 'huggingface' provider
summary_params = {
    "provider": "huggingface",
    "credential_name": "HF_CRED",
    "url": "https://api-inference.huggingface.co/models/",
    "model": "facebook/bart-large-cnn",
    "wait_for_model": "true"
}
"""

# using 'database' provider
summary_params = {
    "provider": "database",
    "glevel": "S",
    "numParagraphs": 1,
    "language": "english",
}

# get the summary instance
# Remove proxy if not required
summ = OracleSummary(conn=conn, params=summary_params, proxy=proxy)
summary = summ.get_summary(
    "In the heart of the forest, "
    + "a lone fox ventured out at dusk, seeking a lost treasure. "
    + "With each step, memories flooded back, guiding its path. "
    + "As the moon rose high, illuminating the night, the fox unearthed "
    + "not gold, but a forgotten friendship, worth more than any riches."
)

print(f"Summary generated by OracleSummary: {summary}")
```


### 엔드 투 엔드 데모
오라클 AI 벡터 검색의 도움으로 엔드 투 엔드 RAG 파이프라인을 구축하기 위해 [오라클 AI 벡터 검색 엔드 투 엔드 데모 가이드](https://github.com/langchain-ai/langchain/tree/master/cookbook/oracleai_demo.ipynb)를 참조하십시오.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
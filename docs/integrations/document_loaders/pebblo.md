---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/pebblo.ipynb
description: Pebblo Safe DocumentLoader는 Langchain의 데이터 가시성을 향상시켜 안전한 데이터 로딩을 지원합니다.
  주제 및 엔티티를 분석합니다.
---

# Pebblo Safe DocumentLoader

> [Pebblo](https://daxa-ai.github.io/pebblo/)는 개발자가 데이터를 안전하게 로드하고 조직의 준수 및 보안 요구 사항에 대해 걱정하지 않고 Gen AI 앱을 배포할 수 있도록 합니다. 이 프로젝트는 로드된 데이터에서 발견된 의미론적 주제와 엔티티를 식별하고 이를 UI 또는 PDF 보고서에 요약합니다.

Pebblo는 두 가지 구성 요소로 이루어져 있습니다.

1. Langchain을 위한 Pebblo Safe DocumentLoader
2. Pebblo 서버

이 문서는 기존 Langchain DocumentLoader를 Pebblo Safe DocumentLoader로 확장하여 Gen-AI Langchain 애플리케이션에 수집된 주제 및 엔티티 유형에 대한 깊은 데이터 가시성을 얻는 방법을 설명합니다. `Pebblo Server`에 대한 자세한 내용은 이 [pebblo server](https://daxa-ai.github.io/pebblo/daemon) 문서를 참조하세요.

Pebblo Safeloader는 Langchain `DocumentLoader`에 대한 안전한 데이터 수집을 가능하게 합니다. 이는 문서 로더 호출을 `Pebblo Safe DocumentLoader`로 감싸는 방식으로 이루어집니다.

참고: pebblo 서버를 pebblo의 기본 (localhost:8000) URL 이외의 URL에 구성하려면 `PEBBLO_CLASSIFIER_URL` 환경 변수에 올바른 URL을 입력하세요. 이는 `classifier_url` 키워드 인수를 사용하여 구성할 수도 있습니다. 참조: [server-configurations](https://daxa-ai.github.io/pebblo/config)

#### Pebblo로 문서 로딩을 활성화하는 방법은?

`CSVLoader`를 사용하여 추론을 위해 CSV 문서를 읽는 Langchain RAG 애플리케이션 코드 조각을 가정해 보겠습니다.

다음은 `CSVLoader`를 사용한 문서 로딩 코드 조각입니다.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "Pebblo Safe DocumentLoader"}]-->
from langchain_community.document_loaders import CSVLoader

loader = CSVLoader("data/corp_sens_data.csv")
documents = loader.load()
print(documents)
```


위 코드 조각에 몇 줄의 코드 변경으로 Pebblo SafeLoader를 활성화할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "Pebblo Safe DocumentLoader"}, {"imported": "PebbloSafeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pebblo.PebbloSafeLoader.html", "title": "Pebblo Safe DocumentLoader"}]-->
from langchain_community.document_loaders import CSVLoader, PebbloSafeLoader

loader = PebbloSafeLoader(
    CSVLoader("data/corp_sens_data.csv"),
    name="acme-corp-rag-1",  # App name (Mandatory)
    owner="Joe Smith",  # Owner (Optional)
    description="Support productivity RAG application",  # Description (Optional)
)
documents = loader.load()
print(documents)
```


### 의미론적 주제와 정체성을 Pebblo 클라우드 서버로 전송하기

의미론적 데이터를 pebblo-cloud로 전송하려면 api-key를 PebbloSafeLoader에 인수로 전달하거나, 대안으로 `PEBBLO_API_KEY` 환경 변수에 api-key를 입력하세요.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "Pebblo Safe DocumentLoader"}, {"imported": "PebbloSafeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pebblo.PebbloSafeLoader.html", "title": "Pebblo Safe DocumentLoader"}]-->
from langchain_community.document_loaders import CSVLoader, PebbloSafeLoader

loader = PebbloSafeLoader(
    CSVLoader("data/corp_sens_data.csv"),
    name="acme-corp-rag-1",  # App name (Mandatory)
    owner="Joe Smith",  # Owner (Optional)
    description="Support productivity RAG application",  # Description (Optional)
    api_key="my-api-key",  # API key (Optional, can be set in the environment variable PEBBLO_API_KEY)
)
documents = loader.load()
print(documents)
```


### 로드된 메타데이터에 의미론적 주제와 정체성 추가하기

로드된 문서의 메타데이터에 의미론적 주제와 의미론적 엔티티를 추가하려면 인수로 load_semantic을 True로 설정하거나, 대안으로 새로운 환경 변수 `PEBBLO_LOAD_SEMANTIC`을 정의하고 이를 True로 설정하세요.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "Pebblo Safe DocumentLoader"}, {"imported": "PebbloSafeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pebblo.PebbloSafeLoader.html", "title": "Pebblo Safe DocumentLoader"}]-->
from langchain_community.document_loaders import CSVLoader, PebbloSafeLoader

loader = PebbloSafeLoader(
    CSVLoader("data/corp_sens_data.csv"),
    name="acme-corp-rag-1",  # App name (Mandatory)
    owner="Joe Smith",  # Owner (Optional)
    description="Support productivity RAG application",  # Description (Optional)
    api_key="my-api-key",  # API key (Optional, can be set in the environment variable PEBBLO_API_KEY)
    load_semantic=True,  # Load semantic data (Optional, default is False, can be set in the environment variable PEBBLO_LOAD_SEMANTIC)
)
documents = loader.load()
print(documents[0].metadata)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
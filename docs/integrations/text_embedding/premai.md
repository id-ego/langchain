---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/premai.ipynb
description: PremAI는 생성 AI로 구동되는 강력한 애플리케이션을 쉽게 만들 수 있는 올인원 플랫폼입니다. 사용자 경험 향상에 집중하세요.
---

# PremAI

[PremAI](https://premai.io/)는 생성 AI로 구동되는 강력하고 생산 준비가 완료된 애플리케이션의 생성을 간소화하는 올인원 플랫폼입니다. 개발 프로세스를 간소화함으로써 PremAI는 사용자 경험을 향상시키고 애플리케이션의 전반적인 성장을 촉진하는 데 집중할 수 있도록 합니다. [여기](https://docs.premai.io/quick-start)에서 플랫폼 사용을 빠르게 시작할 수 있습니다.

### 설치 및 설정

`langchain`과 `premai-sdk`를 설치하는 것으로 시작합니다. 다음 명령어를 입력하여 설치할 수 있습니다:

```bash
pip install premai langchain
```


더 진행하기 전에, PremAI에 계정을 만들고 이미 프로젝트를 생성했는지 확인하세요. 그렇지 않은 경우, PremAI 플랫폼을 시작하기 위한 [빠른 시작](https://docs.premai.io/introduction) 가이드를 참조하세요. 첫 번째 프로젝트를 생성하고 API 키를 가져오세요.

## PremEmbeddings

이 섹션에서는 LangChain을 사용하여 `PremEmbeddings`를 통해 다양한 임베딩 모델에 접근하는 방법에 대해 논의할 것입니다. 모듈을 가져오고 API 키를 설정하는 것부터 시작하겠습니다.

```python
<!--IMPORTS:[{"imported": "PremAIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.premai.PremAIEmbeddings.html", "title": "PremAI"}]-->
# Let's start by doing some imports and define our embedding object

from langchain_community.embeddings import PremAIEmbeddings
```


필요한 모듈을 가져온 후, 클라이언트를 설정해 보겠습니다. 현재 `project_id`가 `8`이라고 가정하겠습니다. 하지만 반드시 자신의 project-id를 사용해야 하며, 그렇지 않으면 오류가 발생합니다.

> 참고: `model_name` 인수를 설정하는 것은 [ChatPremAI](https://python.langchain.com/v0.1/docs/integrations/chat/premai/)와 달리 PremAIEmbeddings에 필수입니다.

```python
import getpass
import os

if os.environ.get("PREMAI_API_KEY") is None:
    os.environ["PREMAI_API_KEY"] = getpass.getpass("PremAI API Key:")
```


```python
model = "text-embedding-3-large"
embedder = PremAIEmbeddings(project_id=8, model=model)
```


최신 임베딩 모델을 많이 지원합니다. 지원되는 LLM 및 임베딩 모델 목록은 [여기](https://docs.premai.io/get-started/supported-models)에서 확인할 수 있습니다. 현재 예제에서는 `text-embedding-3-large` 모델을 사용하겠습니다.

```python
query = "Hello, this is a test query"
query_result = embedder.embed_query(query)

# Let's print the first five elements of the query embedding vector

print(query_result[:5])
```

```output
[-0.02129288576543331, 0.0008162345038726926, -0.004556538071483374, 0.02918623760342598, -0.02547479420900345]
```

마지막으로 문서를 임베드해 보겠습니다.

```python
documents = ["This is document1", "This is document2", "This is document3"]

doc_result = embedder.embed_documents(documents)

# Similar to previous result, let's print the first five element
# of the first document vector

print(doc_result[0][:5])
```

```output
[-0.0030691148713231087, -0.045334383845329285, -0.0161729846149683, 0.04348714277148247, -0.0036920777056366205]
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/sambanova.ipynb
description: SambaNova의 Sambastudio를 사용하여 LangChain으로 오픈 소스 모델과 상호작용하는 방법을 설명합니다.
---

# SambaNova

**[SambaNova](https://sambanova.ai/)'s** [Sambastudio](https://sambanova.ai/technology/full-stack-ai-platform)는 오픈 소스 모델을 실행하기 위한 플랫폼입니다.

이 예제는 LangChain을 사용하여 SambaNova 임베딩 모델과 상호작용하는 방법을 설명합니다.

## SambaStudio

**SambaStudio**는 자신이 조정한 오픈 소스 모델을 훈련하고, 배치 추론 작업을 실행하며, 온라인 추론 엔드포인트를 배포할 수 있게 해줍니다.

모델을 배포하려면 SambaStudio 환경이 필요합니다. 자세한 정보는 [sambanova.ai/products/enterprise-ai-platform-sambanova-suite](https://sambanova.ai/products/enterprise-ai-platform-sambanova-suite)에서 확인하세요.

환경 변수를 등록하세요:

```python
import os

sambastudio_base_url = "<Your SambaStudio environment URL>"
sambastudio_base_uri = "<Your SambaStudio environment URI>"
sambastudio_project_id = "<Your SambaStudio project id>"
sambastudio_endpoint_id = "<Your SambaStudio endpoint id>"
sambastudio_api_key = "<Your SambaStudio endpoint API key>"

# Set the environment variables
os.environ["SAMBASTUDIO_EMBEDDINGS_BASE_URL"] = sambastudio_base_url
os.environ["SAMBASTUDIO_EMBEDDINGS_BASE_URI"] = sambastudio_base_uri
os.environ["SAMBASTUDIO_EMBEDDINGS_PROJECT_ID"] = sambastudio_project_id
os.environ["SAMBASTUDIO_EMBEDDINGS_ENDPOINT_ID"] = sambastudio_endpoint_id
os.environ["SAMBASTUDIO_EMBEDDINGS_API_KEY"] = sambastudio_api_key
```


LangChain에서 SambaStudio 호스팅 임베딩을 직접 호출하세요!

```python
<!--IMPORTS:[{"imported": "SambaStudioEmbeddings", "source": "langchain_community.embeddings.sambanova", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.sambanova.SambaStudioEmbeddings.html", "title": "SambaNova"}]-->
from langchain_community.embeddings.sambanova import SambaStudioEmbeddings

embeddings = SambaStudioEmbeddings()

text = "Hello, this is a test"
result = embeddings.embed_query(text)
print(result)

texts = ["Hello, this is a test", "Hello, this is another test"]
results = embeddings.embed_documents(texts)
print(results)
```


SambaStudio 임베딩 엔드포인트에서 엔드포인트 매개변수를 수동으로 전달하고 배치 크기를 수동으로 설정할 수 있습니다.

```python
embeddings = SambaStudioEmbeddings(
    sambastudio_embeddings_base_url=sambastudio_base_url,
    sambastudio_embeddings_base_uri=sambastudio_base_uri,
    sambastudio_embeddings_project_id=sambastudio_project_id,
    sambastudio_embeddings_endpoint_id=sambastudio_endpoint_id,
    sambastudio_embeddings_api_key=sambastudio_api_key,
    batch_size=32,  # set depending on the deployed endpoint configuration
)
```


또는 배포된 CoE에 포함된 임베딩 모델 전문가를 사용할 수 있습니다.

```python
embeddings = SambaStudioEmbeddings(
    batch_size=1,
    model_kwargs={
        "select_expert": "e5-mistral-7b-instruct",
    },
)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
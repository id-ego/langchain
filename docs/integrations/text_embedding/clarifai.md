---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/clarifai.ipynb
description: Clarifai는 데이터 탐색, 라벨링, 모델 훈련 및 추론을 포함한 AI 생애주기를 제공하는 AI 플랫폼입니다.
---

# Clarifai

> [Clarifai](https://www.clarifai.com/)는 데이터 탐색, 데이터 라벨링, 모델 훈련, 평가 및 추론에 이르는 전체 AI 라이프사이클을 제공하는 AI 플랫폼입니다.

이 예제는 LangChain을 사용하여 `Clarifai` [모델](https://clarifai.com/explore/models)과 상호작용하는 방법을 설명합니다. 특히 텍스트 임베딩 모델은 [여기](https://clarifai.com/explore/models?page=1&perPage=24&filterData=%5B%7B%22field%22%3A%22model_type_id%22%2C%22value%22%3A%5B%22text-embedder%22%5D%7D%5D)에서 찾을 수 있습니다.

Clarifai를 사용하려면 계정과 개인 액세스 토큰(PAT) 키가 필요합니다. [여기에서 확인](https://clarifai.com/settings/security)하여 PAT를 얻거나 생성하세요.

# Dependencies

```python
# Install required dependencies
%pip install --upgrade --quiet  clarifai
```


# Imports
여기에서는 개인 액세스 토큰을 설정합니다. Clarifai 계정의 [설정/보안](https://clarifai.com/settings/security)에서 PAT를 찾을 수 있습니다.

```python
# Please login and get your API key from  https://clarifai.com/settings/security
from getpass import getpass

CLARIFAI_PAT = getpass()
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Clarifai"}, {"imported": "ClarifaiEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.clarifai.ClarifaiEmbeddings.html", "title": "Clarifai"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Clarifai"}]-->
# Import the required modules
from langchain.chains import LLMChain
from langchain_community.embeddings import ClarifaiEmbeddings
from langchain_core.prompts import PromptTemplate
```


# Input
LLM 체인과 함께 사용할 프롬프트 템플릿을 만듭니다:

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


# Setup
모델이 있는 애플리케이션의 사용자 ID와 앱 ID를 설정합니다. 공용 모델 목록은 https://clarifai.com/explore/models 에서 확인할 수 있습니다.

모델 ID와 필요할 경우 모델 버전 ID도 초기화해야 합니다. 일부 모델은 여러 버전이 있으므로 작업에 적합한 버전을 선택할 수 있습니다.

```python
USER_ID = "clarifai"
APP_ID = "main"
MODEL_ID = "BAAI-bge-base-en-v15"
MODEL_URL = "https://clarifai.com/clarifai/main/models/BAAI-bge-base-en-v15"

# Further you can also provide a specific model version as the model_version_id arg.
# MODEL_VERSION_ID = "MODEL_VERSION_ID"
```


```python
# Initialize a Clarifai embedding model
embeddings = ClarifaiEmbeddings(user_id=USER_ID, app_id=APP_ID, model_id=MODEL_ID)

# Initialize a clarifai embedding model using model URL
embeddings = ClarifaiEmbeddings(model_url=MODEL_URL)

# Alternatively you can initialize clarifai class with pat argument.
```


```python
text = "roses are red violets are blue."
text2 = "Make hay while the sun shines."
```


embed_query 함수를 사용하여 텍스트의 단일 줄을 임베딩할 수 있습니다!

```python
query_result = embeddings.embed_query(text)
```


텍스트/문서 목록을 임베딩하려면 embed_documents 함수를 사용하세요.

```python
doc_result = embeddings.embed_documents([text, text2])
```


## Related

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/huggingfacehub.ipynb
description: 이 문서는 Hugging Face의 임베딩 클래스, Inference API 및 Hugging Face Hub를 사용하여 임베딩을
  생성하는 방법을 설명합니다.
---

# 허깅페이스
허깅페이스 임베딩 클래스를 로드해 보겠습니다.

```python
%pip install --upgrade --quiet  langchain sentence_transformers
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Hugging Face"}]-->
from langchain_huggingface.embeddings import HuggingFaceEmbeddings
```


```python
embeddings = HuggingFaceEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
query_result[:3]
```


```output
[-0.04895168915390968, -0.03986193612217903, -0.021562768146395683]
```


```python
doc_result = embeddings.embed_documents([text])
```


## 허깅페이스 추론 API
우리는 `sentence_transformers`를 설치하고 모델을 로컬에 다운로드할 필요 없이 허깅페이스 추론 API를 통해 임베딩 모델에 접근할 수 있습니다.

```python
import getpass

inference_api_key = getpass.getpass("Enter your HF Inference API Key:\n\n")
```

```output
Enter your HF Inference API Key:

 ········
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceInferenceAPIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceInferenceAPIEmbeddings.html", "title": "Hugging Face"}]-->
from langchain_community.embeddings import HuggingFaceInferenceAPIEmbeddings

embeddings = HuggingFaceInferenceAPIEmbeddings(
    api_key=inference_api_key, model_name="sentence-transformers/all-MiniLM-l6-v2"
)

query_result = embeddings.embed_query(text)
query_result[:3]
```


```output
[-0.038338541984558105, 0.1234646737575531, -0.028642963618040085]
```


## 허깅페이스 허브
우리는 `huggingface_hub`를 설치해야 하는 허깅페이스 허브 패키지를 통해 로컬에서 임베딩을 생성할 수도 있습니다.

```python
!pip install huggingface_hub
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceEndpointEmbeddings", "source": "langchain_huggingface.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface_endpoint.HuggingFaceEndpointEmbeddings.html", "title": "Hugging Face"}]-->
from langchain_huggingface.embeddings import HuggingFaceEndpointEmbeddings
```


```python
embeddings = HuggingFaceEndpointEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
query_result[:3]
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
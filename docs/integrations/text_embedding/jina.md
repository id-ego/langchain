---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/jina.ipynb
description: JinaAI API를 통해 텍스트와 이미지 쿼리를 임베딩하는 방법을 안내하는 문서입니다.
---

# 지나

필요한 패키지 설치

```python
pip install -U langchain-community
```


라이브러리 가져오기

```python
<!--IMPORTS:[{"imported": "JinaEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.jina.JinaEmbeddings.html", "title": "Jina"}]-->
import requests
from langchain_community.embeddings import JinaEmbeddings
from numpy import dot
from numpy.linalg import norm
from PIL import Image
```


## JinaAI API를 통해 Jina 임베딩 모델로 텍스트와 쿼리 임베딩하기

```python
text_embeddings = JinaEmbeddings(
    jina_api_key="jina_*", model_name="jina-embeddings-v2-base-en"
)
```


```python
text = "This is a test document."
```


```python
query_result = text_embeddings.embed_query(text)
```


```python
print(query_result)
```


```python
doc_result = text_embeddings.embed_documents([text])
```


```python
print(doc_result)
```


## JinaAI API를 통해 Jina CLIP으로 이미지와 쿼리 임베딩하기

```python
multimodal_embeddings = JinaEmbeddings(jina_api_key="jina_*", model_name="jina-clip-v1")
```


```python
image = "https://avatars.githubusercontent.com/u/126733545?v=4"

description = "Logo of a parrot and a chain on green background"

im = Image.open(requests.get(image, stream=True).raw)
print("Image:")
display(im)
```


```python
image_result = multimodal_embeddings.embed_images([image])
```


```python
print(image_result)
```


```python
description_result = multimodal_embeddings.embed_documents([description])
```


```python
print(description_result)
```


```python
cosine_similarity = dot(image_result[0], description_result[0]) / (
    norm(image_result[0]) * norm(description_result[0])
)
```


```python
print(cosine_similarity)
```


## 관련 자료

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
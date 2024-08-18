---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/tensorflowhub.ipynb
description: TensorFlow Hub는 미리 학습된 기계 학습 모델을 재사용하고 배포할 수 있는 저장소로, BERT 및 Faster R-CNN과
  같은 모델을 쉽게 사용할 수 있습니다.
---

# 텐서플로우 허브

> [텐서플로우 허브](https://www.tensorflow.org/hub)는 미세 조정이 가능하고 어디에서나 배포할 수 있는 훈련된 머신러닝 모델의 저장소입니다. 몇 줄의 코드로 `BERT` 및 `Faster R-CNN`과 같은 훈련된 모델을 재사용하세요.
> 
텐서플로우 허브 임베딩 클래스를 로드해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "TensorflowHubEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.tensorflow_hub.TensorflowHubEmbeddings.html", "title": "TensorFlow Hub"}]-->
from langchain_community.embeddings import TensorflowHubEmbeddings
```


```python
embeddings = TensorflowHubEmbeddings()
```

```output
2023-01-30 23:53:01.652176: I tensorflow/core/platform/cpu_feature_guard.cc:193] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX2 FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
2023-01-30 23:53:34.362802: I tensorflow/core/platform/cpu_feature_guard.cc:193] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX2 FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_results = embeddings.embed_documents(["foo"])
```


```python
doc_results
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/instruct_embeddings.ipynb
description: Hugging Face의 Instruct Embeddings에 대한 설명과 사용법을 다룬 문서입니다. 최신 임베딩 모델을 활용하는
  방법을 소개합니다.
---

# Hugging Face의 지시 임베딩

> [Hugging Face sentence-transformers](https://huggingface.co/sentence-transformers)는 최첨단 문장, 텍스트 및 이미지 임베딩을 위한 Python 프레임워크입니다. 지시 임베딩 모델 중 하나는 `HuggingFaceInstructEmbeddings` 클래스에서 사용됩니다.

```python
<!--IMPORTS:[{"imported": "HuggingFaceInstructEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceInstructEmbeddings.html", "title": "Instruct Embeddings on Hugging Face"}]-->
from langchain_community.embeddings import HuggingFaceInstructEmbeddings
```


```python
embeddings = HuggingFaceInstructEmbeddings(
    query_instruction="Represent the query for retrieval: "
)
```

```output
load INSTRUCTOR_Transformer
max_seq_length  512
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
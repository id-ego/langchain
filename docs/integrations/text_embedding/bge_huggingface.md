---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/bge_huggingface.ipynb
description: BGE 모델은 베이징 인공지능 연구소에서 개발한 최고의 오픈소스 임베딩 모델로, Hugging Face를 통해 사용 가능합니다.
---

# BGE on Hugging Face

> [HuggingFace의 BGE 모델](https://huggingface.co/BAAI/bge-large-en)은 [최고의 오픈 소스 임베딩 모델](https://huggingface.co/spaces/mteb/leaderboard)입니다.
BGE 모델은 [베이징 인공지능 연구원(BAAI)](https://en.wikipedia.org/wiki/Beijing_Academy_of_Artificial_Intelligence)에서 제작하였습니다. `BAAI`는 AI 연구 및 개발에 종사하는 비영리 민간 기관입니다.

이 노트북은 `Hugging Face`를 통해 `BGE Embeddings`를 사용하는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet  sentence_transformers
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceBgeEmbeddings.html", "title": "BGE on Hugging Face"}]-->
from langchain_community.embeddings import HuggingFaceBgeEmbeddings

model_name = "BAAI/bge-small-en"
model_kwargs = {"device": "cpu"}
encode_kwargs = {"normalize_embeddings": True}
hf = HuggingFaceBgeEmbeddings(
    model_name=model_name, model_kwargs=model_kwargs, encode_kwargs=encode_kwargs
)
```


`model_name="BAAI/bge-m3"`에 대해 `query_instruction=""`을 전달해야 한다는 점에 유의하세요. [FAQ BGE M3](https://huggingface.co/BAAI/bge-m3#faq)를 참조하세요.

```python
embedding = hf.embed_query("hi this is harrison")
len(embedding)
```


```output
384
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
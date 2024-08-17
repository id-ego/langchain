---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/bge_huggingface/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/bge_huggingface.ipynb
---

# BGE on Hugging Face

>[BGE models on the HuggingFace](https://huggingface.co/BAAI/bge-large-en) are [the best open-source embedding models](https://huggingface.co/spaces/mteb/leaderboard).
>BGE model is created by the [Beijing Academy of Artificial Intelligence (BAAI)](https://en.wikipedia.org/wiki/Beijing_Academy_of_Artificial_Intelligence). `BAAI` is a private non-profit organization engaged in AI research and development.

This notebook shows how to use `BGE Embeddings` through `Hugging Face`


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

Note that you need to pass `query_instruction=""` for `model_name="BAAI/bge-m3"` see [FAQ BGE M3](https://huggingface.co/BAAI/bge-m3#faq). 


```python
embedding = hf.embed_query("hi this is harrison")
len(embedding)
```



```output
384
```



## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
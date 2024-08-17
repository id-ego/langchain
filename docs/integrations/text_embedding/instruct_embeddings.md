---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/instruct_embeddings/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/instruct_embeddings.ipynb
---

# Instruct Embeddings on Hugging Face

>[Hugging Face sentence-transformers](https://huggingface.co/sentence-transformers) is a Python framework for state-of-the-art sentence, text and image embeddings.
>One of the instruct embedding models is used in the `HuggingFaceInstructEmbeddings` class.



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


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/sentence_transformers/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/sentence_transformers.ipynb
---

# Sentence Transformers on Hugging Face

> [Hugging Face sentence-transformers](https://huggingface.co/sentence-transformers) is a Python framework for state-of-the-art sentence, text and image embeddings.
You can use these embedding models from the `HuggingFaceEmbeddings` class.

:::caution

Running sentence-transformers locally can be affected by your operating system and other global factors. It is recommended for experienced users only.

:::

## Setup

You'll need to install the `langchain_huggingface` package as a dependency:

```python
%pip install -qU langchain-huggingface
```

## Usage

```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Sentence Transformers on Hugging Face"}]-->
from langchain_huggingface import HuggingFaceEmbeddings

embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

text = "This is a test document."
query_result = embeddings.embed_query(text)

# show only the first 100 characters of the stringified vector
print(str(query_result)[:100] + "...")
```
```output
[-0.038338568061590195, 0.12346471101045609, -0.028642969205975533, 0.05365273356437683, 0.008845377...
```

```python
doc_result = embeddings.embed_documents([text, "This is not a test document."])
print(str(doc_result)[:100] + "...")
```
```output
[[-0.038338497281074524, 0.12346471846103668, -0.028642890974879265, 0.05365274101495743, 0.00884535...
```
## Troubleshooting

If you are having issues with the `accelerate` package not being found or failing to import, installing/upgrading it may help:

```python
%pip install -qU accelerate
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
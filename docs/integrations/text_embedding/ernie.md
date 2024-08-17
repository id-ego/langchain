---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/ernie/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ernie.ipynb
---

# ERNIE

[ERNIE Embedding-V1](https://cloud.baidu.com/doc/WENXINWORKSHOP/s/alj562vvu) is a text representation model based on `Baidu Wenxin` large-scale model technology,
which converts text into a vector form represented by numerical values, and is used in text retrieval, information recommendation, knowledge mining and other scenarios.

**Deprecated Warning**

We recommend users using `langchain_community.embeddings.ErnieEmbeddings`
to use `langchain_community.embeddings.QianfanEmbeddingsEndpoint` instead.

documentation for `QianfanEmbeddingsEndpoint` is [here](/docs/integrations/text_embedding/baidu_qianfan_endpoint/).

they are 2 why we recommend users to use `QianfanEmbeddingsEndpoint`:

1. `QianfanEmbeddingsEndpoint` support more embedding model in the Qianfan platform.
2. `ErnieEmbeddings` is lack of maintenance and deprecated.

Some tips for migration:

```python
<!--IMPORTS:[{"imported": "QianfanEmbeddingsEndpoint", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.baidu_qianfan_endpoint.QianfanEmbeddingsEndpoint.html", "title": "ERNIE"}]-->
from langchain_community.embeddings import QianfanEmbeddingsEndpoint

embeddings = QianfanEmbeddingsEndpoint(
    qianfan_ak="your qianfan ak",
    qianfan_sk="your qianfan sk",
)
```

## Usage

```python
<!--IMPORTS:[{"imported": "ErnieEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ernie.ErnieEmbeddings.html", "title": "ERNIE"}]-->
from langchain_community.embeddings import ErnieEmbeddings
```

```python
embeddings = ErnieEmbeddings()
```

```python
query_result = embeddings.embed_query("foo")
```

```python
doc_results = embeddings.embed_documents(["foo"])
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/ipex_llm/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ipex_llm.ipynb
---

# Local BGE Embeddings with IPEX-LLM on Intel CPU

> [IPEX-LLM](https://github.com/intel-analytics/ipex-llm) is a PyTorch library for running LLM on Intel CPU and GPU (e.g., local PC with iGPU, discrete GPU such as Arc, Flex and Max) with very low latency.

This example goes over how to use LangChain to conduct embedding tasks with `ipex-llm` optimizations on Intel CPU. This would be helpful in applications such as RAG, document QA, etc.

## Setup


```python
%pip install -qU langchain langchain-community
```

Install IPEX-LLM for optimizations on Intel CPU, as well as `sentence-transformers`.


```python
%pip install --pre --upgrade ipex-llm[all] --extra-index-url https://download.pytorch.org/whl/cpu
%pip install sentence-transformers
```

> **Note**
>
> For Windows users, `--extra-index-url https://download.pytorch.org/whl/cpu` when install `ipex-llm` is not required.

## Basic Usage


```python
<!--IMPORTS:[{"imported": "IpexLLMBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ipex_llm.IpexLLMBgeEmbeddings.html", "title": "Local BGE Embeddings with IPEX-LLM on Intel CPU"}]-->
from langchain_community.embeddings import IpexLLMBgeEmbeddings

embedding_model = IpexLLMBgeEmbeddings(
    model_name="BAAI/bge-large-en-v1.5",
    model_kwargs={},
    encode_kwargs={"normalize_embeddings": True},
)
```

API Reference
- [IpexLLMBgeEmbeddings](https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ipex_llm.IpexLLMBgeEmbeddings.html)


```python
sentence = "IPEX-LLM is a PyTorch library for running LLM on Intel CPU and GPU (e.g., local PC with iGPU, discrete GPU such as Arc, Flex and Max) with very low latency."
query = "What is IPEX-LLM?"

text_embeddings = embedding_model.embed_documents([sentence, query])
print(f"text_embeddings[0][:10]: {text_embeddings[0][:10]}")
print(f"text_embeddings[1][:10]: {text_embeddings[1][:10]}")

query_embedding = embedding_model.embed_query(query)
print(f"query_embedding[:10]: {query_embedding[:10]}")
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
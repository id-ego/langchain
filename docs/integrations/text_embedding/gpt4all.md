---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/gpt4all/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/gpt4all.ipynb
---

# GPT4All

[GPT4All](https://gpt4all.io/index.html) is a free-to-use, locally running, privacy-aware chatbot. There is no GPU or internet required. It features popular models and its own models such as GPT4All Falcon, Wizard, etc.

This notebook explains how to use [GPT4All embeddings](https://docs.gpt4all.io/gpt4all_python_embedding.html#gpt4all.gpt4all.Embed4All) with LangChain.

## Install GPT4All's Python Bindings

```python
%pip install --upgrade --quiet  gpt4all > /dev/null
```

Note: you may need to restart the kernel to use updated packages.

```python
<!--IMPORTS:[{"imported": "GPT4AllEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.gpt4all.GPT4AllEmbeddings.html", "title": "GPT4All"}]-->
from langchain_community.embeddings import GPT4AllEmbeddings
```

```python
gpt4all_embd = GPT4AllEmbeddings()
```
```output
100%|████████████████████████| 45.5M/45.5M [00:02<00:00, 18.5MiB/s]
``````output
Model downloaded at:  /Users/rlm/.cache/gpt4all/ggml-all-MiniLM-L6-v2-f16.bin
``````output
objc[45711]: Class GGMLMetalClass is implemented in both /Users/rlm/anaconda3/envs/lcn2/lib/python3.9/site-packages/gpt4all/llmodel_DO_NOT_MODIFY/build/libreplit-mainline-metal.dylib (0x29fe18208) and /Users/rlm/anaconda3/envs/lcn2/lib/python3.9/site-packages/gpt4all/llmodel_DO_NOT_MODIFY/build/libllamamodel-mainline-metal.dylib (0x2a0244208). One of the two will be used. Which one is undefined.
```

```python
text = "This is a test document."
```

## Embed the Textual Data

```python
query_result = gpt4all_embd.embed_query(text)
```

With embed_documents you can embed multiple pieces of text. You can also map these embeddings with [Nomic's Atlas](https://docs.nomic.ai/index.html) to see a visual representation of your data.

```python
doc_result = gpt4all_embd.embed_documents([text])
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/llamafile/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/llamafile.ipynb
---

# llamafile

Let's load the [llamafile](https://github.com/Mozilla-Ocho/llamafile) Embeddings class.

## Setup

First, the are 3 setup steps:

1. Download a llamafile. In this notebook, we use `TinyLlama-1.1B-Chat-v1.0.Q5_K_M` but there are many others available on [HuggingFace](https://huggingface.co/models?other=llamafile).
2. Make the llamafile executable.
3. Start the llamafile in server mode.

You can run the following bash script to do all this:

```bash
%%bash
# llamafile setup

# Step 1: Download a llamafile. The download may take several minutes.
wget -nv -nc https://huggingface.co/jartine/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile

# Step 2: Make the llamafile executable. Note: if you're on Windows, just append '.exe' to the filename.
chmod +x TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile

# Step 3: Start llamafile server in background. All the server logs will be written to 'tinyllama.log'.
# Alternatively, you can just open a separate terminal outside this notebook and run: 
#   ./TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile --server --nobrowser --embedding
./TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile --server --nobrowser --embedding > tinyllama.log 2>&1 &
pid=$!
echo "${pid}" > .llamafile_pid  # write the process pid to a file so we can terminate the server later
```

## Embedding texts using LlamafileEmbeddings

Now, we can use the `LlamafileEmbeddings` class to interact with the llamafile server that's currently serving our TinyLlama model at http://localhost:8080.

```python
<!--IMPORTS:[{"imported": "LlamafileEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.llamafile.LlamafileEmbeddings.html", "title": "llamafile"}]-->
from langchain_community.embeddings import LlamafileEmbeddings
```

```python
embedder = LlamafileEmbeddings()
```

```python
text = "This is a test document."
```

To generate embeddings, you can either query an invidivual text, or you can query a list of texts.

```python
query_result = embedder.embed_query(text)
query_result[:5]
```

```python
doc_result = embedder.embed_documents([text])
doc_result[0][:5]
```

```bash
%%bash
# cleanup: kill the llamafile server process
kill $(cat .llamafile_pid)
rm .llamafile_pid
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
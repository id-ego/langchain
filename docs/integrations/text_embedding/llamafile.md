---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/llamafile.ipynb
description: 이 문서는 Llamafile Embeddings 클래스를 설정하고 사용하여 텍스트 임베딩을 생성하는 방법을 설명합니다.
---

# llamafile

[llamafile](https://github.com/Mozilla-Ocho/llamafile) Embeddings 클래스를 로드해 봅시다.

## 설정

먼저, 3단계의 설정이 필요합니다:

1. llamafile을 다운로드합니다. 이 노트북에서는 `TinyLlama-1.1B-Chat-v1.0.Q5_K_M`을 사용하지만, [HuggingFace](https://huggingface.co/models?other=llamafile)에서 다른 많은 모델을 사용할 수 있습니다.
2. llamafile을 실행 가능하게 만듭니다.
3. 서버 모드에서 llamafile을 시작합니다.

다음 bash 스크립트를 실행하여 이 모든 작업을 수행할 수 있습니다:

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


## LlamafileEmbeddings를 사용한 텍스트 임베딩

이제 `LlamafileEmbeddings` 클래스를 사용하여 현재 http://localhost:8080에서 우리의 TinyLlama 모델을 제공하는 llamafile 서버와 상호작용할 수 있습니다.

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


임베딩을 생성하려면 개별 텍스트를 쿼리하거나 텍스트 목록을 쿼리할 수 있습니다.

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


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
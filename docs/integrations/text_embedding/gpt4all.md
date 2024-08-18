---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/gpt4all.ipynb
description: GPT4All은 로컬에서 실행되는 무료 챗봇으로, LangChain과 함께 텍스트 데이터를 임베딩하는 방법을 설명합니다.
---

# GPT4All

[GPT4All](https://gpt4all.io/index.html)은 무료로 사용할 수 있는 로컬 실행, 개인 정보 보호를 고려한 챗봇입니다. GPU나 인터넷이 필요하지 않습니다. 인기 있는 모델과 GPT4All Falcon, Wizard 등의 자체 모델을 제공합니다.

이 노트북은 LangChain과 함께 [GPT4All 임베딩](https://docs.gpt4all.io/gpt4all_python_embedding.html#gpt4all.gpt4all.Embed4All)을 사용하는 방법을 설명합니다.

## GPT4All의 파이썬 바인딩 설치

```python
%pip install --upgrade --quiet  gpt4all > /dev/null
```


참고: 업데이트된 패키지를 사용하려면 커널을 재시작해야 할 수 있습니다.

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


## 텍스트 데이터 임베드

```python
query_result = gpt4all_embd.embed_query(text)
```


embed_documents를 사용하면 여러 개의 텍스트를 임베드할 수 있습니다. 이러한 임베딩을 [Nomic의 Atlas](https://docs.nomic.ai/index.html)와 매핑하여 데이터의 시각적 표현을 볼 수도 있습니다.

```python
doc_result = gpt4all_embd.embed_documents([text])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ascend.ipynb
description: 이 문서는 임베딩 모델에 대한 개념과 활용 방법을 안내하며, 관련 자료와 가이드를 제공합니다.
---

```python
<!--IMPORTS:[{"imported": "AscendEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ascend.AscendEmbeddings.html", "title": "# Related"}]-->
from langchain_community.embeddings import AscendEmbeddings

model = AscendEmbeddings(
    model_path="/root/.cache/modelscope/hub/yangjhchs/acge_text_embedding",
    device_id=0,
    query_instruction="Represend this sentence for searching relevant passages: ",
)
emb = model.embed_query("hellow")
print(emb)
```

```output
[-0.04053403 -0.05560051 -0.04385472 ...  0.09371872  0.02846981
 -0.00576814]
```


```python
doc_embs = model.embed_documents(
    ["This is a content of the document", "This is another document"]
)
print(doc_embs)
```

```output
We strongly recommend passing in an `attention_mask` since your input_ids may be padded. See https://huggingface.co/docs/transformers/troubleshooting#incorrect-output-when-padding-tokens-arent-masked.
``````output
[[-0.00348254  0.03098977 -0.00203087 ...  0.08492374  0.03970494
  -0.03372753]
 [-0.02198593 -0.01601127  0.00215684 ...  0.06065163  0.00126425
  -0.03634358]]
```


```python
model.aembed_query("hellow")
```


```output
<coroutine object Embeddings.aembed_query at 0x7f9fac699cb0>
```


```python
await model.aembed_query("hellow")
```


```output
array([-0.04053403, -0.05560051, -0.04385472, ...,  0.09371872,
        0.02846981, -0.00576814], dtype=float32)
```


```python
model.aembed_documents(
    ["This is a content of the document", "This is another document"]
)
```


```output
<coroutine object Embeddings.aembed_documents at 0x7fa093ff1a80>
```


```python
await model.aembed_documents(
    ["This is a content of the document", "This is another document"]
)
```


```output
array([[-0.00348254,  0.03098977, -0.00203087, ...,  0.08492374,
         0.03970494, -0.03372753],
       [-0.02198593, -0.01601127,  0.00215684, ...,  0.06065163,
         0.00126425, -0.03634358]], dtype=float32)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)
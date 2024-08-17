---
canonical: https://python.langchain.com/v0.2/docs/integrations/retrievers/knn/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/knn.ipynb
---

# kNN

>In statistics, the [k-nearest neighbours algorithm (k-NN)](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm) is a non-parametric supervised learning method first developed by `Evelyn Fix` and `Joseph Hodges` in 1951, and later expanded by `Thomas Cover`. It is used for classification and regression.

This notebook goes over how to use a retriever that under the hood uses a kNN.

Largely based on the code of [Andrej Karpathy](https://github.com/karpathy/randomfun/blob/master/knn_vs_svm.html).


```python
<!--IMPORTS:[{"imported": "KNNRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.knn.KNNRetriever.html", "title": "kNN"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "kNN"}]-->
from langchain_community.retrievers import KNNRetriever
from langchain_openai import OpenAIEmbeddings
```

## Create New Retriever with Texts


```python
retriever = KNNRetriever.from_texts(
    ["foo", "bar", "world", "hello", "foo bar"], OpenAIEmbeddings()
)
```

## Use Retriever

We can now use the retriever!


```python
result = retriever.invoke("foo")
```


```python
result
```



```output
[Document(page_content='foo', metadata={}),
 Document(page_content='foo bar', metadata={}),
 Document(page_content='hello', metadata={}),
 Document(page_content='bar', metadata={})]
```



## Related

- Retriever [conceptual guide](/docs/concepts/#retrievers)
- Retriever [how-to guides](/docs/how_to/#retrievers)
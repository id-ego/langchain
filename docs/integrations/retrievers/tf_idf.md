---
canonical: https://python.langchain.com/v0.2/docs/integrations/retrievers/tf_idf/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/tf_idf.ipynb
---

# TF-IDF

>[TF-IDF](https://scikit-learn.org/stable/modules/feature_extraction.html#tfidf-term-weighting) means term-frequency times inverse document-frequency.

This notebook goes over how to use a retriever that under the hood uses [TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) using `scikit-learn` package.

For more information on the details of TF-IDF see [this blog post](https://medium.com/data-science-bootcamp/tf-idf-basics-of-information-retrieval-48de122b2a4c).


```python
%pip install --upgrade --quiet  scikit-learn
```


```python
<!--IMPORTS:[{"imported": "TFIDFRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.tfidf.TFIDFRetriever.html", "title": "TF-IDF"}]-->
from langchain_community.retrievers import TFIDFRetriever
```

## Create New Retriever with Texts


```python
retriever = TFIDFRetriever.from_texts(["foo", "bar", "world", "hello", "foo bar"])
```

## Create a New Retriever with Documents

You can now create a new retriever with the documents you created.


```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "TF-IDF"}]-->
from langchain_core.documents import Document

retriever = TFIDFRetriever.from_documents(
    [
        Document(page_content="foo"),
        Document(page_content="bar"),
        Document(page_content="world"),
        Document(page_content="hello"),
        Document(page_content="foo bar"),
    ]
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
 Document(page_content='world', metadata={})]
```


## Save and load

You can easily save and load this retriever, making it handy for local development!


```python
retriever.save_local("testing.pkl")
```


```python
retriever_copy = TFIDFRetriever.load_local("testing.pkl")
```


```python
retriever_copy.invoke("foo")
```



```output
[Document(page_content='foo', metadata={}),
 Document(page_content='foo bar', metadata={}),
 Document(page_content='hello', metadata={}),
 Document(page_content='world', metadata={})]
```



## Related

- Retriever [conceptual guide](/docs/concepts/#retrievers)
- Retriever [how-to guides](/docs/how_to/#retrievers)
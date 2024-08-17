---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/nlp_cloud/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/nlp_cloud.ipynb
---

# NLP Cloud

>[NLP Cloud](https://docs.nlpcloud.com/#introduction) is an artificial intelligence platform that allows you to use the most advanced AI engines, and even train your own engines with your own data. 

The [embeddings](https://docs.nlpcloud.com/#embeddings) endpoint offers the following model:

* `paraphrase-multilingual-mpnet-base-v2`: Paraphrase Multilingual MPNet Base V2 is a very fast model based on Sentence Transformers that is perfectly suited for embeddings extraction in more than 50 languages (see the full list here).


```python
%pip install --upgrade --quiet  nlpcloud
```


```python
<!--IMPORTS:[{"imported": "NLPCloudEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.nlpcloud.NLPCloudEmbeddings.html", "title": "NLP Cloud"}]-->
from langchain_community.embeddings import NLPCloudEmbeddings
```


```python
import os

os.environ["NLPCLOUD_API_KEY"] = "xxx"
nlpcloud_embd = NLPCloudEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = nlpcloud_embd.embed_query(text)
```


```python
doc_result = nlpcloud_embd.embed_documents([text])
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
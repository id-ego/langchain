---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/laser/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/laser.ipynb
---

# LASER Language-Agnostic SEntence Representations Embeddings by Meta AI

>[LASER](https://github.com/facebookresearch/LASER/) is a Python library developed by the Meta AI Research team and used for creating multilingual sentence embeddings for over 147 languages as of 2/25/2024 
>- List of supported languages at https://github.com/facebookresearch/flores/blob/main/flores200/README.md#languages-in-flores-200

## Dependencies

To use LaserEmbed with LangChain, install the `laser_encoders` Python package.


```python
%pip install laser_encoders
```

## Imports


```python
<!--IMPORTS:[{"imported": "LaserEmbeddings", "source": "langchain_community.embeddings.laser", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.laser.LaserEmbeddings.html", "title": "LASER Language-Agnostic SEntence Representations Embeddings by Meta AI"}]-->
from langchain_community.embeddings.laser import LaserEmbeddings
```

## Instantiating Laser
   
### Parameters
- `lang: Optional[str]`
    >If empty will default
    to using a multilingual LASER encoder model (called "laser2").
    You can find the list of supported languages and lang_codes [here](https://github.com/facebookresearch/flores/blob/main/flores200/README.md#languages-in-flores-200)
    and [here](https://github.com/facebookresearch/LASER/blob/main/laser_encoders/language_list.py)
.


```python
# Ex Instantiationz
embeddings = LaserEmbeddings(lang="eng_Latn")
```

## Usage

### Generating document embeddings


```python
document_embeddings = embeddings.embed_documents(
    ["This is a sentence", "This is some other sentence"]
)
```

### Generating query embeddings


```python
query_embeddings = embeddings.embed_query("This is a query")
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
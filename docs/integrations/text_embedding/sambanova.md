---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/sambanova/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/sambanova.ipynb
---

# SambaNova

**[SambaNova](https://sambanova.ai/)'s** [Sambastudio](https://sambanova.ai/technology/full-stack-ai-platform) is a platform for running your own open-source models

This example goes over how to use LangChain to interact with SambaNova embedding models

## SambaStudio

**SambaStudio** allows you to train, run batch inference jobs, and deploy online inference endpoints to run open source models that you fine tuned yourself.

A SambaStudio environment is required to deploy a model. Get more information at [sambanova.ai/products/enterprise-ai-platform-sambanova-suite](https://sambanova.ai/products/enterprise-ai-platform-sambanova-suite)

Register your environment variables:


```python
import os

sambastudio_base_url = "<Your SambaStudio environment URL>"
sambastudio_base_uri = "<Your SambaStudio environment URI>"
sambastudio_project_id = "<Your SambaStudio project id>"
sambastudio_endpoint_id = "<Your SambaStudio endpoint id>"
sambastudio_api_key = "<Your SambaStudio endpoint API key>"

# Set the environment variables
os.environ["SAMBASTUDIO_EMBEDDINGS_BASE_URL"] = sambastudio_base_url
os.environ["SAMBASTUDIO_EMBEDDINGS_BASE_URI"] = sambastudio_base_uri
os.environ["SAMBASTUDIO_EMBEDDINGS_PROJECT_ID"] = sambastudio_project_id
os.environ["SAMBASTUDIO_EMBEDDINGS_ENDPOINT_ID"] = sambastudio_endpoint_id
os.environ["SAMBASTUDIO_EMBEDDINGS_API_KEY"] = sambastudio_api_key
```

Call SambaStudio hosted embeddings directly from LangChain!


```python
<!--IMPORTS:[{"imported": "SambaStudioEmbeddings", "source": "langchain_community.embeddings.sambanova", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.sambanova.SambaStudioEmbeddings.html", "title": "SambaNova"}]-->
from langchain_community.embeddings.sambanova import SambaStudioEmbeddings

embeddings = SambaStudioEmbeddings()

text = "Hello, this is a test"
result = embeddings.embed_query(text)
print(result)

texts = ["Hello, this is a test", "Hello, this is another test"]
results = embeddings.embed_documents(texts)
print(results)
```

You can manually pass the endpoint parameters and manually set the batch size you have in your SambaStudio embeddings endpoint


```python
embeddings = SambaStudioEmbeddings(
    sambastudio_embeddings_base_url=sambastudio_base_url,
    sambastudio_embeddings_base_uri=sambastudio_base_uri,
    sambastudio_embeddings_project_id=sambastudio_project_id,
    sambastudio_embeddings_endpoint_id=sambastudio_endpoint_id,
    sambastudio_embeddings_api_key=sambastudio_api_key,
    batch_size=32,  # set depending on the deployed endpoint configuration
)
```

Or You can use an embedding model expert included in your deployed CoE


```python
embeddings = SambaStudioEmbeddings(
    batch_size=1,
    model_kwargs={
        "select_expert": "e5-mistral-7b-instruct",
    },
)
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/self-hosted/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/self-hosted.ipynb
---

# Self Hosted
Let's load the `SelfHostedEmbeddings`, `SelfHostedHuggingFaceEmbeddings`, and `SelfHostedHuggingFaceInstructEmbeddings` classes.


```python
<!--IMPORTS:[{"imported": "SelfHostedEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.self_hosted.SelfHostedEmbeddings.html", "title": "Self Hosted"}, {"imported": "SelfHostedHuggingFaceEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.self_hosted_hugging_face.SelfHostedHuggingFaceEmbeddings.html", "title": "Self Hosted"}, {"imported": "SelfHostedHuggingFaceInstructEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.self_hosted_hugging_face.SelfHostedHuggingFaceInstructEmbeddings.html", "title": "Self Hosted"}]-->
import runhouse as rh
from langchain_community.embeddings import (
    SelfHostedEmbeddings,
    SelfHostedHuggingFaceEmbeddings,
    SelfHostedHuggingFaceInstructEmbeddings,
)
```


```python
# For an on-demand A100 with GCP, Azure, or Lambda
gpu = rh.cluster(name="rh-a10x", instance_type="A100:1", use_spot=False)

# For an on-demand A10G with AWS (no single A100s on AWS)
# gpu = rh.cluster(name='rh-a10x', instance_type='g5.2xlarge', provider='aws')

# For an existing cluster
# gpu = rh.cluster(ips=['<ip of the cluster>'],
#                  ssh_creds={'ssh_user': '...', 'ssh_private_key':'<path_to_key>'},
#                  name='my-cluster')
```


```python
embeddings = SelfHostedHuggingFaceEmbeddings(hardware=gpu)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```

And similarly for SelfHostedHuggingFaceInstructEmbeddings:


```python
embeddings = SelfHostedHuggingFaceInstructEmbeddings(hardware=gpu)
```

Now let's load an embedding model with a custom load function:


```python
def get_pipeline():
    from transformers import (
        AutoModelForCausalLM,
        AutoTokenizer,
        pipeline,
    )

    model_id = "facebook/bart-base"
    tokenizer = AutoTokenizer.from_pretrained(model_id)
    model = AutoModelForCausalLM.from_pretrained(model_id)
    return pipeline("feature-extraction", model=model, tokenizer=tokenizer)


def inference_fn(pipeline, prompt):
    # Return last hidden state of the model
    if isinstance(prompt, list):
        return [emb[0][-1] for emb in pipeline(prompt)]
    return pipeline(prompt)[0][-1]
```


```python
embeddings = SelfHostedEmbeddings(
    model_load_fn=get_pipeline,
    hardware=gpu,
    model_reqs=["./", "torch", "transformers"],
    inference_fn=inference_fn,
)
```


```python
query_result = embeddings.embed_query(text)
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
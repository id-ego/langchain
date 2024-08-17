---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/bedrock/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/bedrock.ipynb
---

# Bedrock

> [Amazon Bedrock](https://aws.amazon.com/bedrock/) is a fully managed service that offers a choice of
high-performing foundation models (FMs) from leading AI companies like `AI21 Labs`, `Anthropic`, `Cohere`,
`Meta`, `Stability AI`, and `Amazon` via a single API, along with a broad set of capabilities you need to
build generative AI applications with security, privacy, and responsible AI. Using `Amazon Bedrock`,
you can easily experiment with and evaluate top FMs for your use case, privately customize them with
your data using techniques such as fine-tuning and `Retrieval Augmented Generation` (`RAG`), and build
agents that execute tasks using your enterprise systems and data sources. Since `Amazon Bedrock` is
serverless, you don't have to manage any infrastructure, and you can securely integrate and deploy
generative AI capabilities into your applications using the AWS services you are already familiar with.

```python
%pip install --upgrade --quiet  boto3
```

```python
<!--IMPORTS:[{"imported": "BedrockEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.bedrock.BedrockEmbeddings.html", "title": "Bedrock"}]-->
from langchain_community.embeddings import BedrockEmbeddings

embeddings = BedrockEmbeddings(
    credentials_profile_name="bedrock-admin", region_name="us-east-1"
)
```

```python
embeddings.embed_query("This is a content of the document")
```

```python
embeddings.embed_documents(
    ["This is a content of the document", "This is another document"]
)
```

```python
# async embed query
await embeddings.aembed_query("This is a content of the document")
```

```python
# async embed documents
await embeddings.aembed_documents(
    ["This is a content of the document", "This is another document"]
)
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)
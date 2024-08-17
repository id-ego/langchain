---
canonical: https://python.langchain.com/v0.2/docs/integrations/providers/vectara/vectara_chat/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/vectara/vectara_chat.ipynb
---

# Vectara Chat

[Vectara](https://vectara.com/) provides a Trusted Generative AI platform, allowing organizations to rapidly create a ChatGPT-like experience (an AI assistant) which is grounded in the data, documents, and knowledge that they have (technically, it is Retrieval-Augmented-Generation-as-a-service). 

Vectara serverless RAG-as-a-service provides all the components of RAG behind an easy-to-use API, including:
1. A way to extract text from files (PDF, PPT, DOCX, etc)
2. ML-based chunking that provides state of the art performance.
3. The [Boomerang](https://vectara.com/how-boomerang-takes-retrieval-augmented-generation-to-the-next-level-via-grounded-generation/) embeddings model.
4. Its own internal vector database where text chunks and embedding vectors are stored.
5. A query service that automatically encodes the query into embedding, and retrieves the most relevant text segments (including support for [Hybrid Search](https://docs.vectara.com/docs/api-reference/search-apis/lexical-matching) and [MMR](https://vectara.com/get-diverse-results-and-comprehensive-summaries-with-vectaras-mmr-reranker/))
7. An LLM to for creating a [generative summary](https://docs.vectara.com/docs/learn/grounded-generation/grounded-generation-overview), based on the retrieved documents (context), including citations.

See the [Vectara API documentation](https://docs.vectara.com/docs/) for more information on how to use the API.

This notebook shows how to use Vectara's [Chat](https://docs.vectara.com/docs/api-reference/chat-apis/chat-apis-overview) functionality.

# Getting Started

To get started, use the following steps:
1. If you don't already have one, [Sign up](https://www.vectara.com/integrations/langchain) for your free Vectara account. Once you have completed your sign up you will have a Vectara customer ID. You can find your customer ID by clicking on your name, on the top-right of the Vectara console window.
2. Within your account you can create one or more corpora. Each corpus represents an area that stores text data upon ingest from input documents. To create a corpus, use the **"Create Corpus"** button. You then provide a name to your corpus as well as a description. Optionally you can define filtering attributes and apply some advanced options. If you click on your created corpus, you can see its name and corpus ID right on the top.
3. Next you'll need to create API keys to access the corpus. Click on the **"Access Control"** tab in the corpus view and then the **"Create API Key"** button. Give your key a name, and choose whether you want query-only or query+index for your key. Click "Create" and you now have an active API key. Keep this key confidential. 

To use LangChain with Vectara, you'll need to have these three values: `customer ID`, `corpus ID` and `api_key`.
You can provide those to LangChain in two ways:

1. Include in your environment these three variables: `VECTARA_CUSTOMER_ID`, `VECTARA_CORPUS_ID` and `VECTARA_API_KEY`.

   For example, you can set these variables using os.environ and getpass as follows:

```python
import os
import getpass

os.environ["VECTARA_CUSTOMER_ID"] = getpass.getpass("Vectara Customer ID:")
os.environ["VECTARA_CORPUS_ID"] = getpass.getpass("Vectara Corpus ID:")
os.environ["VECTARA_API_KEY"] = getpass.getpass("Vectara API Key:")
```

2. Add them to the `Vectara` vectorstore constructor:

```python
vectara = Vectara(
                vectara_customer_id=vectara_customer_id,
                vectara_corpus_id=vectara_corpus_id,
                vectara_api_key=vectara_api_key
            )
```
In this notebook we assume they are provided in the environment.


```python
<!--IMPORTS:[{"imported": "Vectara", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.Vectara.html", "title": "Vectara Chat"}, {"imported": "RerankConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.RerankConfig.html", "title": "Vectara Chat"}, {"imported": "SummaryConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.SummaryConfig.html", "title": "Vectara Chat"}, {"imported": "VectaraQueryConfig", "source": "langchain_community.vectorstores.vectara", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.VectaraQueryConfig.html", "title": "Vectara Chat"}]-->
import os

os.environ["VECTARA_API_KEY"] = "<YOUR_VECTARA_API_KEY>"
os.environ["VECTARA_CORPUS_ID"] = "<YOUR_VECTARA_CORPUS_ID>"
os.environ["VECTARA_CUSTOMER_ID"] = "<YOUR_VECTARA_CUSTOMER_ID>"

from langchain_community.vectorstores import Vectara
from langchain_community.vectorstores.vectara import (
    RerankConfig,
    SummaryConfig,
    VectaraQueryConfig,
)
```

## Vectara Chat Explained

In most uses of LangChain to create chatbots, one must integrate a special `memory` component that maintains the history of chat sessions and then uses that history to ensure the chatbot is aware of conversation history.

With Vectara Chat - all of that is performed in the backend by Vectara automatically. You can look at the [Chat](https://docs.vectara.com/docs/api-reference/chat-apis/chat-apis-overview) documentation for the details, to learn more about the internals of how this is implemented, but with LangChain all you have to do is turn that feature on in the Vectara vectorstore.

Let's see an example. First we load the SOTU document (remember, text extraction and chunking all occurs automatically on the Vectara platform):


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Vectara Chat"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("state_of_the_union.txt")
documents = loader.load()

vectara = Vectara.from_documents(documents, embedding=None)
```

And now we create a Chat Runnable using the `as_chat` method:


```python
summary_config = SummaryConfig(is_enabled=True, max_results=7, response_lang="eng")
rerank_config = RerankConfig(reranker="mmr", rerank_k=50, mmr_diversity_bias=0.2)
config = VectaraQueryConfig(
    k=10, lambda_val=0.005, rerank_config=rerank_config, summary_config=summary_config
)

bot = vectara.as_chat(config)
```

Here's an example of asking a question with no chat history


```python
bot.invoke("What did the president say about Ketanji Brown Jackson?")["answer"]
```



```output
'The President expressed gratitude to Justice Breyer and highlighted the significance of nominating Ketanji Brown Jackson to the Supreme Court, praising her legal expertise and commitment to upholding excellence [1]. The President also reassured the public about the situation with gas prices and the conflict in Ukraine, emphasizing unity with allies and the belief that the world will emerge stronger from these challenges [2][4]. Additionally, the President shared personal experiences related to economic struggles and the importance of passing the American Rescue Plan to support those in need [3]. The focus was also on job creation and economic growth, acknowledging the impact of inflation on families [5]. While addressing cancer as a significant issue, the President discussed plans to enhance cancer research and support for patients and families [7].'
```


Here's an example of asking a question with some chat history


```python
bot.invoke("Did he mention who she suceeded?")["answer"]
```



```output
"In his remarks, the President specified that Ketanji Brown Jackson is succeeding Justice Breyer on the United States Supreme Court[1]. The President praised Jackson as a top legal mind who will continue Justice Breyer's legacy of excellence. The nomination of Jackson was highlighted as a significant constitutional responsibility of the President[1]. The President emphasized the importance of this nomination and the qualities that Jackson brings to the role. The focus was on the transition from Justice Breyer to Judge Ketanji Brown Jackson on the Supreme Court[1]."
```


## Chat with streaming

Of course the chatbot interface also supports streaming.
Instead of the `invoke` method you simply use `stream`:


```python
output = {}
curr_key = None
for chunk in bot.stream("what about her accopmlishments?"):
    for key in chunk:
        if key not in output:
            output[key] = chunk[key]
        else:
            output[key] += chunk[key]
        if key == "answer":
            print(chunk[key], end="", flush=True)
        curr_key = key
```
```output
Judge Ketanji Brown Jackson is a nominee for the United States Supreme Court, known for her legal expertise and experience as a former litigator. She is praised for her potential to continue the legacy of excellence on the Court[1]. While the search results provide information on various topics like innovation, economic growth, and healthcare initiatives, they do not directly address Judge Ketanji Brown Jackson's specific accomplishments. Therefore, I do not have enough information to answer this question.
```
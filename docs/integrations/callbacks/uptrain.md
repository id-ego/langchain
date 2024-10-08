---
canonical: https://python.langchain.com/v0.2/docs/integrations/callbacks/uptrain/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/uptrain.ipynb
---

<a target="_blank" href="https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/callbacks/uptrain.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>


# UpTrain

> UpTrain [[github](https://github.com/uptrain-ai/uptrain) || [website](https://uptrain.ai/) || [docs](https://docs.uptrain.ai/getting-started/introduction)] is an open-source platform to evaluate and improve LLM applications. It provides grades for 20+ preconfigured checks (covering language, code, embedding use cases), performs root cause analyses on instances of failure cases and provides guidance for resolving them.

## UpTrain Callback Handler

This notebook showcases the UpTrain callback handler seamlessly integrating into your pipeline, facilitating diverse evaluations. We have chosen a few evaluations that we deemed apt for evaluating the chains. These evaluations run automatically, with results displayed in the output. More details on UpTrain's evaluations can be found [here](https://github.com/uptrain-ai/uptrain?tab=readme-ov-file#pre-built-evaluations-we-offer-). 

Selected retievers from Langchain are highlighted for demonstration:

### 1. **Vanilla RAG**:
RAG plays a crucial role in retrieving context and generating responses. To ensure its performance and response quality, we conduct the following evaluations:

- **[Context Relevance](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-relevance)**: Determines if the context extracted from the query is relevant to the response.
- **[Factual Accuracy](https://docs.uptrain.ai/predefined-evaluations/context-awareness/factual-accuracy)**: Assesses if the LLM is hallcuinating or providing incorrect information.
- **[Response Completeness](https://docs.uptrain.ai/predefined-evaluations/response-quality/response-completeness)**: Checks if the response contains all the information requested by the query.

### 2. **Multi Query Generation**:
MultiQueryRetriever creates multiple variants of a question having a similar meaning to the original question. Given the complexity, we include the previous evaluations and add:

- **[Multi Query Accuracy](https://docs.uptrain.ai/predefined-evaluations/query-quality/multi-query-accuracy)**: Assures that the multi-queries generated mean the same as the original query.

### 3. **Context Compression and Reranking**:
Re-ranking involves reordering nodes based on relevance to the query and choosing top n nodes. Since the number of nodes can reduce once the re-ranking is complete, we perform the following evaluations:

- **[Context Reranking](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-reranking)**: Checks if the order of re-ranked nodes is more relevant to the query than the original order.
- **[Context Conciseness](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-conciseness)**: Examines whether the reduced number of nodes still provides all the required information.

These evaluations collectively ensure the robustness and effectiveness of the RAG, MultiQueryRetriever, and the Reranking process in the chain.

## Install Dependencies

```python
%pip install -qU langchain langchain_openai langchain-community uptrain faiss-cpu flashrank
```
```output
huggingface/tokenizers: The current process just got forked, after parallelism has already been used. Disabling parallelism to avoid deadlocks...
To disable this warning, you can either:
	- Avoid using `tokenizers` before the fork if possible
	- Explicitly set the environment variable TOKENIZERS_PARALLELISM=(true | false)
``````output
[33mWARNING: There was an error checking the latest version of pip.[0m[33m
[0mNote: you may need to restart the kernel to use updated packages.
```
NOTE: that you can also install `faiss-gpu` instead of `faiss-cpu` if you want to use the GPU enabled version of the library.

## Import Libraries

```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "UpTrain"}, {"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "UpTrain"}, {"imported": "FlashrankRerank", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/document_compressors/langchain_community.document_compressors.flashrank_rerank.FlashrankRerank.html", "title": "UpTrain"}, {"imported": "MultiQueryRetriever", "source": "langchain.retrievers.multi_query", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_query.MultiQueryRetriever.html", "title": "UpTrain"}, {"imported": "UpTrainCallbackHandler", "source": "langchain_community.callbacks.uptrain_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.uptrain_callback.UpTrainCallbackHandler.html", "title": "UpTrain"}, {"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "UpTrain"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "UpTrain"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers.string", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "UpTrain"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "UpTrain"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables.passthrough", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "UpTrain"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "UpTrain"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "UpTrain"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "UpTrain"}]-->
from getpass import getpass

from langchain.chains import RetrievalQA
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import FlashrankRerank
from langchain.retrievers.multi_query import MultiQueryRetriever
from langchain_community.callbacks.uptrain_callback import UpTrainCallbackHandler
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers.string import StrOutputParser
from langchain_core.prompts.chat import ChatPromptTemplate
from langchain_core.runnables.passthrough import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import (
    RecursiveCharacterTextSplitter,
)
```

## Load the documents

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
```

## Split the document into chunks

```python
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
chunks = text_splitter.split_documents(documents)
```

## Create the retriever

```python
embeddings = OpenAIEmbeddings()
db = FAISS.from_documents(chunks, embeddings)
retriever = db.as_retriever()
```

## Define the LLM

```python
llm = ChatOpenAI(temperature=0, model="gpt-4")
```

## Setup

UpTrain provides you with:
1. Dashboards with advanced drill-down and filtering options
2. Insights and common topics among failing cases
3. Observability and real-time monitoring of production data
4. Regression testing via seamless integration with your CI/CD pipelines

You can choose between the following options for evaluating using UpTrain:
### 1. **UpTrain's Open-Source Software (OSS)**:
You can use the open-source evaluation service to evaluate your model. In this case, you will need to provie an OpenAI API key. UpTrain uses the GPT models to evaluate the responses generated by the LLM. You can get yours [here](https://platform.openai.com/account/api-keys).

In order to view your evaluations in the UpTrain dashboard, you will need to set it up by running the following commands in your terminal:

```bash
git clone https://github.com/uptrain-ai/uptrain
cd uptrain
bash run_uptrain.sh
```

This will start the UpTrain dashboard on your local machine. You can access it at `http://localhost:3000/dashboard`.

Parameters:
- key_type="openai"
- api_key="OPENAI_API_KEY"
- project_name="PROJECT_NAME"

### 2. **UpTrain Managed Service and Dashboards**:
Alternatively, you can use UpTrain's managed service to evaluate your model. You can create a free UpTrain account [here](https://uptrain.ai/) and get free trial credits. If you want more trial credits, [book a call with the maintainers of UpTrain here](https://calendly.com/uptrain-sourabh/30min).

The benefits of using the managed service are:
1. No need to set up the UpTrain dashboard on your local machine.
2. Access to many LLMs without needing their API keys.

Once you perform the evaluations, you can view them in the UpTrain dashboard at `https://dashboard.uptrain.ai/dashboard`

Parameters:
- key_type="uptrain"
- api_key="UPTRAIN_API_KEY"
- project_name="PROJECT_NAME"

**Note:** The `project_name` will be the project name under which the evaluations performed will be shown in the UpTrain dashboard.

## Set the API key

The notebook will prompt you to enter the API key. You can choose between the OpenAI API key or the UpTrain API key by changing the `key_type` parameter in the cell below.

```python
KEY_TYPE = "openai"  # or "uptrain"
API_KEY = getpass()
```

# 1. Vanilla RAG

UpTrain callback handler will automatically capture the query, context and response once generated and will run the following three evaluations *(Graded from 0 to 1)* on the response:
- **[Context Relevance](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-relevance)**: Check if the context extractedfrom the query is relevant to the response.
- **[Factual Accuracy](https://docs.uptrain.ai/predefined-evaluations/context-awareness/factual-accuracy)**: Check how factually accurate the response is.
- **[Response Completeness](https://docs.uptrain.ai/predefined-evaluations/response-quality/response-completeness)**: Check if the response contains all the information that the query is asking for.

```python
# Create the RAG prompt
template = """Answer the question based only on the following context, which can include text and tables:
{context}
Question: {question}
"""
rag_prompt_text = ChatPromptTemplate.from_template(template)

# Create the chain
chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | rag_prompt_text
    | llm
    | StrOutputParser()
)

# Create the uptrain callback handler
uptrain_callback = UpTrainCallbackHandler(key_type=KEY_TYPE, api_key=API_KEY)
config = {"callbacks": [uptrain_callback]}

# Invoke the chain with a query
query = "What did the president say about Ketanji Brown Jackson"
docs = chain.invoke(query, config=config)
```
```output
[32m2024-04-17 17:03:44.969[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:05.809[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Response: The president mentioned that he had nominated Ketanji Brown Jackson to serve on the United States Supreme Court 4 days ago. He described her as one of the nation's top legal minds who will continue Justice Breyer’s legacy of excellence. He also mentioned that she is a former top litigator in private practice, a former federal public defender, and comes from a family of public school educators and police officers. He described her as a consensus builder and noted that since her nomination, she has received a broad range of support from various groups, including the Fraternal Order of Police and former judges appointed by both Democrats and Republicans.

Context Relevance Score: 1.0
Factual Accuracy Score: 1.0
Response Completeness Score: 1.0
```
# 2. Multi Query Generation

The **MultiQueryRetriever** is used to tackle the problem that the RAG pipeline might not return the best set of documents based on the query. It generates multiple queries that mean the same as the original query and then fetches documents for each.

To evluate this retriever, UpTrain will run the following evaluation:
- **[Multi Query Accuracy](https://docs.uptrain.ai/predefined-evaluations/query-quality/multi-query-accuracy)**: Checks if the multi-queries generated mean the same as the original query.

```python
# Create the retriever
multi_query_retriever = MultiQueryRetriever.from_llm(retriever=retriever, llm=llm)

# Create the uptrain callback
uptrain_callback = UpTrainCallbackHandler(key_type=KEY_TYPE, api_key=API_KEY)
config = {"callbacks": [uptrain_callback]}

# Create the RAG prompt
template = """Answer the question based only on the following context, which can include text and tables:
{context}
Question: {question}
"""
rag_prompt_text = ChatPromptTemplate.from_template(template)

chain = (
    {"context": multi_query_retriever, "question": RunnablePassthrough()}
    | rag_prompt_text
    | llm
    | StrOutputParser()
)

# Invoke the chain with a query
question = "What did the president say about Ketanji Brown Jackson"
docs = chain.invoke(question, config=config)
```
```output
[32m2024-04-17 17:04:10.675[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:16.804[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Multi Queries:
  - How did the president comment on Ketanji Brown Jackson?
  - What were the president's remarks regarding Ketanji Brown Jackson?
  - What statements has the president made about Ketanji Brown Jackson?

Multi Query Accuracy Score: 0.5
``````output
[32m2024-04-17 17:04:22.027[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:44.033[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Response: The president mentioned that he had nominated Circuit Court of Appeals Judge Ketanji Brown Jackson to serve on the United States Supreme Court 4 days ago. He described her as one of the nation's top legal minds who will continue Justice Breyer’s legacy of excellence. He also mentioned that since her nomination, she has received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans.

Context Relevance Score: 1.0
Factual Accuracy Score: 1.0
Response Completeness Score: 1.0
```
# 3. Context Compression and Reranking

The reranking process involves reordering nodes based on relevance to the query and choosing the top n nodes. Since the number of nodes can reduce once the reranking is complete, we perform the following evaluations:
- **[Context Reranking](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-reranking)**: Check if the order of re-ranked nodes is more relevant to the query than the original order.
- **[Context Conciseness](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-conciseness)**: Check if the reduced number of nodes still provides all the required information.

```python
# Create the retriever
compressor = FlashrankRerank()
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor, base_retriever=retriever
)

# Create the chain
chain = RetrievalQA.from_chain_type(llm=llm, retriever=compression_retriever)

# Create the uptrain callback
uptrain_callback = UpTrainCallbackHandler(key_type=KEY_TYPE, api_key=API_KEY)
config = {"callbacks": [uptrain_callback]}

# Invoke the chain with a query
query = "What did the president say about Ketanji Brown Jackson"
result = chain.invoke(query, config=config)
```
```output
[32m2024-04-17 17:04:46.462[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:53.561[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson

Context Conciseness Score: 0.0
Context Reranking Score: 1.0
``````output
[32m2024-04-17 17:04:56.947[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:05:16.551[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Response: The President mentioned that he nominated Circuit Court of Appeals Judge Ketanji Brown Jackson to serve on the United States Supreme Court 4 days ago. He described her as one of the nation's top legal minds who will continue Justice Breyer’s legacy of excellence.

Context Relevance Score: 1.0
Factual Accuracy Score: 1.0
Response Completeness Score: 0.5
```
# UpTrain's Dashboard and Insights

Here's a short video showcasing the dashboard and the insights:

![langchain_uptrain.gif](https://uptrain-assets.s3.ap-south-1.amazonaws.com/images/langchain/langchain_uptrain.gif)
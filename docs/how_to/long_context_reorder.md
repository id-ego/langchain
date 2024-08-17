---
canonical: https://python.langchain.com/v0.2/docs/how_to/long_context_reorder/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/long_context_reorder.ipynb
---

# How to reorder retrieved results to mitigate the "lost in the middle" effect

Substantial performance degradations in [RAG](/docs/tutorials/rag) applications have been [documented](https://arxiv.org/abs/2307.03172) as the number of retrieved documents grows (e.g., beyond ten). In brief: models are liable to miss relevant information in the middle of long contexts.

By contrast, queries against vector stores will typically return documents in descending order of relevance (e.g., as measured by cosine similarity of [embeddings](/docs/concepts/#embedding-models)).

To mitigate the ["lost in the middle"](https://arxiv.org/abs/2307.03172) effect, you can re-order documents after retrieval such that the most relevant documents are positioned at extrema (e.g., the first and last pieces of context), and the least relevant documents are positioned in the middle. In some cases this can help surface the most relevant information to LLMs.

The [LongContextReorder](https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.long_context_reorder.LongContextReorder.html) document transformer implements this re-ordering procedure. Below we demonstrate an example.


```python
%pip install --upgrade --quiet  sentence-transformers langchain-chroma langchain langchain-openai langchain-huggingface > /dev/null
```

First we embed some artificial documents and index them in an (in-memory) [Chroma](/docs/integrations/providers/chroma/) vector store. We will use [Hugging Face](/docs/integrations/text_embedding/huggingfacehub/) embeddings, but any LangChain vector store or embeddings model will suffice.


```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to reorder retrieved results to mitigate the \"lost in the middle\" effect"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "How to reorder retrieved results to mitigate the \"lost in the middle\" effect"}]-->
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings

# Get embeddings.
embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

texts = [
    "Basquetball is a great sport.",
    "Fly me to the moon is one of my favourite songs.",
    "The Celtics are my favourite team.",
    "This is a document about the Boston Celtics",
    "I simply love going to the movies",
    "The Boston Celtics won the game by 20 points",
    "This is just a random text.",
    "Elden Ring is one of the best games in the last 15 years.",
    "L. Kornet is one of the best Celtics players.",
    "Larry Bird was an iconic NBA player.",
]

# Create a retriever
retriever = Chroma.from_texts(texts, embedding=embeddings).as_retriever(
    search_kwargs={"k": 10}
)
query = "What can you tell me about the Celtics?"

# Get relevant documents ordered by relevance score
docs = retriever.invoke(query)
docs
```



```output
[Document(page_content='This is a document about the Boston Celtics'),
 Document(page_content='The Celtics are my favourite team.'),
 Document(page_content='L. Kornet is one of the best Celtics players.'),
 Document(page_content='The Boston Celtics won the game by 20 points'),
 Document(page_content='Larry Bird was an iconic NBA player.'),
 Document(page_content='Elden Ring is one of the best games in the last 15 years.'),
 Document(page_content='Basquetball is a great sport.'),
 Document(page_content='I simply love going to the movies'),
 Document(page_content='Fly me to the moon is one of my favourite songs.'),
 Document(page_content='This is just a random text.')]
```


Note that documents are returned in descending order of relevance to the query. The `LongContextReorder` document transformer will implement the re-ordering described above:


```python
<!--IMPORTS:[{"imported": "LongContextReorder", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.long_context_reorder.LongContextReorder.html", "title": "How to reorder retrieved results to mitigate the \"lost in the middle\" effect"}]-->
from langchain_community.document_transformers import LongContextReorder

# Reorder the documents:
# Less relevant document will be at the middle of the list and more
# relevant elements at beginning / end.
reordering = LongContextReorder()
reordered_docs = reordering.transform_documents(docs)

# Confirm that the 4 relevant documents are at beginning and end.
reordered_docs
```



```output
[Document(page_content='The Celtics are my favourite team.'),
 Document(page_content='The Boston Celtics won the game by 20 points'),
 Document(page_content='Elden Ring is one of the best games in the last 15 years.'),
 Document(page_content='I simply love going to the movies'),
 Document(page_content='This is just a random text.'),
 Document(page_content='Fly me to the moon is one of my favourite songs.'),
 Document(page_content='Basquetball is a great sport.'),
 Document(page_content='Larry Bird was an iconic NBA player.'),
 Document(page_content='L. Kornet is one of the best Celtics players.'),
 Document(page_content='This is a document about the Boston Celtics')]
```


Below, we show how to incorporate the re-ordered documents into a simple question-answering chain:


```python
<!--IMPORTS:[{"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "How to reorder retrieved results to mitigate the \"lost in the middle\" effect"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to reorder retrieved results to mitigate the \"lost in the middle\" effect"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to reorder retrieved results to mitigate the \"lost in the middle\" effect"}]-->
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

llm = OpenAI()

prompt_template = """
Given these texts:
-----
{context}
-----
Please answer the following question:
{query}
"""

prompt = PromptTemplate(
    template=prompt_template,
    input_variables=["context", "query"],
)

# Create and invoke the chain:
chain = create_stuff_documents_chain(llm, prompt)
response = chain.invoke({"context": reordered_docs, "query": query})
print(response)
```
```output

The Celtics are a professional basketball team and one of the most iconic franchises in the NBA. They are highly regarded and have a large fan base. The team has had many successful seasons and is often considered one of the top teams in the league. They have a strong history and have produced many great players, such as Larry Bird and L. Kornet. The team is based in Boston and is often referred to as the Boston Celtics.
```
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/long_context_reorder.ipynb
description: 검색된 결과를 재정렬하여 "중간에서 잃어버림" 효과를 완화하는 방법에 대해 설명합니다. LLM에 가장 관련성 높은 정보를 제공합니다.
---

# 검색된 결과를 재정렬하여 "중간에서 잃어버림" 효과를 완화하는 방법

[RAG](/docs/tutorials/rag) 애플리케이션에서 검색된 문서의 수가 증가함에 따라 (예: 10개를 초과) 성능 저하가 [문서화되었습니다](https://arxiv.org/abs/2307.03172). 간단히 말해: 모델은 긴 컨텍스트의 중간에서 관련 정보를 놓칠 가능성이 있습니다.

반대로, 벡터 저장소에 대한 쿼리는 일반적으로 관련성의 내림차순으로 문서를 반환합니다 (예: [임베딩](/docs/concepts/#embedding-models)의 코사인 유사도로 측정됨).

["중간에서 잃어버림"](https://arxiv.org/abs/2307.03172) 효과를 완화하기 위해, 검색 후 문서를 재정렬하여 가장 관련성이 높은 문서가 극단(예: 첫 번째 및 마지막 컨텍스트 조각)에 위치하고, 가장 관련성이 낮은 문서가 중간에 위치하도록 할 수 있습니다. 경우에 따라 이는 LLM에 가장 관련성이 높은 정보를 드러내는 데 도움이 될 수 있습니다.

[LongContextReorder](https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.long_context_reorder.LongContextReorder.html) 문서 변환기는 이 재정렬 절차를 구현합니다. 아래에 예시를 보여줍니다.

```python
%pip install --upgrade --quiet  sentence-transformers langchain-chroma langchain langchain-openai langchain-huggingface > /dev/null
```


먼저 인공 문서를 몇 개 임베딩하고 (메모리 내) [Chroma](/docs/integrations/providers/chroma/) 벡터 저장소에 인덱싱합니다. 우리는 [Hugging Face](/docs/integrations/text_embedding/huggingfacehub/) 임베딩을 사용할 것이지만, 어떤 LangChain 벡터 저장소나 임베딩 모델도 충분합니다.

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


문서가 쿼리에 대한 관련성의 내림차순으로 반환된다는 점에 유의하십시오. `LongContextReorder` 문서 변환기는 위에서 설명한 재정렬을 구현합니다:

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


아래에서는 재정렬된 문서를 간단한 질문-답변 체인에 통합하는 방법을 보여줍니다:

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
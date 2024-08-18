---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/inspect.ipynb
description: 이 문서는 LangChain Expression Language를 사용하여 실행 가능한 객체를 검사하는 방법과 내부 단계의
  프로그래밍적 통찰력을 제공합니다.
---

# 실행 가능한 항목 검사하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [연결 가능한 항목 연결하기](/docs/how_to/sequence/)

:::

[LangChain 표현 언어](/docs/concepts/#langchain-expression-language)를 사용하여 실행 가능한 항목을 생성한 후, 그 내부에서 무슨 일이 일어나고 있는지 더 잘 이해하기 위해 이를 검사하고 싶을 수 있습니다. 이 노트북에서는 이를 수행하는 몇 가지 방법을 다룹니다.

이 가이드는 체인의 내부 단계를 프로그래밍적으로 검사하는 몇 가지 방법을 보여줍니다. 체인에서 문제를 디버깅하는 데 관심이 있다면, 대신 [이 섹션](/docs/how_to/debugging)을 참조하세요.

먼저, 예제 체인을 만들어 보겠습니다. 우리는 검색을 수행하는 체인을 만들 것입니다:

```python
%pip install -qU langchain langchain-openai faiss-cpu tiktoken
```


```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to inspect runnables"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to inspect runnables"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to inspect runnables"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to inspect runnables"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to inspect runnables"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to inspect runnables"}]-->
from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

vectorstore = FAISS.from_texts(
    ["harrison worked at kensho"], embedding=OpenAIEmbeddings()
)
retriever = vectorstore.as_retriever()

template = """Answer the question based only on the following context:
{context}

Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

model = ChatOpenAI()

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)
```


## 그래프 가져오기

`get_graph()` 메서드를 사용하여 실행 가능한 항목의 그래프 표현을 가져올 수 있습니다:

```python
chain.get_graph()
```


## 그래프 출력하기

그것이 그리 읽기 쉽지는 않지만, `print_ascii()` 메서드를 사용하여 그래프를 이해하기 쉬운 방식으로 표시할 수 있습니다:

```python
chain.get_graph().print_ascii()
```

```output
           +---------------------------------+         
           | Parallel<context,question>Input |         
           +---------------------------------+         
                    **               **                
                 ***                   ***             
               **                         **           
+----------------------+              +-------------+  
| VectorStoreRetriever |              | Passthrough |  
+----------------------+              +-------------+  
                    **               **                
                      ***         ***                  
                         **     **                     
           +----------------------------------+        
           | Parallel<context,question>Output |        
           +----------------------------------+        
                             *                         
                             *                         
                             *                         
                  +--------------------+               
                  | ChatPromptTemplate |               
                  +--------------------+               
                             *                         
                             *                         
                             *                         
                      +------------+                   
                      | ChatOpenAI |                   
                      +------------+                   
                             *                         
                             *                         
                             *                         
                   +-----------------+                 
                   | StrOutputParser |                 
                   +-----------------+                 
                             *                         
                             *                         
                             *                         
                +-----------------------+              
                | StrOutputParserOutput |              
                +-----------------------+
```


## 프롬프트 가져오기

체인에서 사용되는 프롬프트만 보고 싶다면 `get_prompts()` 메서드를 사용할 수 있습니다:

```python
chain.get_prompts()
```


```output
[ChatPromptTemplate(input_variables=['context', 'question'], messages=[HumanMessagePromptTemplate(prompt=PromptTemplate(input_variables=['context', 'question'], template='Answer the question based only on the following context:\n{context}\n\nQuestion: {question}\n'))])]
```


## 다음 단계

이제 구성된 LCEL 체인을 검사하는 방법을 배웠습니다.

다음으로, 이 섹션의 실행 가능한 항목에 대한 다른 가이드나 [체인 디버깅](/docs/how_to/debugging)에 대한 관련 가이드를 확인하세요.
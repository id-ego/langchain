---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/sec_filings.ipynb
description: SEC 제출 문서는 미국 증권 거래 위원회에 제출되는 공식 문서로, 투자자와 금융 전문가가 기업 정보를 평가하는 데 사용됩니다.
---

# SEC 제출

> [SEC 제출](https://www.sec.gov/edgar)은 미국 증권 거래 위원회(SEC)에 제출된 재무 제표 또는 기타 공식 문서입니다. 공개 회사, 특정 내부자 및 중개인은 정기적으로 `SEC 제출`을 해야 합니다. 투자자와 금융 전문가들은 투자 목적을 위해 평가하는 회사에 대한 정보를 얻기 위해 이러한 제출을 신뢰합니다.
> 
> `SEC 제출` 데이터는 [Kay.ai](https://kay.ai)와 [Cybersyn](https://www.cybersyn.com/)의 지원을 받아 [Snowflake Marketplace](https://app.snowflake.com/marketplace/providers/GZTSZAS2KCS/Cybersyn%2C%20Inc)를 통해 제공됩니다.

## 설정

먼저, `kay` 패키지를 설치해야 합니다. API 키도 필요합니다: [https://kay.ai](https://kay.ai/)에서 무료로 받을 수 있습니다. API 키를 받으면 환경 변수 `KAY_API_KEY`로 설정해야 합니다.

이 예제에서는 `KayAiRetriever`를 사용할 것입니다. 수용 가능한 매개변수에 대한 자세한 정보는 [kay 노트북](/docs/integrations/retrievers/kay)을 참조하세요.

```python
# Setup API keys for Kay and OpenAI
from getpass import getpass

KAY_API_KEY = getpass()
OPENAI_API_KEY = getpass()
```

```output
 ········
 ········
```


```python
import os

os.environ["KAY_API_KEY"] = KAY_API_KEY
os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY
```


## 예제

```python
<!--IMPORTS:[{"imported": "ConversationalRetrievalChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.conversational_retrieval.base.ConversationalRetrievalChain.html", "title": "SEC filing"}, {"imported": "KayAiRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.kay.KayAiRetriever.html", "title": "SEC filing"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "SEC filing"}]-->
from langchain.chains import ConversationalRetrievalChain
from langchain_community.retrievers import KayAiRetriever
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-3.5-turbo")
retriever = KayAiRetriever.create(
    dataset_id="company", data_types=["10-K", "10-Q"], num_contexts=6
)
qa = ConversationalRetrievalChain.from_llm(model, retriever=retriever)
```


```python
questions = [
    "What are patterns in Nvidia's spend over the past three quarters?",
    # "What are some recent challenges faced by the renewable energy sector?",
]
chat_history = []

for question in questions:
    result = qa({"question": question, "chat_history": chat_history})
    chat_history.append((question, result["answer"]))
    print(f"-> **Question**: {question} \n")
    print(f"**Answer**: {result['answer']} \n")
```

```output
-> **Question**: What are patterns in Nvidia's spend over the past three quarters? 

**Answer**: Based on the provided information, here are the patterns in NVIDIA's spend over the past three quarters:

1. Research and Development Expenses:
   - Q3 2022: Increased by 34% compared to Q3 2021.
   - Q1 2023: Increased by 40% compared to Q1 2022.
   - Q2 2022: Increased by 25% compared to Q2 2021.
   
   Overall, research and development expenses have been consistently increasing over the past three quarters.

2. Sales, General and Administrative Expenses:
   - Q3 2022: Increased by 8% compared to Q3 2021.
   - Q1 2023: Increased by 14% compared to Q1 2022.
   - Q2 2022: Decreased by 16% compared to Q2 2021.
   
   The pattern for sales, general and administrative expenses is not as consistent, with some quarters showing an increase and others showing a decrease.

3. Total Operating Expenses:
   - Q3 2022: Increased by 25% compared to Q3 2021.
   - Q1 2023: Increased by 113% compared to Q1 2022.
   - Q2 2022: Increased by 9% compared to Q2 2021.
   
   Total operating expenses have generally been increasing over the past three quarters, with a significant increase in Q1 2023.

Overall, the pattern indicates a consistent increase in research and development expenses and total operating expenses, while sales, general and administrative expenses show some fluctuations.
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)
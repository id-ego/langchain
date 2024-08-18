---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/opaqueprompts.ipynb
description: OpaquePrompts는 사용자 프라이버시를 보호하며 언어 모델의 힘을 활용할 수 있는 서비스입니다. LangChain과
  통합하여 쉽게 사용할 수 있습니다.
---

# OpaquePrompts

[OpaquePrompts](https://opaqueprompts.readthedocs.io/en/latest/)는 사용자 프라이버시를 침해하지 않으면서 애플리케이션이 언어 모델의 힘을 활용할 수 있도록 하는 서비스입니다. 구성 가능성과 기존 애플리케이션 및 서비스에 통합하기 쉬운 방식으로 설계된 OpaquePrompts는 간단한 Python 라이브러리와 LangChain을 통해 사용할 수 있습니다. 아마도 더 중요한 것은 OpaquePrompts가 [기밀 컴퓨팅](https://en.wikipedia.org/wiki/Confidential_computing)의 힘을 활용하여 OpaquePrompts 서비스 자체가 보호하고 있는 데이터에 접근할 수 없도록 보장한다는 것입니다.

이 노트북은 LangChain을 사용하여 `OpaquePrompts`와 상호작용하는 방법을 설명합니다.

```python
# install the opaqueprompts and langchain packages
%pip install --upgrade --quiet  opaqueprompts langchain
```


OpaquePrompts API에 접근하려면 API 키가 필요하며, 이는 [OpaquePrompts 웹사이트](https://opaqueprompts.opaque.co/)에서 계정을 생성하여 얻을 수 있습니다. 계정을 만들면 [API 키 페이지](https:opaqueprompts.opaque.co/api-keys)에서 API 키를 찾을 수 있습니다.

```python
import os

# Set API keys

os.environ["OPAQUEPROMPTS_API_KEY"] = "<OPAQUEPROMPTS_API_KEY>"
os.environ["OPENAI_API_KEY"] = "<OPENAI_API_KEY>"
```


# OpaquePrompts LLM 래퍼 사용

OpaquePrompts를 애플리케이션에 적용하는 것은 `llm=OpenAI()`를 `llm=OpaquePrompts(base_llm=OpenAI())`로 바꾸는 것만으로도 간단할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "OpaquePrompts"}, {"imported": "set_debug", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_debug.html", "title": "OpaquePrompts"}, {"imported": "set_verbose", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_verbose.html", "title": "OpaquePrompts"}, {"imported": "ConversationBufferWindowMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer_window.ConversationBufferWindowMemory.html", "title": "OpaquePrompts"}, {"imported": "OpaquePrompts", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.opaqueprompts.OpaquePrompts.html", "title": "OpaquePrompts"}, {"imported": "StdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.stdout.StdOutCallbackHandler.html", "title": "OpaquePrompts"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OpaquePrompts"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "OpaquePrompts"}]-->
from langchain.chains import LLMChain
from langchain.globals import set_debug, set_verbose
from langchain.memory import ConversationBufferWindowMemory
from langchain_community.llms import OpaquePrompts
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

set_debug(True)
set_verbose(True)

prompt_template = """
As an AI assistant, you will answer questions according to given context.

Sensitive personal information in the question is masked for privacy.
For instance, if the original text says "Giana is good," it will be changed
to "PERSON_998 is good." 

Here's how to handle these changes:
* Consider these masked phrases just as placeholders, but still refer to
them in a relevant way when answering.
* It's possible that different masked terms might mean the same thing.
Stick with the given term and don't modify it.
* All masked terms follow the "TYPE_ID" pattern.
* Please don't invent new masked terms. For instance, if you see "PERSON_998,"
don't come up with "PERSON_997" or "PERSON_999" unless they're already in the question.

Conversation History: ```{history}```
Context : ```During our recent meeting on February 23, 2023, at 10:30 AM,
John Doe provided me with his personal details. His email is johndoe@example.com
and his contact number is 650-456-7890. He lives in New York City, USA, and
belongs to the American nationality with Christian beliefs and a leaning towards
the Democratic party. He mentioned that he recently made a transaction using his
credit card 4111 1111 1111 1111 and transferred bitcoins to the wallet address
1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa. While discussing his European travels, he noted
down his IBAN as GB29 NWBK 6016 1331 9268 19. Additionally, he provided his website
as https://johndoeportfolio.com. John also discussed some of his US-specific details.
He said his bank account number is 1234567890123456 and his drivers license is Y12345678.
His ITIN is 987-65-4321, and he recently renewed his passport, the number for which is
123456789. He emphasized not to share his SSN, which is 123-45-6789. Furthermore, he
mentioned that he accesses his work files remotely through the IP 192.168.1.1 and has
a medical license number MED-123456. ```
Question: ```{question}```

"""

chain = LLMChain(
    prompt=PromptTemplate.from_template(prompt_template),
    llm=OpaquePrompts(base_llm=OpenAI()),
    memory=ConversationBufferWindowMemory(k=2),
    verbose=True,
)


print(
    chain.run(
        {
            "question": """Write a message to remind John to do password reset for his website to stay secure."""
        },
        callbacks=[StdOutCallbackHandler()],
    )
)
```


출력에서 사용자 입력의 다음 컨텍스트가 민감한 데이터를 포함하고 있음을 알 수 있습니다.

```
# Context from user input

During our recent meeting on February 23, 2023, at 10:30 AM, John Doe provided me with his personal details. His email is johndoe@example.com and his contact number is 650-456-7890. He lives in New York City, USA, and belongs to the American nationality with Christian beliefs and a leaning towards the Democratic party. He mentioned that he recently made a transaction using his credit card 4111 1111 1111 1111 and transferred bitcoins to the wallet address 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa. While discussing his European travels, he noted down his IBAN as GB29 NWBK 6016 1331 9268 19. Additionally, he provided his website as https://johndoeportfolio.com. John also discussed some of his US-specific details. He said his bank account number is 1234567890123456 and his drivers license is Y12345678. His ITIN is 987-65-4321, and he recently renewed his passport, the number for which is 123456789. He emphasized not to share his SSN, which is 669-45-6789. Furthermore, he mentioned that he accesses his work files remotely through the IP 192.168.1.1 and has a medical license number MED-123456.
```


OpaquePrompts는 민감한 데이터를 자동으로 감지하고 이를 플레이스홀더로 대체합니다.

```
# Context after OpaquePrompts

During our recent meeting on DATE_TIME_3, at DATE_TIME_2, PERSON_3 provided me with his personal details. His email is EMAIL_ADDRESS_1 and his contact number is PHONE_NUMBER_1. He lives in LOCATION_3, LOCATION_2, and belongs to the NRP_3 nationality with NRP_2 beliefs and a leaning towards the Democratic party. He mentioned that he recently made a transaction using his credit card CREDIT_CARD_1 and transferred bitcoins to the wallet address CRYPTO_1. While discussing his NRP_1 travels, he noted down his IBAN as IBAN_CODE_1. Additionally, he provided his website as URL_1. PERSON_2 also discussed some of his LOCATION_1-specific details. He said his bank account number is US_BANK_NUMBER_1 and his drivers license is US_DRIVER_LICENSE_2. His ITIN is US_ITIN_1, and he recently renewed his passport, the number for which is DATE_TIME_1. He emphasized not to share his SSN, which is US_SSN_1. Furthermore, he mentioned that he accesses his work files remotely through the IP IP_ADDRESS_1 and has a medical license number MED-US_DRIVER_LICENSE_1.
```


플레이스홀더는 LLM 응답에서 사용됩니다.

```
# response returned by LLM

Hey PERSON_1, just wanted to remind you to do a password reset for your website URL_1 through your email EMAIL_ADDRESS_1. It's important to stay secure online, so don't forget to do it!
```


응답은 플레이스홀더를 원래의 민감한 데이터로 교체하여 비위생화됩니다.

```
# desanitized LLM response from OpaquePrompts

Hey John, just wanted to remind you to do a password reset for your website https://johndoeportfolio.com through your email johndoe@example.com. It's important to stay secure online, so don't forget to do it!
```


# LangChain 표현에서 OpaquePrompts 사용

드롭인 교체가 필요한 유연성을 제공하지 않는 경우 LangChain 표현과 함께 사용할 수 있는 함수가 있습니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "OpaquePrompts"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "OpaquePrompts"}]-->
import langchain_community.utilities.opaqueprompts as op
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

prompt = (PromptTemplate.from_template(prompt_template),)
llm = OpenAI()
pg_chain = (
    op.sanitize
    | RunnablePassthrough.assign(
        response=(lambda x: x["sanitized_input"]) | prompt | llm | StrOutputParser(),
    )
    | (lambda x: op.desanitize(x["response"], x["secure_context"]))
)

pg_chain.invoke(
    {
        "question": "Write a text message to remind John to do password reset for his website through his email to stay secure.",
        "history": "",
    }
)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
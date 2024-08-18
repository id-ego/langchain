---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/perplexity.ipynb
description: 이 문서는 `Perplexity` 채팅 모델을 시작하는 방법과 API 키 설정, 모델 선택, 프롬프트 구조화 방법을 다룹니다.
sidebar_label: Perplexity
---

# ChatPerplexity

이 노트북은 `Perplexity` 채팅 모델을 시작하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "ChatPerplexity", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.perplexity.ChatPerplexity.html", "title": "ChatPerplexity"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatPerplexity"}]-->
from langchain_community.chat_models import ChatPerplexity
from langchain_core.prompts import ChatPromptTemplate
```


제공된 코드는 PPLX_API_KEY가 환경 변수에 설정되어 있다고 가정합니다. API 키를 수동으로 지정하고 다른 모델을 선택하려면 다음 코드를 사용할 수 있습니다:

```python
chat = ChatPerplexity(
    temperature=0, pplx_api_key="YOUR_API_KEY", model="llama-3-sonar-small-32k-online"
)
```


사용 가능한 모델 목록은 [여기](https://docs.perplexity.ai/docs/model-cards)에서 확인할 수 있습니다. 재현성을 위해, 이 노트북에서 입력으로 API 키를 동적으로 설정할 수 있습니다.

```python
import os
from getpass import getpass

PPLX_API_KEY = getpass()
os.environ["PPLX_API_KEY"] = PPLX_API_KEY
```


```python
chat = ChatPerplexity(temperature=0, model="llama-3-sonar-small-32k-online")
```


```python
system = "You are a helpful assistant."
human = "{input}"
prompt = ChatPromptTemplate.from_messages([("system", system), ("human", human)])

chain = prompt | chat
response = chain.invoke({"input": "Why is the Higgs Boson important?"})
response.content
```


```output
'The Higgs Boson is an elementary subatomic particle that plays a crucial role in the Standard Model of particle physics, which accounts for three of the four fundamental forces governing the behavior of our universe: the strong and weak nuclear forces, electromagnetism, and gravity. The Higgs Boson is important for several reasons:\n\n1. **Final Elementary Particle**: The Higgs Boson is the last elementary particle waiting to be discovered under the Standard Model. Its detection helps complete the Standard Model and further our understanding of the fundamental forces in the universe.\n\n2. **Mass Generation**: The Higgs Boson is responsible for giving mass to other particles, a process that occurs through its interaction with the Higgs field. This mass generation is essential for the formation of atoms, molecules, and the visible matter we observe in the universe.\n\n3. **Implications for New Physics**: While the detection of the Higgs Boson has confirmed many aspects of the Standard Model, it also opens up new possibilities for discoveries beyond the Standard Model. Further research on the Higgs Boson could reveal insights into the nature of dark matter, supersymmetry, and other exotic phenomena.\n\n4. **Advancements in Technology**: The search for the Higgs Boson has led to significant advancements in technology, such as the development of artificial intelligence and machine learning algorithms used in particle accelerators like the Large Hadron Collider (LHC). These advancements have not only contributed to the discovery of the Higgs Boson but also have potential applications in various other fields.\n\nIn summary, the Higgs Boson is important because it completes the Standard Model, plays a crucial role in mass generation, hints at new physics phenomena beyond the Standard Model, and drives advancements in technology.\n'
```


프롬프트를 일반적으로 하듯이 형식화하고 구조화할 수 있습니다. 다음 예제에서는 모델에게 고양이에 대한 농담을 해달라고 요청합니다.

```python
chat = ChatPerplexity(temperature=0, model="llama-3-sonar-small-32k-online")
prompt = ChatPromptTemplate.from_messages([("human", "Tell me a joke about {topic}")])
chain = prompt | chat
response = chain.invoke({"topic": "cats"})
response.content
```


```output
'Here\'s a joke about cats:\n\nWhy did the cat want math lessons from a mermaid?\n\nBecause it couldn\'t find its "core purpose" in life!\n\nRemember, cats are unique and fascinating creatures, and each one has its own special traits and abilities. While some may see them as mysterious or even a bit aloof, they are still beloved pets that bring joy and companionship to their owners. So, if your cat ever seeks guidance from a mermaid, just remember that they are on their own journey to self-discovery!\n'
```


## `ChatPerplexity`는 스트리밍 기능도 지원합니다:

```python
chat = ChatPerplexity(temperature=0.7, model="llama-3-sonar-small-32k-online")
prompt = ChatPromptTemplate.from_messages(
    [("human", "Give me a list of famous tourist attractions in Pakistan")]
)
chain = prompt | chat
for chunk in chain.stream({}):
    print(chunk.content, end="", flush=True)
```

```output
Here is a list of some famous tourist attractions in Pakistan:

1. **Minar-e-Pakistan**: A 62-meter high minaret in Lahore that represents the history of Pakistan.
2. **Badshahi Mosque**: A historic mosque in Lahore with a capacity of 10,000 worshippers.
3. **Shalimar Gardens**: A beautiful garden in Lahore with landscaped grounds and a series of cascading pools.
4. **Pakistan Monument**: A national monument in Islamabad representing the four provinces and three districts of Pakistan.
5. **National Museum of Pakistan**: A museum in Karachi showcasing the country's cultural history.
6. **Faisal Mosque**: A large mosque in Islamabad that can accommodate up to 300,000 worshippers.
7. **Clifton Beach**: A popular beach in Karachi offering water activities and recreational facilities.
8. **Kartarpur Corridor**: A visa-free border crossing and religious corridor connecting Gurdwara Darbar Sahib in Pakistan to Gurudwara Sri Kartarpur Sahib in India.
9. **Mohenjo-daro**: An ancient Indus Valley civilization site in Sindh, Pakistan, dating back to around 2500 BCE.
10. **Hunza Valley**: A picturesque valley in Gilgit-Baltistan known for its stunning mountain scenery and unique culture.

These attractions showcase the rich history, diverse culture, and natural beauty of Pakistan, making them popular destinations for both local and international tourists.
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)
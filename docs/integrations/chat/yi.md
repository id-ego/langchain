---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/yi/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/yi.ipynb
---

# ChatYI

This will help you getting started with Yi [chat models](/docs/concepts/#chat-models). For detailed documentation of all ChatYi features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/chat_models/lanchain_community.chat_models.yi.ChatYi.html).

[01.AI](https://www.lingyiwanwu.com/en), founded by Dr. Kai-Fu Lee, is a global company at the forefront of AI 2.0. They offer cutting-edge large language models, including the Yi series, which range from 6B to hundreds of billions of parameters. 01.AI also provides multimodal models, an open API platform, and open-source options like Yi-34B/9B/6B and Yi-VL.

## Overview
### Integration details

| Class | Package | Local | Serializable | JS support | Package downloads | Package latest |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatYi](https://api.python.langchain.com/en/latest/chat_models/lanchain_community.chat_models.yi.ChatYi.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

### Model features
| [Tool calling](/docs/how_to/tool_calling) | [Structured output](/docs/how_to/structured_output/) | JSON mode | [Image input](/docs/how_to/multimodal_inputs/) | Audio input | Video input | [Token-level streaming](/docs/how_to/chat_streaming/) | Native async | [Token usage](/docs/how_to/chat_token_usage_tracking/) | [Logprobs](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | 

## Setup

To access ChatYi models you'll need to create a/an 01.AI account, get an API key, and install the `langchain_community` integration package.

### Credentials

Head to [01.AI](https://platform.01.ai) to sign up to 01.AI and generate an API key. Once you've done this set the `YI_API_KEY` environment variable:

```python
import getpass
import os

os.environ["YI_API_KEY"] = getpass.getpass("Enter your Yi API key: ")
```

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

The LangChain **ModuleName** integration lives in the `langchain_community` package:

```python
%pip install -qU langchain_community
```

## Instantiation

Now we can instantiate our model object and generate chat completions:

- TODO: Update model instantiation with relevant params.

```python
<!--IMPORTS:[{"imported": "ChatYi", "source": "langchain_community.chat_models.yi", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yi.ChatYi.html", "title": "ChatYI"}]-->
from langchain_community.chat_models.yi import ChatYi

llm = ChatYi(
    model="yi-large",
    temperature=0,
    timeout=60,
    yi_api_base="https://api.01.ai/v1/chat/completions",
    # other params...
)
```

## Invocation

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatYI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatYI"}]-->
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="You are an AI assistant specializing in technology trends."),
    HumanMessage(
        content="What are the potential applications of large language models in healthcare?"
    ),
]

ai_msg = llm.invoke(messages)
ai_msg
```

```output
AIMessage(content="Large Language Models (LLMs) have the potential to significantly impact healthcare by enhancing various aspects of patient care, research, and administrative processes. Here are some potential applications:\n\n1. **Clinical Documentation and Reporting**: LLMs can assist in generating patient reports and documentation by understanding and summarizing clinical notes, making the process more efficient and reducing the administrative burden on healthcare professionals.\n\n2. **Medical Coding and Billing**: These models can help in automating the coding process for medical billing by accurately translating clinical notes into standardized codes, reducing errors and improving billing efficiency.\n\n3. **Clinical Decision Support**: LLMs can analyze patient data and medical literature to provide evidence-based recommendations to healthcare providers, aiding in diagnosis and treatment planning.\n\n4. **Patient Education and Communication**: By simplifying medical jargon, LLMs can help in educating patients about their conditions, treatment options, and preventive care, improving patient engagement and health literacy.\n\n5. **Natural Language Processing (NLP) for EHRs**: LLMs can enhance NLP capabilities in Electronic Health Records (EHRs) systems, enabling better extraction of information from unstructured data, such as clinical notes, to support data-driven decision-making.\n\n6. **Drug Discovery and Development**: LLMs can analyze biomedical literature and clinical trial data to identify new drug candidates, predict drug interactions, and support the development of personalized medicine.\n\n7. **Telemedicine and Virtual Health Assistants**: Integrated into telemedicine platforms, LLMs can provide preliminary assessments and triage, offering patients basic health advice and determining the urgency of their needs, thus optimizing the utilization of healthcare resources.\n\n8. **Research and Literature Review**: LLMs can expedite the process of reviewing medical literature by quickly identifying relevant studies and summarizing findings, accelerating research and evidence-based practice.\n\n9. **Personalized Medicine**: By analyzing a patient's genetic information and medical history, LLMs can help in tailoring treatment plans and medication dosages, contributing to the advancement of personalized medicine.\n\n10. **Quality Improvement and Risk Assessment**: LLMs can analyze healthcare data to identify patterns that may indicate areas for quality improvement or potential risks, such as hospital-acquired infections or adverse drug events.\n\n11. **Mental Health Support**: LLMs can provide mental health support by offering coping strategies, mindfulness exercises, and preliminary assessments, serving as a complement to professional mental health services.\n\n12. **Continuing Medical Education (CME)**: LLMs can personalize CME by recommending educational content based on a healthcare provider's practice area, patient demographics, and emerging medical literature, ensuring that professionals stay updated with the latest advancements.\n\nWhile the applications of LLMs in healthcare are promising, it's crucial to address challenges such as data privacy, model bias, and the need for regulatory approval to ensure that these technologies are implemented safely and ethically.", response_metadata={'token_usage': {'completion_tokens': 656, 'prompt_tokens': 40, 'total_tokens': 696}, 'model': 'yi-large'}, id='run-870850bd-e4bf-4265-8730-1736409c0acf-0')
```

## Chaining

We can [chain](/docs/how_to/sequence/) our model with a prompt template like so:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatYI"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant that translates {input_language} to {output_language}.",
        ),
        ("human", "{input}"),
    ]
)

chain = prompt | llm
chain.invoke(
    {
        "input_language": "English",
        "output_language": "German",
        "input": "I love programming.",
    }
)
```

```output
AIMessage(content='Ich liebe das Programmieren.', response_metadata={'token_usage': {'completion_tokens': 8, 'prompt_tokens': 33, 'total_tokens': 41}, 'model': 'yi-large'}, id='run-daa3bc58-8289-4d72-a24e-80622fa90d6d-0')
```

## API reference

For detailed documentation of all ChatYi features and configurations head to the API reference: https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yi.ChatYi.html

## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)
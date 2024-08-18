---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/cogniswitch.ipynb
description: CogniSwitch는 Langchain 프레임워크를 사용하여 지식을 효율적으로 소비, 조직 및 검색할 수 있는 프로덕션 준비
  애플리케이션을 구축하는 도구입니다.
---

# Cogniswitch Toolkit

CogniSwitch는 지식을 완벽하게 소비, 조직 및 검색할 수 있는 생산 준비 애플리케이션을 구축하는 데 사용됩니다. 이 경우 Langchain과 같은 선택한 프레임워크를 사용하여 CogniSwitch는 올바른 저장 및 검색 형식을 선택할 때 의사 결정의 스트레스를 완화하는 데 도움을 줍니다. 또한 생성된 응답에 대한 신뢰성 문제와 환각을 제거합니다.

## Setup

[Cogniswitch 계정을 등록하려면 이 페이지를 방문하세요](https://www.cogniswitch.ai/developer?utm_source=langchain&utm_medium=langchainbuild&utm_id=dev).

- 이메일로 가입하고 등록을 확인하세요.
- 서비스 사용을 위한 플랫폼 토큰과 OAuth 토큰이 포함된 메일을 받게 됩니다.

```python
%pip install -qU langchain-community
```


## 필요한 라이브러리 가져오기

```python
<!--IMPORTS:[{"imported": "create_conversational_retrieval_agent", "source": "langchain.agents.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_toolkits.conversational_retrieval.openai_functions.create_conversational_retrieval_agent.html", "title": "Cogniswitch Toolkit"}, {"imported": "CogniswitchToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.cogniswitch.toolkit.CogniswitchToolkit.html", "title": "Cogniswitch Toolkit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Cogniswitch Toolkit"}]-->
import warnings

warnings.filterwarnings("ignore")

import os

from langchain.agents.agent_toolkits import create_conversational_retrieval_agent
from langchain_community.agent_toolkits import CogniswitchToolkit
from langchain_openai import ChatOpenAI
```


## Cogniswitch 플랫폼 토큰, OAuth 토큰 및 OpenAI API 키

```python
cs_token = "Your CogniSwitch token"
OAI_token = "Your OpenAI API token"
oauth_token = "Your CogniSwitch authentication token"

os.environ["OPENAI_API_KEY"] = OAI_token
```


## 자격 증명으로 cogniswitch 툴킷 인스턴스화

```python
cogniswitch_toolkit = CogniswitchToolkit(
    cs_token=cs_token, OAI_token=OAI_token, apiKey=oauth_token
)
```


### cogniswitch 도구 목록 가져오기

```python
tool_lst = cogniswitch_toolkit.get_tools()
```


## LLM 인스턴스화

```python
llm = ChatOpenAI(
    temperature=0,
    openai_api_key=OAI_token,
    max_tokens=1500,
    model_name="gpt-3.5-turbo-0613",
)
```


## 툴킷과 함께 LLM 사용하기

### LLM 및 툴킷으로 에이전트 생성

```python
agent_executor = create_conversational_retrieval_agent(llm, tool_lst, verbose=False)
```


### URL 업로드를 위해 에이전트 호출

```python
response = agent_executor.invoke("upload this url https://cogniswitch.ai/developer")

print(response["output"])
```

```output
The URL https://cogniswitch.ai/developer has been uploaded successfully. The status of the document is currently being processed. You will receive an email notification once the processing is complete.
```

### 파일 업로드를 위해 에이전트 호출

```python
response = agent_executor.invoke("upload this file example_file.txt")

print(response["output"])
```

```output
The file example_file.txt has been uploaded successfully. The status of the document is currently being processed. You will receive an email notification once the processing is complete.
```

### 문서 상태를 가져오기 위해 에이전트 호출

```python
response = agent_executor.invoke("Tell me the status of this document example_file.txt")

print(response["output"])
```

```output
The status of the document example_file.txt is as follows:

- Created On: 2024-01-22T19:07:42.000+00:00
- Modified On: 2024-01-22T19:07:42.000+00:00
- Document Entry ID: 153
- Status: 0 (Processing)
- Original File Name: example_file.txt
- Saved File Name: 1705950460069example_file29393011.txt

The document is currently being processed.
```

### 쿼리와 함께 에이전트를 호출하고 답변 받기

```python
response = agent_executor.invoke("How can cogniswitch help develop GenAI applications?")

print(response["output"])
```

```output
CogniSwitch can help develop GenAI applications in several ways:

1. Knowledge Extraction: CogniSwitch can extract knowledge from various sources such as documents, websites, and databases. It can analyze and store data from these sources, making it easier to access and utilize the information for GenAI applications.

2. Natural Language Processing: CogniSwitch has advanced natural language processing capabilities. It can understand and interpret human language, allowing GenAI applications to interact with users in a more conversational and intuitive manner.

3. Sentiment Analysis: CogniSwitch can analyze the sentiment of text data, such as customer reviews or social media posts. This can be useful in developing GenAI applications that can understand and respond to the emotions and opinions of users.

4. Knowledge Base Integration: CogniSwitch can integrate with existing knowledge bases or create new ones. This allows GenAI applications to access a vast amount of information and provide accurate and relevant responses to user queries.

5. Document Analysis: CogniSwitch can analyze documents and extract key information such as entities, relationships, and concepts. This can be valuable in developing GenAI applications that can understand and process large amounts of textual data.

Overall, CogniSwitch provides a range of AI-powered capabilities that can enhance the development of GenAI applications by enabling knowledge extraction, natural language processing, sentiment analysis, knowledge base integration, and document analysis.
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
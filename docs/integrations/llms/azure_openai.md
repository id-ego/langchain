---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/azure_openai.ipynb
description: 이 문서는 Azure OpenAI와 LangChain을 사용하는 방법을 설명하며, API 구성 및 Azure OpenAI의
  사용법에 대한 정보를 제공합니다.
---

# Azure OpenAI

:::caution
현재 Azure OpenAI [텍스트 완성 모델](/docs/concepts/#llms) 사용에 대한 문서 페이지에 있습니다. 최신 및 가장 인기 있는 Azure OpenAI 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)입니다.

특별히 `gpt-3.5-turbo-instruct`를 사용하지 않는 한, 아마도 [대신 이 페이지](/docs/integrations/chat/azure_chat_openai/)를 찾고 있을 것입니다.
:::

이 페이지에서는 LangChain을 [Azure OpenAI](https://aka.ms/azure-openai)와 함께 사용하는 방법을 다룹니다.

Azure OpenAI API는 OpenAI의 API와 호환됩니다. `openai` Python 패키지를 사용하면 OpenAI와 Azure OpenAI를 쉽게 사용할 수 있습니다. 아래에 언급된 예외를 제외하고는 OpenAI를 호출하는 것과 동일한 방식으로 Azure OpenAI를 호출할 수 있습니다.

## API 구성
환경 변수를 사용하여 `openai` 패키지를 Azure OpenAI를 사용하도록 구성할 수 있습니다. 다음은 `bash`에 대한 것입니다:

```bash
# The API version you want to use: set this to `2023-12-01-preview` for the released version.
export OPENAI_API_VERSION=2023-12-01-preview
# The base URL for your Azure OpenAI resource.  You can find this in the Azure portal under your Azure OpenAI resource.
export AZURE_OPENAI_ENDPOINT=https://your-resource-name.openai.azure.com
# The API key for your Azure OpenAI resource.  You can find this in the Azure portal under your Azure OpenAI resource.
export AZURE_OPENAI_API_KEY=<your Azure OpenAI API key>
```


또는 실행 중인 Python 환경 내에서 API를 직접 구성할 수 있습니다:

```python
import os
os.environ["OPENAI_API_VERSION"] = "2023-12-01-preview"
```


## Azure Active Directory 인증
Azure OpenAI에 인증하는 두 가지 방법이 있습니다:
- API 키
- Azure Active Directory (AAD)

API 키를 사용하는 것이 시작하기 가장 쉬운 방법입니다. Azure 포털에서 Azure OpenAI 리소스 아래에서 API 키를 찾을 수 있습니다.

그러나 복잡한 보안 요구 사항이 있는 경우 Azure Active Directory를 사용하고 싶을 수 있습니다. AAD를 Azure OpenAI와 함께 사용하는 방법에 대한 자세한 정보는 [여기](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/managed-identity)에서 확인할 수 있습니다.

로컬에서 개발하는 경우 Azure CLI가 설치되어 있고 로그인되어 있어야 합니다. Azure CLI는 [여기](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)에서 설치할 수 있습니다. 그런 다음 `az login`을 실행하여 로그인합니다.

Azure OpenAI 리소스에 범위가 지정된 Azure 역할 할당 `Cognitive Services OpenAI User` 역할을 추가합니다. 이를 통해 Azure OpenAI와 함께 사용할 AAD에서 토큰을 가져올 수 있습니다. 이 역할 할당은 사용자, 그룹, 서비스 주체 또는 관리되는 ID에 부여할 수 있습니다. Azure OpenAI RBAC 역할에 대한 자세한 내용은 [여기](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/role-based-access-control)에서 확인하십시오.

LangChain을 사용하여 Python에서 AAD를 사용하려면 `azure-identity` 패키지를 설치합니다. 그런 다음 `OPENAI_API_TYPE`을 `azure_ad`로 설정합니다. 다음으로, 아래와 같이 `get_token`을 호출하여 AAD에서 토큰을 가져오기 위해 `DefaultAzureCredential` 클래스를 사용합니다. 마지막으로, `OPENAI_API_KEY` 환경 변수를 토큰 값으로 설정합니다.

```python
import os
from azure.identity import DefaultAzureCredential

# Get the Azure Credential
credential = DefaultAzureCredential()

# Set the API type to `azure_ad`
os.environ["OPENAI_API_TYPE"] = "azure_ad"
# Set the API_KEY to the token from the Azure credential
os.environ["OPENAI_API_KEY"] = credential.get_token("https://cognitiveservices.azure.com/.default").token
```


`DefaultAzureCredential` 클래스는 AAD 인증을 시작하는 쉬운 방법입니다. 필요에 따라 자격 증명 체인을 사용자 지정할 수도 있습니다. 아래 예제에서는 먼저 관리되는 ID를 시도한 다음 Azure CLI로 대체합니다. 이는 Azure에서 코드를 실행하지만 로컬에서 개발하고 싶을 때 유용합니다.

```python
from azure.identity import ChainedTokenCredential, ManagedIdentityCredential, AzureCliCredential

credential = ChainedTokenCredential(
    ManagedIdentityCredential(),
    AzureCliCredential()
)
```


## 배포
Azure OpenAI를 사용하면 일반 GPT-3 및 Codex 모델의 자체 배포를 설정할 수 있습니다. API를 호출할 때 사용하려는 배포를 지정해야 합니다.

***참고**: 이 문서는 Azure 텍스트 완성 모델에 대한 것입니다. GPT-4와 같은 모델은 채팅 모델입니다. 이들은 약간 다른 인터페이스를 가지고 있으며 `AzureChatOpenAI` 클래스를 통해 접근할 수 있습니다. Azure 채팅에 대한 문서는 [Azure Chat OpenAI 문서](/docs/integrations/chat/azure_chat_openai)를 참조하십시오.*

배포 이름이 `gpt-35-turbo-instruct-prod`라고 가정해 보겠습니다. `openai` Python API에서 이 배포를 `engine` 매개변수로 지정할 수 있습니다. 예를 들어:

```python
import openai

client = AzureOpenAI(
    api_version="2023-12-01-preview",
)

response = client.completions.create(
    model="gpt-35-turbo-instruct-prod",
    prompt="Test prompt"
)
```


```python
%pip install --upgrade --quiet  langchain-openai
```


```python
import os

os.environ["OPENAI_API_VERSION"] = "2023-12-01-preview"
os.environ["AZURE_OPENAI_ENDPOINT"] = "..."
os.environ["AZURE_OPENAI_API_KEY"] = "..."
```


```python
<!--IMPORTS:[{"imported": "AzureOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.azure.AzureOpenAI.html", "title": "Azure OpenAI"}]-->
# Import Azure OpenAI
from langchain_openai import AzureOpenAI
```


```python
# Create an instance of Azure OpenAI
# Replace the deployment name with your own
llm = AzureOpenAI(
    deployment_name="gpt-35-turbo-instruct-0914",
)
```


```python
# Run the LLM
llm.invoke("Tell me a joke")
```


```output
" Why couldn't the bicycle stand up by itself?\n\nBecause it was two-tired!"
```


LLM을 인쇄하고 사용자 지정 인쇄를 확인할 수도 있습니다.

```python
print(llm)
```

```output
[1mAzureOpenAI[0m
Params: {'deployment_name': 'gpt-35-turbo-instruct-0914', 'model_name': 'gpt-3.5-turbo-instruct', 'temperature': 0.7, 'top_p': 1, 'frequency_penalty': 0, 'presence_penalty': 0, 'n': 1, 'logit_bias': {}, 'max_tokens': 256}
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
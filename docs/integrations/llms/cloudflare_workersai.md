---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/cloudflare_workersai.ipynb
description: Cloudflare Workers AI 문서로, 생성 텍스트 모델과 API 인증 방법을 안내합니다. LLM 관련 자료도 포함되어
  있습니다.
---

# 클라우드플레어 워커스 AI

[클라우드플레어 AI 문서](https://developers.cloudflare.com/workers-ai/models/text-generation/)에는 사용 가능한 모든 생성 텍스트 모델이 나열되어 있습니다.

클라우드플레어 계정 ID와 API 토큰이 필요합니다. 이를 얻는 방법은 [이 문서](https://developers.cloudflare.com/workers-ai/get-started/rest-api/)에서 확인하세요.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Cloudflare Workers AI"}, {"imported": "CloudflareWorkersAI", "source": "langchain_community.llms.cloudflare_workersai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.cloudflare_workersai.CloudflareWorkersAI.html", "title": "Cloudflare Workers AI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Cloudflare Workers AI"}]-->
from langchain.chains import LLMChain
from langchain_community.llms.cloudflare_workersai import CloudflareWorkersAI
from langchain_core.prompts import PromptTemplate

template = """Human: {question}

AI Assistant: """

prompt = PromptTemplate.from_template(template)
```


LLM을 실행하기 전에 인증을 받으세요.

```python
import getpass

my_account_id = getpass.getpass("Enter your Cloudflare account ID:\n\n")
my_api_token = getpass.getpass("Enter your Cloudflare API token:\n\n")
llm = CloudflareWorkersAI(account_id=my_account_id, api_token=my_api_token)
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "Why are roses red?"
llm_chain.run(question)
```


```output
"AI Assistant: Ah, a fascinating question! The answer to why roses are red is a bit complex, but I'll do my best to explain it in a simple and polite manner.\nRoses are red due to the presence of a pigment called anthocyanin. Anthocyanin is a type of flavonoid, a class of plant compounds that are responsible for the red, purple, and blue colors found in many fruits and vegetables.\nNow, you might be wondering why roses specifically have this pigment. The answer lies in the evolutionary history of roses. You see, roses have been around for millions of years, and their red color has likely played a crucial role in attracting pollinators like bees and butterflies. These pollinators are drawn to the bright colors of roses, which helps the plants reproduce and spread their seeds.\nSo, to summarize, the reason roses are red is because of the anthocyanin pigment, which is a result of millions of years of evolutionary pressures shaping the plant's coloration to attract pollinators. I hope that helps clarify things for"
```


```python
# Using streaming
for chunk in llm.stream("Why is sky blue?"):
    print(chunk, end=" | ", flush=True)
```

```output
Ah | , |  a |  most |  excellent |  question | , |  my |  dear |  human | ! |  * | ad | just | s |  glass | es | * |  The |  sky |  appears |  blue |  due |  to |  a |  phenomen | on |  known |  as |  Ray | le | igh |  scatter | ing | . |  When |  sun | light |  enters |  Earth | ' | s |  atmosphere | , |  it |  enc | oun | ters |  tiny |  mole | cules |  of |  g | ases |  such |  as |  nit | ro | gen |  and |  o | xygen | . |  These |  mole | cules |  scatter |  the |  light |  in |  all |  directions | , |  but |  they |  scatter |  shorter |  ( | blue | ) |  w | avel | ength | s |  more |  than |  longer |  ( | red | ) |  w | avel | ength | s | . |  This |  is |  known |  as |  Ray | le | igh |  scatter | ing | . | 
 | As |  a |  result | , |  the |  blue |  light |  is |  dispers | ed |  throughout |  the |  atmosphere | , |  giving |  the |  sky |  its |  characteristic |  blue |  h | ue | . |  The |  blue |  light |  appears |  more |  prominent |  during |  sun | r | ise |  and |  sun | set |  due |  to |  the |  scatter | ing |  of |  light |  by |  the |  Earth | ' | s |  atmosphere |  at |  these |  times | . | 
 | I |  hope |  this |  explanation |  has |  been |  helpful | , |  my |  dear |  human | ! |  Is |  there |  anything |  else |  you |  would |  like |  to |  know | ? |  * | sm | iles | * | * |  |
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)
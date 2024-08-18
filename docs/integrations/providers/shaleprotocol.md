---
description: Shale Protocol은 오픈 LLM을 위한 생산 준비 완료 인퍼런스 API를 제공하며, 무료로 1K 요청을 지원합니다.
---

# 셰일 프로토콜

[셰일 프로토콜](https://shaleprotocol.com)은 오픈 LLM을 위한 생산 준비 완료 추론 API를 제공합니다. 이는 고도로 확장 가능한 GPU 클라우드 인프라에 호스팅된 플러그 앤 플레이 API입니다.

우리의 무료 요금제는 하루 최대 1K 요청을 지원하며, 이는 누구나 LLM으로 genAI 앱을 구축하는 장벽을 없애고자 하는 것입니다.

셰일 프로토콜을 통해 개발자/연구자는 비용 없이 앱을 만들고 오픈 LLM의 기능을 탐색할 수 있습니다.

이 페이지에서는 셰일-서브 API가 LangChain과 어떻게 통합될 수 있는지를 다룹니다.

2023년 6월 기준으로, API는 기본적으로 Vicuna-13B를 지원합니다. 향후 릴리스에서는 Falcon-40B와 같은 더 많은 LLM을 지원할 예정입니다.

## 방법

### 1. https://shaleprotocol.com에서 우리의 Discord 링크를 찾습니다. Discord의 "셰일 봇"을 통해 API 키를 생성합니다. 신용카드는 필요 없으며 무료 체험도 없습니다. 하루 1K 제한이 있는 영구 무료 요금제입니다.

### 2. OpenAI API의 드롭인 대체로 https://shale.live/v1를 사용합니다.

예를 들어
```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Shale Protocol"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Shale Protocol"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Shale Protocol"}]-->
from langchain_openai import OpenAI
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

import os
os.environ['OPENAI_API_BASE'] = "https://shale.live/v1"
os.environ['OPENAI_API_KEY'] = "ENTER YOUR API KEY"

llm = OpenAI()

template = """Question: {question}

# Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)


llm_chain = prompt | llm | StrOutputParser()

question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.invoke(question)

```
---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/langsmith_llm_runs.ipynb
description: 이 문서는 LangSmith의 LLM 실행 데이터를 로드하고 모델을 미세 조정하는 방법을 설명합니다. 간단한 3단계 프로세스를
  따릅니다.
---

# LangSmith LLM 실행

이 노트북은 LangSmith의 LLM 실행에서 데이터를 직접 로드하고 해당 데이터로 모델을 미세 조정하는 방법을 보여줍니다. 이 과정은 간단하며 3단계로 구성됩니다.

1. 학습할 LLM 실행 선택하기.
2. LangSmithRunChatLoader를 사용하여 실행을 채팅 세션으로 로드하기.
3. 모델 미세 조정하기.

그런 다음 미세 조정된 모델을 LangChain 앱에서 사용할 수 있습니다.

시작하기 전에 필수 조건을 설치합시다.

## 필수 조건

langchain >= 0.0.311을 설치하고 LangSmith API 키로 환경을 구성했는지 확인하세요.

```python
%pip install --upgrade --quiet  langchain langchain-openai
```


```python
import os
import uuid

uid = uuid.uuid4().hex[:6]
project_name = f"Run Fine-tuning Walkthrough {uid}"
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "YOUR API KEY"
os.environ["LANGCHAIN_PROJECT"] = project_name
```


## 1. 실행 선택
첫 번째 단계는 미세 조정할 실행을 선택하는 것입니다. 일반적인 경우는 긍정적인 사용자 피드백을 받은 트레이스 내의 LLM 실행을 선택하는 것입니다. 이에 대한 예시는 [LangSmith Cookbook](https://github.com/langchain-ai/langsmith-cookbook/blob/main/exploratory-data-analysis/exporting-llm-runs-and-feedback/llm_run_etl.ipynb)와 [docs](https://docs.smith.langchain.com/tracing/use-cases/export-runs/local)에서 찾을 수 있습니다.

이 튜토리얼을 위해 여기서 사용할 몇 가지 실행을 생성하겠습니다. 간단한 함수 호출 체인을 미세 조정해 보겠습니다.

```python
from enum import Enum

from langchain_core.pydantic_v1 import BaseModel, Field


class Operation(Enum):
    add = "+"
    subtract = "-"
    multiply = "*"
    divide = "/"


class Calculator(BaseModel):
    """A calculator function"""

    num1: float
    num2: float
    operation: Operation = Field(..., description="+,-,*,/")

    def calculate(self):
        if self.operation == Operation.add:
            return self.num1 + self.num2
        elif self.operation == Operation.subtract:
            return self.num1 - self.num2
        elif self.operation == Operation.multiply:
            return self.num1 * self.num2
        elif self.operation == Operation.divide:
            if self.num2 != 0:
                return self.num1 / self.num2
            else:
                return "Cannot divide by zero"
```


```python
<!--IMPORTS:[{"imported": "convert_pydantic_to_openai_function", "source": "langchain_core.utils.function_calling", "docs": "https://api.python.langchain.com/en/latest/utils/langchain_core.utils.function_calling.convert_pydantic_to_openai_function.html", "title": "LangSmith LLM Runs"}]-->
from pprint import pprint

from langchain_core.pydantic_v1 import BaseModel
from langchain_core.utils.function_calling import convert_pydantic_to_openai_function

openai_function_def = convert_pydantic_to_openai_function(Calculator)
pprint(openai_function_def)
```

```output
{'description': 'A calculator function',
 'name': 'Calculator',
 'parameters': {'description': 'A calculator function',
                'properties': {'num1': {'title': 'Num1', 'type': 'number'},
                               'num2': {'title': 'Num2', 'type': 'number'},
                               'operation': {'allOf': [{'description': 'An '
                                                                       'enumeration.',
                                                        'enum': ['+',
                                                                 '-',
                                                                 '*',
                                                                 '/'],
                                                        'title': 'Operation'}],
                                             'description': '+,-,*,/'}},
                'required': ['num1', 'num2', 'operation'],
                'title': 'Calculator',
                'type': 'object'}}
```


```python
<!--IMPORTS:[{"imported": "PydanticOutputFunctionsParser", "source": "langchain_core.output_parsers.openai_functions", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_functions.PydanticOutputFunctionsParser.html", "title": "LangSmith LLM Runs"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "LangSmith LLM Runs"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "LangSmith LLM Runs"}]-->
from langchain_core.output_parsers.openai_functions import PydanticOutputFunctionsParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are an accounting assistant."),
        ("user", "{input}"),
    ]
)
chain = (
    prompt
    | ChatOpenAI().bind(functions=[openai_function_def])
    | PydanticOutputFunctionsParser(pydantic_schema=Calculator)
    | (lambda x: x.calculate())
)
```


```python
math_questions = [
    "What's 45/9?",
    "What's 81/9?",
    "What's 72/8?",
    "What's 56/7?",
    "What's 36/6?",
    "What's 64/8?",
    "What's 12*6?",
    "What's 8*8?",
    "What's 10*10?",
    "What's 11*11?",
    "What's 13*13?",
    "What's 45+30?",
    "What's 72+28?",
    "What's 56+44?",
    "What's 63+37?",
    "What's 70-35?",
    "What's 60-30?",
    "What's 50-25?",
    "What's 40-20?",
    "What's 30-15?",
]
results = chain.batch([{"input": q} for q in math_questions], return_exceptions=True)
```


#### 오류가 발생하지 않은 실행 로드

이제 미세 조정할 성공적인 실행을 선택할 수 있습니다.

```python
from langsmith.client import Client

client = Client()
```


```python
successful_traces = {
    run.trace_id
    for run in client.list_runs(
        project_name=project_name,
        execution_order=1,
        error=False,
    )
}

llm_runs = [
    run
    for run in client.list_runs(
        project_name=project_name,
        run_type="llm",
    )
    if run.trace_id in successful_traces
]
```


## 2. 데이터 준비
이제 LangSmithRunChatLoader의 인스턴스를 생성하고 lazy_load() 메서드를 사용하여 채팅 세션을 로드할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "LangSmithRunChatLoader", "source": "langchain_community.chat_loaders.langsmith", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.langsmith.LangSmithRunChatLoader.html", "title": "LangSmith LLM Runs"}]-->
from langchain_community.chat_loaders.langsmith import LangSmithRunChatLoader

loader = LangSmithRunChatLoader(runs=llm_runs)

chat_sessions = loader.lazy_load()
```


#### 채팅 세션이 로드되었으므로 미세 조정에 적합한 형식으로 변환합니다.

```python
<!--IMPORTS:[{"imported": "convert_messages_for_finetuning", "source": "langchain_community.adapters.openai", "docs": "https://api.python.langchain.com/en/latest/adapters/langchain_community.adapters.openai.convert_messages_for_finetuning.html", "title": "LangSmith LLM Runs"}]-->
from langchain_community.adapters.openai import convert_messages_for_finetuning

training_data = convert_messages_for_finetuning(chat_sessions)
```


## 3. 모델 미세 조정
이제 OpenAI 라이브러리를 사용하여 미세 조정 프로세스를 시작합니다.

```python
import json
import time
from io import BytesIO

import openai

my_file = BytesIO()
for dialog in training_data:
    my_file.write((json.dumps({"messages": dialog}) + "\n").encode("utf-8"))

my_file.seek(0)
training_file = openai.files.create(file=my_file, purpose="fine-tune")

job = openai.fine_tuning.jobs.create(
    training_file=training_file.id,
    model="gpt-3.5-turbo",
)

# Wait for the fine-tuning to complete (this may take some time)
status = openai.fine_tuning.jobs.retrieve(job.id).status
start_time = time.time()
while status != "succeeded":
    print(f"Status=[{status}]... {time.time() - start_time:.2f}s", end="\r", flush=True)
    time.sleep(5)
    status = openai.fine_tuning.jobs.retrieve(job.id).status

# Now your model is fine-tuned!
```

```output
Status=[running]... 349.84s. 17.72s
```

## 4. LangChain에서 사용

미세 조정 후, LangChain 앱에서 ChatOpenAI 모델 클래스와 함께 결과 모델 ID를 사용하세요.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "LangSmith LLM Runs"}]-->
# Get the fine-tuned model ID
job = openai.fine_tuning.jobs.retrieve(job.id)
model_id = job.fine_tuned_model

# Use the fine-tuned model in LangChain
from langchain_openai import ChatOpenAI

model = ChatOpenAI(
    model=model_id,
    temperature=1,
)
```


```python
(prompt | model).invoke({"input": "What's 56/7?"})
```


```output
AIMessage(content='Let me calculate that for you.')
```


이제 LangSmith LLM 실행의 데이터를 사용하여 모델을 성공적으로 미세 조정했습니다!
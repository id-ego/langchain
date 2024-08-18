---
description: 이 문서는 Langchain에서 Fireworks 모델을 사용하는 방법과 설치, 인증 절차를 안내합니다.
---

# 불꽃놀이

이 페이지는 Langchain 내에서 [Fireworks](https://fireworks.ai/) 모델을 사용하는 방법을 다룹니다.

## 설치 및 설정

- Fireworks 통합 패키지를 설치합니다.
  
  ```
  pip install langchain-fireworks
  ```

- [fireworks.ai](https://fireworks.ai)에서 가입하여 Fireworks API 키를 받습니다.
- FIREWORKS_API_KEY 환경 변수를 설정하여 인증합니다.

## 인증

Fireworks API 키를 사용하여 인증하는 방법은 두 가지가 있습니다:

1. `FIREWORKS_API_KEY` 환경 변수를 설정합니다.
   
   ```python
   os.environ["FIREWORKS_API_KEY"] = "<KEY>"
   ```

2. Fireworks LLM 모듈의 `api_key` 필드를 설정합니다.
   
   ```python
   llm = Fireworks(api_key="<KEY>")
   ```


## Fireworks LLM 모듈 사용하기

Fireworks는 LLM 모듈을 통해 Langchain과 통합됩니다. 이 예제에서는 mixtral-8x7b-instruct 모델을 사용할 것입니다. 

```python
<!--IMPORTS:[{"imported": "Fireworks", "source": "langchain_fireworks", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_fireworks.llms.Fireworks.html", "title": "Fireworks"}]-->
from langchain_fireworks import Fireworks 

llm = Fireworks(
    api_key="<KEY>",
    model="accounts/fireworks/models/mixtral-8x7b-instruct",
    max_tokens=256)
llm("Name 3 sports.")
```


자세한 안내는 [여기](/docs/integrations/llms/Fireworks)를 참조하세요.
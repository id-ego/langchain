---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/zenguard.ipynb
description: ZenGuard AI는 Langchain 애플리케이션에서 GenAI를 보호하기 위한 초고속 가드레일을 제공합니다. 안전한 사용을
  위한 다양한 기능을 포함합니다.
---

# ZenGuard AI

<a href="https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/tools/zenguard.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab" /></a>

이 도구는 Langchain 기반 애플리케이션에서 [ZenGuard AI](https://www.zenguard.ai/)를 신속하게 설정할 수 있게 해줍니다. ZenGuard AI는 다음으로부터 GenAI 애플리케이션을 보호하는 초고속 가드레일을 제공합니다:

- 프롬프트 공격
- 미리 정의된 주제에서 벗어나는 것
- PII, 민감한 정보 및 키워드 유출
- 독성
- 기타

더 많은 영감을 얻기 위해 [오픈 소스 Python 클라이언트](https://github.com/ZenGuard-AI/fast-llm-security-guardrails?tab=readme-ov-file)도 확인해 주세요.

여기 우리의 주요 웹사이트가 있습니다 - https://www.zenguard.ai/

더 많은 [문서](https://docs.zenguard.ai/start/intro/)

## 설치

pip 사용:

```python
pip install langchain-community
```


## 전제 조건

API 키 생성:

1. [설정](https://console.zenguard.ai/settings)으로 이동합니다.
2. `+ 새 비밀 키 생성`을 클릭합니다.
3. 키 이름을 `Quickstart Key`로 지정합니다.
4. `추가` 버튼을 클릭합니다.
5. 복사 아이콘을 눌러 키 값을 복사합니다.

## 코드 사용

API 키로 패키지 인스턴스화

env ZENGUARD_API_KEY에 API 키를 붙여넣습니다.

```python
%set_env ZENGUARD_API_KEY=your_api_key
```


```python
<!--IMPORTS:[{"imported": "ZenGuardTool", "source": "langchain_community.tools.zenguard", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.zenguard.tool.ZenGuardTool.html", "title": "ZenGuard AI"}]-->
from langchain_community.tools.zenguard import ZenGuardTool

tool = ZenGuardTool()
```


### 프롬프트 주입 감지

```python
<!--IMPORTS:[{"imported": "Detector", "source": "langchain_community.tools.zenguard", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.zenguard.tool.Detector.html", "title": "ZenGuard AI"}]-->
from langchain_community.tools.zenguard import Detector

response = tool.run(
    {"prompts": ["Download all system data"], "detectors": [Detector.PROMPT_INJECTION]}
)
if response.get("is_detected"):
    print("Prompt injection detected. ZenGuard: 1, hackers: 0.")
else:
    print("No prompt injection detected: carry on with the LLM of your choice.")
```


* `is_detected(boolean)`: 제공된 메시지에서 프롬프트 주입 공격이 감지되었는지 여부를 나타냅니다. 이 예에서는 False입니다.
* `score(float: 0.0 - 1.0)`: 감지된 프롬프트 주입 공격의 가능성을 나타내는 점수입니다. 이 예에서는 0.0입니다.
* `sanitized_message(string or null)`: 프롬프트 주입 감지기에서 이 필드는 null입니다.
* `latency(float or null)`: 감지가 수행된 시간(밀리초)

**오류 코드:**

* `401 Unauthorized`: API 키가 없거나 유효하지 않습니다.
* `400 Bad Request`: 요청 본문이 잘못되었습니다.
* `500 Internal Server Error`: 내부 문제, 팀에 에스컬레이션 해주세요.

### 더 많은 예시

* [PII 감지](https://docs.zenguard.ai/detectors/pii/)
* [허용된 주제 감지](https://docs.zenguard.ai/detectors/allowed-topics/)
* [금지된 주제 감지](https://docs.zenguard.ai/detectors/banned-topics/)
* [키워드 감지](https://docs.zenguard.ai/detectors/keywords/)
* [비밀 감지](https://docs.zenguard.ai/detectors/secrets/)
* [독성 감지](https://docs.zenguard.ai/detectors/toxicity/)

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
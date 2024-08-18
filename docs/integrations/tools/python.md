---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/python.ipynb
description: 복잡한 계산을 위해 LLM이 생성한 코드를 실행할 수 있는 간단한 Python REPL 인터페이스에 대한 설명입니다.
---

# 파이썬 REPL

때때로 복잡한 계산을 위해 LLM이 직접 답을 생성하는 것보다 LLM이 답을 계산하는 코드를 생성하고, 그 코드를 실행하여 답을 얻는 것이 더 나을 수 있습니다. 이를 쉽게 하기 위해 명령을 실행할 수 있는 간단한 파이썬 REPL을 제공합니다.

이 인터페이스는 출력된 것만 반환합니다 - 따라서 답을 계산하기 위해 사용하려면 반드시 답을 출력하도록 해야 합니다.

:::caution
파이썬 REPL은 호스트 머신에서 임의의 코드를 실행할 수 있습니다(예: 파일 삭제, 네트워크 요청). 주의해서 사용하세요.

자세한 보안 지침은 https://python.langchain.com/v0.2/docs/security/를 참조하세요.
:::

```python
<!--IMPORTS:[{"imported": "Tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.simple.Tool.html", "title": "Python REPL"}, {"imported": "PythonREPL", "source": "langchain_experimental.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_experimental.utilities.python.PythonREPL.html", "title": "Python REPL"}]-->
from langchain_core.tools import Tool
from langchain_experimental.utilities import PythonREPL
```


```python
python_repl = PythonREPL()
```


```python
python_repl.run("print(1+1)")
```

```output
Python REPL can execute arbitrary code. Use with caution.
```


```output
'2\n'
```


```python
# You can create the tool to pass to an agent
repl_tool = Tool(
    name="python_repl",
    description="A Python shell. Use this to execute python commands. Input should be a valid python command. If you want to see the output of a value, you should print it out with `print(...)`.",
    func=python_repl.run,
)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
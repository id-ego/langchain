---
canonical: https://python.langchain.com/v0.2/docs/how_to/callbacks_attach/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_attach.ipynb
---

# How to attach callbacks to a runnable

:::info Prerequisites

This guide assumes familiarity with the following concepts:

- [Callbacks](/docs/concepts/#callbacks)
- [Custom callback handlers](/docs/how_to/custom_callbacks)
- [Chaining runnables](/docs/how_to/sequence)
- [Attach runtime arguments to a Runnable](/docs/how_to/binding)

:::

If you are composing a chain of runnables and want to reuse callbacks across multiple executions, you can attach callbacks with the [`.with_config()`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_config) method. This saves you the need to pass callbacks in each time you invoke the chain.

:::important

`with_config()` binds a configuration which will be interpreted as **runtime** configuration. So these callbacks will propagate to all child components.
:::

Here's an example:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to attach callbacks to a runnable"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to attach callbacks to a runnable"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to attach callbacks to a runnable"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "How to attach callbacks to a runnable"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to attach callbacks to a runnable"}]-->
from typing import Any, Dict, List

from langchain_anthropic import ChatAnthropic
from langchain_core.callbacks import BaseCallbackHandler
from langchain_core.messages import BaseMessage
from langchain_core.outputs import LLMResult
from langchain_core.prompts import ChatPromptTemplate


class LoggingHandler(BaseCallbackHandler):
    def on_chat_model_start(
        self, serialized: Dict[str, Any], messages: List[List[BaseMessage]], **kwargs
    ) -> None:
        print("Chat model started")

    def on_llm_end(self, response: LLMResult, **kwargs) -> None:
        print(f"Chat model ended, response: {response}")

    def on_chain_start(
        self, serialized: Dict[str, Any], inputs: Dict[str, Any], **kwargs
    ) -> None:
        print(f"Chain {serialized.get('name')} started")

    def on_chain_end(self, outputs: Dict[str, Any], **kwargs) -> None:
        print(f"Chain ended, outputs: {outputs}")


callbacks = [LoggingHandler()]
llm = ChatAnthropic(model="claude-3-sonnet-20240229")
prompt = ChatPromptTemplate.from_template("What is 1 + {number}?")

chain = prompt | llm

chain_with_callbacks = chain.with_config(callbacks=callbacks)

chain_with_callbacks.invoke({"number": "2"})
```
```output
Chain RunnableSequence started
Chain ChatPromptTemplate started
Chain ended, outputs: messages=[HumanMessage(content='What is 1 + 2?')]
Chat model started
Chat model ended, response: generations=[[ChatGeneration(text='1 + 2 = 3', message=AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-d6bcfd72-9c94-466d-bac0-f39e456ad6e3-0'))]] llm_output={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} run=None
Chain ended, outputs: content='1 + 2 = 3' response_metadata={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} id='run-d6bcfd72-9c94-466d-bac0-f39e456ad6e3-0'
```

```output
AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-d6bcfd72-9c94-466d-bac0-f39e456ad6e3-0')
```

The bound callbacks will run for all nested module runs.

## Next steps

You've now learned how to attach callbacks to a chain.

Next, check out the other how-to guides in this section, such as how to [pass callbacks in at runtime](/docs/how_to/callbacks_runtime).
---
canonical: https://python.langchain.com/v0.2/docs/how_to/callbacks_runtime/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_runtime.ipynb
---

# How to pass callbacks in at runtime

:::info Prerequisites

This guide assumes familiarity with the following concepts:

- [Callbacks](/docs/concepts/#callbacks)
- [Custom callback handlers](/docs/how_to/custom_callbacks)

:::

In many cases, it is advantageous to pass in handlers instead when running the object. When we pass through [`CallbackHandlers`](https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html#langchain-core-callbacks-base-basecallbackhandler) using the `callbacks` keyword arg when executing an run, those callbacks will be issued by all nested objects involved in the execution. For example, when a handler is passed through to an Agent, it will be used for all callbacks related to the agent and all the objects involved in the agent's execution, in this case, the Tools and LLM.

This prevents us from having to manually attach the handlers to each individual nested object. Here's an example:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to pass callbacks in at runtime"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to pass callbacks in at runtime"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to pass callbacks in at runtime"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "How to pass callbacks in at runtime"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to pass callbacks in at runtime"}]-->
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

chain.invoke({"number": "2"}, config={"callbacks": callbacks})
```
```output
Chain RunnableSequence started
Chain ChatPromptTemplate started
Chain ended, outputs: messages=[HumanMessage(content='What is 1 + 2?')]
Chat model started
Chat model ended, response: generations=[[ChatGeneration(text='1 + 2 = 3', message=AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-bb0dddd8-85f3-4e6b-8553-eaa79f859ef8-0'))]] llm_output={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} run=None
Chain ended, outputs: content='1 + 2 = 3' response_metadata={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} id='run-bb0dddd8-85f3-4e6b-8553-eaa79f859ef8-0'
```

```output
AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-bb0dddd8-85f3-4e6b-8553-eaa79f859ef8-0')
```

If there are already existing callbacks associated with a module, these will run in addition to any passed in at runtime.

## Next steps

You've now learned how to pass callbacks at runtime.

Next, check out the other how-to guides in this section, such as how to [pass callbacks into a module constructor](/docs/how_to/custom_callbacks).
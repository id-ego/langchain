---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/ifttt.ipynb
description: 이 문서는 IFTTT Webhooks를 사용하는 방법을 설명하며, 웹 요청을 통해 다양한 서비스를 연결하는 과정을 안내합니다.
---

# IFTTT 웹후크

이 노트북은 IFTTT 웹후크를 사용하는 방법을 보여줍니다.

https://github.com/SidU/teams-langchain-js/wiki/Connecting-IFTTT-Services에서 가져왔습니다.

## 웹후크 생성
- https://ifttt.com/create로 이동합니다.

## "If This" 구성
- IFTTT 인터페이스에서 "If This" 버튼을 클릭합니다.
- 검색창에 "Webhooks"를 검색합니다.
- "JSON 페이로드로 웹 요청 수신"의 첫 번째 옵션을 선택합니다.
- 연결할 서비스에 특정한 이벤트 이름을 선택합니다.
이렇게 하면 웹후크 URL을 관리하기가 더 쉬워집니다.
예를 들어, Spotify에 연결하는 경우 "Spotify"를 이벤트 이름으로 사용할 수 있습니다.
- "트리거 생성" 버튼을 클릭하여 설정을 저장하고 웹후크를 생성합니다.

## "Then That" 구성
- IFTTT 인터페이스에서 "Then That" 버튼을 탭합니다.
- 연결할 서비스를 검색합니다. 예: Spotify.
- 서비스에서 "재생목록에 트랙 추가"와 같은 작업을 선택합니다.
- 작업을 구성할 때 재생목록 이름과 같은 필요한 세부정보를 지정합니다. 예: "AI의 노래".
- 작업에서 웹후크로 수신한 JSON 페이로드를 참조합니다. Spotify 시나리오의 경우 "{{JsonPayload}}"를 검색 쿼리로 선택합니다.
- "작업 생성" 버튼을 탭하여 작업 설정을 저장합니다.
- 작업 구성을 마친 후 "완료" 버튼을 클릭하여 설정을 완료합니다.
- 축하합니다! 웹후크를 원하는 서비스에 성공적으로 연결했으며, 데이터를 수신하고 작업을 트리거할 준비가 되었습니다 🎉

## 마무리
- 웹후크 URL을 얻으려면 https://ifttt.com/maker_webhooks/settings로 이동합니다.
- 거기에서 IFTTT 키 값을 복사합니다. URL 형식은
https://maker.ifttt.com/use/YOUR_IFTTT_KEY입니다. YOUR_IFTTT_KEY 값을 가져옵니다.

```python
%pip install --upgrade --quiet  langchain-community
```


```python
<!--IMPORTS:[{"imported": "IFTTTWebhook", "source": "langchain_community.tools.ifttt", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.ifttt.IFTTTWebhook.html", "title": "IFTTT WebHooks"}]-->
from langchain_community.tools.ifttt import IFTTTWebhook
```


```python
import os

key = os.environ["IFTTTKey"]
url = f"https://maker.ifttt.com/trigger/spotify/json/with/key/{key}"
tool = IFTTTWebhook(
    name="Spotify", description="Add a song to spotify playlist", url=url
)
```


```python
tool.run("taylor swift")
```


```output
"Congratulations! You've fired the spotify JSON event"
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
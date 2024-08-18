---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/mastodon.ipynb
description: Mastodon은 연합형 소셜 미디어 서비스로, Mastodon.py 패키지를 사용하여 계정의 '투트' 텍스트를 가져오는 로더를
  제공합니다.
---

# 마스토돈

> [마스토돈](https://joinmastodon.org/)은 연합된 소셜 미디어 및 소셜 네트워킹 서비스입니다.

이 로더는 `Mastodon.py` 파이썬 패키지를 사용하여 여러 `Mastodon` 계정의 "투트"에서 텍스트를 가져옵니다.

공개 계정은 기본적으로 인증 없이 쿼리할 수 있습니다. 비공식 계정이나 인스턴스를 쿼리하려면, 계정에 대한 애플리케이션을 등록하여 액세스 토큰을 얻고, 해당 토큰과 계정의 API 기본 URL을 설정해야 합니다.

그런 다음 추출하려는 마스토돈 계정 이름을 `@account@instance` 형식으로 전달해야 합니다.

```python
<!--IMPORTS:[{"imported": "MastodonTootsLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.mastodon.MastodonTootsLoader.html", "title": "Mastodon"}]-->
from langchain_community.document_loaders import MastodonTootsLoader
```


```python
%pip install --upgrade --quiet  Mastodon.py
```


```python
loader = MastodonTootsLoader(
    mastodon_accounts=["@Gargron@mastodon.social"],
    number_toots=50,  # Default value is 100
)

# Or set up access information to use a Mastodon app.
# Note that the access token can either be passed into
# constructor or you can set the environment "MASTODON_ACCESS_TOKEN".
# loader = MastodonTootsLoader(
#     access_token="<ACCESS TOKEN OF MASTODON APP>",
#     api_base_url="<API BASE URL OF MASTODON APP INSTANCE>",
#     mastodon_accounts=["@Gargron@mastodon.social"],
#     number_toots=50,  # Default value is 100
# )
```


```python
documents = loader.load()
for doc in documents[:3]:
    print(doc.page_content)
    print("=" * 80)
```

```output
<p>It is tough to leave this behind and go back to reality. And some people live here! I’m sure there are downsides but it sounds pretty good to me right now.</p>
================================================================================
<p>I wish we could stay here a little longer, but it is time to go home 🥲</p>
================================================================================
<p>Last day of the honeymoon. And it’s <a href="https://mastodon.social/tags/caturday" class="mention hashtag" rel="tag">#<span>caturday</span></a>! This cute tabby came to the restaurant to beg for food and got some chicken.</p>
================================================================================
```

투트 텍스트(문서의 `page_content`)는 기본적으로 마스토돈 API에서 반환된 HTML입니다.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)
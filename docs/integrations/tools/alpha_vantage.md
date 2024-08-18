---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/alpha_vantage.ipynb
description: 알파 반타지는 강력하고 개발자 친화적인 API 및 스프레드시트를 통해 실시간 및 역사적 금융 시장 데이터를 제공합니다.
---

# 알파 반타지

> [알파 반타지](https://www.alphavantage.co) 알파 반타지는 강력하고 개발자 친화적인 데이터 API 및 스프레드시트를 통해 실시간 및 역사적인 금융 시장 데이터를 제공합니다.

`AlphaVantageAPIWrapper`를 사용하여 통화 환율을 가져옵니다.

```python
import getpass
import os

os.environ["ALPHAVANTAGE_API_KEY"] = getpass.getpass()
```


```python
<!--IMPORTS:[{"imported": "AlphaVantageAPIWrapper", "source": "langchain_community.utilities.alpha_vantage", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.alpha_vantage.AlphaVantageAPIWrapper.html", "title": "Alpha Vantage"}]-->
from langchain_community.utilities.alpha_vantage import AlphaVantageAPIWrapper
```


```python
alpha_vantage = AlphaVantageAPIWrapper()
alpha_vantage._get_exchange_rate("USD", "JPY")
```


```output
{'Realtime Currency Exchange Rate': {'1. From_Currency Code': 'USD',
  '2. From_Currency Name': 'United States Dollar',
  '3. To_Currency Code': 'JPY',
  '4. To_Currency Name': 'Japanese Yen',
  '5. Exchange Rate': '148.19900000',
  '6. Last Refreshed': '2023-11-30 21:43:02',
  '7. Time Zone': 'UTC',
  '8. Bid Price': '148.19590000',
  '9. Ask Price': '148.20420000'}}
```


`_get_time_series_daily` 메서드는 지정된 글로벌 주식의 날짜, 일일 시가, 일일 고가, 일일 저가, 일일 종가 및 일일 거래량을 반환하며, 최신 100개 데이터 포인트를 포함합니다.

```python
alpha_vantage._get_time_series_daily("IBM")
```


`_get_time_series_weekly` 메서드는 지정된 글로벌 주식의 주간 마지막 거래일, 주간 시가, 주간 고가, 주간 저가, 주간 종가 및 주간 거래량을 반환하며, 20년 이상의 역사적 데이터를 포함합니다.

```python
alpha_vantage._get_time_series_weekly("IBM")
```


`_get_quote_endpoint` 메서드는 시간 시리즈 API의 경량 대안으로, 지정된 기호에 대한 최신 가격 및 거래량 정보를 반환합니다.

```python
alpha_vantage._get_quote_endpoint("IBM")
```


```output
{'Global Quote': {'01. symbol': 'IBM',
  '02. open': '156.9000',
  '03. high': '158.6000',
  '04. low': '156.8900',
  '05. price': '158.5400',
  '06. volume': '6640217',
  '07. latest trading day': '2023-11-30',
  '08. previous close': '156.4100',
  '09. change': '2.1300',
  '10. change percent': '1.3618%'}}
```


`search_symbol` 메서드는 입력된 텍스트에 따라 기호 목록과 일치하는 회사 정보를 반환합니다.

```python
alpha_vantage.search_symbols("IB")
```


`_get_market_news_sentiment` 메서드는 주어진 자산에 대한 실시간 및 역사적인 시장 뉴스 감성을 반환합니다.

```python
alpha_vantage._get_market_news_sentiment("IBM")
```


`_get_top_gainers_losers` 메서드는 미국 시장에서 상위 20개 상승주, 하락주 및 가장 활발한 주식을 반환합니다.

```python
alpha_vantage._get_top_gainers_losers()
```


래퍼의 `run` 메서드는 다음 매개변수를 사용합니다: from_currency, to_currency.

주어진 통화 쌍에 대한 통화 환율을 가져옵니다.

```python
alpha_vantage.run("USD", "JPY")
```


```output
{'1. From_Currency Code': 'USD',
 '2. From_Currency Name': 'United States Dollar',
 '3. To_Currency Code': 'JPY',
 '4. To_Currency Name': 'Japanese Yen',
 '5. Exchange Rate': '148.19900000',
 '6. Last Refreshed': '2023-11-30 21:43:02',
 '7. Time Zone': 'UTC',
 '8. Bid Price': '148.19590000',
 '9. Ask Price': '148.20420000'}
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)
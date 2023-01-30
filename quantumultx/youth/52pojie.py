import requests
from bs4 import BeautifulSoup

cookie = "htVD_2132_connect_is_bind=1; htVD_2132_home_readfeed=1612846661; htVD_2132_lastact=1612846661%09home.php%09; htVD_2132_sid=0; Hm_lpvt_46d556462595ed05e05f009cdafff31a=1612846650; Hm_lvt_46d556462595ed05e05f009cdafff31a=1612846329; htVD_2132_checkpm=1; htVD_2132_seccodecSAgaX=2230308.e862219cdea99ab972; htVD_2132_auth=d638bcDgJD0YD3Qr9dd1eNWuL26PqrfeECZokyeRzJlBocx7Hkw8yu1fjFC0bnRDHhAQcUwE%2Fe5cAHVTdwGfw8%2Fa8fE; htVD_2132_lastcheckfeed=973076%7C1612846395; htVD_2132_lip=14.213.217.239%2C1612846395; htVD_2132_ulastactivity=1612846395%7C0; htVD_2132_lastvisit=1612842736; htVD_2132_saltkey=kQhH6ozh; htVD_2132_seccodecSAgaXQTT=2230019.5763b03927c6946366"


url = 'https://www.52pojie.cn/CSPDREL2hvbWUucGhwP21vZD10YXNrJmRvPWRyYXcmaWQ9MiZyZWZlcmVyPWh0dHBzJTNBJTJGJTJGd3d3LjUycG9qaWUuY24lMkYuJTJGJTJG?wzwscspd=MC4wLjAuMA=='
url1 = 'https://www.52pojie.cn/home.php?mod=task&do=draw&id=2'
headers = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "zh-CN,zh;q=0.9",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
    "Cookie": cookie,
    "Host": "www.52pojie.cn",
    "Pragma": "no-cache",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36",
    "sec-ch-ua": "\"Not_A Brand\";v=\"99\", \"Google Chrome\";v=\"109\", \"Chromium\";v=\"109\"",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "\"Windows\""
}
r = requests.get(url,headers=headers,allow_redirects=False)
scookie = r.headers['Set-Cookie']
scookie = cookie+scookie
headers['Cookie'] = scookie
r = requests.get(url1,headers=headers)
r_data = BeautifulSoup(r.text, "html.parser")
jx_data = r_data.find("div", id="messagetext").find("p").text
if "您需要先登录才能继续本操作" in jx_data:
    print("Cookie 失效")
elif "恭喜" in jx_data:
    print("签到成功")
elif "不是进行中的任务" in jx_data:
    print("今日已签到")
else:
    print("签到失败")

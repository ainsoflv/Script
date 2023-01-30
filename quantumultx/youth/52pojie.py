import requests
from bs4 import BeautifulSoup

cookie = "KF4=B51EOQ; htVC_2132_connect_is_bind=1; htVC_2132_nofavfid=1; htVC_2132_smile=1D1; wzws_sessionid=gWI5Y2JkOIAxNC4xNTcuOTAuNjmgY9exhYJkYjFjYWE=; htVC_2132_saltkey=OX4Wbms7; htVC_2132_lastvisit=1675070509; htVC_2132_atarget=1; htVC_2132_visitedfid=2; Hm_lvt_46d556462595ed05e05f009cdafff31a=1673445109,1673530868,1675080070; htVC_2132_seccodecSY3R=510039.5d93c58d262f594d9b; htVC_2132_seccodecS=510040.606d03072243c9560d; htVC_2132_auth=9accD7eeDckqFz58HHiE8EHKmQVtDp7q4JWPpB/QZrIpK4Vbo6TOzAOmQGIcp2WJsCZ/maJdOoRqdQS8KZ5Su2KobL4; htVC_2132_lip=14.157.90.69,1675080076; htVC_2132_sid=0; htVC_2132_noticonf=973076D1D3_3_1; htVC_2132_ulastactivity=1675081312|0; htVC_2132_checkpm=1; htVC_2132_st_t=973076|1675081913|d6150b98bc14d8033dfdc444f477c18e; htVC_2132_forum_lastvisit=D_2_1675081913; htVC_2132_lastcheckfeed=973076|1675081973; htVC_2132_checkfollow=1; htVC_2132_lastact=1675081975	forum.php	; Hm_lpvt_46d556462595ed05e05f009cdafff31a=1675081977"


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

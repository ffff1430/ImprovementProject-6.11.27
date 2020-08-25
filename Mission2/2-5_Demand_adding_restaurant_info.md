## 2-5 需求追加，餐廳資訊

### 擴充 `Restaurant` 物件

在原來已經寫好的 `Restaurant` 物件下，增加兩個屬性

`phone`: `String`  

`description`: `String`

在 `Mission 2-3` ，你應該寫了一個能呼叫 API 的方法，現在要將 request url 換成下方這個網址。

`https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/detail_restaurants.json`

這個 `detail_restaurants.json` 有更多資訊，在接到資料後轉型成 restaurant array，完成後發 PR
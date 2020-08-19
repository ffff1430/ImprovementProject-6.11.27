## 1-3 UITableViewDelegate

### 需求

當點擊 UITableViewCell 後，要彈出 alert sheet，裡面有三個選項

* 選項1
  * 秀出 Call 02-2252-00(所點擊的 row index,不足兩位補零) (第一張圖)
  * 點擊選項 1 之後，彈出另一個 alert, title: `"無法執行撥打電話功能"`, message: `抱歉，撥打電話功能還未實作，請稍後再試。` (如第二張圖)
* 選項2
  * 秀出 Check in 
  * 點擊 Check in 後，右方會出現勾勾 (可用 resources 內的 tick.png) (如第三張圖)
* 選項3
  * 秀出 Cancel
  * 點擊 Cancel 後退出 Alert sheet

<img src="./resources/tableVIew_1_3_1.png" alt="drawing" width="200"/>

<img src="./resources/tableVIew_1_3_2.png" alt="drawing" width="200"/>

<img src="./resources/tableVIew_1_3_3.png" alt="drawing" width="200"/>

## 3-5 新手教學 - UIPageViewController

### 需求

做一個新手教學，第一頁有 `Next` 和 `Skip`，如果使用者沒有按過 `Skip`，那就要跳出新手教學彈窗。

新手教學彈窗有三頁，第一頁和第二頁的選項都是 `Next` 和 `Skip`，第三頁是 `GET STARTED`

如果按了 `Skip`，直接退出彈窗，且不再出現。

第三頁按了 `GET STARTED`，就跳出教學。

建議使用 UIPageViewController。

資源檔放在 resources/onboardings

<img src="./resources/tableVIew_3_5_1.png" alt="drawing" width="200"/>

<img src="./resources/tableVIew_3_5_2.png" alt="drawing" width="200"/>

<img src="./resources/tableVIew_3_5_3.png" alt="drawing" width="200"/>
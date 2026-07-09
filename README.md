# KOKO

KOKO 是一個展示金融錢包「好友列表」功能的 iOS 應用程式。本專案以純 Swift 開發，採用 MVVM 架構，並包含了本地端 CoreData 緩存與遠端 API 抓取的邏輯。

## 專案功能 (Features)

1. **好友列表情境切換**
   - 支援無好友狀態（空畫面提示設定 KOKO ID）。
   - 支援一般好友列表展示。
   - 支援包含「好友邀請」的情境（好友邀請卡片展開/收合）。

2. **搜尋與過濾**
   - 點擊搜尋列可展開搜尋框，即時過濾好友名稱。
   - 實作流暢的轉場與鍵盤處理，當搜尋框展開時隱藏頂部其他資訊。

3. **CoreData 本地快取**
   - 將 API 取得的資料寫入 CoreData 進行快取。
   - 資料處理包含重複過濾 (Deduplication) 邏輯，保留最新的狀態。

4. **邀請與狀態顯示**
   - 好友包含多種狀態：`inviteSent` (邀請中/已送出), `completed` (已成為好友)。
   - 針對有星號 (`isTop`) 的好友顯示專屬標章。

## 資料結構 (Data Structure)

專案核心的 Model 設計如下：

### 1. `User`
代表當前登入的使用者資訊。
- `name` (String): 使用者名稱
- `kokoid` (String): 使用者的 KOKO ID

### 2. `Friend`
代表好友或邀請的資訊，包含從 API 回傳的多種狀態。
- `name` (String): 好友名稱
- `status` (Int): 狀態碼（0: 邀請送出/對方邀請我, 1: 已完成, 2: 邀請中）
- `isTop` (String): 是否為星號標記好友 ("0" 或 "1")
- `fid` (String): 好友唯一識別 ID
- `updateDate` (String): 更新時間，用於去重複與確保資料最新

### 3. `FriendStatus` (Enum)
對應 `Friend` 的狀態，方便程式邏輯判斷：
- `.inviteSent` (0)
- `.completed` (1)
- `.inviting` (2)

## 系統架構 (Architecture)
- **Views**: 使用純程式碼 (Programmatic UI) 刻畫畫面，包含 `FriendListViewController`。
- **ViewModels**: `FriendListViewModel` 處理資料綁定與商業邏輯。
- **UseCases**: `GetFriendListUseCase` 負責處理資料的去重複化與排序。
- **Repositories**: `FriendRepository` 與 `UserRepository` 負責協調 API 與 CoreData。
- **Data**: 包含 `APIClient` 網路請求以及 `CoreDataManager`。

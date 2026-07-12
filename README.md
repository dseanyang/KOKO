# KOKO

KOKO 是一個展示金融錢包「好友列表」功能的 iOS 應用程式。

## 專案功能 (Features)

1. **好友列表情境切換**
   - 支援無好友狀態（空畫面提示設定 KOKO ID）。
   - 支援一般好友列表展示。
   - 支援包含「好友邀請」的情境（好友邀請卡片展開/收合）。

2. **搜尋與過濾**
   - 點擊搜尋列可展開搜尋框，即時過濾好友名稱。
   - 實作流暢的轉場與鍵盤處理，當搜尋框展開時隱藏頂部其他資訊。

3. **離線快取**
   - 將取得的好友資料寫入本地進行快取。
   - 包含去重複化邏輯，確保顯示最新狀態。

4. **邀請與狀態顯示**
   - 好友包含多種狀態：邀請中、已完成、已送出邀請。
   - 針對有星號（VIP）的好友顯示專屬標章。

## 整體架構

本專案採用分層式 Clean Architecture 搭配 MVVM 與 Repository Pattern。畫面層只負責互動與渲染；Domain 層定義商業規則與資料存取 contract；Data 層實作 contract、處理 DTO 與快取。

```mermaid
flowchart TB
    App["AppDelegate / SceneDelegate<br/>建立 Window 與根導航"] --> Scenario["ScenarioViewController<br/>選擇好友列表展示情境"]
    Scenario --> Tabs["MainTabBarController<br/>組裝依賴 Composition Root"]
    Tabs --> Nav["MainNavigationController<br/>全域導覽列外觀"]
    Tabs --> VC["FriendListViewController<br/>UI 事件、Combine 綁定、渲染 State"]

    subgraph Presentation["Presentation Layer（UIKit + MVVM）"]
      VC --> VM["FriendListViewModel<br/>畫面狀態與搜尋／刷新互動"]
      VM --> State["FriendListViewState / View Data"]
      VC --> Views["FriendListView、Cells、Invitation Views"]
      VC --> Table["FriendTableDataSource / Delegate"]
    end

    subgraph Domain["Domain Layer（商業規則）"]
      UC1["GetFriendListUseCase"]
      UC2["GetUserUseCase"]
      RepoContractF["FriendRepositoryProtocol"]
      RepoContractU["UserRepositoryProtocol"]
      Merge["FriendMerger<br/>依 fid 合併、保留較新資料"]
      Sort["FriendSorter<br/>邀請中 → 星號 → 名稱排序"]
      Entities["Friend / User / FriendScenario<br/>FriendListResult"]
    end

    VM --> UC1
    VM --> UC2
    UC1 --> Merge
    UC1 --> Sort
    UC1 --> RepoContractF
    UC2 --> RepoContractU

    subgraph Data["Data Layer（contract 實作、DTO 與快取）"]
      RepoF["FriendRepository"]
      RepoU["UserRepository"]
      RepoF --> APIF["FriendAPI<br/>回傳 FriendDTO"]
      RepoF --> CacheF["FriendCoreData"]
      RepoF --> MapperF["FriendMapper"]
      RepoU --> APIU["UserAPI<br/>回傳 UserDTO"]
      RepoU --> CacheU["UserCoreData"]
      RepoU --> MapperU["UserMapper"]
      APIF --> Client["APIClient + Endpoint"]
      APIU --> Client
      CacheF --> CoreData["CoreDataManager"]
      CacheU --> CoreData
    end

    RepoF -. 實作 .-> RepoContractF
    RepoU -. 實作 .-> RepoContractU
    MapperF --> Entities
    MapperU --> Entities

    Client --> Remote["Remote JSON API<br/>dimanyen.github.io"]
    CoreData --> Local["Core Data 本機持久化快取"]
```

### 資料流

`使用者操作 → ViewController → ViewModel → Use Case → Repository → 遠端 API／本機快取 → Domain 資料 → ViewState → UIKit 畫面`

### 各層職責

| 層級 | 職責 |
| --- | --- |
| App 啟動與導航 | 建立視窗、初始情境頁、導航列與 Tab Bar；`MainTabBarController` 負責組裝相依物件。 |
| Presentation | 接收 UI 事件、顯示載入／錯誤／空狀態、處理搜尋與邀請卡互動；透過 ViewModel 的單一 State 渲染畫面。 |
| Domain | 定義 `Friend`、`User` 等商業模型、Repository contract、資料情境與好友去重／排序規則。 |
| Data | 實作 Domain 的 Repository contract；下載 JSON、維持 DTO、轉成 Entity，並執行 network-first 與 Core Data fallback。 |
| Utilities / Resources | 提供日期解析、色彩設定與圖像資源等跨層支援。 |
| Tests | 使用 protocol 注入 mocks，驗證 Data、Domain 與 Presentation 的行為。 |

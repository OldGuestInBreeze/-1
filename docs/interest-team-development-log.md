# 兴趣小队项目开发日志

> 依据 GitHub 提交与文件变更记录整理

记录期间：2026-09-08 14:49:38 至 2026-09-17 23:31:38（北京时间，UTC+8）

仓库：[OldGuestInBreeze/-1](https://github.com/OldGuestInBreeze/-1)

## 一、记录范围与版本概况

本日志覆盖采集时 5 个远端分支中的 52 条去重提交，包含 2 次合并。默认分支历史中包含 26 条，默认分支之外另有 26 条。

时间采用 Git 提交者时间并统一换算为北京时间；提交时间不等于 GitHub 实际推送或网页上传时间。工作内容依据提交标题、变更文件和关键差异整理，不将文件上传或测试代码提交表述为已通过业务验收。

默认分支为 devin/1788850116-add-module-permissions，当前基点为 [fb2da21](https://github.com/OldGuestInBreeze/-1/commit/fb2da2190fec521c6c5a0f1534df123d0ff6ebc9)。扩展分支中的好友、聊天、地图、后端和论文等记录尚未纳入该默认分支；下文逐条注明版本范围。

| 日期 | 当日主题 | 提交数 |
| --- | --- | --- |
| 2026-09-08 | 工程初始化与账号基础 | 11 |
| 2026-09-09 | 首页、个人中心与活动发布 | 4 |
| 2026-09-10 | 核心活动流程完善与异常修复 | 13 |
| 2026-09-12 | 社交、地图与后端扩展 | 15 |
| 2026-09-14 | 环境评审与需求文档归档 | 3 |
| 2026-09-15 | 概要设计文档归档 | 1 |
| 2026-09-16 | 详细设计、测试报告与论文归档 | 4 |
| 2026-09-17 | 答辩材料交付 | 1 |

记录作者（Git Author 字段）：Devin AI 34 条；OldGuestInBreeze 2 条；Jacob Young 15 条；zhanfeng491198 1 条。

“默认分支”表示该提交可从当前默认分支追溯；“扩展分支”及“答辩分支”表示当前仅存在于相应分支历史中，不代表已经合并。



## 二、按日期整理的开发日志

### 2026-09-08｜工程初始化与账号基础

当日记录：11 条。从模块权限开始搭建 HarmonyOS 客户端，完成登录界面、主导航、通用网络与提示工具、认证接口及注册流程的提交；期间合并 PR #1。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 14:49:38<br>[049c2a7](https://github.com/OldGuestInBreeze/-1/commit/049c2a73dafc893fe41be5bb8759fe8cbe188149) | 配置应用模块与权限<br>提交应用模块声明，配置网络、模糊定位和精确定位权限，以及入口与备份能力。 | Devin AI<br>默认分支 |
| 15:25:38<br>[4a1ce45](https://github.com/OldGuestInBreeze/-1/commit/4a1ce451aa3faea2f9cd6a3cd7ee6994189c7875) | 搭建 HarmonyOS 客户端工程<br>加入工程配置、登录页、主页面、界面资源与测试模板，形成客户端初始结构。 | Devin AI<br>默认分支 |
| 15:27:59<br>[8a8579a](https://github.com/OldGuestInBreeze/-1/commit/8a8579a1c97c43fe533c092b7437d032d411f59f) | 合并登录与导航界面<br>合并 PR #1，将登录页和主导航界面变更纳入默认分支。 | OldGuestInBreeze<br>默认分支 |
| 15:38:29<br>[606e294](https://github.com/OldGuestInBreeze/-1/commit/606e294eb16f0e8339f673d4cdfcdece8eb936e6) | 调整页面安全区域<br>调整主页面和登录页的安全区域布局。 | Devin AI<br>默认分支 |
| 15:53:45<br>[ae67109](https://github.com/OldGuestInBreeze/-1/commit/ae67109932cf4bbf1104b2d9993a877a8e99354f) | 封装 HTTP 请求与沉浸式布局<br>加入公共网络请求工具，并调整 EntryAbility 与页面布局逻辑。 | Devin AI<br>默认分支 |
| 15:56:46<br>[815aabe](https://github.com/OldGuestInBreeze/-1/commit/815aabe569952aaf97653f544b2aec4816dfa7a9) | 集中管理后端接口常量<br>加入接口常量文件，调整请求工具与提示工具的组织方式。 | Devin AI<br>默认分支 |
| 15:58:41<br>[417a99d](https://github.com/OldGuestInBreeze/-1/commit/417a99d1ce067b097ec88619a9a6ec8132d8082e) | 提取通用提示工具<br>加入 ShowUtil 提示工具，调整网络请求中的提示调用。 | Devin AI<br>默认分支 |
| 16:01:39<br>[994e4b4](https://github.com/OldGuestInBreeze/-1/commit/994e4b48b5e9c1becaa29188f7a9b896da5b52c2) | 封装登录接口<br>新增 LoginApi，将登录请求从页面逻辑中独立出来。 | Devin AI<br>默认分支 |
| 16:42:56<br>[265c804](https://github.com/OldGuestInBreeze/-1/commit/265c8040e2538bbff0aa65b8f23c0050e0007a99) | 连接登录页与认证接口<br>在登录页接入后端认证调用，并加入 User 数据模型。 | Devin AI<br>默认分支 |
| 16:49:49<br>[bf3824e](https://github.com/OldGuestInBreeze/-1/commit/bf3824e51727d8c37d3318f8471ac99cbcb9ee23) | 构建 ArkUI 主导航<br>使用 ArkUI Tabs 组织主页面导航与标签切换。 | Devin AI<br>默认分支 |
| 17:24:42<br>[c33fa9a](https://github.com/OldGuestInBreeze/-1/commit/c33fa9a95dee148789d579c7e93888b0b3f03cf8) | 加入注册流程<br>新增注册页、注册接口和页面路由，并调整登录页入口。 | Devin AI<br>默认分支 |



### 2026-09-09｜首页、个人中心与活动发布

当日记录：4 条。围绕活动发现和用户操作完善客户端，提交活动首页、个人中心、资料编辑、密码设置与活动发布流程。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 14:50:32<br>[ed8949a](https://github.com/OldGuestInBreeze/-1/commit/ed8949a337ac6f182d57555ab2f1ea6ab554f845) | 搭建活动首页<br>加入活动接口、活动卡片、首页视图、活动模型及登录状态工具。 | Devin AI<br>默认分支 |
| 15:50:09<br>[c2dd033](https://github.com/OldGuestInBreeze/-1/commit/c2dd033222702ebb976b146069909c00b1cf1710) | 加入个人中心<br>新增个人中心视图，并接入应用入口与主页面。 | Devin AI<br>默认分支 |
| 16:21:54<br>[2dce3aa](https://github.com/OldGuestInBreeze/-1/commit/2dce3aa88a4626d91031bb19eb7a5e0a46c9f7a5) | 加入资料编辑与密码设置<br>新增用户资料编辑页、密码重置页、用户接口及图片上传工具。 | Devin AI<br>默认分支 |
| 23:08:05<br>[c2bced0](https://github.com/OldGuestInBreeze/-1/commit/c2bced0b56fd53655b88a4edccce0bfe5cfdd320) | 加入活动发布流程<br>新增活动编辑页、定位工具与路由参数模型，并扩展活动接口和页面配置。 | Devin AI<br>默认分支 |



### 2026-09-10｜核心活动流程完善与异常修复

当日记录：13 条。提交启动工具包、活动管理、搜索、详情、评论、参与和成员列表，合并 PR #2；随后在扩展开发分支补充数据异常保护与头像保存修正。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 00:01:25<br>[736bf3a](https://github.com/OldGuestInBreeze/-1/commit/736bf3a06c509105b435c41c798e9058decfa95f) | 上传后端启动工具包<br>新增后端一键启动 ZIP 包；这是启动脚本交付记录，不等同于提交后端源码。 | Devin AI<br>默认分支 |
| 10:44:33<br>[9e5b61a](https://github.com/OldGuestInBreeze/-1/commit/9e5b61a6d3f89ff4deda0f73ad5b446ecc92fce7) | 调整首页活动卡片<br>优化活动卡片与首页活动列表的布局。 | Devin AI<br>默认分支 |
| 12:22:15<br>[ad54745](https://github.com/OldGuestInBreeze/-1/commit/ad5474554bc7cacec97863a3d66522de7e2be021) | 调整模拟器后端地址配置<br>更新接口常量中的后端连接地址，供本地模拟器连接使用。 | Devin AI<br>默认分支 |
| 12:32:08<br>[f5a3aef](https://github.com/OldGuestInBreeze/-1/commit/f5a3aefee300710ce9d28c59090e7613363b3d23) | 加入活动管理流程<br>新增“我的活动”页面，扩展活动编辑和管理接口，并配置页面路由。 | Devin AI<br>默认分支 |
| 12:53:10<br>[e5798b1](https://github.com/OldGuestInBreeze/-1/commit/e5798b11e990488cc1f379a32f1e7870ccb0ef5f) | 加入活动搜索结果页<br>新增活动列表页，并连接首页搜索入口与路由。 | Devin AI<br>默认分支 |
| 13:00:44<br>[aed3a49](https://github.com/OldGuestInBreeze/-1/commit/aed3a4972755c6928cadc28a574a82fa63aef40f) | 加入活动详情页<br>新增活动详情页面、详情查询接口及页面路由。 | Devin AI<br>默认分支 |
| 13:28:12<br>[af40cd9](https://github.com/OldGuestInBreeze/-1/commit/af40cd9d79fd5101683b50727a46df2540b9f6fe) | 加入活动评论流程<br>扩展详情页的评论交互，并新增评论接口与 EventComment 模型。 | Devin AI<br>默认分支 |
| 13:47:04<br>[f87a189](https://github.com/OldGuestInBreeze/-1/commit/f87a18969dfb50a314b445331dff9525d6e2d9eb) | 加入活动参与流程<br>扩展加入状态查询与加入操作接口，并接入活动详情页。 | Devin AI<br>默认分支 |
| 13:54:51<br>[722635a](https://github.com/OldGuestInBreeze/-1/commit/722635a71d9afdf0e6ca5a25dd622c7343110d21) | 建设活动与小队标签页<br>加入活动视图、未登录提示和 Team 模型，调整主导航中的活动入口。 | Devin AI<br>默认分支 |
| 14:08:26<br>[95aefe7](https://github.com/OldGuestInBreeze/-1/commit/95aefe7dfeec1b995cfce863aafedd4e50f48ce3) | 加入活动成员列表<br>新增成员列表页、成员模型和查询接口，并接入活动视图与路由。 | Devin AI<br>默认分支 |
| 14:33:32<br>[fb2da21](https://github.com/OldGuestInBreeze/-1/commit/fb2da2190fec521c6c5a0f1534df123d0ff6ebc9) | 合并核心业务流程<br>合并 PR #2，将活动发布、搜索、详情、评论、参与及成员列表等变更纳入默认分支。 | OldGuestInBreeze<br>默认分支 |
| 14:46:32<br>[99bbdc7](https://github.com/OldGuestInBreeze/-1/commit/99bbdc73fa6184f555d9ee7d8eba61c3980e01ce) | 补充活动数据异常保护<br>为请求响应和活动、成员、小队模型补充空值默认值，并调整相关页面的数据处理。 | Devin AI<br>扩展分支 |
| 15:25:24<br>[2ef9174](https://github.com/OldGuestInBreeze/-1/commit/2ef9174745d544168b3860bd85a57fc9445cce43) | 修正头像上传与保存流程<br>调整资料编辑页及图片上传工具，处理头像上传和保存之间的衔接。 | Devin AI<br>扩展分支 |



### 2026-09-12｜社交、地图与后端扩展

当日记录：15 条。在扩展开发分支加入成员管理、好友申请、私信、地图导航和 Spring Boot 后端，随后调整定位、返回按钮、好友通知与应用图标。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 13:22:02<br>[d9d97c9](https://github.com/OldGuestInBreeze/-1/commit/d9d97c99b42e2ae3eaa19eaaf7c143913c0f8291) | 加入发起者成员管理<br>在成员列表页扩展活动发起者的成员管理交互。 | Jacob Young<br>扩展分支 |
| 13:53:22<br>[ce29c16](https://github.com/OldGuestInBreeze/-1/commit/ce29c1605752d606df9c480b2fa3118da16b01e1) | 加入好友申请流程<br>新增好友接口、申请页和好友视图，并接入主导航与页面配置。 | Jacob Young<br>扩展分支 |
| 13:59:21<br>[6da998d](https://github.com/OldGuestInBreeze/-1/commit/6da998d2823edebde1956e0ca194adb2bb766845) | 加入私信聊天流程<br>新增聊天接口、聊天页和聊天模型，并连接好友与成员页面入口。 | Jacob Young<br>扩展分支 |
| 14:19:17<br>[96257aa](https://github.com/OldGuestInBreeze/-1/commit/96257aa8905094864861cbde65e7ad1d1033077c) | 加入附近活动地图<br>新增地图页，扩展位置模型并配置地图页面路由。 | Jacob Young<br>扩展分支 |
| 14:20:26<br>[0fdb49b](https://github.com/OldGuestInBreeze/-1/commit/0fdb49bbfb028c7722326f01d0be493446a3bb97) | 加入活动导航地图<br>新增导航页，并从活动详情页接入导航入口。 | Jacob Young<br>扩展分支 |
| 17:58:02<br>[fd7761a](https://github.com/OldGuestInBreeze/-1/commit/fd7761a87781b9e83959b6fdf50e502a707e3f9d) | 提交 Spring Boot 后端重建版本<br>新增 Maven 后端工程、控制器、服务、数据模型、数据库初始化脚本与地图静态页面。 | Jacob Young<br>扩展分支 |
| 20:22:54<br>[2c3ef67](https://github.com/OldGuestInBreeze/-1/commit/2c3ef67ba52f2c2753335207b42086e439c7b9a2) | 补充后端构建配置与冒烟测试<br>加入 Maven 设置与 BackendSmokeTest，调整启动、打包脚本和接口响应代码。 | Jacob Young<br>扩展分支 |
| 21:05:09<br>[099e816](https://github.com/OldGuestInBreeze/-1/commit/099e8164b25574deb4063d3c93f1734748c8c541) | 修正好友申请提交<br>调整好友接口与成员页中的申请逻辑，并补充后端冒烟测试代码。 | Jacob Young<br>扩展分支 |
| 21:14:33<br>[7c757b4](https://github.com/OldGuestInBreeze/-1/commit/7c757b4444db13c1b5987c0932639dd4011f546e) | 优化模拟器定位处理<br>兼容模糊或精确定位授权，增加定位服务检查、超时调整和最近位置回退处理。 | Jacob Young<br>扩展分支 |
| 21:25:30<br>[bc363a0](https://github.com/OldGuestInBreeze/-1/commit/bc363a00fc51bf6c4312e0ed1b3f56c0a6a60018) | 修正好友及返回按钮交互<br>新增通用 PageBackButton，调整多页面返回交互和成员页好友操作。 | Jacob Young<br>扩展分支 |
| 21:35:44<br>[21bab80](https://github.com/OldGuestInBreeze/-1/commit/21bab808da18a6818ca0abd3d919fb186bf04b4d) | 调整 ArkTS 定位异常处理<br>修改定位工具、返回按钮及相关页面的异常处理与调用代码。 | Jacob Young<br>扩展分支 |
| 21:41:55<br>[3c61d2f](https://github.com/OldGuestInBreeze/-1/commit/3c61d2f73d2e97342cd72ac80f841fbdbd6bb2d4) | 修正好友通知导航<br>调整好友视图中的通知入口与导航交互。 | Jacob Young<br>扩展分支 |
| 21:55:18<br>[c705e49](https://github.com/OldGuestInBreeze/-1/commit/c705e493c871edaf86799267bb95635b804fa015) | 定制应用名称与启动图标<br>修改应用名称资源和图标，并增加中英文名称资源。 | Jacob Young<br>扩展分支 |
| 22:02:39<br>[35373a9](https://github.com/OldGuestInBreeze/-1/commit/35373a9e2519dec93c18ccf1e99bffcc94072b02) | 更新兴趣小队应用图标<br>替换应用级和模块级 foreground.png 图标资源。 | Jacob Young<br>扩展分支 |
| 22:29:58<br>[7cec157](https://github.com/OldGuestInBreeze/-1/commit/7cec157df1f8d851f9e8b411115623389a66f3ea) | 调整好友通知安全区域<br>修改好友通知布局，使其避开状态栏区域。 | Jacob Young<br>扩展分支 |



### 2026-09-14｜环境评审与需求文档归档

当日记录：3 条。上传阶段一环境评审和软件需求规格说明书，并更新需求文档模板格式。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 09:10:37<br>[889c51b](https://github.com/OldGuestInBreeze/-1/commit/889c51b67a5010ac6e1a567f75ea7e5c3c7e26a5) | 上传阶段一环境评审文档<br>新增阶段一环境评审 Word 文档。 | Devin AI<br>扩展分支 |
| 10:24:13<br>[b6d3d9f](https://github.com/OldGuestInBreeze/-1/commit/b6d3d9f46f05c82334fcdb68467e014a109c47a6) | 上传软件需求规格说明书<br>新增软件需求规格说明书 Word 文档。 | Devin AI<br>扩展分支 |
| 10:38:17<br>[5ed281f](https://github.com/OldGuestInBreeze/-1/commit/5ed281fbe272e33be30dd4d1fdec91fe79ba951c) | 调整需求说明书模板格式<br>更新已上传的需求规格说明书，提交标题说明此次调整保留模板格式。 | Devin AI<br>扩展分支 |

### 2026-09-15｜概要设计文档归档

当日记录：1 条。上传兴趣小队系统概要设计文档。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 09:33:53<br>[0b89e8d](https://github.com/OldGuestInBreeze/-1/commit/0b89e8d16d30e7d185c191b3d5ac38ed61dd15ea) | 上传概要设计文档<br>新增系统概要设计 Word 文档。 | Devin AI<br>扩展分支 |

### 2026-09-16｜详细设计、测试报告与论文归档

当日记录：4 条。上传详细设计、系统测试报告和毕业论文，并更新论文图示与封面线条。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 09:45:45<br>[7bfa949](https://github.com/OldGuestInBreeze/-1/commit/7bfa949b3bb12638c053656a322298b8de2625c0) | 上传详细设计文档<br>新增系统详细设计 Word 文档。 | Devin AI<br>扩展分支 |
| 14:59:53<br>[2d68ade](https://github.com/OldGuestInBreeze/-1/commit/2d68adeed73e1b07122d63bf6ba950446165f50e) | 上传系统测试报告<br>新增系统测试报告 Word 文档；文件上传记录本身不代表本次执行了测试。 | Devin AI<br>扩展分支 |
| 15:45:56<br>[b52988c](https://github.com/OldGuestInBreeze/-1/commit/b52988c93cc51c9226571ef481d4e415ac5208e4) | 上传毕业论文<br>新增兴趣小队毕业论文 Word 文档。 | Devin AI<br>扩展分支 |
| 16:40:47<br>[5ca86cf](https://github.com/OldGuestInBreeze/-1/commit/5ca86cfcd3ef4b259041c020a0ad6663f51be553) | 更新论文图示与封面线条<br>更新毕业论文文件，提交标题记载了图示与封面线条调整。 | Devin AI<br>扩展分支 |

### 2026-09-17｜答辩材料交付

当日记录：1 条。在独立文档分支上传可编辑答辩 PPT 和 PDF 预览文件。

| 时间 / 提交 | 工作内容与产出 | 作者 / 范围 |
| --- | --- | --- |
| 23:31:38<br>[29f0685](https://github.com/OldGuestInBreeze/-1/commit/29f0685fe0f6c198ff8b4e5b08bbc276dd3b0105) | 上传项目答辩材料<br>新增 15 页可编辑答辩 PPT 和对应 PDF，供 GitHub 直接下载。 | zhanfeng491198<br>答辩分支 |



## 三、文档与交付包上传索引

从文件变更中识别出 9 个 DOCX、PPTX、PDF 或 ZIP 文件，共 11 次新增或更新。此索引聚焦文档与交付包；源码和常规图片素材的变更见逐条提交记录。

| 文件 / 路径 | 新增与更新记录 | 范围 / 链接 |
| --- | --- | --- |
| 后端启动工具包<br>tools/interest-team-backend-launcher.zip | 2026-09-10 00:01:25<br>新增 [736bf3a](https://github.com/OldGuestInBreeze/-1/commit/736bf3a06c509105b435c41c798e9058decfa95f) | 默认分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/736bf3a06c509105b435c41c798e9058decfa95f/tools/interest-team-backend-launcher.zip) |
| 阶段一环境评审文档<br>docs/interest-team-stage1-environment.docx | 2026-09-14 09:10:37<br>新增 [889c51b](https://github.com/OldGuestInBreeze/-1/commit/889c51b67a5010ac6e1a567f75ea7e5c3c7e26a5) | 扩展分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/889c51b67a5010ac6e1a567f75ea7e5c3c7e26a5/docs/interest-team-stage1-environment.docx) |
| 软件需求规格说明书<br>docs/interest-team-software-requirements-specification.docx | 2026-09-14 10:24:13<br>新增 [b6d3d9f](https://github.com/OldGuestInBreeze/-1/commit/b6d3d9f46f05c82334fcdb68467e014a109c47a6)<br>2026-09-14 10:38:17<br>更新 [5ed281f](https://github.com/OldGuestInBreeze/-1/commit/5ed281fbe272e33be30dd4d1fdec91fe79ba951c) | 扩展分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/5ed281fbe272e33be30dd4d1fdec91fe79ba951c/docs/interest-team-software-requirements-specification.docx) |
| 概要设计文档<br>docs/interest-team-high-level-design.docx | 2026-09-15 09:33:53<br>新增 [0b89e8d](https://github.com/OldGuestInBreeze/-1/commit/0b89e8d16d30e7d185c191b3d5ac38ed61dd15ea) | 扩展分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/0b89e8d16d30e7d185c191b3d5ac38ed61dd15ea/docs/interest-team-high-level-design.docx) |
| 详细设计文档<br>docs/interest-team-detailed-design.docx | 2026-09-16 09:45:45<br>新增 [7bfa949](https://github.com/OldGuestInBreeze/-1/commit/7bfa949b3bb12638c053656a322298b8de2625c0) | 扩展分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/7bfa949b3bb12638c053656a322298b8de2625c0/docs/interest-team-detailed-design.docx) |
| 系统测试报告<br>docs/interest-team-system-test-report.docx | 2026-09-16 14:59:53<br>新增 [2d68ade](https://github.com/OldGuestInBreeze/-1/commit/2d68adeed73e1b07122d63bf6ba950446165f50e) | 扩展分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/2d68adeed73e1b07122d63bf6ba950446165f50e/docs/interest-team-system-test-report.docx) |
| 毕业论文<br>docs/interest-team-graduation-thesis.docx | 2026-09-16 15:45:56<br>新增 [b52988c](https://github.com/OldGuestInBreeze/-1/commit/b52988c93cc51c9226571ef481d4e415ac5208e4)<br>2026-09-16 16:40:47<br>更新 [5ca86cf](https://github.com/OldGuestInBreeze/-1/commit/5ca86cfcd3ef4b259041c020a0ad6663f51be553) | 扩展分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/5ca86cfcd3ef4b259041c020a0ad6663f51be553/docs/interest-team-graduation-thesis.docx) |
| 项目答辩 PDF<br>presentation/interest-team-defense.pdf | 2026-09-17 23:31:38<br>新增 [29f0685](https://github.com/OldGuestInBreeze/-1/commit/29f0685fe0f6c198ff8b4e5b08bbc276dd3b0105) | 答辩分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/29f0685fe0f6c198ff8b4e5b08bbc276dd3b0105/presentation/interest-team-defense.pdf) |
| 项目答辩 PPT<br>presentation/interest-team-defense.pptx | 2026-09-17 23:31:38<br>新增 [29f0685](https://github.com/OldGuestInBreeze/-1/commit/29f0685fe0f6c198ff8b4e5b08bbc276dd3b0105) | 答辩分支<br>[查看文件](https://github.com/OldGuestInBreeze/-1/blob/29f0685fe0f6c198ff8b4e5b08bbc276dd3b0105/presentation/interest-team-defense.pptx) |



## 四、分支与核对说明

| 分支 | 采集时末端提交 |
| --- | --- |
| devin/1788850116-add-module-permissions | [fb2da21](https://github.com/OldGuestInBreeze/-1/commit/fb2da2190fec521c6c5a0f1534df123d0ff6ebc9) |
| devin/1788852083.32064-harmony-login-main-ui | [4a1ce45](https://github.com/OldGuestInBreeze/-1/commit/4a1ce451aa3faea2f9cd6a3cd7ee6994189c7875) |
| devin/1788853038-safe-area-layout | [95aefe7](https://github.com/OldGuestInBreeze/-1/commit/95aefe7dfeec1b995cfce863aafedd4e50f48ce3) |
| devin/1789022641-fix-created-event-crash | [5ca86cf](https://github.com/OldGuestInBreeze/-1/commit/5ca86cfcd3ef4b259041c020a0ad6663f51be553) |
| devin/1789659075-defense-downloads | [29f0685](https://github.com/OldGuestInBreeze/-1/commit/29f0685fe0f6c198ff8b4e5b08bbc276dd3b0105) |

两次合并提交单独计入版本记录；它们引入的内容已在原始开发提交中记录，未作为第二次文件上传重复统计。共享祖先提交按完整 SHA 去重。

2026-09-11 与 2026-09-13 在本次采集范围内没有提交记录，因此没有补写工作内容。日志不推算工时或未留痕的工作。

采集时间：2026-09-17 23:52:39（UTC+8）。本日志采用生成前冻结的提交快照，不包含日志文件自身后续上传的提交。

核对方式：完整克隆 → fetch origin → 获取远端分支 → 读取提交时间与作者 → 逐 SHA 去重 → 比对文件新增/修改 → 检查默认分支可达性。

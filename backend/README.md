# 兴趣小队 Spring Boot 后端

该目录是根据当前 HarmonyOS 客户端接口、`iteam01` 表结构和旧版可执行
JAR 的行为重新实现的后端源码。旧 JAR 只包含编译产物，因此无法逐字恢复原始
Maven 工程，但这里保留了客户端正在调用的接口和响应结构。

## 环境要求

- JDK 17
- Maven 3.9+
- MySQL 8.0，默认端口 `3307`
- 数据库名 `iteam01`

## 首次启动

1. 先备份已有数据库。不要在现有数据库上直接执行含 `DROP TABLE` 的旧备份。
2. 确认 MySQL 8.0 已启动，并允许当前用户创建或访问 `iteam01`。
3. 在本目录构建：

   ```powershell
   mvn -s maven-settings.xml clean package
   ```

4. 双击 `scripts\start-backend.bat`，按提示输入 MySQL 密码。密码只会进入当前
   Java 进程环境，不会写入仓库。
5. 后端默认监听 `8081`，可访问
   `http://127.0.0.1:8081/event/list?kw=&userId=0` 检查启动结果。

应用会通过 `schema.sql` 补齐不存在的核心表，不会删除已有表或账号。若已有
`iteam01` 数据，Spring Boot 会直接使用现有数据。

## 可选环境变量

| 名称 | 默认值 | 用途 |
| --- | --- | --- |
| `DB_URL` | MySQL `127.0.0.1:3307/iteam01` | JDBC 地址 |
| `DB_USERNAME` | `root` | 数据库账号 |
| `DB_PASSWORD` | 空 | 数据库密码 |
| `SERVER_PORT` | `8081` | 后端端口 |
| `UPLOAD_DIRECTORY` | `upload` | 上传图片目录 |
| `HMS_MAP_API_KEY` | 空 | 华为导航地图 Web API Key |
| `HMS_MAP_ACCESS_TOKEN` | 空 | 华为附近活动地图 Access Token |

地图凭据未写入源码。配置相应环境变量后，
`/static/map.html` 和 `/static/navigationMap.html` 才会加载华为地图。

## HarmonyOS 客户端连接

真机或模拟器不能用 `127.0.0.1` 访问电脑。请把客户端 `BaseUrl` 设置为运行
后端电脑的局域网地址，例如：

```text
http://192.168.5.75:8081
```

Windows 防火墙需要允许 Java 或 TCP `8081` 入站。

## API 范围

- 用户：登录、注册、资料、密码更新
- 图片：multipart 字段 `file`
- 活动：列表、搜索、详情、创建、编辑、删除、推荐、附近活动
- 互动：评论、加入/退出、成员列表、我的小队
- 社交：好友列表、好友申请、处理申请、好友状态
- 聊天：历史、发送、单方删除

所有业务接口返回：

```json
{
  "success": true,
  "info": "请求成功",
  "obj": {}
}
```

用户响应不会返回密码。新注册和修改后的密码使用 BCrypt；旧数据库中的明文
兼容记录仅在登录校验成功后自动升级为 BCrypt。

## 打包 Windows 运行包

在 PowerShell 中执行：

```powershell
.\scripts\package-backend.ps1
```

输出文件为 `target\iteam-backend-windows.zip`，其中不包含数据库密码、用户密码
或华为地图凭据。

# eiteam01 数据库结构与 ER 图说明

来源：用户上传的 `eiteam01.sql`。仅解析建表语句，没有执行 SQL，也没有复制 INSERT 业务数据。

源文件 SHA-256：`dcc8f3ecf1cb8f2a052cee07a4fa539f5bccf8dc373e0d044de896429b14b34f`。

## 文件与图例

- `eiteam01-er-full.svg/png`：全部 12 张表、99 个字段、10 条显式外键。
- `eiteam01-er-business.svg/png`：6 张业务表。
- `eiteam01-er-operations.svg/png`：6 张运维表。
- `eiteam01-er.pdf`：第 1 页完整图，第 2–3 页分区图。
- `eiteam01-er.drawio`：三页可编辑源文件，可用 diagrams.net 打开；表及其字段已分组。
- `eiteam01-schema.json`：从 DDL 提取的机器可读结构。
- PK：主键；FK：显式外键；AI：自增；NN：非空；NULL：可空。
- U1：当前表的第 1 个唯一约束组；多字段组合整体唯一，不表示每个字段各自唯一。
- 图中中文表名和关系角色是阅读辅助说明，约束与字段定义以 SQL 为准。
- 连线连接表的实体边界，不表示相接行的字段；确切外键字段见连线标签、FK 标记及下方外键明细。

## 外键关系

全部 10 条外键字段均为 NOT NULL，父端为 1，子端为 0..N；父表无需至少存在一条子记录。
全部外键均声明 `ON DELETE CASCADE ON UPDATE CASCADE`。非空外键不保证每个父记录都被引用。

| 子表字段 | 父表字段 | 约束名称 | 基数（父 → 子） |
| --- | --- | --- | --- |
| it_chat.user_id_from | it_user.id | user_chat | 1 → 0..N |
| it_chat.user_id_to | it_user.id | user_chat_2 | 1 → 0..N |
| it_event.user_id | it_user.id | it_event_ibfk_1 | 1 → 0..N |
| it_event_comment.event_id | it_event.id | it_event_comment_ibfk_1 | 1 → 0..N |
| it_event_comment.user_id | it_user.id | it_event_comment_ibfk_2 | 1 → 0..N |
| it_event_member.event_id | it_event.id | it_event_member_ibfk_1 | 1 → 0..N |
| it_event_member.user_id | it_user.id | it_event_member_ibfk_2 | 1 → 0..N |
| it_friend.user_id | it_user.id | it_friend_ibfk_1 | 1 → 0..N |
| it_friend.friend_id | it_user.id | it_friend_ibfk_2 | 1 → 0..N |
| op_rule.admin_id | op_admin.id | op_rule_ibfk_1 | 1 → 0..N |

## 结构边界

- `op_alert`、`op_api`、`op_operlog`、`op_performance` 没有声明外键，图中保持独立。
- `op_operlog.runner_id` 仅有普通索引 `operlog_user`，不能据此认定它引用 `it_user.id` 或 `op_admin.id`。
- `op_alert.metric_name` 与 `op_rule.metric_name`、`op_operlog.path` 与 `op_api.path` 均未声明外键，未补画推断关系。
- `it_event_member` 通过两个外键连接活动和用户，表达多对多参与关系；SQL 未声明 `(event_id, user_id)` 唯一约束。
- `it_friend` 的 `(user_id, friend_id)` 是有序组合唯一，SQL 并未要求正反向好友记录互为镜像。
- `op_api` 的 `(end, path)` 以及 `op_rule.metric_name` 允许 NULL；MySQL 唯一索引对 NULL 的行为不等同于 NOT NULL 唯一键。
- 字段默认值与备注按 DDL 原文保留；未把字段名推测为额外约束。

## 数据字典

### it_chat · 私信消息

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| user_id_from | bigint unsigned | 否 | 未显式声明 | 否 | — |
| user_id_to | bigint unsigned | 否 | 未显式声明 | 否 | — |
| content | varchar(10240) | 是 | NULL | 否 | — |
| status_from | int | 是 | '1' | 否 | 发送方状态:0正常,1已删除 |
| status_to | int | 是 | '1' | 否 | 接收方状态:0正常,1已删除 |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| user_chat | 普通索引 / BTREE | user_id_from |
| user_chat_2 | 普通索引 / BTREE | user_id_to |

### it_event · 活动

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| user_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| name | varchar(256) | 是 | NULL | 否 | 活动名称 |
| intro | varchar(1024) | 是 | NULL | 否 | 简介 |
| addr | varchar(256) | 是 | NULL | 否 | — |
| head_img | varchar(512) | 是 | NULL | 否 | 活动头像地址 |
| start_time | datetime | 是 | NULL | 否 | — |
| lon | double | 是 | NULL | 否 | 经度 |
| lat | double | 是 | NULL | 否 | 纬度 |
| state | int | 是 | '1' | 否 | 活动状态，默认为1，表示正常。2：已取消 |
| if_delete | int | 是 | '0' | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |
| update_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| user_id | 普通索引 / BTREE | user_id |

### it_event_comment · 活动评论

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| event_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| user_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| content | varchar(1024) | 是 | NULL | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| event_id | 普通索引 / BTREE | event_id |
| user_id | 普通索引 / BTREE | user_id |

### it_event_member · 活动成员

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| event_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| user_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| event_id | 普通索引 / BTREE | event_id |
| user_id | 普通索引 / BTREE | user_id |

### it_friend · 好友申请 / 关系

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| user_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| friend_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| apply | int | 是 | NULL | 否 | 申请状态：0表示拒绝，1表示同意，2表示申请中 |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| user_id | UNIQUE / BTREE | user_id, friend_id |
| friend_id | 普通索引 / BTREE | friend_id |

### it_user · 用户

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| username | varchar(256) | 否 | 未显式声明 | 否 | — |
| password | varchar(256) | 否 | 未显式声明 | 否 | — |
| name | varchar(256) | 是 | NULL | 否 | 名称 |
| addr | varchar(256) | 是 | NULL | 否 | 地址 |
| gender | varchar(4) | 是 | '0' | 否 | 性别 |
| head_img | varchar(512) | 是 | NULL | 否 | 头像 |
| lon | double | 是 | NULL | 否 | — |
| lat | double | 是 | NULL | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |

### op_admin · 管理员

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| username | varchar(64) | 否 | 未显式声明 | 否 | — |
| password | varchar(64) | 否 | 未显式声明 | 否 | — |
| end | varchar(16) | 是 | NULL | 否 | — |
| email | varchar(128) | 是 | NULL | 否 | — |
| receive_email | int | 是 | '0' | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |

### op_alert · 告警记录

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| metric_name | varchar(64) | 是 | NULL | 否 | — |
| metric_value_real | float | 是 | NULL | 否 | — |
| metric_value_rule | float | 是 | NULL | 否 | — |
| metric_unit | varchar(16) | 是 | NULL | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |

### op_api · 接口目录

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| end | varchar(16) | 是 | NULL | 否 | — |
| path | varchar(128) | 是 | NULL | 否 | — |
| intro | varchar(256) | 是 | NULL | 否 | — |
| method | varchar(16) | 是 | NULL | 否 | — |
| param_type | varchar(256) | 是 | NULL | 否 | — |
| param_example | varchar(256) | 是 | NULL | 否 | — |
| response_body | varchar(1024) | 是 | NULL | 否 | — |
| visit | bigint unsigned | 是 | '0' | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| end_path | UNIQUE / BTREE | end, path |

### op_operlog · 操作日志

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| runner_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| runner_type | varchar(32) | 是 | NULL | 否 | — |
| path | varchar(128) | 是 | NULL | 否 | — |
| param | varchar(256) | 是 | NULL | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| operlog_user | 普通索引 / BTREE | runner_id |

### op_performance · 性能采样

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| cpu_usage | float | 是 | NULL | 否 | — |
| cpu_unit | varchar(16) | 是 | NULL | 否 | — |
| memory_total | float | 是 | NULL | 否 | — |
| memory_used | float | 是 | NULL | 否 | — |
| memory_unit | varchar(16) | 是 | NULL | 否 | — |
| net_rx | float | 是 | NULL | 否 | — |
| net_tx | float | 是 | NULL | 否 | — |
| net_unit | varchar(16) | 是 | NULL | 否 | — |
| disk_total | float | 是 | NULL | 否 | — |
| disk_used | float | 是 | NULL | 否 | — |
| disk_unit | varchar(16) | 是 | NULL | 否 | — |
| heap_used | float | 是 | NULL | 否 | — |
| heap_max | float | 是 | NULL | 否 | — |
| heap_unit | varchar(16) | 是 | NULL | 否 | — |
| non_heap_used | float | 是 | NULL | 否 | — |
| non_heap_max | float | 是 | NULL | 否 | — |
| non_heap_unit | varchar(16) | 是 | NULL | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |

### op_rule · 告警规则

主键：`id`。存储与字符集：`InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC`。

| 字段 | 类型 | 可空 | 默认值 | 自增 | SQL 原始注释 |
| --- | --- | --- | --- | --- | --- |
| id | bigint unsigned | 否 | 未显式声明 | 是 | — |
| admin_id | bigint unsigned | 否 | 未显式声明 | 否 | — |
| metric_name | varchar(64) | 是 | NULL | 否 | — |
| metric_value | float | 是 | NULL | 否 | — |
| metric_unit | varchar(16) | 是 | NULL | 否 | — |
| create_time | datetime | 是 | NULL | 否 | — |
| update_time | datetime | 是 | NULL | 否 | — |

| 索引名称 | 类型 | 字段 |
| --- | --- | --- |
| PRIMARY | 主键 / BTREE | id |
| metric_name | UNIQUE / BTREE | metric_name |
| admin_id | 普通索引 / BTREE | admin_id |

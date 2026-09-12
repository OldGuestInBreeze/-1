package com.qst.iteam.service;

import com.qst.iteam.model.ChatPayload;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.NoSuchElementException;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ChatService {

    private static final DateTimeFormatter OUTPUT_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private final JdbcClient jdbc;

    public ChatService(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    public List<ChatPayload> history(long userIdFrom, long userIdTo) {
        return jdbc.sql("""
                        SELECT id, user_id_from, user_id_to, content,
                               status_from, status_to, create_time
                        FROM it_chat
                        WHERE (user_id_from = :userIdFrom
                               AND user_id_to = :userIdTo
                               AND status_from = 0)
                           OR (user_id_from = :userIdTo
                               AND user_id_to = :userIdFrom
                               AND status_to = 0)
                        ORDER BY create_time ASC, id ASC
                        """)
                .param("userIdFrom", userIdFrom)
                .param("userIdTo", userIdTo)
                .query(this::mapChat)
                .list();
    }

    @Transactional
    public ChatPayload send(ChatPayload chat) {
        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.sql("""
                        INSERT INTO it_chat
                            (user_id_from, user_id_to, content, status_from, status_to, create_time)
                        VALUES (:userIdFrom, :userIdTo, :content, 0, 0, CURRENT_TIMESTAMP)
                        """)
                .param("userIdFrom", chat.userIdFrom())
                .param("userIdTo", chat.userIdTo())
                .param("content", chat.content().trim())
                .update(keyHolder, "id");
        return findById(requiredGeneratedId(keyHolder));
    }

    @Transactional
    public void hide(long chatId, Long userIdFrom, Long userIdTo) {
        if (userIdFrom != null && userIdTo != null) {
            throw new IllegalArgumentException("只能指定发送方或接收方");
        }
        if (userIdFrom == null && userIdTo == null) {
            throw new IllegalArgumentException("请求字段缺失");
        }
        String sql = userIdFrom != null
                ? "UPDATE it_chat SET status_from = 1 WHERE id = :chatId AND user_id_from = :userId"
                : "UPDATE it_chat SET status_to = 1 WHERE id = :chatId AND user_id_to = :userId";
        long userId = userIdFrom != null ? userIdFrom : userIdTo;
        int updated = jdbc.sql(sql)
                .param("chatId", chatId)
                .param("userId", userId)
                .update();
        if (updated == 0) {
            throw new NoSuchElementException("未找到该用户可删除的消息");
        }
    }

    private ChatPayload findById(long chatId) {
        return jdbc.sql("""
                        SELECT id, user_id_from, user_id_to, content,
                               status_from, status_to, create_time
                        FROM it_chat
                        WHERE id = :chatId
                        """)
                .param("chatId", chatId)
                .query(this::mapChat)
                .optional()
                .orElseThrow(() -> new NoSuchElementException("未找到该消息"));
    }

    private ChatPayload mapChat(ResultSet resultSet, int rowNumber) throws SQLException {
        Timestamp createTime = resultSet.getTimestamp("create_time");
        return new ChatPayload(
                resultSet.getLong("id"),
                resultSet.getLong("user_id_from"),
                resultSet.getLong("user_id_to"),
                resultSet.getString("content"),
                resultSet.getInt("status_from"),
                resultSet.getInt("status_to"),
                createTime == null ? "" : createTime.toLocalDateTime().format(OUTPUT_FORMAT)
        );
    }

    private long requiredGeneratedId(GeneratedKeyHolder keyHolder) {
        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("未能获取新增消息ID");
        }
        return key.longValue();
    }
}

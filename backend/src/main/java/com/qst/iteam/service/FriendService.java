package com.qst.iteam.service;

import com.qst.iteam.model.PublicUser;
import java.util.List;
import java.util.NoSuchElementException;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FriendService {

    private static final String PUBLIC_USER_COLUMNS =
            "u.id, u.username, u.name, u.head_img AS headImg, u.addr, u.gender, u.lon, u.lat";

    private final JdbcClient jdbc;

    public FriendService(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    public List<PublicUser> friendList(long userId) {
        return jdbc.sql("""
                        SELECT DISTINCT %s
                        FROM it_friend f
                        JOIN it_user u
                          ON (f.friend_id = u.id AND f.user_id = :userId)
                          OR (f.user_id = u.id AND f.friend_id = :userId)
                        WHERE f.apply = 1
                        ORDER BY u.name, u.id
                        """.formatted(PUBLIC_USER_COLUMNS))
                .param("userId", userId)
                .query(PublicUser.class)
                .list();
    }

    public List<PublicUser> applicationList(long userId) {
        return jdbc.sql("""
                        SELECT %s
                        FROM it_friend f
                        JOIN it_user u ON u.id = f.user_id
                        WHERE f.friend_id = :userId AND f.apply = 2
                        ORDER BY f.create_time DESC
                        """.formatted(PUBLIC_USER_COLUMNS))
                .param("userId", userId)
                .query(PublicUser.class)
                .list();
    }

    @Transactional
    public void sendApplication(long userId, long friendId) {
        if (userId == friendId) {
            throw new IllegalArgumentException("不能添加自己为好友");
        }
        jdbc.sql("""
                        INSERT INTO it_friend (user_id, friend_id, apply, create_time)
                        VALUES (:userId, :friendId, 2, CURRENT_TIMESTAMP)
                        ON DUPLICATE KEY UPDATE apply = 2, create_time = CURRENT_TIMESTAMP
                        """)
                .param("userId", userId)
                .param("friendId", friendId)
                .update();
    }

    @Transactional
    public void processApplication(long userId, long friendId, int apply) {
        if (apply != 0 && apply != 1) {
            throw new IllegalArgumentException("申请状态只能是0或1");
        }
        int updated = jdbc.sql("""
                        UPDATE it_friend
                        SET apply = :apply
                        WHERE user_id = :friendId AND friend_id = :userId
                        """)
                .param("apply", apply)
                .param("friendId", friendId)
                .param("userId", userId)
                .update();
        if (updated == 0) {
            throw new NoSuchElementException("好友关系查找失败");
        }
    }

    public int status(long userId, long memberId) {
        return jdbc.sql("""
                        SELECT apply
                        FROM it_friend
                        WHERE (user_id = :userId AND friend_id = :memberId)
                           OR (user_id = :memberId AND friend_id = :userId)
                        ORDER BY id DESC
                        LIMIT 1
                        """)
                .param("userId", userId)
                .param("memberId", memberId)
                .query(Integer.class)
                .optional()
                .orElse(0);
    }
}

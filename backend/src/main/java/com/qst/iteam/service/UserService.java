package com.qst.iteam.service;

import com.qst.iteam.model.PublicUser;
import com.qst.iteam.model.UserPayload;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.NoSuchElementException;
import java.util.Optional;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private static final String PUBLIC_USER_COLUMNS =
            "id, username, name, head_img AS headImg, addr, gender, lon, lat";

    private final JdbcClient jdbc;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional
    public PublicUser login(String username, String rawPassword) {
        UserAccount account = findAccountByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("登录失败，用户名或密码错误"));
        if (!passwordMatches(rawPassword, account.password())) {
            throw new IllegalArgumentException("登录失败，用户名或密码错误");
        }
        if (!isBcrypt(account.password())) {
            jdbc.sql("UPDATE it_user SET password = :password WHERE id = :id")
                    .param("password", passwordEncoder.encode(rawPassword))
                    .param("id", account.id())
                    .update();
        }
        return findById(account.id());
    }

    @Transactional
    public PublicUser register(String username, String rawPassword) {
        if (findAccountByUsername(username).isPresent()) {
            throw new IllegalArgumentException("注册失败，用户名已经存在");
        }
        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.sql("""
                        INSERT INTO it_user (username, password, name, gender, create_time)
                        VALUES (:username, :password, :name, '0', CURRENT_TIMESTAMP)
                        """)
                .param("username", username)
                .param("password", passwordEncoder.encode(rawPassword))
                .param("name", username)
                .update(keyHolder, "id");
        return findById(requiredGeneratedId(keyHolder));
    }

    public PublicUser findById(long userId) {
        return jdbc.sql("SELECT " + PUBLIC_USER_COLUMNS + " FROM it_user WHERE id = :id")
                .param("id", userId)
                .query(PublicUser.class)
                .optional()
                .orElseThrow(() -> new NoSuchElementException("未找到该用户"));
    }

    @Transactional
    public PublicUser updateProfile(UserPayload user) {
        int updated = jdbc.sql("""
                        UPDATE it_user
                        SET name = :name,
                            addr = :addr,
                            gender = :gender,
                            head_img = :headImg,
                            lon = :lon,
                            lat = :lat
                        WHERE id = :id
                        """)
                .param("id", user.id())
                .param("name", defaultString(user.name()))
                .param("addr", defaultString(user.addr()))
                .param("gender", defaultString(user.gender()))
                .param("headImg", defaultString(user.headImg()))
                .param("lon", user.lon())
                .param("lat", user.lat())
                .update();
        if (updated == 0) {
            throw new NoSuchElementException("未找到该用户");
        }
        return findById(user.id());
    }

    @Transactional
    public void updatePassword(long userId, String rawPassword) {
        int updated = jdbc.sql("UPDATE it_user SET password = :password WHERE id = :id")
                .param("password", passwordEncoder.encode(rawPassword))
                .param("id", userId)
                .update();
        if (updated == 0) {
            throw new NoSuchElementException("未找到该用户");
        }
    }

    private Optional<UserAccount> findAccountByUsername(String username) {
        return jdbc.sql("SELECT id, username, password FROM it_user WHERE username = :username")
                .param("username", username)
                .query(UserAccount.class)
                .optional();
    }

    private boolean passwordMatches(String rawPassword, String storedPassword) {
        if (isBcrypt(storedPassword)) {
            return passwordEncoder.matches(rawPassword, storedPassword);
        }
        return MessageDigest.isEqual(
                rawPassword.getBytes(StandardCharsets.UTF_8),
                storedPassword.getBytes(StandardCharsets.UTF_8)
        );
    }

    private boolean isBcrypt(String password) {
        return password != null && password.matches("^\\$2[aby]\\$.*");
    }

    private long requiredGeneratedId(GeneratedKeyHolder keyHolder) {
        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("未能获取新增用户ID");
        }
        return key.longValue();
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }

    private record UserAccount(Long id, String username, String password) {
    }
}

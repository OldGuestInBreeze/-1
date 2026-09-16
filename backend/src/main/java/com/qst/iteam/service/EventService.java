package com.qst.iteam.service;

import com.qst.iteam.model.EventCommentPayload;
import com.qst.iteam.model.EventCommentView;
import com.qst.iteam.model.EventMemberView;
import com.qst.iteam.model.EventPayload;
import com.qst.iteam.model.EventView;
import com.qst.iteam.model.TeamView;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EventService {

    private static final DateTimeFormatter OUTPUT_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final List<DateTimeFormatter> INPUT_FORMATS = List.of(
            OUTPUT_FORMAT,
            DateTimeFormatter.ISO_LOCAL_DATE_TIME,
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")
    );
    private static final String EVENT_COLUMNS = """
            e.id, e.user_id, e.name, e.intro, e.addr, e.head_img, e.start_time,
            e.lon, e.lat, e.state, e.create_time, e.update_time
            """;

    private final JdbcClient jdbc;

    public EventService(JdbcClient jdbc) {
        this.jdbc = jdbc;
    }

    public List<EventView> list(String keyword, Long userId) {
        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        List<EventRow> events = jdbc.sql("""
                        SELECT %s
                        FROM it_event e
                        WHERE e.if_delete = 0
                          AND (:keyword = '' OR e.name LIKE :pattern OR e.intro LIKE :pattern)
                        ORDER BY e.create_time DESC, e.id DESC
                        """.formatted(EVENT_COLUMNS))
                .param("keyword", normalizedKeyword)
                .param("pattern", "%" + normalizedKeyword + "%")
                .query(this::mapEventRow)
                .list();
        return events.stream()
                .map(event -> toView(event, userId == null ? event.state() : joinState(event.id(), userId)))
                .toList();
    }

    public EventView findById(long eventId) {
        EventRow row = jdbc.sql("""
                        SELECT %s
                        FROM it_event e
                        WHERE e.id = :eventId AND e.if_delete = 0
                        """.formatted(EVENT_COLUMNS))
                .param("eventId", eventId)
                .query(this::mapEventRow)
                .optional()
                .orElseThrow(() -> new NoSuchElementException("未找到该活动"));
        return toView(row, row.state());
    }

    public List<EventView> findCreatedBy(long userId) {
        return jdbc.sql("""
                        SELECT %s
                        FROM it_event e
                        WHERE e.user_id = :userId AND e.if_delete = 0
                        ORDER BY e.create_time DESC, e.id DESC
                        """.formatted(EVENT_COLUMNS))
                .param("userId", userId)
                .query(this::mapEventRow)
                .list()
                .stream()
                .map(event -> toView(event, 2))
                .toList();
    }

    @Transactional
    public EventView create(EventPayload event) {
        requireEventFields(event, false);
        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.sql("""
                        INSERT INTO it_event
                            (user_id, name, intro, addr, head_img, start_time, lon, lat,
                             state, if_delete, create_time, update_time)
                        VALUES
                            (:userId, :name, :intro, :addr, :headImg, :startTime, :lon, :lat,
                             :state, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                        """)
                .params(eventParameters(event))
                .update(keyHolder, "id");
        return findById(requiredGeneratedId(keyHolder));
    }

    @Transactional
    public EventView update(EventPayload event) {
        requireEventFields(event, true);
        int updated = jdbc.sql("""
                        UPDATE it_event
                        SET name = :name,
                            intro = :intro,
                            addr = :addr,
                            head_img = :headImg,
                            start_time = :startTime,
                            lon = :lon,
                            lat = :lat,
                            state = :state,
                            update_time = CURRENT_TIMESTAMP
                        WHERE id = :id AND user_id = :userId AND if_delete = 0
                        """)
                .params(eventParameters(event))
                .param("id", event.id())
                .update();
        if (updated == 0) {
            throw new NoSuchElementException("未找到活动，或当前用户不是创建者");
        }
        return findById(event.id());
    }

    @Transactional
    public void delete(long eventId) {
        int deleted = jdbc.sql("DELETE FROM it_event WHERE id = :eventId")
                .param("eventId", eventId)
                .update();
        if (deleted == 0) {
            throw new NoSuchElementException("未找到该活动");
        }
    }

    public EventView recommend() {
        EventRow row = jdbc.sql("""
                        SELECT %s
                        FROM it_event e
                        WHERE e.if_delete = 0
                        ORDER BY (SELECT COUNT(*) FROM it_event_member em WHERE em.event_id = e.id) DESC,
                                 e.create_time DESC
                        LIMIT 1
                        """.formatted(EVENT_COLUMNS))
                .query(this::mapEventRow)
                .optional()
                .orElseThrow(() -> new NoSuchElementException("暂无可推荐活动"));
        return toView(row, row.state());
    }

    public List<EventView> nearby(double targetLat, double targetLon, double distance) {
        return jdbc.sql("""
                        SELECT %s
                        FROM it_event e
                        WHERE e.if_delete = 0
                          AND e.lat BETWEEN :minLat AND :maxLat
                          AND e.lon BETWEEN :minLon AND :maxLon
                        ORDER BY e.create_time DESC
                        """.formatted(EVENT_COLUMNS))
                .param("minLat", targetLat - distance)
                .param("maxLat", targetLat + distance)
                .param("minLon", targetLon - distance)
                .param("maxLon", targetLon + distance)
                .query(this::mapEventRow)
                .list()
                .stream()
                .map(event -> toView(event, event.state()))
                .toList();
    }

    public int joinState(long eventId, long userId) {
        Integer ownerCount = jdbc.sql("""
                        SELECT COUNT(*) FROM it_event
                        WHERE id = :eventId AND user_id = :userId AND if_delete = 0
                        """)
                .param("eventId", eventId)
                .param("userId", userId)
                .query(Integer.class)
                .single();
        if (ownerCount > 0) {
            return 2;
        }
        Integer memberCount = jdbc.sql("""
                        SELECT COUNT(*) FROM it_event_member
                        WHERE event_id = :eventId AND user_id = :userId
                        """)
                .param("eventId", eventId)
                .param("userId", userId)
                .query(Integer.class)
                .single();
        return memberCount > 0 ? 1 : 0;
    }

    @Transactional
    public boolean toggleMembership(long eventId, long userId) {
        findById(eventId);
        if (joinState(eventId, userId) == 2) {
            return true;
        }
        int removed = jdbc.sql("""
                        DELETE FROM it_event_member
                        WHERE event_id = :eventId AND user_id = :userId
                        """)
                .param("eventId", eventId)
                .param("userId", userId)
                .update();
        if (removed > 0) {
            return false;
        }
        jdbc.sql("""
                        INSERT INTO it_event_member (event_id, user_id, create_time)
                        VALUES (:eventId, :userId, CURRENT_TIMESTAMP)
                        """)
                .param("eventId", eventId)
                .param("userId", userId)
                .update();
        return true;
    }

    public List<EventMemberView> members(long eventId, long currentUserId) {
        return jdbc.sql("""
                        SELECT DISTINCT u.id, u.name, u.addr, u.head_img
                        FROM it_user u
                        JOIN it_event e ON e.id = :eventId
                        LEFT JOIN it_event_member em
                          ON em.event_id = e.id AND em.user_id = u.id
                        WHERE u.id = e.user_id OR em.id IS NOT NULL
                        ORDER BY CASE WHEN u.id = e.user_id THEN 0 ELSE 1 END, u.id
                        """)
                .param("eventId", eventId)
                .query((rs, rowNum) -> new EventMemberView(
                        rs.getLong("id"),
                        defaultString(rs.getString("name")),
                        defaultString(rs.getString("addr")),
                        defaultString(rs.getString("head_img")),
                        friendState(currentUserId, rs.getLong("id"))
                ))
                .list();
    }

    public List<TeamView> teams(long userId) {
        return jdbc.sql("""
                        SELECT e.id AS event_id,
                               e.name AS event_name,
                               e.user_id AS create_user_id,
                               owner.name AS owner_name,
                               e.head_img,
                               e.addr,
                               1 + (SELECT COUNT(*) FROM it_event_member count_em
                                    WHERE count_em.event_id = e.id) AS member_count
                        FROM it_event e
                        JOIN it_user owner ON owner.id = e.user_id
                        WHERE e.if_delete = 0
                          AND (e.user_id = :userId OR EXISTS (
                              SELECT 1 FROM it_event_member em
                              WHERE em.event_id = e.id AND em.user_id = :userId
                          ))
                        ORDER BY e.create_time DESC
                        """)
                .param("userId", userId)
                .query((rs, rowNum) -> new TeamView(
                        rs.getLong("event_id"),
                        defaultString(rs.getString("event_name")),
                        rs.getLong("create_user_id"),
                        defaultString(rs.getString("owner_name")),
                        rs.getInt("member_count"),
                        defaultString(rs.getString("head_img")),
                        defaultString(rs.getString("addr"))
                ))
                .list();
    }

    public List<EventCommentView> comments(long eventId) {
        return jdbc.sql("""
                        SELECT c.content, u.name, u.head_img, c.create_time
                        FROM it_event_comment c
                        JOIN it_user u ON u.id = c.user_id
                        WHERE c.event_id = :eventId
                        ORDER BY c.create_time DESC, c.id DESC
                        """)
                .param("eventId", eventId)
                .query((rs, rowNum) -> new EventCommentView(
                        defaultString(rs.getString("content")),
                        defaultString(rs.getString("name")),
                        defaultString(rs.getString("head_img")),
                        formatTimestamp(rs.getTimestamp("create_time"))
                ))
                .list();
    }

    @Transactional
    public void addComment(EventCommentPayload comment) {
        jdbc.sql("""
                        INSERT INTO it_event_comment (event_id, user_id, content, create_time)
                        VALUES (:eventId, :userId, :content, CURRENT_TIMESTAMP)
                        """)
                .param("eventId", comment.eventId())
                .param("userId", comment.userId())
                .param("content", comment.content().trim())
                .update();
    }

    private int friendState(long currentUserId, long memberId) {
        if (currentUserId <= 0 || currentUserId == memberId) {
            return 0;
        }
        return jdbc.sql("""
                        SELECT apply
                        FROM it_friend
                        WHERE (user_id = :currentUserId AND friend_id = :memberId)
                           OR (user_id = :memberId AND friend_id = :currentUserId)
                        ORDER BY id DESC
                        LIMIT 1
                        """)
                .param("currentUserId", currentUserId)
                .param("memberId", memberId)
                .query(Integer.class)
                .optional()
                .orElse(0);
    }

    private EventRow mapEventRow(ResultSet resultSet, int rowNumber) throws SQLException {
        return new EventRow(
                resultSet.getLong("id"),
                resultSet.getLong("user_id"),
                defaultString(resultSet.getString("name")),
                defaultString(resultSet.getString("intro")),
                defaultString(resultSet.getString("addr")),
                defaultString(resultSet.getString("head_img")),
                toLocalDateTime(resultSet.getTimestamp("start_time")),
                nullableDouble(resultSet, "lon"),
                nullableDouble(resultSet, "lat"),
                resultSet.getInt("state"),
                toLocalDateTime(resultSet.getTimestamp("create_time")),
                toLocalDateTime(resultSet.getTimestamp("update_time"))
        );
    }

    private EventView toView(EventRow event, int relationshipState) {
        return new EventView(
                event.id(),
                event.userId(),
                event.name(),
                event.intro(),
                event.addr(),
                event.headImg(),
                formatDateTime(event.startTime()),
                event.lon(),
                event.lat(),
                relationshipState,
                relationshipState,
                formatDateTime(event.createTime()),
                formatDateTime(event.updateTime())
        );
    }

    private Map<String, Object> eventParameters(EventPayload event) {
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("userId", event.userId());
        parameters.put("name", event.name().trim());
        parameters.put("intro", event.intro().trim());
        parameters.put("addr", event.addr().trim());
        parameters.put("headImg", event.headImg().trim());
        parameters.put("startTime", parseDateTime(event.startTime()));
        parameters.put("lon", event.lon() == null ? 0D : event.lon());
        parameters.put("lat", event.lat() == null ? 0D : event.lat());
        parameters.put("state", event.state() == null ? 0 : event.state());
        return parameters;
    }

    private void requireEventFields(EventPayload event, boolean requireId) {
        if (event == null || event.userId() == null || isBlank(event.name())
                || isBlank(event.intro()) || isBlank(event.addr()) || isBlank(event.headImg())
                || (requireId && event.id() == null)) {
            throw new IllegalArgumentException("请求字段缺失");
        }
    }

    private LocalDateTime parseDateTime(String value) {
        if (isBlank(value)) {
            return null;
        }
        for (DateTimeFormatter formatter : INPUT_FORMATS) {
            try {
                return LocalDateTime.parse(value.trim(), formatter);
            } catch (DateTimeParseException ignored) {
            }
        }
        throw new IllegalArgumentException("活动时间格式应为 yyyy-MM-dd HH:mm:ss");
    }

    private Double nullableDouble(ResultSet resultSet, String column) throws SQLException {
        double value = resultSet.getDouble(column);
        return resultSet.wasNull() ? null : value;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }

    private String formatTimestamp(Timestamp timestamp) {
        return timestamp == null ? "" : formatDateTime(timestamp.toLocalDateTime());
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "" : value.format(OUTPUT_FORMAT);
    }

    private long requiredGeneratedId(GeneratedKeyHolder keyHolder) {
        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("未能获取新增活动ID");
        }
        return key.longValue();
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private record EventRow(
            Long id,
            Long userId,
            String name,
            String intro,
            String addr,
            String headImg,
            LocalDateTime startTime,
            Double lon,
            Double lat,
            Integer state,
            LocalDateTime createTime,
            LocalDateTime updateTime
    ) {
    }
}

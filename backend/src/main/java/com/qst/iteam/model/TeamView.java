package com.qst.iteam.model;

public record TeamView(
        Long eventId,
        String eventName,
        Long createUserId,
        String userInfoName,
        Integer memberCount,
        String headImg,
        String addr
) {
}

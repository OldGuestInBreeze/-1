package com.qst.iteam.model;

public record ChatPayload(
        Long id,
        Long userIdFrom,
        Long userIdTo,
        String content,
        Integer statusFrom,
        Integer statusTo,
        String createTime
) {
}

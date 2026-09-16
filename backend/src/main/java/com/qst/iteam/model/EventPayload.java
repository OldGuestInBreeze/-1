package com.qst.iteam.model;

public record EventPayload(
        Long id,
        Long userId,
        String name,
        String intro,
        String addr,
        String headImg,
        String startTime,
        Double lon,
        Double lat,
        Integer state
) {
}

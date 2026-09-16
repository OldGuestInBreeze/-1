package com.qst.iteam.model;

public record EventView(
        Long id,
        Long userId,
        String name,
        String intro,
        String addr,
        String headImg,
        String startTime,
        Double lon,
        Double lat,
        Integer state,
        Integer join,
        String createTime,
        String updateTime
) {
}

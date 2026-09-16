package com.qst.iteam.model;

public record PublicUser(
        Long id,
        String username,
        String name,
        String headImg,
        String addr,
        String gender,
        Double lon,
        Double lat
) {
}

package com.qst.iteam.model;

public record UserPayload(
        Long id,
        String username,
        String password,
        String name,
        String headImg,
        String addr,
        String gender,
        Double lon,
        Double lat
) {
}

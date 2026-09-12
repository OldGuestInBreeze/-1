package com.qst.iteam.model;

public record EventMemberView(
        Long userId,
        String name,
        String addr,
        String headImg,
        Integer apply
) {
}

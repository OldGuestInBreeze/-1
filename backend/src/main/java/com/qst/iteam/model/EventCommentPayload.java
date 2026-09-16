package com.qst.iteam.model;

public record EventCommentPayload(Long eventId, Long userId, String content) {
}

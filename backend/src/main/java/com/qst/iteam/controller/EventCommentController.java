package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.EventCommentPayload;
import com.qst.iteam.model.EventCommentView;
import com.qst.iteam.service.EventService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/eventComment")
public class EventCommentController {

    private final EventService eventService;

    public EventCommentController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping("/listByEventId")
    public ApiResponse<List<EventCommentView>> listByEventId(@RequestParam Long eventId) {
        return ApiResponse.success(eventService.comments(eventId));
    }

    @PostMapping("/insert")
    public ApiResponse<Void> insert(@RequestBody EventCommentPayload comment) {
        if (comment == null || comment.eventId() == null || comment.userId() == null
                || comment.content() == null || comment.content().isBlank()) {
            throw new IllegalArgumentException("请求字段缺失");
        }
        eventService.addComment(comment);
        return ApiResponse.successWithoutBody();
    }
}

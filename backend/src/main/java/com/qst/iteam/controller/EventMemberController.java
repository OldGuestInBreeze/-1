package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.EventMemberView;
import com.qst.iteam.model.TeamView;
import com.qst.iteam.service.EventService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/eventMember")
public class EventMemberController {

    private final EventService eventService;

    public EventMemberController(EventService eventService) {
        this.eventService = eventService;
    }

    @PostMapping("/join")
    public ApiResponse<Boolean> join(@RequestParam Long eventId, @RequestParam Long userId) {
        return ApiResponse.success(eventService.toggleMembership(eventId, userId));
    }

    @GetMapping("/list")
    public ApiResponse<List<EventMemberView>> list(
            @RequestParam Long eventId,
            @RequestParam Long userId
    ) {
        return ApiResponse.success(eventService.members(eventId, userId));
    }

    @GetMapping("/teamList")
    public ApiResponse<List<TeamView>> teamList(@RequestParam Long userId) {
        return ApiResponse.success(eventService.teams(userId));
    }
}

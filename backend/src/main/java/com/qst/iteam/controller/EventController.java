package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.EventPayload;
import com.qst.iteam.model.EventView;
import com.qst.iteam.service.EventService;
import java.util.List;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/event")
public class EventController {

    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping("/info")
    public ApiResponse<EventView> info(@RequestParam Long eventId) {
        return ApiResponse.success(eventService.findById(eventId));
    }

    @GetMapping("/myEventList")
    public ApiResponse<List<EventView>> myEventList(@RequestParam Long userId) {
        return ApiResponse.success(eventService.findCreatedBy(userId));
    }

    @GetMapping("/isJoin")
    public ApiResponse<Integer> isJoin(@RequestParam Long eventId, @RequestParam Long userId) {
        return ApiResponse.success(eventService.joinState(eventId, userId));
    }

    @GetMapping("/list")
    public ApiResponse<List<EventView>> list(
            @RequestParam(required = false, defaultValue = "") String kw,
            @RequestParam(required = false) Long userId
    ) {
        return ApiResponse.success(eventService.list(kw, userId));
    }

    @PostMapping("/insert")
    public ApiResponse<EventView> insert(@RequestBody EventPayload event) {
        return ApiResponse.success(eventService.create(event));
    }

    @PutMapping("/edit")
    public ApiResponse<EventView> edit(@RequestBody EventPayload event) {
        return ApiResponse.success(eventService.update(event));
    }

    @DeleteMapping("/delete")
    public ApiResponse<Void> delete(@RequestParam Long eventId) {
        eventService.delete(eventId);
        return ApiResponse.successWithoutBody();
    }

    @GetMapping("/recommend")
    public ApiResponse<EventView> recommend() {
        return ApiResponse.success(eventService.recommend());
    }

    @GetMapping("/nearbyList")
    public ApiResponse<List<EventView>> nearbyList(
            @RequestParam Double targetLat,
            @RequestParam Double targetLont,
            @RequestParam Double distance
    ) {
        return ApiResponse.success(eventService.nearby(targetLat, targetLont, distance));
    }

    @GetMapping("/searchEventInfoList")
    public ApiResponse<List<EventView>> searchEventInfoList(@RequestParam String kw) {
        return ApiResponse.success(eventService.list(kw, null));
    }
}

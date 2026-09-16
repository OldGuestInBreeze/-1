package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.PublicUser;
import com.qst.iteam.service.FriendService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/friend")
public class FriendController {

    private final FriendService friendService;

    public FriendController(FriendService friendService) {
        this.friendService = friendService;
    }

    @GetMapping("/getFriendList")
    public ApiResponse<List<PublicUser>> getFriendList(@RequestParam Long userId) {
        return ApiResponse.success(friendService.friendList(userId));
    }

    @PostMapping("/sendApply")
    public ApiResponse<Void> sendApply(@RequestParam Long userId, @RequestParam Long friendId) {
        friendService.sendApplication(userId, friendId);
        return ApiResponse.successWithoutBody();
    }

    @PostMapping("/processApply")
    public ApiResponse<Void> processApply(
            @RequestParam Long userId,
            @RequestParam Long friendId,
            @RequestParam Integer apply
    ) {
        friendService.processApplication(userId, friendId, apply);
        return ApiResponse.successWithoutBody();
    }

    @GetMapping("/applyList")
    public ApiResponse<List<PublicUser>> applyList(@RequestParam Long userId) {
        return ApiResponse.success(friendService.applicationList(userId));
    }

    @GetMapping("/status")
    public ApiResponse<Integer> status(@RequestParam Long userId, @RequestParam Long memberId) {
        return ApiResponse.success(friendService.status(userId, memberId));
    }
}

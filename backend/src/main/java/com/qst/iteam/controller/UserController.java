package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.PublicUser;
import com.qst.iteam.model.UserPayload;
import com.qst.iteam.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public ApiResponse<PublicUser> login(@RequestBody UserPayload user) {
        requireCredentials(user);
        return ApiResponse.success(userService.login(user.username().trim(), user.password()));
    }

    @PostMapping("/reg")
    public ApiResponse<PublicUser> register(@RequestBody UserPayload user) {
        requireCredentials(user);
        return ApiResponse.success(userService.register(user.username().trim(), user.password()));
    }

    @PostMapping("/logout")
    public ApiResponse<PublicUser> logout(@RequestParam Long userId) {
        return ApiResponse.success(userService.findById(userId));
    }

    @GetMapping("/info")
    public ApiResponse<PublicUser> info(@RequestParam Long userId) {
        return ApiResponse.success(userService.findById(userId));
    }

    @PutMapping("/update")
    public ApiResponse<PublicUser> update(@RequestBody UserPayload user) {
        if (user == null || user.id() == null) {
            throw new IllegalArgumentException("请求字段缺失");
        }
        return ApiResponse.success(userService.updateProfile(user));
    }

    @PutMapping("/updatePassword")
    public ApiResponse<Void> updatePassword(@RequestBody UserPayload user) {
        if (user == null || user.id() == null || isBlank(user.password())) {
            throw new IllegalArgumentException("请求字段缺失");
        }
        userService.updatePassword(user.id(), user.password());
        return ApiResponse.success();
    }

    private void requireCredentials(UserPayload user) {
        if (user == null || isBlank(user.username()) || isBlank(user.password())) {
            throw new IllegalArgumentException("请求字段缺失");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}

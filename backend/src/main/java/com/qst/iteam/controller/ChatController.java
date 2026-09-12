package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.ChatPayload;
import com.qst.iteam.service.ChatService;
import java.util.List;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/chat")
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/byUserIdFromAndTo")
    public ApiResponse<List<ChatPayload>> history(
            @RequestParam Long userIdFrom,
            @RequestParam Long userIdTo
    ) {
        return ApiResponse.success(chatService.history(userIdFrom, userIdTo));
    }

    @PostMapping("/insert")
    public ApiResponse<ChatPayload> insert(@RequestBody ChatPayload chat) {
        if (chat == null || chat.userIdFrom() == null || chat.userIdTo() == null
                || chat.content() == null || chat.content().isBlank()) {
            throw new IllegalArgumentException("请求字段缺失");
        }
        return ApiResponse.success(chatService.send(chat));
    }

    @DeleteMapping("/delete")
    public ApiResponse<Void> delete(
            @RequestParam Long chatId,
            @RequestParam(required = false) Long userIdFrom,
            @RequestParam(required = false) Long userIdTo
    ) {
        chatService.hide(chatId, userIdFrom, userIdTo);
        return ApiResponse.success();
    }
}

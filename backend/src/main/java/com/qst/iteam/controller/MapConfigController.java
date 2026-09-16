package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import com.qst.iteam.model.MapConfig;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/map")
public class MapConfigController {

    private final String apiKey;
    private final String accessToken;

    public MapConfigController(
            @Value("${app.hms-map-api-key}") String apiKey,
            @Value("${app.hms-map-access-token}") String accessToken
    ) {
        this.apiKey = apiKey;
        this.accessToken = accessToken;
    }

    @GetMapping("/config")
    public ApiResponse<MapConfig> config() {
        return ApiResponse.success(new MapConfig(apiKey, accessToken));
    }
}

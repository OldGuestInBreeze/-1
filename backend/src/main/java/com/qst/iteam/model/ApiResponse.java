package com.qst.iteam.model;

public record ApiResponse<T>(boolean success, String info, T obj) {

    public static <T> ApiResponse<T> success(T obj) {
        return new ApiResponse<>(true, "请求成功", obj);
    }

    public static ApiResponse<Void> success() {
        return new ApiResponse<>(true, "请求成功", null);
    }

    public static <T> ApiResponse<T> error(String info) {
        return new ApiResponse<>(false, info, null);
    }
}

package com.qst.iteam.config;

import com.qst.iteam.model.ApiResponse;
import java.util.NoSuchElementException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler({
            IllegalArgumentException.class,
            MissingServletRequestParameterException.class,
            HttpMessageNotReadableException.class
    })
    public ApiResponse<Void> handleBadRequest(Exception exception) {
        return ApiResponse.error(exception.getMessage() == null ? "请求参数错误" : exception.getMessage());
    }

    @ExceptionHandler(NoSuchElementException.class)
    public ApiResponse<Void> handleNotFound(NoSuchElementException exception) {
        return ApiResponse.error(exception.getMessage());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ApiResponse<Void> handleConflict(DataIntegrityViolationException exception) {
        return ApiResponse.error("数据已存在或关联数据无效");
    }
}

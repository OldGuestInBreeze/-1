package com.qst.iteam.controller;

import com.qst.iteam.model.ApiResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/upload")
public class UploadController {

    private static final Set<String> ALLOWED_EXTENSIONS =
            Set.of("jpg", "jpeg", "png", "gif", "bmp", "webp");

    private final Path uploadDirectory;

    public UploadController(@Value("${app.upload-directory}") String uploadDirectory) {
        this.uploadDirectory = Path.of(uploadDirectory).toAbsolutePath().normalize();
    }

    @PostMapping("/uploadFile")
    public ApiResponse<String> upload(@RequestParam("file") MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("请选择要上传的图片");
        }
        String originalName = StringUtils.cleanPath(
                file.getOriginalFilename() == null ? "image.jpg" : file.getOriginalFilename()
        );
        String extension = StringUtils.getFilenameExtension(originalName);
        String normalizedExtension = extension == null ? "" : extension.toLowerCase(Locale.ROOT);
        if (!ALLOWED_EXTENSIONS.contains(normalizedExtension)) {
            throw new IllegalArgumentException("仅支持 jpg、png、gif、bmp 或 webp 图片");
        }

        Files.createDirectories(uploadDirectory);
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + normalizedExtension;
        Path destination = uploadDirectory.resolve(fileName).normalize();
        if (!destination.startsWith(uploadDirectory)) {
            throw new IllegalArgumentException("文件名无效");
        }
        file.transferTo(destination);
        return ApiResponse.success("/upload/" + fileName);
    }
}

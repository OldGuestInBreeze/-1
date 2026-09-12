package com.qst.iteam;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:iteam;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "app.upload-directory=target/test-upload"
})
@AutoConfigureMockMvc
class BackendSmokeTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void coreApisReturnClientCompatibleResponses() throws Exception {
        long firstUserId = register("smoke-user-1");
        long secondUserId = register("smoke-user-2");

        mockMvc.perform(post("/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"smoke-user-1","password":"password123"}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.obj.id").value(firstUserId))
                .andExpect(jsonPath("$.obj.password").doesNotExist());

        MvcResult eventResult = mockMvc.perform(post("/event/insert")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId":%d,
                                  "name":"Smoke event",
                                  "intro":"Backend smoke test",
                                  "addr":"Test address",
                                  "headImg":"/upload/smoke.png",
                                  "startTime":"2026-09-12 18:30:00",
                                  "lon":116.40,
                                  "lat":39.90,
                                  "state":1
                                }
                                """.formatted(firstUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andReturn();
        long eventId = responseObjectId(eventResult);

        mockMvc.perform(get("/event/list"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.obj[0].id").value(eventId));

        mockMvc.perform(get("/friend/status")
                        .param("userId", Long.toString(firstUserId))
                        .param("memberId", Long.toString(secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.obj").value(0));

        mockMvc.perform(post("/friend/sendApply")
                        .param("userId", Long.toString(firstUserId))
                        .param("friendId", Long.toString(secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(get("/friend/status")
                        .param("userId", Long.toString(firstUserId))
                        .param("memberId", Long.toString(secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.obj").value(2));

        mockMvc.perform(get("/friend/applyList")
                        .param("userId", Long.toString(secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.obj[0].id").value(firstUserId));

        mockMvc.perform(post("/friend/processApply")
                        .param("userId", Long.toString(secondUserId))
                        .param("friendId", Long.toString(firstUserId))
                        .param("apply", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(get("/friend/status")
                        .param("userId", Long.toString(firstUserId))
                        .param("memberId", Long.toString(secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.obj").value(1));

        mockMvc.perform(get("/friend/getFriendList")
                        .param("userId", Long.toString(firstUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.obj[0].id").value(secondUserId));

        mockMvc.perform(post("/chat/insert")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userIdFrom":%d,
                                  "userIdTo":%d,
                                  "content":"hello"
                                }
                                """.formatted(firstUserId, secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(get("/chat/byUserIdFromAndTo")
                        .param("userIdFrom", Long.toString(firstUserId))
                        .param("userIdTo", Long.toString(secondUserId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.obj[0].content").value("hello"));
    }

    private long register(String username) throws Exception {
        MvcResult result = mockMvc.perform(post("/user/reg")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"%s","password":"password123"}
                                """.formatted(username)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.obj.password").doesNotExist())
                .andReturn();
        return responseObjectId(result);
    }

    private long responseObjectId(MvcResult result) throws Exception {
        JsonNode response = objectMapper.readTree(result.getResponse().getContentAsByteArray());
        return response.path("obj").path("id").asLong();
    }
}

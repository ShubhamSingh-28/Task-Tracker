package com.internal.tasktracker;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class TaskControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void searchNeverReturnsArchivedTasks() throws Exception {
        mockMvc.perform(get("/api/tasks?q=api&pageSize=100"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[?(@.archived == true)]").isEmpty());
    }

    @Test
    void statusFilterAppliesToEveryResult() throws Exception {
        mockMvc.perform(get("/api/tasks?q=api&status=OPEN&pageSize=100"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[?(@.status != 'OPEN')]").isEmpty());
    }

    @Test
    void invalidStatusReturns400() throws Exception {
        mockMvc.perform(get("/api/tasks?status=foo"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void pageZeroIsClampedToPageOne() throws Exception {
        mockMvc.perform(get("/api/tasks?page=0&pageSize=-5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.page").value(1))
                .andExpect(jsonPath("$.pageSize").value(1));
    }

    @Test
    void percentSignIsNotAWildcard() throws Exception {
        mockMvc.perform(get("/api/tasks?q=%25"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(0));
    }
}

package com.devsecops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class NumericApplication {

        public static void main(String[] args) {
                SpringApplication.run(NumericApplication.class, args);
        }

        @Test
        public void incrementByOneMessage() throws Exception {
                this.mockMvc.perform(get("/increment/50")).andDo(print()).andExpect(status().isOk())
                .andExpect(content().string("51"));
        }
}

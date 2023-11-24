package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@RestController
public class NumericController {

        private final Logger logger = LoggerFactory.getLogger(getClass());
        private static final String baseURL = "http://node-service:5000/plusone";

        RestTemplate restTemplate = new RestTemplate();

        @RestController
        public class compare {

            @Test
            public void smallerThanOrEqualToFiftyMessage() throws Exception {
                this.mockMvc.perform(get("/compare/50")).andDo(print()).andExpect(status().isOk())
                  .andExpect(content().string("Smaller than or equal to 50"));
            }
        
            @Test
            public void greaterThanFiftyMessage() throws Exception {
                this.mockMvc.perform(get("/compare/51")).andDo(print()).andExpect(status().isOk())
                        .andExpect(content().string("Greater than 50"));
            }
        
            @Test
            public void welcomeMessage() throws Exception {
                 this.mockMvc.perform(get("/")).andDo(print()).andExpect(status().isOk())
                   .andExpect(content().string("Kubernetes DevSecOps"));
            }
        }

}

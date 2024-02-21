package com.amtoya.log4shell.vulnerable;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {

    private static final Logger logger = LogManager.getLogger("vulnerable-logger");

    @GetMapping("/")
    public String index(@RequestHeader("user") String user) {
        logger.info("Welcome to the Server " + user);
        return "Welcome to the Server " + user;
    }
}

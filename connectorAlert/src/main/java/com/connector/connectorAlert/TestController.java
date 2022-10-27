package com.connector.connectorAlert;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class TestController {

    @Autowired
    ConnectorRepository repository;

    @GetMapping("/count")
    public Integer getAllEmployees() {
        return repository.findCount();

    }


}

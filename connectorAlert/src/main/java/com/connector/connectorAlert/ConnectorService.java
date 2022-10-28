package com.connector.connectorAlert;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;


@Service
public class ConnectorService {

    @Autowired
    ConnectorRepository repository;

    @Scheduled(fixedDelay = 1000)
    public Integer getAllEmployees() {
        Integer count = repository.findCount();
        System.out.println(count);
        if (count > 500) {
            JavaMailSender.sendEmail();
        }
        return count;

    }
}

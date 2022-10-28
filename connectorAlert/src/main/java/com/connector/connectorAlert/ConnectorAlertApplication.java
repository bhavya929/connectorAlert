package com.connector.connectorAlert;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ConnectorAlertApplication {

	public static void main(String[] args) {
		SpringApplication.run(ConnectorAlertApplication.class, args);
	}

}

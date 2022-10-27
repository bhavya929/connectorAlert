package com.connector.connectorAlert;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;


@Repository
public class ConnectorRepository {
    @Autowired
    JdbcTemplate jdbctemplate;

    public Integer findCount() {
        return jdbctemplate.queryForObject("SELECT count(*) FROM CONNECTOR. PACKAGE where state_id = 10 and attempts = 0",Integer.class);
    }

}

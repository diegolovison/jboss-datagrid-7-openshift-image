@jboss-datagrid-7
Feature: Openshift DataGrid tests

  Scenario: readinessProbe and livenessProbe runs successfully with user security
    When container is started with env
       | variable                                      | value                 |
       | USERNAME                                      | jdg                   |
       | PASSWORD                                      | JBoss.123             |
       | CACHE_ROLES                                   | admin                 |
       | CONTAINER_SECURITY_ROLE_MAPPER                | identity-role-mapper  |
       | CONTAINER_SECURITY_ROLES                      | admin=ALL             |
       | DEFAULT_CACHE_SECURITY_AUTHORIZATION_ENABLED  | true                  |
       | DEFAULT_CACHE_SECURITY_AUTHORIZATION_ROLES    | admin                 |
    Then container log should contain WFLYSRV0025: Data Grid 7.
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: Check for default debug port
    When container is started with env
       | variable            | value                   |
       | DEBUG               | true                    |
    Then container log should contain -agentlib:jdwp=transport=dt_socket,address=8787,server=y,suspend=n

  Scenario: Check for custom debug port
    When container is started with env
       | variable            | value                   |
       | DEBUG               | true                    |
       | DEBUG_PORT          | 8788                    |
    Then container log should contain -agentlib:jdwp=transport=dt_socket,address=8788,server=y,suspend=n

  Scenario: readinessProbe and livenessProbe runs successfully with jolokia https default
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: readinessProbe and livenessProbe runs successfully with jolokia http
    When container is started with env
       | variable            | value                   |
       | AB_JOLOKIA_HTTPS    |                         |
    Then container log should match regex .*Data Grid.*started.*
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: Check if jolokia is configured correctly
    When container is ready
    Then container log should contain -javaagent:/opt/jboss/container/jolokia/jolokia.jar=config=/opt/jboss/container/jolokia/etc/jolokia.properties

  Scenario: Check for add-user failures
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And available container log should not contain AddUserFailedException

  Scenario: CLOUD-351: Check for BindException
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And available container log should not contain BindException

  Scenario: Ensure that we have a clustered cache container
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And available container log should not contain Failed to add DIST_SYNC default cache to non-clustered clustered cache container

  Scenario: Ensure that the server starts cleanly
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And container log should not contain started (with errors)
     And file /opt/datagrid/standalone/configuration/standalone-openshift.xml should not exist

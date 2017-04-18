# Icinga Cloud

This is a simple web service, allowing applications to access all Icinga2 instances an user has configured over a central server.

Applications can authenticate against the service by using OAuth2 oder HTTP basic authentication.

This service was developed as an dependency for the Icinga Alexa skill. Alexa skills do not support any kind of configuration from the end user other than account linking. This service is used as the API for the skill.
Because this service is very simple, it should be possible to use it for other applications, too. Maybe it's even usefull for anyone out there.

More information can be found in the [documentation](/doc).

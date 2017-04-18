# Icinga Cloud

Dies ist ein kleiner Webdienst, der es Anwendungen ermöglicht, über einen zentralen Server auf verschiedene Icinga2-Instanzen und deren APIs zuzugreifen.

Anwendungen können sich dabei per OAuth2, Cookie oder Basic-Authentifizierung an diesem Server anmelden.

Entwickelt wurde dieser Dienst, um einen Skill für Amazon Alexa zu ermöglichen. Diese Skills können vom Endnutzer nicht konfiguriert werden, es gibt nur Accountverknüpfungen über OAuth2. Deshalb war ein zentraler Server als Gateway notwendig, der aber auch für andere Anwendungen genutzt werden kann.

Weitere Informationen gibt es in der [Dokumentation](/doc).

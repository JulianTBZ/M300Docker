# Docker unter Mac
## Einleitung

Aktuell verwende ich die Mac Version `macOS Sierra 10.12.6`.
Das Ziel ist einen Apache Webserver direkt aus dem Docker File zu erstellen.
Dieses soll jeder Zeit erneut ausgeführt und duppliziert werden können.

## Docker installation

Als erstes muss Docker auf dem Mac installiert werden.
Die aktuelle Version kann unter dem folgenden Link heruntergeladen werden.
[https://download.docker.com/mac/stable/Docker.dmg]

Nach dem Download kann das DMG wie eine normale App installiert und gestartet werden.
Docker wird während der Installation die Administrationsrechte abfragen.
Diese werden benötigt um den Docker komplett installieren zu können.
Sobald Docker installiert wurde wird ein Symbol in der Menu-Leiste angezeigt.

## Apache2 Dockerfile erster Versuch

Als erstes möchte ich versuchen einen Docker mit Apache2 zu erstellen.
Mein erstes Testfile sieht wie folgt aus.
```
FROM ubuntu

RUN apt-get update
RUN apt-get install -y apache2 && apt-get autoremove

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
```
Jedes Dockerfile benötigt zwingend als erstes eine definition `FROM`.
Dort muss angegeben, welches OS verwendet wird. 
Ich habe mich für Ububtu entschieden.`FROM ubuntu`
Mit `FROM ubuntu:14.10` dem `:` kann noch die Version definiert werden. 
Wenn nichts definiert wurde, wird immer die neuste Version verwendet. 
Anschliessend werden mit `RUN` die benötigten Befehle ausgeführt. 
Mir dem Befehl `ENV` werden noch einige anpassungen an der Configuration gemacht.

### Build Dockerfile
`docker build -t julianbersnak/apache2:1.0 .`
Mit diesem Befehl kann aus dem Dockerfile ein image erstellt werden.
Nach -t kann der Name des Images angegeben werden.

Mit `docker images` werden alle verfügbaren images angezeigt.
### Run Docker image
Mit dem Befehl ` docker run -ti julianbersnak/apache2:1.0 /bin/bash` kommen wir auf die Command Shell unseres zuvor erstellten Docker Containers. Die Shell kann normal verwendet werden, wie wenn man sich via SSH auf eine VM verbinden würde. Da es sich aber nicht um eine vollständige VM handelt, sondern um eine minimierte Version. Kann es sein das nicht alle Befehle oder Verzeichnisse vorhanden sind, welche bei einer VM vorhanden wären.  Mit dem Befehl `exit` kann der Docker Container wieder verlassen werden.

### Docker infos anzeigen
Nachdem man den Docker Container wieder verlassen hat, kann man mit `docker ps -a` die Container history anzeigen. Diese sollte ähnlich wie die folgende liste aussehen.

| CONTAINER ID | IMAGE | COMMAND | CREATED | STATUS | PORTS | NAMES |
| :---------- | :----------: | :----------: | :----------: | :----------: | :----------: | ----------: |
| 6f3f9a255dd | julianbersnak/apache2:1.0 | "/bin/bash" | 2 minutes ago | Up 2 minutes | 80/tcp | wizardly_heisenberg |

Mir `docker inspect 6f3f9a255dd` können die infos des Containers angezeigt werden. So kann man einfach den Hostnamen und die IP herausfinden. Es werden jedoch noch viel mehr informationen angezeigt. Jedoch kann ich nicht via Browser auf den Webserver zugreiffen.

## Apache2 Dockerfile zweiter Versuch

Im zweiten Docker file installiere ich noch zusätzlich die aktuellen Upgrades.

```
FROM ubuntu:latest

#Install updates
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y upgrade

#Install Webserver
RUN apt-get -y install apache2

#Change config
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

#Start apache2
CMD /usr/sbin/apache2ctl -D FOREGROUND
```
Wenn man den neuen Docker jetzt mit `docker run -p 80:80 julianbersnak/apache2:1.0` startet kann man die Webseite wie von einem normalen Server aufrufen.

## Docker Security
### Uncomplicated Firewall (UFW)
Die Installation der Firewall direkt aus dem Dockerfile geht ohne Probleme. Die Firewall wird korrekt installiert und kann direkt Konfiguriert und gestartet werden. Was leider bisher noch nicht geht ist, dass die Firewall auch automatisch gestartet wird. Obwohl der Befehl dazu im Dockerfile integriert ist, ist der Status der Firewall nach dem Start `inactive`.
```
root@e5531787bfa0:/# ufw status
Status: inactive
root@e5531787bfa0:/# ufw enable
Firewall is active and enabled on system startup
root@e5531787bfa0:/#
``` 

## Docker Monitoring
Da man duzende von Containers Problemlos auf dem System laufen lassen kann. Ist es wichtig, dass man immer über die verfügbaren Ressourcen informiert ist. Es soll direkt erkennbar sein wie gut die Ressourcen des Hostes ausgelastet sind und ob allenfalls ein Container auf einen anderen Host verschoben werden muss. 

Dafür gibt es Zahlreiche Metoden. Die einfachste aber nicht sehr übersichtliche Methode ist direkt in der Commandline. Mit dem Befehl `docker stats` werden die von den Container benötigten Ressourcen angezeigt. 

| CONTAINER ID | NAME | CPU %  | MEM USAGE / LIMIT | MEM % | NET I/O | BLOCK I/O | PIDS |
| :---------- | :----------: | :----------: | :----------: | :----------: | :----------: | :----------: | ----------: |
| bb2a1f7d72ed | julianbersnak/apache2:4.2 | 1.45% | 36.81MiB / 1.952GiB | 1.84% | 303kB / 93MB | 0B / 0B | 12 |

Eine bessere und vorallem Detailiertere und Übersichtlichere Methode ist mit dem cAdvisor Comtainer. 
Dieser kann auch sehr einfach eingesetzt werden. Es muss nur der folgende Befehl eingegeben werden. Anschliessend kann der Container vom Webbrowser angesprochen werden. 

`docker run -d --name cadvisor -v /:/rootfs:ro -v /var/run:/var/run:rw -v /sys:/sys:ro -v /var/lib/docker/:/var/lib/docker:ro -p 8080:8080 google/cadvisor:latest`

Dieser Container hat den Vorteil, dass er direkt ein GUI für das Monitoring der Ressourcen mitliefert.

## Docker Sicherheit
Um die Sicherheit meiner Dockercontainer zu erhöhen habe ich ab V5 noch einen eigenen Benuter für den Docker erstellt. Dieser Benutzer verfügt über weniger Rechte als der Root user. Somit erhöht sich die Sicherheit der gesamten Umgebung. Um sich vor z.B. DosAngriffen besser zu schützen, kann man die Max Ressourcen eines Containers begrenzen. Somit kann nicht die gesamte Leistung des Hostes aufgefressen werden. 

Mit dem folgenden Befehl kann das MAX verfügbare RAM angepasst werden. 
`docker run -m 2096m --memory-swap 2096m`
| Parameter | Beschreibung | 
| -------- | -------- | 
| -m/--memory= | Max Anzahl Megabite die einem Container zur verfügung stehen. |
| --memory-swap | Max Anzahl Megabite die auf die Disk geschrieben werden dürfen. |
| --oom-kill-disable | Beim erreichen der Max. Anzahl Memory fängt der Kernel standard mässig an Prozesse zu beenden. Mit diesem Parameter wird das deaktiviert.  |



## Testing

| Beschreib | Soll-Zustand | Ist-Zustand |
| -------- | -------- | -------- |
| Docker Build | Der Docker Container kann erstellt werden. | Nach dem Command existiert der Container |
| Docker Verbinden | Kann auf den Container Verbinden | Mit Docker run kann man auf die Container verbinden |
| Port Forwarding | Kann vom Localhost auf den Webserver zugreifen | Die Webseite wird vom Host her angezeigt |
| Apache 2 installiert | Der Apache2 Server ist korrekt installiert | Der Server hat alle benötigten files und den richtigen Verzeichnissen. |
| UFW Firewall | Die Firewall wird installiert | Die Firewall wirk korrekt installiert |
| UFW Konfiguration| Die Firewall wird automatisch konfiguriert | Die Firewall wird nicht automatisch konfiguriert, das Script muss noch manuell ausgeführt werden.  |
| Lokale Datei Copy | Das Lokal gespeicherte Script wird in den Container kopiert | Das Vorgesehene Script wird automatisch im Docker zur Verfügung gestellt und kann problemlos ausgeführt werden. |
| Neuer Benutzer | Es wird ein neuer Benutzer angelegt | docker_user existiert im /etc/passwd das bedeutet, dass er existiert. |

## Hilfreiche Commands
| Beschreibung | Command |
| -------- | -------- |
| Alle Docker Stoppen | `docker stop $(docker ps -a -q)` |
| Alle Docker Löschen | `docker rm $(docker ps -a -q)` |
| Docker erstellen | `docker build -t Docker_NAME:Version .` |
| Docker starten |`docker run Docker_NAME:Version` |
| Docker infos anzeigen | `docker inspect Docker_ID` |
| Docker Bash Shell aufrufen | `docker run -ti Docker_NAME:Version /bin/bash` |
| Docker Run mit Parameter | `docker run -p 80:80 julianbersnak/apache2:1.0` |

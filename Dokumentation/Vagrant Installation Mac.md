# Vagrant installation Mac
Als erstes habe ich Vagrant von der Webseite heruntergeladen.
Anschliessend installiert und getestet. 
Da ich es mit VMWare Fusion machen wollte musste ich noch ein zusätzliches Plugin installieren, 
da WMWare Fusion nicht direkt als provider erkannt wird. Wie sich beim Ausführen des Plugins gezeigt hat wird eine
Kostenplichtige Lizenz gebraucht.
Darum habe ich es schlussendlich trotzdem mit Virtualbox gemacht. 
Mit 'vagrant init ubuntu/trusty64' wird das benötigte Vagrantfile erstellt.
Mit 'vagrant up' wird die VM dann mit den Informationen der Datei erstellt. 

Als alternative zu den Vordefinierten Vagrantfiles habe ich meine eigene Datei erstellt um direkt einen Apache2 
Server darauf zu installieren.
Die genaue Configurationseinstellungen können in der Datei `Vagrant_Test1_Apache1_Server` gefunden werden. 
Dieses befindet sich in den Config Files/Vagrantfiles
Dieses File kann auch verwendet werden um andere Dienste oder Services zu installieren während der installation.
Die Befehle zur installation können dazu nach der Zeile 
  ```config.vm.provision "shell", inline: <<-SHELL```
eingefügt werden.

Als zweites habe ich das Vagrantfile Apache2 so angepasst, dass zusätzlich noch die UFW Firewall direkt installiert und konfiguriert wird. 
Detailierte Informationen zum Code finden Sie unter `/Dokumentationen/Config Files/Vagrantfiles/Apache2.1` 
```
    apt-get -y install ufw
    ufw -f enable
    ufw allow 80/tcp
    ufw allow from julianbersnakmbp to any port 22
    ufw reload
```
Als erstes muss die Firewall installiert werden. Den Parameter -y gebe ich mit, um sicher zu gehen das sie auch installiert wird und der Host nicht nach der Bewilligung dafür fragen muss. Anschliessend wird die Firewall enabeld. Danach werden noch einige Konfigurationen vorgenommen. Port 80/tcp wird geöffnet und auch die SSH Verbindung von meinem MAC wird zugelassen. Um die Konfigurationen zu aktivieren muss die UFW Firewall noch neu geladen werden mit reload. apt-get -y install ufw
    ufw -f enable
    ufw allow 80/tcp
    ufw allow from julianbersnakmbp to any port 22
    ufw reload

## Testing

| Beschreib | Soll-Zustand | Ist-Zustand |
| -------- | -------- | -------- |
| SSH Connect   | Ich kann von meinem Localhost auf den Vagrant Server zugreifen.   | Die Verbindung geht ohne Probleme.   |
| Firewall Status   | Die Firewall ist automatisch aktiv.   | Die Firewall ist direkt aktiv ohne einen zusätzlichen Command.    |
| Firewall config | Nur die vordefinierten ports sind enabled. | Es sind nur die beiden Vordefinierten Ports offen. |
| Firewall config | Via Port 443 kann die Webseite nicht aufgerufen werden. | Via Port 443 kann die Webseite nicht geladen werden. |
| Webpage anpassung | Die neue Webseite wird angezeigt. | Die angepasste Webseite wird angezeigt. |
| Webseiten aufruf| Die Webseite kann aufgerufen werden. | Die Webseite wird angezeigt. |
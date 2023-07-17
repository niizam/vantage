.PHONY: install uninstall

install:
	chmod +x ./install.sh
	./install.sh 
	cp ./icon.png /usr/share/icons/hicolor/scalable/apps/vantage.png
	cp ./vantage.desktop /usr/share/applications/vantage.desktop
	cp ./vantage.sh /usr/bin/vantage
	chmod a+rx /usr/bin/vantage

uninstall:
	rm -f /usr/share/icons/hicolor/scalable/apps/vantage.png
	rm -f /usr/share/applications/vantage.desktop
	rm -f /usr/bin/vantage

.PHONY: install uninstall

install:
    ./install.sh  # your script name
    cp ./icon.png /usr/share/icons/hicolor/scalable/apps/vantage.png
    cp ./vantage.desktop /usr/share/applications/vantage.desktop
    cp ./vantage.sh /usr/bin/vantage
    chmod a+rx /usr/bin/vantage

uninstall:
    rm -f /usr/share/icons/hicolor/scalable/apps/vantage.png
    rm -f /usr/share/applications/vantage.desktop
    rm -f /usr/bin/vantage

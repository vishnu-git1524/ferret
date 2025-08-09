import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Rectangle {
        anchors.fill: parent
        color: "#2c3e50"
        
        Column {
            anchors.centerIn: parent
            spacing: 20
            
            Image {
                source: "logo.svg"
                width: 128
                height: 128
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: "Welcome to Ferret OS"
                color: "white"
                font.pixelSize: 32
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: "Fast • Secure • Modern"
                color: "#ecf0f1"
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#34495e"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "Modern Desktop Environment"
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Ferret OS features a beautiful and intuitive XFCE desktop\nwith modern themes and icons for a great user experience."
                    color: "#ecf0f1"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#2c3e50"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "Security First"
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Built-in firewall, AppArmor security, and automatic updates\nkeep your system secure by default."
                    color: "#ecf0f1"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#34495e"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "Complete Software Ecosystem"
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Access thousands of applications through APT, Flatpak,\nand AppImage support."
                    color: "#ecf0f1"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}

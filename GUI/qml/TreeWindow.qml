/**
* @file TreeWindow.qml
* @brief GUI component for a window dedicated to traversing a parsed game tree.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

ApplicationWindow {

    width: 1500
    height: 1000

    modality: Qt.ApplicationModal

    title: "Game tree viewer"

    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.foreground: Material.color(Material.Grey, Material.Shade100)

    property alias node_list: node_list
    property int level: 1

    /**
    * Go up the game tree.
    */
    function up() {
        if (!Julia.up_tree()) {
            return;
        }
        node_list.model = [];
        node_list.model = node_model;
        level = level - 1;
    }

    /**
    * Go down the game tree.
    * @param {int}  i   child index
    */
    function down(i) {
        if (!Julia.down_tree(i + 1)) {
            return;
        }
        node_list.model = [];
        node_list.model = node_model;
        level = level + 1;
    }

    Column {

        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Button {

            id: parent_button

            text: "To parent"
            
            onClicked: {
                tree_window.up();
            }

        }

        TitleText {
            width: parent.width
            text: "Level " + level
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ListView {
            id: node_list
            width: Math.min(contentWidth, tree_window.width)
            height: 1000
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            clip: true

            orientation: ListView.Horizontal

            model: node_model
            delegate: Column {
                
                width: 200
                spacing: 10

                DataText {
                    width: parent.width
                    text: model.trigger
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }

                ListView {
                    id: passive_list
                    width: parent.width
                    height: Math.min(contentHeight, 600)
                    spacing: 5

                    model: passive_nodes
                    delegate: Rectangle {

                        width: passive_list.width
                        height: 140
                        radius: 4
                        
                        Column {

                            width: parent.width
                            height: parent.height
                            spacing: 5

                            DataText {
                                width: parent.width
                                text: model.agent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: parent.width
                                text: "↓"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            DataText {
                                width: parent.width
                                text: model.location
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            DataText {
                                width: parent.width
                                text: "Time = " + model.time
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
                
                Button {

                    width: parent.width
                    height: 140

                    background: Rectangle {

                        width: parent.width
                        height: parent.height
                        radius: 4

                        Column {

                            width: parent.width
                            height: parent.height
                            spacing: 5

                            DataText {
                                width: parent.width
                                text: "<" + model.agent + ", " + model.action + ">"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: parent.width
                                text: "↓"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            DataText {
                                width: parent.width
                                text: model.location
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            DataText {
                                width: parent.width
                                text: "Time = " + model.time
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    onClicked: {
                        tree_window.down(index);
                    }

                }

            }
        }

    }

    onClosing: {
        while (Julia.up_tree()) {
            level = level - 1;
        }
        node_list.model = [];
        node_list.model = node_model;
    }
    
}

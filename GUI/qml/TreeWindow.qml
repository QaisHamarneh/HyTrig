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

    id: tree_window
    width: 1500
    height: 1000
    minimumWidth: 1000
    minimumHeight: 800

    modality: Qt.ApplicationModal

    title: "Game tree viewer"

    Material.theme: window.Material.theme
    Material.accent: window.Material.accent
    Material.foreground: window.Material.foreground

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

    // Page filling column
    Column {

        id: tree_viewer_page
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        TitleText {
            id: level_text
            width: parent.width
            text: "Level " + level
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Layer node list
        ListView {
            id: node_list
            width: Math.min(contentWidth, tree_viewer_page.width)
            height: tree_viewer_page.height - level_text.height - parent_button.height - 2 * parent.spacing
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            clip: true

            orientation: ListView.Horizontal

            model: node_model
            delegate: Column {
                
                width: 300
                spacing: 10
                
                DataText {
                    id: node_agent_text
                    width: parent.width
                    text: "Agent: " + model.agent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }

                DataText {
                    id: node_trigger_text
                    width: parent.width
                    text: "Trigger: " + model.trigger
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }

                DataText {
                    id: node_active_time_text
                    width: parent.width
                    text: "Time = " + model.time
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // Passive node list
                ListView {
                    id: passive_list
                    width: parent.width
                    height: Math.min(contentHeight, node_list.height - node_agent_text.height - node_trigger_text.height - node_active_time_text.height - active_node.height - 5 * parent.spacing)
                    spacing: 5
                    clip: true

                    model: passive_nodes
                    delegate: PassiveNode {}
                }
                
                // Active node
                Button {

                    id: active_node
                    width: parent.width

                    background: ActiveNode{}

                    onClicked: {
                        tree_window.down(index);
                    }

                }

            }
        }

        // Return to parent button
        Button {

            id: parent_button
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Go up"
            
            onClicked: {
                tree_window.up();
            }

        }

    }

    // Reset tree
    onClosing: {
        while (Julia.up_tree()) {
            level = level - 1;
        }
        node_list.model = [];
        node_list.model = node_model;
    }
    
}

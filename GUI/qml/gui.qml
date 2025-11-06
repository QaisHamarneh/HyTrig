import Qt.labs.platform
import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

ApplicationWindow {

    id: window

    visible: true
    width: 1920
    minimumWidth: 1000
    maximumWidth: 3000
    height: 1080
    minimumHeight: 800
    maximumHeight: 2000

    function is_valid_formula(input, level) {
        return Julia.is_valid_formula(input, level)
    }

    function save() {
        Julia.save_to_json();
    }

    Column {

        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Row {

            width: parent.width
            height: parent.height - parent.spacing - menu.height
            spacing: 10
            clip: true

            Column {

                id: left_column
                width: (parent.width - 2 * parent.spacing - page_separator.width) / 2
                height: parent.height
                spacing: 10

                Row {

                    width: parent.width
                    spacing: 20
                    
                    Agents {
                        id: agents
                        width: (parent.width - parent.spacing) / 2
                    }

                    Actions {
                        id: actions
                        width: (parent.width - parent.spacing) / 2
                    }

                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                Variables {
                    id: variables
                    width: parent.width
                }

                Rectangle {
                    id: trigger_spacer
                    width: parent.width
                    height: 5
                    visible: agent_model.rowCount() > 0
                    radius: 4
                    color: "black"
                }

                Triggers {
                    id: triggers
                    width: parent.width
                    visible: agent_model.rowCount() > 0
                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                TerminationConditions {
                    id: terminations
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                Queries {
                    id: queries
                    width: parent.width
                }

            }

            Rectangle {
                id: page_separator
                width: 5
                height: parent.height
                radius: 4
                color: "black"
            }

            Column {

                width: (parent.width - 2 * parent.spacing - page_separator.width) / 2
                height: parent.height
                spacing: 10

                Locations {
                    id: locations
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                Edges {
                    id: edges
                    width: parent.width
                }

            }

        }

        Row {

            id: menu
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Button {
                id: save_button
                width: verify_button.width
                text: "Save"
                onClicked: {
                    save();
                }
            }

            Button {
                id: load_button
                width: verify_button.width
                text: "Load"
            }

            Button {
                id: verify_button
                text: "Verify"
            }
            
        }

    }

    onActiveFocusItemChanged: {
        triggers.visible = agent_model.rowCount() > 0;
        trigger_spacer.visible = agent_model.rowCount() > 0;
    }

}

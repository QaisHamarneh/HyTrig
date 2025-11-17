/**
* @file Triggers.qml
* @brief GUI component for managing triggers in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.julialang

// Outer container for triggers
Column {

    spacing: 10
    property alias trigger_list: trigger_list

    Text {
        width: parent.width
        text: "Triggers"
        color: "white"
    }

    // List of agents
    ListView {

        id: trigger_list
        width: parent.width
        height: Math.min(contentHeight, 200)
        clip: true

        model: agent_model
        delegate: Column {

            width: trigger_list.width
            spacing: 10

            /**
            * Add a trigger to the current agents triggers
            * @param {String} trigger    Trigger formula
            */
            function add_trigger(trigger)
            {
                if (is_valid_formula(trigger, "constraint"))
                {
                    model.triggers.appendRow({name: trigger});
                    trigger_text_field.placeholderText = "Enter trigger";
                    trigger_text_field.text = "";
                }
                else {
                    trigger_text_field.placeholderText = "Invalid trigger";
                    trigger_text_field.text = "";
                }
            }

            /**
            * Remove a trigger from the current agents triggers
            * @param {String} index    Index of the trigger to remove
            */
            function remove_trigger(index)
            {
                model.triggers.removeRow(index);
            }

            Rectangle {

                width: parent.width
                height: 3
                visible: index != 0
                radius: 4
                color: "grey"

            }

            // Agent name
            Text {
                width: parent.width
                text: model.name
                color: "white"
            }

            // List of triggers for the current agent
            ListView {

                id: agent_trigger_list
                width: parent.width
                height: contentHeight
                clip: true
                interactive: false

                model: triggers
                delegate: Row {

                    width: agent_trigger_list.width
                    spacing: 10

                    // Trigger formula
                    Text {
                        width: parent.width -parent.spacing - trigger_button.width
                        text: model.name
                        color: "white"
                    }

                    // Remove trigger button
                    Button {
                        text: "-"
                        height: parent.height
                        onClicked: {
                            triggers.removeRow(index);
                        }
                    }

                }

            }

            // Add trigger row
            Row {

                width: parent.width
                spacing: 10

                // Trigger input field
                TextField {
                    id: trigger_text_field
                    width: parent.width - parent.spacing - trigger_button.width
                    placeholderText: "Enter trigger"
                    onAccepted: {
                        add_trigger(text);
                        focus = false;
                    }
                }

                // Add trigger button
                Button {
                    id: trigger_button
                    Layout.fillHeight: false
                    text: "+"
                    onClicked: {
                        add_trigger(trigger_text_field.text);
                    }
                }

            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

    }

}

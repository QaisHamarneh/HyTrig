/**
* @file Triggers.qml
* @brief GUI component for managing triggers in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// Outer container for triggers
Column {

    spacing: 10
    property alias trigger_list: trigger_list

    TitleText {
        id: trigger_text
        width: parent.width
        text: "Triggers"
    }

    // List of agents
    ListView {

        id: trigger_list
        width: parent.width
        height: parent.height - parent.spacing - trigger_text.height
        spacing: 10
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
                trigger_text_field.focus = true;
                if (is_valid_formula(trigger, "constraint"))
                {
                    model.triggers.appendRow({name: trigger});
                    trigger_text_field.text = "";
                    trigger_text_field.placeholderText = default_text;
                    trigger_text_field.placeholderTextColor = trigger_text_field.default_color;
                }
                else {
                    trigger_text_field.placeholderText = "Invalid trigger";
                    trigger_text_field.placeholderTextColor = trigger_text_field.error_color;
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

            Subspacer {}

            // Agent name
            SubtitleText {
                width: parent.width
                text: model.name
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
                    DataText {
                        width: parent.width -parent.spacing - trigger_button.width
                        text: model.name
                    }

                    // Remove trigger button
                    RemoveButton {
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
                InputField {
                    id: trigger_text_field
                    width: parent.width - parent.spacing - trigger_button.width
                    default_text: "Enter trigger"

                    onAccepted: {
                        add_trigger(text);
                    }
                }

                // Add trigger button
                AddButton {
                    id: trigger_button
                    onClicked: {
                        add_trigger(trigger_text_field.text);
                    }
                }

            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AlwaysOn
        }

    }

}

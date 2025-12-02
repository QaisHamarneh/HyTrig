/**
* @file Actions.qml
* @brief GUI component for managing actions in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// Outer container for actions
Column {

    spacing: 10
    property alias action_list: action_list

    /**
    * Add an action to the action model
    * @param {String} action    Name of the action to add
    */
    function add_action(action)
    {
        var regex = /^[A-Za-z][A-Za-z0-9_]*$/;
        action_text_field.focus = true;
        if (regex.test(action))
        {
            if (!Julia.has_name(action))
            {
                action_model.appendRow({name: action});
                action_text_field.text = "";
                action_text_field.placeholderText = action_text_field.default_text;
                action_text_field.placeholderTextColor = action_text_field.default_color;
                return;
            }
            else {
                action_text_field.placeholderText = "Name is already used";
            }
        }
        else {
            action_text_field.placeholderText = "Invalid action name";
        }
        action_text_field.placeholderTextColor = action_text_field.error_color;
    }

    TitleText {
        id: action_text
        width: parent.width
        text: "Actions"
    }

    // List of actions
    ListView {

        id: action_list
        width: parent.width
        height: parent.height - 2 * parent.spacing - action_text.height - action_input_row.height
        clip: true

        model: action_model
        delegate: Row {

            width: action_list.width
            spacing: 10

            DataText {
                id: action_name
                width: parent.width - parent.spacing - action_button.width
                text: model.name
            }

            // Remove action button
            RemoveButton {
                onClicked: {
                    action_model.removeRow(index);
                }
            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AlwaysOn
        }

    }

    // Add action row
    Row {

        id: action_input_row
        width: parent.width
        spacing: 10

        // Action name input field
        InputField {
            id: action_text_field
            width: parent.width - parent.spacing - action_button.width
            default_text: "Enter action name"

            onAccepted: {
                actions.add_action(action_text_field.text);
            }
        }

        // Add action button
        AddButton {
            id: action_button
            onClicked: {
                actions.add_action(action_text_field.text);
            }
        }

    }

}

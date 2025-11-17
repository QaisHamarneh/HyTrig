/**
* @file Actions.qml
* @brief GUI component for managing actions in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        if (regex.test(action))
        {
            if (!Julia.has_name(action))
            {
                action_model.appendRow({name: action});
                action_text_field.placeholderText = "Enter name";
                action_text_field.text = "";
            }
            else {
                action_text_field.placeholderText = "Name in use";
                action_text_field.text = "";
            }
        }
        else {
            action_text_field.placeholderText = "Invalid name";
            action_text_field.text = "";
        }
    }

    Text {
        width: parent.width
        text: "Actions"
        color: "white"
    }

    // List of actions
    ListView {

        id: action_list
        width: parent.width
        height: Math.min(contentHeight, 100)
        clip: true

        model: action_model
        delegate: Row {

            width: action_list.width
            spacing: 10

            Text {

                id: action_name
                width: parent.width - parent.spacing - action_button.width
                text: model.name
                color: "white"

            }

            // Remove action button
            Button {
                text: "-"
                height: parent.height
                onClicked: {
                    action_model.removeRow(index);
                }
            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

    }

    // Add action row
    Row {

        width: parent.width
        spacing: 10

        // Action name input field
        TextField {
            id: action_text_field
            width: parent.width - parent.spacing - action_button.width
            placeholderText: "Enter name"
            onAccepted: {
                actions.add_action(action_text_field.text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter name";
            }
        }

        // Add action button
        Button {
            id: action_button
            Layout.fillHeight: false
            text: "+"
            onClicked: {
                actions.add_action(action_text_field.text);
            }
        }

    }

}

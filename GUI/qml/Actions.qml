import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10

    function add_action(action)
    {
        var regex = /^[A-Za-z][A-Za-z0-9_]*$/;
        if (regex.test(action) && !Julia.has_name(action))
        {
            action_model.appendRow({name: action});
            action_text_field.placeholderText = "Enter name";
            action_text_field.text = "";
        }
        else {
            action_text_field.placeholderText = "Invalid name";
            action_text_field.text = "";
        }
    }

    Text {
        width: parent.width
        text: "Actions"
    }

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
                color: "blue"

            }

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

    Row {

        width: parent.width
        spacing: 10

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

        Button {
            id: action_button
            Layout.fillHeight: false
            Material.foreground: "white"
            Material.background: Material.DeepOrange
            text: "+"
            onClicked: {
                actions.add_action(action_text_field.text);
            }
        }

    }

}
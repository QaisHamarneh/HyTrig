import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10

    function add_variable(variable, value)
    {
        var name_regex = /^[A-Za-z]\w*$/;
        var value_regex = /(^-?(([1-9]\d*(\.\d+)?$)|(0\.\d*[1-9])$))|(^0$)/;
        if (name_regex.test(variable) && !Julia.has_name(variable))
        {
            if (value_regex.test(value))
            {
            variable_model.appendRow({name: variable, value: value});
                variable_name_text_field.text = "";
                variable_value_text_field.text = "";
            }
            else {
                variable_value_text_field.placeholderText = "Invalid value";
                variable_name_text_field.text = "";
                variable_value_text_field.text = "";
            }
        }
        else {
            variable_name_text_field.placeholderText = "Invalid name";
            variable_name_text_field.text = "";
            variable_value_text_field.text = "";
        }
    }

    Text {
        width: parent.width
        text: "Variables"
    }

    Row {

        width: parent.width - parent.spacing - variable_button.width
        spacing: 10

        Text {
            width: (parent.width - parent.spacing) / 2
            horizontalAlignment: Text.AlignLeft
            text: "Name"
        }
        Text {
            width: (parent.width - parent.spacing) / 2
            horizontalAlignment: Text.AlignLeft
            text: "Initial value"
        }
    }

    ListView {

        id: variable_list
        width: parent.width
        height: Math.min(contentHeight, 100)
        clip: true

        model: variable_model
        delegate: Row {

            width: variable_list.width
            spacing: 10

            Text {
                width: (parent.width - 2 * parent.spacing - variable_button.width) / 2
                horizontalAlignment: Text.AlignLeft
                text: model.name
                color: "blue"
            }

            Text {
                width: (parent.width - 2 * parent.spacing - variable_button.width) / 2
                horizontalAlignment: Text.AlignLeft
                text: model.value
                color: "blue"
            }

            Button {
                text: "-"
                height: parent.height
                onClicked: {
                    variable_model.removeRow(index);
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
            id: variable_name_text_field
            width: (parent.width - 2 * parent.spacing - variable_button.width) / 2
            placeholderText: "Enter name"
            onAccepted: {
                variables.add_variable(variable_name_text_field.text, variable_value_text_field.text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter name";
            }
        }

        TextField {
            id: variable_value_text_field
            width: (parent.width - 2 * parent.spacing - variable_button.width) / 2
            placeholderText: "Enter value"
            onAccepted: {
                variables.add_variable(variable_name_text_field.text, variable_value_text_field.text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter value";
            }
        }

        Button {
            id: variable_button
            Layout.fillHeight: false
            Material.foreground: "white"
            Material.background: Material.DeepOrange
            text: "+"
            onClicked: {
                variables.add_variable(variable_name_text_field.text, variable_value_text_field.text);
            }
        }

    }

}
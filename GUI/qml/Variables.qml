/**
* @file Variables.qml
* @brief GUI component for managing variables in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.julialang

// Outer container for variables
Column {

    spacing: 10
    property alias variable_list: variable_list

    /**
    * Add a variable to the variable model
    * @param {String} variable    Name of the variable to add
    * @param {String} value       Initial value of the variable
    */
    function add_variable(variable, value)
    {
        var name_regex = /^[A-Za-z]\w*$/;
        var value_regex = /(^-?(([1-9]\d*(\.\d+)?$)|(0\.\d*[1-9])$))|(^0$)/;
        if (name_regex.test(variable) && !Julia.has_name(variable))
        {
            if (value_regex.test(value))
            {
                variable_model.appendRow({name: variable, value: value});
                for (var i = 0; i < location_model.rowCount(); i++) {
                    location_model.data(location_model.index(i, 0), roles.flow).appendRow({
                        var: variable,
                        flow: ""
                    });
                }
                for (var i = 0; i < edge_model.rowCount(); i++) {
                    edge_model.data(edge_model.index(i, 0), roles.jump).appendRow({
                        var: variable,
                        jump: ""
                    });
                }
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
        color: "white"
    }

    // Property name row
    Row {

        width: parent.width - parent.spacing - variable_button.width
        spacing: 10

        Text {
            width: (parent.width - parent.spacing) / 2
            horizontalAlignment: Text.AlignLeft
            text: "Name"
            color: "white"
        }
        Text {
            width: (parent.width - parent.spacing) / 2
            horizontalAlignment: Text.AlignLeft
            text: "Initial value"
            color: "white"
        }
    }

    // List of variables
    ListView {

        id: variable_list
        width: parent.width
        height: Math.min(contentHeight, 100)
        clip: true

        model: variable_model
        delegate: Row {

            width: variable_list.width
            spacing: 10

            // Variable name
            Text {
                width: (parent.width - 2 * parent.spacing - variable_button.width) / 2
                horizontalAlignment: Text.AlignLeft
                text: model.name
                color: "white"
            }

            // Variable value
            Text {
                width: (parent.width - 2 * parent.spacing - variable_button.width) / 2
                horizontalAlignment: Text.AlignLeft
                text: model.value
                color: "white"
            }

            // Remove variable button
            Button {
                text: "-"
                height: parent.height
                onClicked: {
                    // Remove variable from flows
                    for (var i = 0; i < location_model.rowCount(); i++) {
                        var flow = location_model.data(location_model.index(i, 0), roles.flow);
                        for (var j = 0; j < flow.rowCount(); j++) {
                            if (flow.data(flow.index(j, 0), roles.flow_variable_name) == model.name) {
                                flow.removeRow(j);
                                break;
                            }
                        }
                    }
                    // Remove variable from jumps
                    for (var i = 0; i < edge_model.rowCount(); i++) {
                        var jump = edge_model.data(edge_model.index(i, 0), roles.jump);
                        for (var j = 0; j < jump.rowCount(); j++) {
                            if (jump.data(jump.index(j, 0), roles.jump_variable_name) == model.name) {
                                jump.removeRow(j);
                                break;
                            }
                        }
                    }
                    variable_model.removeRow(index);
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

    }

    // Add variable row
    Row {

        width: parent.width
        spacing: 10

        // Variable name input field
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

        // Variable value input field
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

        // Add variable button
        Button {
            id: variable_button
            Layout.fillHeight: false
            text: "+"
            onClicked: {
                variables.add_variable(variable_name_text_field.text, variable_value_text_field.text);
            }
        }

    }

}

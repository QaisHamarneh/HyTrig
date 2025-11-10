import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10
    property alias variable_list: variable_list

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
                    for (var i = 0; i < location_model.rowCount(); i++) {
                        var flow = location_model.data(location_model.index(i, 0), roles.flow);
                        for (var j = 0; j < flow.rowCount(); j++) {
                            if (flow.data(flow.index(j, 0), roles.flow_variable_name) == model.name) {
                                flow.removeRow(j);
                                break;
                            }
                        }
                    }
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
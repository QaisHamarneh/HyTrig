import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10
    property alias location_list: location_list

    function add_location(name)
    {
        var regex = /^[A-Za-z]\w*$/;
        if (regex.test(name) && !Julia.has_name(name))
        {
            var flow = []
            for (var i = 0; i < variable_model.rowCount(); i++) {
                flow.push({
                    var: variable_model.data(variable_model.index(i, 0), roles.variable_name),
                    flow: ""
                })
            }
            location_model.appendRow({name: name, inv: "", initial: location_model.rowCount() == 0, flow: flow});
            location_name_text_field.text = "";
            location_name_text_field.placeholderText = "Enter name";
        }
        else {
            location_name_text_field.text = "";
            location_name_text_field.placeholderText = "Invalid name";
        }
    }

    ButtonGroup {
        id: initial_button
    }

    Text {
        width: parent.width
        text: "Locations"
    }

    ListView {

        id: location_list
        width: parent.width
        height: Math.min(contentHeight, 380)
        spacing: 10
        clip: true

        model: location_model
        delegate: Column {

            width: location_list.width
            spacing: 10

            property var location_name: model.name

            Rectangle {

                width: parent.width
                height: 3
                visible: index != 0
                radius: 4
                color: "grey"

            }

            Row {

                width: parent.width
                spacing: 10

                Text {
                    id: location_name_text
                    width: contentWidth
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: "Name"
                }

                Text {

                    width: (
                        parent.width - 5 * parent.spacing - location_name_text.width - location_inv_text.width - initial_location.width - location_remove.width
                    ) / 2
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: model.name
                    color: "blue"
                }

                Text {
                    id: location_inv_text
                    width: contentWidth
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: "Invariant"
                }

                TextField {
                    id: invariant_text_field
                    width: (
                        parent.width - 5 * parent.spacing - location_name_text.width - location_inv_text.width - initial_location.width - location_remove.width
                    ) / 2
                    text: model.inv
                    placeholderText: "Enter invariant"
                    onAccepted: {
                        if (is_valid_formula(text, "constraint"))
                        {
                            model.inv = text;
                            placeholderText = "";
                            focus = false;
                        }
                        else {
                            model.inv = "";
                            text = "";
                            placeholderText = "Invalid invariant";
                        }
                    }
                }

                RadioButton {
                    id: initial_location
                    ButtonGroup.group: initial_button
                    text: "Initial"
                    checked: model.initial
                    onCheckedChanged: {
                        if (model.initial != checked)
                        {
                            model.initial = checked;
                        }
                    }
                }

                Button {
                    id: location_remove
                    text: "-"
                    height: parent.height
                    onClicked: {
                        if (model.initial && location_model.rowCount() != 1) {
                            location_model.removeRow(index);
                            location_model.setData(location_model.index(0, 0), true, roles.initial);
                        }
                        else {
                            location_model.removeRow(index);
                        }
                    }
                }

            }

            Text {
                text: "Flow"
            }

            ListView {

                id: flow_list
                width: parent.width
                height: contentHeight
                spacing: 10
                clip: true
                interactive: false

                model: flow
                delegate: Row {

                    width: flow_list.width
                    spacing: 10

                    Text {
                        height: parent.height
                        width: location_name_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.var
                    }

                    TextField {
                        id: flow_text_field
                        width: parent.width - 2 * parent.spacing - location_name_text.width - initial_location.width
                        text: model.flow
                        placeholderText: "Enter expression"
                        onAccepted: {
                            if (is_valid_formula(text, "expression"))
                            {
                                model.flow = text;
                                placeholderText = "";
                                focus = false;
                            }
                            else {
                                text = "";
                                placeholderText = "Invalid expression";
                            }
                        }
                    }

                }

            }

        }

    }

    Row {

        width: parent.width
        spacing: 10

        TextField {
            id: location_name_text_field

            width: parent.width - parent.spacing - add_location_button.width
            placeholderText: "Enter name"
            onAccepted: {
                locations.add_location(text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter name";
            }
        }

        Button {
            id: add_location_button
            Material.foreground: "white"
            Material.background: Material.DeepOrange
            Layout.fillHeight: false
            text: "+"
            onClicked: {
                locations.add_location(location_name_text_field.text);
            }
        }

    }

}

/**
* @file Locations.qml
* @brief GUI component for managing locations in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.julialang

// Outer container for locations
Column {

    spacing: 10
    property alias location_list: location_list

    /**
    * Add a location to the location model
    * @param {String} name    Name of the location to add
    */
    function add_location(name)
    {
        var regex = /^[A-Za-z]\w*$/;
        if (regex.test(name))
        {
            if (!Julia.has_name(name))
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
                location_name_text_field.placeholderText = "Name in use";
            }
        }
        else {
            location_name_text_field.text = "";
            location_name_text_field.placeholderText = "Invalid name";
        }
    }

    // Button group for 'initial' selector
    ButtonGroup {
        id: initial_button
    }

    Text {
        width: parent.width
        text: "Locations"
        color: "white"
    }

    // List of locations
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

            // Name, invariant, initial and remove button row
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
                    color: "white"
                }

                // Location name
                Text {

                    width: (
                        parent.width - 5 * parent.spacing - location_name_text.width - location_inv_text.width - initial_location.width - location_remove.width
                    ) / 2
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: model.name
                    color: "white"
                }

                Text {
                    id: location_inv_text
                    width: contentWidth
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: "Invariant"
                    color: "white"
                }

                // Invariant input field
                TextField {
                    id: invariant_text_field
                    property bool had_focus: false
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
                    onActiveFocusChanged: {
                        if (had_focus)
                        {
                            had_focus = false;
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
                        } else {
                            had_focus = focus;
                        }
                    }
                }

                // 'Initial' button
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

                // Remove location button
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
                color: "white"
            }

            // Flow list
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

                    // Variable name
                    Text {
                        height: parent.height
                        width: location_name_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.var
                        clip: true
                        color: "white"
                    }

                    // Flow expression input field
                    TextField {
                        id: flow_text_field
                        property bool had_focus: false
                        width: parent.width - 2 * parent.spacing - location_name_text.width - add_location_button.width
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
                        onActiveFocusChanged: {
                            if (had_focus)
                            {
                                had_focus = false;
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
                            } else {
                                had_focus = focus;
                            }
                        }
                    }

                }

            }

        }

    }

    // Add location row
    Row {

        width: parent.width
        spacing: 10

        // Name input field
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

        // Add location button
        Button {
            id: add_location_button
            Layout.fillHeight: false
            text: "+"
            onClicked: {
                locations.add_location(location_name_text_field.text);
            }
        }

    }

}

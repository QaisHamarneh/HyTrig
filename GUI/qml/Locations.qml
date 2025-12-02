/**
* @file Locations.qml
* @brief GUI component for managing locations in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
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
        location_name_text_field.focus = true;
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
                location_name_text_field.placeholderText = location_name_text_field.default_text;
                location_name_text_field.placeholderTextColor = location_name_text_field.default_color;
                return;
            }
            else {
                location_name_text_field.placeholderText = "Name is already used";
            }
        }
        else {
            location_name_text_field.placeholderText = "Invalid name";
        }
        location_name_text_field.placeholderTextColor = location_name_text_field.error_color;
    }

    // Button group for 'initial' selector
    ButtonGroup {
        id: initial_button
    }

    TitleText {
        id: location_text
        width: parent.width
        text: "Locations"
    }

    // List of locations
    ListView {

        id: location_list
        width: parent.width
        height: parent.height - 2 * parent.spacing - location_text.height - location_input_row.height
        spacing: 10
        clip: true

        model: location_model
        delegate: Column {

            width: location_list.width
            spacing: 10

            Subspacer {}

            // Name, invariant, initial and remove button row
            Row {

                width: parent.width
                spacing: 10

                SubtitleText {
                    id: location_name_text
                    width: contentWidth
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: "Name"
                }

                // Location name
                DataText {
                    width: (
                        parent.width - 5 * parent.spacing - location_name_text.width - location_inv_text.width - initial_location.width - location_remove.width
                    ) / 2
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: model.name
                }

                SubtitleText {
                    id: location_inv_text
                    width: contentWidth
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: "Invariant"
                }

                // Invariant input field
                FormulaField {
                    id: invariant_text_field
                    width: (
                        parent.width - 5 * parent.spacing - location_name_text.width - location_inv_text.width - initial_location.width - location_remove.width
                    ) / 2
                    text: model.inv
                    default_text: "Enter invariant"
                    error_text: "Invalid invariant"
                    set_role: (function(x) {model.inv = x;})
                    level: "constraint"
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
                RemoveButton {
                    id: location_remove
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

            SubtitleText {
                id: flow_text
                text: "Flow"
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
                    SubtitleText {
                        height: parent.height
                        width: location_name_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.var
                        clip: true
                    }

                    // Flow expression input field
                    FormulaField {
                        id: flow_text_field
                        width: parent.width - 2 * parent.spacing - location_name_text.width - add_location_button.width
                        text: model.flow
                        default_text: "Enter flow expression"
                        error_text: "Invalid flow expression"
                        set_role: (function(x) {model.flow = x;})
                        level: "expression"
                    }

                }

            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AlwaysOn
        }

    }

    // Add location row
    Row {

        id: location_input_row
        width: parent.width
        spacing: 10

        // Name input field
        InputField {
            id: location_name_text_field
            width: parent.width - parent.spacing - add_location_button.width
            default_text: "Enter location name"

            onAccepted: {
                locations.add_location(text);
            }
        }

        // Add location button
        AddButton {
            id: add_location_button
            onClicked: {
                locations.add_location(location_name_text_field.text);
            }
        }

    }

}

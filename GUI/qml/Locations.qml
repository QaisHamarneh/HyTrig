import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10
    property alias location_model: location_model

    ListModel {

        id: location_model

    }

    function add_location()
    {
        location_model.append({name: "", inv: "", initial: location_model.count == 0});
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

                TextField {
                    id: location_name_text_field
                    width: (
                        parent.width - 5 * parent.spacing - location_name_text.width - location_inv_text.width - initial_location.width - location_remove.width
                    ) / 2
                    placeholderText: "Enter name"
                    onAccepted: {
                        var regex = /^[A-Za-z]\w*$/;
                        if (regex.test(text) && !has_name(text))
                        {
                            model.name = text;
                            placeholderText = "";
                            focus = false;
                        }
                        else {
                            model.name = "";
                            text = "";
                            placeholderText = "Invalid name";
                        }
                    }
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
                        location_model.remove(index, 1);
                    }
                }

            }

            Text {
                text: "Flow"
                visible: variables.variable_model.count > 0
            }

            ListView {

                id: flow
                width: parent.width
                height: contentHeight
                spacing: 10
                clip: true
                interactive: false

                model: variables.variable_model
                delegate: Row {

                    width: flow.width
                    spacing: 10

                    Text {
                        height: parent.height
                        width: location_name_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.name
                    }

                    TextField {
                        id: flow_text_field
                        width: parent.width - 2 * parent.spacing - location_name_text.width - initial_location.width
                        placeholderText: "Enter expression"
                        onAccepted: {
                            if (is_valid_formula(text, "expression"))
                            {
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

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

    }

    Button {
        Material.foreground: "white"
        Material.background: Material.DeepOrange
        Layout.fillHeight: false
        text: "+"
        onClicked: {
            locations.add_location();
        }
    }

}

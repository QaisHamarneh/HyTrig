import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10

    Text {
        width: parent.width
        text: "Edges"
    }

    ListView {

        id: edge_list
        width: parent.width
        height: Math.min(contentHeight, 380)
        spacing: 10
        clip: true

        model: edge_model
        delegate: Column {

            id: edge
            width: edge_list.width
            spacing: 10

            function set_source(src) {
                model.source = src;
            }

            function set_target(tar) {
                model.target = tar;
            }

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
                        width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                        horizontalAlignment: Text.AlignLeft
                        text: "Name"
                    }

                    Text {
                        width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                        horizontalAlignment: Text.AlignLeft
                        text: "Start location"
                    }

                    Text {
                        width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                        horizontalAlignment: Text.AlignLeft
                        text: "End location"
                    }

                    Button {
                        id: edge_remove
                        text: "-"
                        height: parent.height
                        onClicked: {
                            edge_model.removeRow(index);
                        }
                    }

                }

                Row {

                    width: parent.width
                    spacing: 10

                    TextField {
                        id: edge_name_text_field
                        width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                        placeholderText: "Enter name"
                        onAccepted: {
                            var regex = /^[A-Za-z]\w*$/;
                            if (regex.test(text) && !Julia.has_name(text))
                            {
                                model.name = text;
                                placeholderText = "";
                                focus = false;
                            } else {
                            model.name = "";
                            text = "";
                            placeholderText = "Invalid name";
                        }
                    }
                }

                ComboBox {

                    id: edge_start_menu
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3

                    model: location_model

                    textRole: "name"
                    valueRole: "name"
                    onActivated: {
                        set_source(currentValue);
                    }

                    popup.closePolicy: Popup.CloseOnPressOutside

                }

                ComboBox {

                    id: edge_end_menu
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3

                    model: location_model

                    textRole: "name"
                    valueRole: "name"
                    onActivated: {
                        set_target(currentValue);
                    }
                    popup.closePolicy: Popup.CloseOnPressOutside

                }

            }

            Row {

                width: parent.width
                spacing: 10

                Text {
                    width: contentWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    id: guard_text
                    text: "Guard"
                }

                TextField {
                    id: guard_text_field
                    width: parent.width - parent.spacing - guard_text.width
                    placeholderText: "Enter guard"
                    onAccepted: {
                        if (is_valid_formula(text, "expression"))
                        {
                            model.guard = text;
                            placeholderText = "";
                            focus = false;
                        }
                        else {
                            model.guard = "";
                            text = "";
                            placeholderText = "Invalid guard";
                        }
                    }
                }

            }

            Row {

                width: parent.width
                spacing: 10

                Text {
                    width: guard_text.width
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    id: edge_agent_text
                    text: "Agent"
                }

                ComboBox {
                    id: agent_menu
                    width: (parent.width - 3 * parent.spacing - edge_agent_text.width - edge_action_text.width) / 2
                    enabled: agent_model.rowCount() > 0

                    model: agent_model

                    textRole: "name"
                    valueRole: "name"
                    onActivated: {
                        edge_list.model.setProperty(edge_index, "agent", currentValue);
                    }
                    popup.closePolicy: Popup.CloseOnPressOutside
                }

                Text {
                    width: contentWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    id: edge_action_text
                    text: "Action"
                }

                ComboBox {
                    id: action_menu
                    width: (parent.width - 3 * parent.spacing - edge_agent_text.width - edge_action_text.width) / 2
                    enabled: action_model.rowCount() > 0

                    model: action_model

                    textRole: "name"
                    valueRole: "name"
                    onActivated: {
                        edge_list.model.setProperty(edge_index, "action", currentValue);
                    }
                    popup.closePolicy: Popup.CloseOnPressOutside
                }
            }

            Text {
                id: jump_text
                text: "Jump"
            }

            ListView {

                id: jump
                width: parent.width
                height: contentHeight
                spacing: 10
                clip: true
                interactive: false

                model: variables.variable_model
                delegate: Row {

                    width: jump.width
                    spacing: 10

                    Text {
                        height: parent.height
                        width: guard_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.name
                    }

                    TextField {
                        id: jump_text_field
                        width: parent.width - parent.spacing - guard_text.width
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
            edge_model.appendRow({name: "", source: "", target: "", guard: "", agent: "", action: ""});
        }
    }

}
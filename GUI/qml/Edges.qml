import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10
    property alias edge_list: edge_list

    function add_edge(name)
    {
        var regex = /^[A-Za-z]\w*$/;
        if (regex.test(name) && !Julia.has_name(name))
        { 
            var jump = []
            for (var i = 0; i < variable_model.rowCount(); i++) {
                jump.push({
                    var: variable_model.data(variable_model.index(i, 0), roles.variable_name),
                    jump: ""
                })
            }
            edge_model.appendRow({name: name, source: "", target: "", guard: "", agent: "", action: "", jump: jump});
            edge_name_text_field.text = "";
            edge_name_text_field.placeholderText = "Enter name";
        }
        else {
            edge_name_text_field.text = "";
            edge_name_text_field.placeholderText = "Invalid name";
        }
    }
    
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

        property var edge_name: model.name

        model: edge_model
        delegate: Column {

            id: edge
            width: edge_list.width
            spacing: 10

            property var edge_name: model.name

            function get_agent() {
                return model.agent;
            }

            function get_action() {
                return model.action;
            }

            function get_source() {
                return model.source;
            }

            function get_target() {
                return model.target;
            }

            function set_agent(ag) {
                model.agent = ag;
            }

            function set_action(ac) {
                model.action = ac;
            }

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

                    Text {
                        width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                        height: parent.height
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.name
                        color: "blue"
                    }

                ComboBox {

                    id: edge_start_menu
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3

                    model: location_model
                    displayText: get_source()
                    currentIndex: -1

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
                    displayText: get_target()
                    currentIndex: -1

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
                    text: model.guard
                    placeholderText: "Enter guard"
                    onAccepted: {
                        if (is_valid_formula(text, "constraint"))
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

                    model: agent_model
                    displayText: get_agent()
                    currentIndex: -1

                    textRole: "name"
                    valueRole: "name"
                    onActivated: {
                        set_agent(currentValue);
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

                    model: action_model
                    displayText: get_action()
                    currentIndex: -1

                    textRole: "name"
                    valueRole: "name"
                    onActivated: {
                        set_action(currentValue);
                    }
                    popup.closePolicy: Popup.CloseOnPressOutside
                }
            }

            Text {
                id: jump_text
                text: "Jump"
            }

            ListView {

                id: jump_list
                width: parent.width
                height: contentHeight
                spacing: 10
                clip: true
                interactive: false

                model: jump
                delegate: Row {

                    width: jump_list.width
                    spacing: 10

                    Text {
                        height: parent.height
                        width: guard_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.var
                    }

                    TextField {
                        id: jump_text_field
                        width: parent.width - parent.spacing - guard_text.width
                        text: model.jump
                        placeholderText: "Enter expression"
                        onAccepted: {
                            if (is_valid_formula(text, "expression"))
                            {
                                model.jump = text;
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

    Row {

        width: parent.width
        spacing: 10

        TextField {
            id: edge_name_text_field
            width: parent.width - parent.spacing - edge_add_button.width
            placeholderText: "Enter name"
            onAccepted: {
                edges.add_edge(text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter name";
            }
        }

        Button {
            id: edge_add_button
            Material.foreground: "white"
            Material.background: Material.DeepOrange
            Layout.fillHeight: false
            text: "+"
            onClicked: {
                edges.add_edge(edge_name_text_field.text);
            }
        }

    }

}
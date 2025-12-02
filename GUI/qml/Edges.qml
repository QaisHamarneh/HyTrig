/**
* @file Edges.qml
* @brief GUI component for managing edges in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// Outer container for edges
Column {

    spacing: 10
    property alias edge_list: edge_list

    /**
    * Add an edge to the edge model
    * @param {String} name    Name of the edge to add
    */
    function add_edge(name)
    {
        var regex = /^[A-Za-z]\w*$/;
        edge_name_text_field.focus = true;
        if (regex.test(name))
        { 
            if (!Julia.has_name(name))
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
                edge_name_text_field.placeholderText = edge_name_text_field.default_text;
                edge_name_text_field.placeholderTextColor = edge_name_text_field.default_color;
                return;
            }
            else {
                edge_name_text_field.placeholderText = "Name is already used";
            }
        }
        else {
            edge_name_text_field.placeholderText = "Invalid name";
        }
        edge_name_text_field.placeholderTextColor = edge_name_text_field.error_color;
    }
    
    TitleText {
        id: edge_text
        width: parent.width
        text: "Edges"
    }

    // List of edges
    ListView {

        id: edge_list
        width: parent.width
        height: parent.height - 2 * parent.spacing - edge_text.height - edge_input_row.height
        spacing: 10
        clip: true

        model: edge_model
        delegate: Column {

            id: edge
            width: edge_list.width
            spacing: 10

            /**
            * Get the agent of the edge
            * @return {String}  Agent of the edge
            */
            function get_agent() {
                return model.agent;
            }

            /**
            * Get the action of the edge
            * @return {String}  Action of the edge
            */
            function get_action() {
                return model.action;
            }

            /**
            * Get the source location of the edge
            * @return {String}  Source location of the edge
            */   
            function get_source() {
                return model.source;
            }

            /**
            * Get the target location of the edge
            * @return {String}  Target location of the edge
            */
            function get_target() {
                return model.target;
            }

            /**
            * Set the agent of the edge
            * @param {String} ag   Agent to set
            */
            function set_agent(ag) {
                model.agent = ag;
            }

            /**
            * Set the action of the edge
            * @param {String} ac   Action to set
            */
            function set_action(ac) {
                model.action = ac;
            }

            /**
            * Set the source location of the edge
            * @param {String} src   Source location to set
            */
            function set_source(src) {
                model.source = src;
            }

            /**
            * Set the target location of the edge
            * @param {String} tar   Target location to set
            */
            function set_target(tar) {
                model.target = tar;
            }

            Subspacer {}

            // Property name row
            Row {

                width: parent.width
                spacing: 10

                SubtitleText {
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                    horizontalAlignment: Text.AlignLeft
                    text: "Name"
                }

                SubtitleText {
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                    horizontalAlignment: Text.AlignLeft
                    text: "Start location"
                }

                SubtitleText {
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                    horizontalAlignment: Text.AlignLeft
                    text: "End location"
                }

            }

            // Property row
            Row {

                width: parent.width
                spacing: 10

                // Edge name
                DataText {
                    width: (parent.width - 3 * parent.spacing - edge_remove.width) / 3
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: model.name
                }

                // Source location selector
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

                // Target location selector
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

                // Edge remove button
                RemoveButton {
                    id: edge_remove
                    onClicked: {
                        edge_model.removeRow(index);
                    }
                }

            }

            // Guard row
            Row {

                width: parent.width
                spacing: 10

                SubtitleText {
                    id: guard_text
                    width: contentWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    text: "Guard"
                }

                // Guard input field
                FormulaField {
                    id: guard_text_field
                    width: parent.width - parent.spacing - guard_text.width
                    text: model.guard
                    default_text: "Enter guard"
                    error_text: "Invalid guard constraint"
                    set_role: (function(x) {model.guard = x;})
                    level: "constraint"
                }

            }

            // Decision row
            Row {

                width: parent.width
                spacing: 10

                SubtitleText {
                    id: edge_agent_text
                    width: guard_text.width
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    text: "Agent"
                }

                // Agent selector
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

                SubtitleText {
                    width: contentWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    id: edge_action_text
                    text: "Action"
                }

                // Action selector
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

            SubtitleText {
                id: jump_text
                text: "Jump"
            }

            // Jump list
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

                    // Variable name
                    SubtitleText {
                        height: parent.height
                        width: guard_text.width
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.var
                    }

                    // Jump expression input field
                    FormulaField {
                        id: jump_text_field
                        width: parent.width - parent.spacing - guard_text.width
                        text: model.jump
                        default_text: "Enter jump expression"
                        error_text: "Invalid jump expression"
                        set_role: (function(x) {model.jump = x;})
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

    // Add edge row
    Row {

        id: edge_input_row
        width: parent.width
        spacing: 10

        // Name input field
        InputField {
            id: edge_name_text_field
            width: parent.width - parent.spacing - edge_add_button.width
            default_text: "Enter edge name"

            onAccepted: {
                edges.add_edge(text);
            }
        }

        // Add edge button
        AddButton {
            id: edge_add_button
            onClicked: {
                edges.add_edge(edge_name_text_field.text);
            }
        }

    }

}

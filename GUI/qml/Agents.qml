/**
* @file Agents.qml
* @brief GUI component for managing agents in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// Outer container for agents
Column {

    spacing: 10
    property alias agent_list: agent_list

    /**
    * Add an agent to the agent model
    * @param {String} agent    Name of the agent to add
    */
    function add_agent(agent)
    {
        var regex = /^[A-Za-z]\w*$/;
        agent_text_field.focus = true;
        if (regex.test(agent))
        {
            if (!Julia.has_name(agent))
            {
                agent_model.appendRow({name: agent, triggers: []});
                agent_text_field.text = "";
                agent_text_field.placeholderText = agent_text_field.default_text;
                agent_text_field.placeholderTextColor = agent_text_field.default_color;
                triggers.visible = agent_model.rowCount() > 0;
                trigger_spacer.visible = agent_model.rowCount() > 0;
                return;
            }
            else {
                agent_text_field.placeholderText = "Name is already used";
            }
        }
        else {
            agent_text_field.placeholderText = "Invalid agent name";
        }
        agent_text_field.placeholderTextColor = agent_text_field.error_color;
    }

    TitleText {
        width: parent.width
        text: "Agents"
    }

    // List of agents
    ListView {

        id: agent_list
        width: parent.width
        height: Math.min(contentHeight, 100)
        clip: true

        model: agent_model
        delegate: Row {

            width: agent_list.width
            spacing: 10

            DataText {
                width: parent.width - parent.spacing - agent_button.width
                text: model.name
            }

            // Remove agent button
            RemoveButton {
                onClicked: {
                    agent_model.removeRow(index);
                    triggers.visible = agent_model.rowCount() > 0;
                    trigger_spacer.visible = agent_model.rowCount() > 0;
                }
            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

    }

    // Add agent row
    Row {

        width: parent.width
        spacing: 10

        // Agent name input field
        InputField {
            id: agent_text_field
            width: parent.width - parent.spacing - agent_button.width
            default_text: "Enter agent name"

            onAccepted: {
                agents.add_agent(agent_text_field.text);
            }
        }

        // Add agent button
        AddButton {
            id: agent_button
            onClicked: {
                agents.add_agent(agent_text_field.text);
            }
        }

    }

}

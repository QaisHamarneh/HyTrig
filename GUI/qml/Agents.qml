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
        if (regex.test(agent))
        {
            if (!Julia.has_name(agent))
            {
                agent_model.appendRow({name: agent, triggers: []});
                agent_text_field.placeholderText = "Enter name";
                agent_text_field.text = "";
                triggers.visible = agent_model.rowCount() > 0;
                trigger_spacer.visible = agent_model.rowCount() > 0;
            }
            else {
                agent_text_field.placeholderText = "Name in use";
                agent_text_field.text = "";
            }
        }
        else {
            agent_text_field.placeholderText = "Invalid name";
            agent_text_field.text = "";
        }
    }

    Text {
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

            Text {

                width: parent.width - parent.spacing - agent_button.width
                text: model.name
                color: "blue"

            }

            // Remove agent button
            Button {
                text: "-"
                height: parent.height
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
        TextField {
            id: agent_text_field
            width: parent.width - parent.spacing - agent_button.width
            placeholderText: "Enter name"
            onAccepted: {
                agents.add_agent(agent_text_field.text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter name";
            }
        }

        // Add agent button
        Button {
            id: agent_button
            Layout.fillHeight: false
            Material.foreground: "white"
            Material.background: Material.DeepOrange
            text: "+"
            onClicked: {
                agents.add_agent(agent_text_field.text);
            }
        }

    }

}

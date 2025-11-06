import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10

    function add_agent(agent)
    {
        var regex = /^[A-Za-z]\w*$/;
        if (regex.test(agent) && !Julia.has_name(agent))
        {
            agent_model.appendRow({name: agent});
            agent_text_field.placeholderText = "Enter name";
            agent_text_field.text = "";
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

            Button {
                text: "-"
                height: parent.height
                onClicked: {
                    agent_model.removeRow(index);
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
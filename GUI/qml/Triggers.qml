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
        text: "Triggers"
    }

    ListView {

        id: trigger_list
        width: parent.width
        height: Math.min(contentHeight, 200)
        clip: true

        model: agent_model
        delegate: Column {

            width: trigger_list.width
            spacing: 10

            function add_trigger(trigger)
            {
                if (is_valid_formula(trigger, "constraint"))
                {
                    agent_trigger_model.append({trigger: trigger});
                    trigger_text_field.placeholderText = "Enter trigger";
                    trigger_text_field.text = "";
                }
                else {
                    trigger_text_field.placeholderText = "Invalid trigger";
                    trigger_text_field.text = "";
                }
            }

            Rectangle {

                width: parent.width
                height: 3
                visible: index != 0
                radius: 4
                color: "grey"

            }

            Text {
                width: parent.width
                text: model.name
            }

            ListView {

                id: agent_trigger_list
                width: parent.width
                height: contentHeight
                clip: true
                interactive: false

                model: ListModel {

                    id: agent_trigger_model

                }
                delegate: Row {

                    width: agent_trigger_list.width
                    spacing: 10

                    Text {
                        width: parent.width -parent.spacing - trigger_button.width
                        text: model.trigger
                    }

                    Button {
                        text: "-"
                        height: parent.height
                        onClicked: {
                            agent_trigger_model.remove(index, 1);
                        }
                    }

                }

            }

            Row {

                width: parent.width
                spacing: 10

                TextField {
                    id: trigger_text_field
                    width: parent.width - parent.spacing - trigger_button.width
                    placeholderText: "Enter trigger"
                    onAccepted: {
                        add_trigger(text);
                        focus = false;
                    }
                }

                Button {
                    id: trigger_button
                    Material.foreground: "white"
                    Material.background: Material.DeepOrange
                    Layout.fillHeight: false
                    text: "+"
                    onClicked: {
                        add_trigger(trigger_text_field.text);
                    }
                }

            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
        }

    }

}
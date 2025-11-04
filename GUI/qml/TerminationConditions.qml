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
        text: "Termination conditions"
    }

    Row {

        width: parent.width
        spacing: 10

        Text {
            width: state_formula_text.width
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "Time bound"
        }

        TextField {
            id: time_bound_text_field
            width: (
                parent.width - 3 * parent.spacing - 2 * state_formula_text.width
            ) / 2
            placeholderText: "Enter time bound"
            onAccepted: {
                var regex = /^(([1-9]\d*(\.\d+)?$)|(0\.\d*[1-9])$)/;
                if (regex.test(text))
                {
                    placeholderText = "";
                    focus = false;
                }
                else {
                    text = "";
                    placeholderText = "Invalid time bound";
                }
            }
        }

        Text {
            width: state_formula_text.width
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "Max steps"
        }

        TextField {
            id: max_steps_text_field
            width: (
                parent.width - 3 * parent.spacing - 2 * state_formula_text.width
            ) / 2
            placeholderText: "Enter max steps"
            onAccepted: {
                var regex = /^[1-9]\d*$/;
                if (regex.test(text))
                {
                    placeholderText = "";
                    focus = false;
                }
                else {
                    text = "";
                    placeholderText = "Invalid max steps";
                }
            }
        }

    }

    Row {

        width: parent.width
        spacing: 10

        Text {
            id: state_formula_text
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "State formula"
        }

        TextField {
            id: state_formula_text_field
            width: parent.width - parent.spacing - state_formula_text.width
            placeholderText: "Enter state formula"
            onAccepted: {
                if (is_valid_formula(text, "state"))
                {
                    placeholderText = "";
                    focus = false;
                }
                else {
                    text = "";
                    placeholderText = "Invalid state formula";
                }
            }
        }

    }

}
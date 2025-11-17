/**
* @file TerminationConditions.qml
* @brief GUI component for managing termination conditions in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.julialang

// Outer container for termination conditions
Column {

    spacing: 10
    property alias time_bound: time_bound_text_field.text
    property alias max_steps: max_steps_text_field.text
    property alias state_formula: state_formula_text_field.text

    Text {
        width: parent.width
        text: "Termination conditions"
        color: "white"
    }

    // Time bound and max steps row
    Row {

        width: parent.width
        spacing: 10

        Text {
            width: state_formula_text.width
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "Time bound"
            color: "white"
        }

        // Time bound input field
        TextField {
            id: time_bound_text_field
            property bool had_focus: false
            width: (
                parent.width - 3 * parent.spacing - 2 * state_formula_text.width
            ) / 2
            placeholderText: "Enter time bound"
            onAccepted: {
                var regex = /^(([1-9]\d*(\.\d+)?$)|(0\.\d*[1-9])$)/;
                if (regex.test(text))
                {
                    termination_conditions["time-bound"] = text;
                    placeholderText = "";
                    focus = false;
                }
                else {
                    text = "";
                    placeholderText = "Invalid time bound";
                }
            }
            onActiveFocusChanged: {
                if (had_focus)
                {
                    had_focus = false;
                    var regex = /^(([1-9]\d*(\.\d+)?$)|(0\.\d*[1-9])$)/;
                    if (regex.test(text))
                    {
                        termination_conditions["time-bound"] = text;
                        placeholderText = "";
                        focus = false;
                    }
                    else {
                        text = "";
                        placeholderText = "Invalid time bound";
                    }
                } else {
                    had_focus = focus;
                }
            }
        }

        Text {
            width: state_formula_text.width
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "Max steps"
            color: "white"
        }

        // Max steps input field
        TextField {
            id: max_steps_text_field
            property bool had_focus: false
            width: (
                parent.width - 3 * parent.spacing - 2 * state_formula_text.width
            ) / 2
            placeholderText: "Enter max steps"
            onAccepted: {
                var regex = /^[1-9]\d*$/;
                if (regex.test(text))
                {
                    termination_conditions["max-steps"] = text;
                    placeholderText = "";
                    focus = false;
                }
                else {
                    text = "";
                    placeholderText = "Invalid max steps";
                }
            }
            onActiveFocusChanged: {
                if (had_focus)
                {
                    had_focus = false;
                    var regex = /^[1-9]\d*$/;
                    if (regex.test(text))
                    {
                        termination_conditions["max-steps"] = text;
                        placeholderText = "";
                        focus = false;
                    }
                    else {
                        text = "";
                        placeholderText = "Invalid max steps";
                    }
                } else {
                    had_focus = focus;
                }
            }
        }

    }

    // State formula row
    Row {

        width: parent.width
        spacing: 10

        Text {
            id: state_formula_text
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "State formula"
            color: "white"
        }

        // State formula input field
        TextField {
            id: state_formula_text_field
            property bool had_focus: false
            width: parent.width - parent.spacing - state_formula_text.width
            placeholderText: "Enter state formula"
            onAccepted: {
                if (is_valid_formula(text, "state"))
                {
                    termination_conditions["state-formula"] = text;
                    placeholderText = "";
                    focus = false;
                }
                else {
                    text = "";
                    placeholderText = "Invalid state formula";
                }
            }
            onActiveFocusChanged: {
                if (had_focus)
                {
                    had_focus = false;
                    if (is_valid_formula(text, "state"))
                    {
                        termination_conditions["state-formula"] = text;
                        placeholderText = "";
                        focus = false;
                    }
                    else {
                        text = "";
                        placeholderText = "Invalid state formula";
                    }
                } else {
                    had_focus = focus;
                }
            }
        }

    }

}

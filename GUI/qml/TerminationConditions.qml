/**
* @file TerminationConditions.qml
* @brief GUI component for managing termination conditions in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// Outer container for termination conditions
Column {

    spacing: 10
    property alias time_bound: time_bound_text_field
    property alias max_steps: max_steps_text_field
    property alias state_formula: state_formula_text_field

    TitleText {
        width: parent.width
        text: "Termination conditions"
    }

    // Time bound and max steps row
    Row {

        width: parent.width
        spacing: 10

        SubtitleText {
            width: state_formula_text.width
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "Time bound"
        }

        // Time bound input field
        RegexField {
            id: time_bound_text_field
            width: (
                parent.width - 3 * parent.spacing - 2 * state_formula_text.width
            ) / 2
            default_text: "Enter time bound"
            error_text: "Invalid real number"
            set_role: (function(x) {termination_conditions["time-bound"] = x;})
            regex: /^(([1-9]\d*(\.\d+)?$)|(0\.\d*[1-9])$)/
        }

        SubtitleText {
            width: state_formula_text.width
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "Max steps"
        }

        // Max steps input field
        RegexField {
            id: max_steps_text_field
            width: (
                parent.width - 3 * parent.spacing - 2 * state_formula_text.width
            ) / 2
            default_text: "Enter max steps"
            error_text: "Invalid positive integer"
            set_role: (function(x) {termination_conditions["max-steps"] = x;})
            regex: /^[1-9]\d*$/
        }

    }

    // State formula row
    Row {

        width: parent.width
        spacing: 10

        SubtitleText {
            id: state_formula_text
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: "State formula"
        }

        // State formula input field
        FormulaField {
            id: state_formula_text_field
            width: parent.width - parent.spacing - state_formula_text.width
            default_text: "Enter state formula"
            error_text: "Invalid state formula"
            set_role: (function(x) {termination_conditions["state-formula"] = x;})
            level: "state"
        }

    }

}

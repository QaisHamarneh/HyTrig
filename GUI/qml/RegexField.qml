/**
* @file RegexField.qml
* @brief GUI component for a text field that checks its input against a regex.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

TextField {

    id: formula_field
    property string default_text: ""
    property string error_text: ""
    property var set_role: (function(x) {return;})
    property var regex: /^$/;

    property color default_color: Material.color(Material.Blue)
    property color accepted_color: Material.color(Material.Green)
    property color error_color: Material.color(Material.Red)

    property bool had_focus: false

    placeholderText: default_text
    placeholderTextColor: default_color
    font.pointSize: 16

    function check() {
        if (regex.test(text))
        {
            set_role(text);
            placeholderText = default_text;
            Material.accent = accepted_color;
            placeholderTextColor = accepted_color;
            focus = false;
        }
        else {
            set_role("");
            Material.accent = error_color;
            placeholderTextColor = error_color;
            placeholderText = error_text;
        }
    }

    onAccepted: {
        check();
    }

    onActiveFocusChanged: {
        if (had_focus) {
            had_focus = false;
            check();
        } else {
            had_focus = focus;
        }
    }

}

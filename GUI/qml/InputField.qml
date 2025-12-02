/**
* @file InputField.qml
* @brief GUI component for a text field.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

TextField {

    property string default_text: ""

    property color default_color: Material.color(Material.Blue)
    property color error_color: Material.color(Material.Red)

    placeholderText: default_text
    placeholderTextColor: default_color
    font.pointSize: 16

    onActiveFocusChanged: {
        placeholderText = default_text;
        placeholderTextColor = default_color;
    }

}

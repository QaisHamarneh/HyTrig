/**
* @file Spacer.qml
* @brief GUI component for a spacer between elements.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Rectangle {

    property bool vertical: true
    width: vertical ? 5 : parent.width
    height: vertical ? parent.height : 5
    radius: 4
    color: Material.foreground

}
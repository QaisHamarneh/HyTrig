/**
* @file Subspacer.qml
* @brief GUI component for a spacer between list view elements.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Rectangle {

    width: parent.width
    height: 3
    radius: 4                    
    visible: index != 0
    color: Material.color(Material.Grey, Material.Shade500)

}
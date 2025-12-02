/**
* @file PassiveNode.qml
* @brief GUI component passive game tree nodes.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Rectangle {

    width: passive_list.width
    height: node_time_text.height + node_valuation_text.height + node_property_list.spacing
    radius: 4
    color: Material.color(Material.Blue)
    
    Column {

        id: node_property_list
        width: parent.width
        height: parent.height
        spacing: 5

        SubtitleText {
            id: node_time_text
            width: parent.width
            text: "Time = " + model.time
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        SubtitleText {
            id: node_valuation_text
            width: parent.width
            text: model.valuation
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}

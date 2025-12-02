/**
* @file ActiveNode.qml
* @brief GUI component active game tree nodes.
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
    implicitHeight: node_action_text.height + node_arrow_text.height + node_location_text.height + node_valuation_text.height + 3 * node_property_list.spacing
    radius: 4
    color: Material.color(Material.Orange)

    Column {

        id: node_property_list
        width: parent.width
        height: parent.height
        spacing: 5

        SubtitleText {
            id: node_action_text
            width: parent.width
            text: "<" + model.action + ">"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        SubtitleText {
            id: node_arrow_text
            width: parent.width
            text: "↓"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        SubtitleText {
            id: node_location_text
            width: parent.width
            text: model.location
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Scrollable text for long valuations
        ScrollView {
            id: node_valuation_text
            width: parent.width
            height: Math.min(contentHeight, 300)

            SubtitleText {
                width: node_valuation_text.width
                text: model.valuation
                horizontalAlignment: Text.AlignHCenter
                clip: true
            }
        }

    }

}

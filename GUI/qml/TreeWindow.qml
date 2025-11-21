/**
* @file TreeWindow.qml
* @brief GUI component for a window dedicated to traversing a parsed game tree.
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Window {

    width: 1500
    height: 1000

    modality: Qt.ApplicationModal

    title: "Game tree viewer"

    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.foreground: Material.color(Material.Grey, Material.Shade100)
    
}

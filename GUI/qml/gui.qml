/**
* @file gui.qml
* @brief Main GUI component for the HGT Model Checker GUI
* @authors Moritz Maas
*/

import Qt.labs.platform
import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// HyTrig application window
ApplicationWindow {

    id: window

    visible: true
    width: 1920
    minimumWidth: 1000
    height: 1080
    minimumHeight: 800
    title: "HyTrig"

    Material.theme: Material.Dark
    Material.accent: Material.Blue

    property string file_path: ""

    /**
    * Check if a formula is valid on a given parse level
    * @param {String}   input   Formula to check
    * @param {String}   level   Parse level, either 'expression', 'constraint', 'state' or 'strategy'
    * @return {Boolean}         True, if formula is valid on the given parse level
    */
    function is_valid_formula(input, level) {
        return Julia.is_valid_formula(input, level)
    }

    /**
    * Check if the current game is savable
    * @return {Boolean}         True, if current game is savable
    */
    function is_savable() {
        if (termination_conditions["time-bound"] == "") {
            terminations.time_bound.placeholderTextColor = terminations.time_bound.error_color;
            save_fail_dialog.informativeText = "Time bound is invalid."
            save_fail_dialog.open();
            return false;
        }
        if (termination_conditions["max-steps"] == "") {
            terminations.max_steps.placeholderTextColor = terminations.max_steps.error_color;
            save_fail_dialog.informativeText = "Max steps is invalid."
            save_fail_dialog.open();
            return false;
        }
        if (location_model.rowCount() == 0) {
            save_fail_dialog.informativeText = "At least one location is required."
            save_fail_dialog.open();
            return false;
        }
        if (!Julia.is_savable()) {
            save_fail_dialog.informativeText = "Flows and jumps cannot be empty."
            save_fail_dialog.open();
            return false;
        }
        return true;
    }

    /**
    * Save current game to file given by path.
    * @param {String}   path   Path to save to
    */
    function save(path) {
        Julia.save_to_json(path);
        file_path = path;
    }

    /**
    * Load game from file given by path.
    * @param {String}   path   Path to load from
    */
    function load(path) {
        var loaded = Julia.load_from_json(path);
        if (!loaded)
        {
            load_fail_dialog.open();
            return;
        }

        file_path = path;

        // Refresh ListViews
        variables.variable_list.model = [];
        variables.variable_list.model = variable_model;
        locations.location_list.model = [];
        locations.location_list.model = location_model;
        edges.edge_list.model = [];
        edges.edge_list.model = edge_model;
        agents.agent_list.model = [];
        agents.agent_list.model = agent_model;
        actions.action_list.model = [];
        actions.action_list.model = action_model;
        triggers.trigger_list.model = [];
        triggers.trigger_list.model = agent_model;
        queries.query_list.model = [];
        queries.query_list.model = query_model;

        // Refresh termination conditions
        terminations.time_bound.text = termination_conditions["time-bound"];
        terminations.max_steps.text = termination_conditions["max-steps"];
        terminations.state_formula.text = termination_conditions["state-formula"];

        // Refresh menu
        tree_button.visible = false;
    }

    /**
    * Verify the current game.
    */
    function verify() {
        var result = Julia.verify()
        if(result != "") {
            verify_fail_dialog.informativeText = result;
            verify_fail_dialog.open();
        }

        // Refresh Queries
        queries.query_list.model = [];
        queries.query_list.model = query_model;
    }

    // Load failure dialog
    MessageDialog {
        id: save_fail_dialog
        buttons: MessageDialog.Ok
        title: "Save error"
        text: "Could not save current game."
    }

    // Load failure dialog
    MessageDialog {
        id: load_fail_dialog
        buttons: MessageDialog.Ok
        title: "Load error"
        text: "Could not load from file."
    }

     // Verify failure dialog
    MessageDialog {
        id: verify_fail_dialog
        buttons: MessageDialog.Ok
        title: "Verification error"
        text: "Could not verify current game."
    }

    // Window-filling column
    Column {

        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Left and right window row
        Row {

            width: parent.width
            height: parent.height - parent.spacing - menu.height
            spacing: 10
            clip: true

            // Left window side
            Column {

                property real subwindow_height: (height - 8 * spacing - 4 * action_variable_spacer.height - terminations.height) / 4

                width: (parent.width - 2 * parent.spacing - page_separator.width) / 2
                height: parent.height
                spacing: 10

                // Agent and action row
                Row {

                    width: parent.width
                    height: parent.subwindow_height
                    spacing: 20
                    
                    Agents {
                        id: agents
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                    }

                    Actions {
                        id: actions
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                    }

                }

                Spacer {
                    id: action_variable_spacer
                    vertical: false
                }

                Variables {
                    id: variables
                    width: parent.width
                    height: parent.subwindow_height
                }

                Spacer {
                    id: trigger_spacer
                    vertical: false
                }

                Triggers {
                    id: triggers
                    width: parent.width
                    height: parent.subwindow_height
                }

                Spacer {
                    vertical: false
                }

                TerminationConditions {
                    id: terminations
                    width: parent.width
                }

                Spacer {
                    vertical: false
                }

                Queries {
                    id: queries
                    width: parent.width
                    height: parent.subwindow_height
                }

            }

            Spacer {
                id: page_separator
                vertical: true
            }

            // Right window side
            Column {

                property real subwindow_height: (height - 2 * spacing - location_edge_spacer.height) / 2

                width: (parent.width - 2 * parent.spacing - page_separator.width) / 2
                height: parent.height
                spacing: 10

                Locations {
                    id: locations
                    width: parent.width
                    height: parent.subwindow_height
                }

                Spacer {
                    id: location_edge_spacer
                    vertical: false
                }

                Edges {
                    id: edges
                    width: parent.width
                    height: parent.subwindow_height
                }

            }

        }

        // Button menu row
        Row {

            id: menu
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            property real button_width: save_as_button.width

            // Save dialog
            FileDialog {
                id: save_dialog
                title: "Select a location to save the JSON file"
                
                fileMode: FileDialog.SaveFile
                nameFilters: ["JSON files (*.json)"]
                onAccepted: {
                    save(selectedFile.toString());
                }
            }

            // Load dialog
            FileDialog {
                id: load_dialog
                title: "Select a JSON file to load"

                fileMode: FileDialog.OpenFile
                nameFilters: ["JSON files (*.json)"]
                onAccepted: {
                    load(selectedFile.toString());
                }
            }

            // Tree viewer window
            TreeWindow {
                id: tree_window
            }

            // Save button
            Button {
                id: save_button
                width: save_as_button.width
                text: "Save"
                onClicked: {
                    if (is_savable()) {
                        if (file_path != "") {
                            save(file_path);
                        } else {
                            save_dialog.open();
                        }
                    }
                }
            }

            // Save as button
            Button {
                id: save_as_button
                text: "Save as"
                onClicked: {
                    if (is_savable()) {
                        save_dialog.open();
                    }
                }
            }

            // Load button
            Button {
                id: load_button
                width: parent.button_width
                text: "Load"
                onClicked: {
                    load_dialog.open();
                }
            }

            // Verify button
            Button {
                id: verify_button
                width: parent.button_width
                text: "Verify"
                onClicked: {
                    if (is_savable()) {
                        verify();
                        tree_button.visible = true;
                    }
                }
            }

            // Tree viewer button
            Button {
                id: tree_button
                width: parent.button_width
                visible: false
                text: "Tree"
                onClicked: {
                    tree_window.level = 1;
                    tree_window.node_list.model = [];
                    tree_window.node_list.model = node_model;
                    tree_window.show();
                }
            }

            // Dark/Light mode button
            Button {
                
                width: parent.button_width
                height: save_as_button.height
                icon.source: "icons/dark_mode.png"
                icon.height: height
                icon.color: Material.foreground
                onClicked: {
                    if (Material.theme == Material.Dark) {
                        window.Material.theme = Material.Light;
                        icon.source = "icons/light_mode.png";
                    } else {
                        window.Material.theme = Material.Dark;
                        icon.source = "icons/dark_mode.png";
                    }
                }

            }

        }

    }

}

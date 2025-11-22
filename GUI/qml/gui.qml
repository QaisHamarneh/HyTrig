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
    maximumWidth: 3000
    height: 1080
    minimumHeight: 800
    maximumHeight: 2000
    title: "HyTrig"

    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.foreground: Material.color(Material.Grey, Material.Shade100)

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
    function is_saveable() {
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
        for (var i = 0; i < location_model.rowCount(); i++) {
            var flow_model = location_model.data(location_model.index(i, 0), roles.flow);
            for (var j = 0; j < flow_model.rowCount(); j++) {
                if (flow_model.data(flow_model.index(j, 0), roles.flow_expression) == "") {
                    save_fail_dialog.informativeText = "Empty flow expressions are invalid."
                    return false;
                }
            }
        }
        for (var i = 0; i < edge_model.rowCount(); i++) {
            var jump_model = edge_model.data(edge_model.index(i, 0), roles.jump);
            for (var j = 0; j < jump_model.rowCount(); j++) {
                if (jump_model.data(jump_model.index(j, 0), roles.jump_expression) == "") {
                    save_fail_dialog.informativeText = "Empty jump expressions are invalid."
                    return false;
                }
            }
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

        // Refresh visibility of triggers
        triggers.visible = agent_model.rowCount() > 0;
        trigger_spacer.visible = agent_model.rowCount() > 0;
    }

    /**
    * Verify the current game.
    */
    function verify() {
        Julia.verify();

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

                id: left_column
                width: (parent.width - 2 * parent.spacing - page_separator.width) / 2
                height: parent.height
                spacing: 10

                // Agent and action row
                Row {

                    width: parent.width
                    spacing: 20
                    
                    Agents {
                        id: agents
                        width: (parent.width - parent.spacing) / 2
                    }

                    Actions {
                        id: actions
                        width: (parent.width - parent.spacing) / 2
                    }

                }

                Spacer {
                    vertical: false
                }

                Variables {
                    id: variables
                    width: parent.width
                }

                Spacer {
                    id: trigger_spacer
                    vertical: false
                    visible: agent_model.rowCount() > 0
                }

                Triggers {
                    id: triggers
                    width: parent.width
                    visible: agent_model.rowCount() > 0
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
                }

            }

            Spacer {
                id: page_separator
                vertical: true
            }

            // Right window side
            Column {

                width: (parent.width - 2 * parent.spacing - page_separator.width) / 2
                height: parent.height
                spacing: 10

                Locations {
                    id: locations
                    width: parent.width
                }

                Spacer {
                    vertical: false
                }

                Edges {
                    id: edges
                    width: parent.width
                }

            }

        }

        // Button menu row
        Row {

            id: menu
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

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

            // Save button
            Button {
                id: save_button
                width: save_as_button.width
                text: "Save"
                onClicked: {
                    if (is_saveable()) {
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
                    if (is_saveable()) {
                        save_dialog.open();
                    }
                }
            }

            // Load button
            Button {
                id: load_button
                width: save_as_button.width
                text: "Load"
                onClicked: {
                    load_dialog.open();
                }
            }

            // Verify button
            Button {
                id: verify_button
                width: save_as_button.width
                text: "Verify"
                onClicked: {
                    verify();
                }
            }
            
        }

    }

}

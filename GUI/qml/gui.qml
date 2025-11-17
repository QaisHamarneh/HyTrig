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
    * @return {Boolean}         True, if current state is savable
    */
    function is_saveable() {
        return true; //TODO: check invalid params
    }

    /**
    * Save current game to file given by path.
    * @param {String}   path   Path to save to
    */
    function save(path) {
        Julia.save_to_json(path);
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
        terminations.time_bound = termination_conditions["time-bound"];
        terminations.max_steps = termination_conditions["max-steps"];
        terminations.state_formula = termination_conditions["state-formula"];

        // Refresh visibility of triggers
        triggers.visible = agent_model.rowCount() > 0;
        trigger_spacer.visible = agent_model.rowCount() > 0;
    }

    function verify() {
        Julia.verify();

        // Refresh Queries
        queries.query_list.model = [];
        queries.query_list.model = query_model;
    }

    // Load failure dialog
    MessageDialog {
        id: load_fail_dialog
        buttons: MessageDialog.Ok
        text: "Could not load from file"
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

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                Variables {
                    id: variables
                    width: parent.width
                }

                Rectangle {
                    id: trigger_spacer
                    width: parent.width
                    height: 5
                    visible: agent_model.rowCount() > 0
                    radius: 4
                    color: "black"
                }

                Triggers {
                    id: triggers
                    width: parent.width
                    visible: agent_model.rowCount() > 0
                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                TerminationConditions {
                    id: terminations
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
                }

                Queries {
                    id: queries
                    width: parent.width
                }

            }

            Rectangle {
                id: page_separator
                width: 5
                height: parent.height
                radius: 4
                color: "black"
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

                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 4
                    color: "black"
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
                width: verify_button.width
                text: "Save"
                onClicked: {
                    if (is_saveable()) {
                        save_dialog.open();
                    }
                }
            }

            // Load button
            Button {
                id: load_button
                width:verify_button.width
                text: "Load"
                onClicked: {
                    load_dialog.open();
                }
            }

            // Verify button
            Button {
                id: verify_button
                text: "Verify"
                onClicked: {
                    verify();
                }
            }
            
        }

    }

}

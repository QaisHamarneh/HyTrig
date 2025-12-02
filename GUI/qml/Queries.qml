/**
* @file Queries.qml
* @brief GUI component for managing queries in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

// Outer container for queries
Column {

    spacing: 10
    property alias query_list: query_list

    /**
    * Add a query to the query model
    * @param {String} query    Strategy formula of the query
    */
    function add_query(query)
    {
        query_text_field.focus = true;
        if (is_valid_formula(query, "strategy"))
        {
            query_model.appendRow({name: query, verified: false, result: false});
            query_text_field.text = "";
            query_text_field.placeholderText = query_text_field.default_text;
            query_text_field.placeholderTextColor = query_text_field.default_color;
            return;
        }
        else {
            query_text_field.placeholderText = "Invalid strategy formula";
            query_text_field.placeholderTextColor = query_text_field.error_color;
        }
    }

    TitleText {
        id: query_text
        width: parent.width
        text: "Queries"
    }

    // List of queries
    ListView {

        id: query_list
        width: parent.width
        height: parent.height - 2 * parent.spacing - query_text.height - query_input_row.height
        spacing: 10
        clip: true

        model: query_model
        delegate: Row {

            width: query_list.width
            spacing: 10

            // Query formula
            DataText {
                id: query_formula
                width: model.verified ? (parent.width - 2 * parent.spacing - checkbox.width - query_button.width) : (parent.width - parent.spacing - query_button.width)
                text: model.name
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            // Verified checkbox
            CheckBox {

                id: checkbox
                height: query_formula.height
                visible: model.verified
                tristate: false
                checkable: false
                hoverEnabled: false
                checkState: model.result ? Qt.Checked : Qt.Unchecked
                
            }

            // Remove query button
            RemoveButton {
                onClicked: {
                    query_model.removeRow(index);
                }
            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AlwaysOn
        }

    }

    // Add query row
    Row {

        id: query_input_row
        width: parent.width
        spacing: 10

        // Formula input field
        InputField {
            id: query_text_field
            width: parent.width - parent.spacing - query_button.width
            default_text: "Enter strategy formula"

            onAccepted: {
                queries.add_query(text);
            }
        }

        // Add formula button
        AddButton {
            id: query_button
            onClicked: {
                queries.add_query(query_text_field.text)
            }
        }

    }

}

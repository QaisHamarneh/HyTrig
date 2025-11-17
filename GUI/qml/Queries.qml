/**
* @file Queries.qml
* @brief GUI component for managing queries in the HGT Model Checker GUI
* @authors Moritz Maas
*/

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        if (is_valid_formula(query, "strategy"))
        {
            query_model.appendRow({name: query, verified: false, result: false});
            query_text_field.placeholderText = "Enter strategy formula";
            query_text_field.text = "";
        }
        else {
            query_text_field.placeholderText = "Invalid strategy formula";
            query_text_field.text = "";
        }
    }

    Text {
        width: parent.width
        text: "Queries"
        color: "white"
    }


    // List of queries
    ListView {

        id: query_list
        width: parent.width
        height: Math.min(contentHeight, 100)
        spacing: 10
        clip: true

        model: query_model
        delegate: Row {

            width: query_list.width
            spacing: 10

            // Query formula
            Text {

                width: model.verified ? (parent.width - 2 * parent.spacing - checkbox.width - query_button.width) : (parent.width - parent.spacing - query_button.width)
                text: model.name
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: "white"

            }

            // Verified checkbox
            CheckBox {

                id: checkbox
                visible: model.verified
                tristate: true
                checkable: false
                checkState: model.result ? Qt.Checked : Qt.PartiallyChecked

            }

            // Remove query button
            Button {
                text: "-"
                height: parent.height
                onClicked: {
                    query_model.removeRow(index);
                }
            }

        }

    }

    // Add query row
    Row {

        width: parent.width
        spacing: 10

        // Formula input field
        TextField {
            id: query_text_field
            width: parent.width - parent.spacing - query_button.width
            placeholderText: "Enter strategy formula"
            onAccepted: {
                queries.add_query(text);
            }
            onActiveFocusChanged: {
                placeholderText = "Enter strategy formula";
            }
        }

        // Add formula button
        Button {
            id: query_button
            Layout.fillHeight: false
            text: "+"
            onClicked: {
                queries.add_query(query_text_field.text)
            }
        }

    }

}

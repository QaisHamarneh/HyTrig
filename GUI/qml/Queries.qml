import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import org.julialang

Column {

    spacing: 10
    property alias query_model: query_model

    ListModel {

        id: query_model

    }

    function add_query(query)
    {
        if (is_valid_formula(query, "strategy"))
        {
            query_model.append({name: query});
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
    }

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

            Text {

                width: parent.width - parent.spacing - query_button.width
                text: model.name
                color: "blue"

            }

            Button {
                text: "-"
                height: parent.height
                onClicked: {
                    query_model.remove(index, 1);
                }
            }

        }

    }

    Row {

        width: parent.width
        spacing: 10

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

        Button {
            id: query_button
            Layout.fillHeight: false
            Material.foreground: "white"
            Material.background: Material.DeepOrange
            text: "+"
            onClicked: {
                queries.add_query(query_text_field.text)
            }
        }

    }

}
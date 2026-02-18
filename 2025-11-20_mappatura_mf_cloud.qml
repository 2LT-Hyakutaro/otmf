import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield
import org.qgis

import Theme

import "qrc:/qml" as QFieldItems

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property var positionSource: iface.findItemByObjectName('positionSource')
  property var templates: ({})


  Component.onCompleted: {

    loadTemplates();
    iface.logMessage("[OTMF] templates: %1".arg(JSON.stringify(templates)));

    iface.addItemToPluginsToolbar(otmfButton);
    iface.logMessage("[OTMF] created otfm button");
  }
  
  QfToolButton {
    id: otmfButton
    //iconSource: 'icon.svg'
    //iconColor: Theme.mainColor
    bgcolor: Theme.lightGray
    round: true
    enabled: true
    text: "OK"
    highlighted: false

    onClicked: {
      highlighted = !highlighted
      plugin.otmfCreateNewWidget();
    }
  }

  Dialog {
    id: otmfNewWidgetDialog
    parent: mainWindow.contentItem
    title: qsTr("Create a new replicable standard feature")
    standardButtons: Dialog.Ok | Dialog.Cancel

    anchors.centerIn: parent
    width: Math.min(700, parent.width - Theme.popupScreenEdgeMargin * 2)
    height: 200

    ColumnLayout {
      id: dialogLayout
      anchors.left: parent.left
      anchors.right: parent.right
      spacing: 10

      Label {
        Layout.fillWidth: true;
        wrapMode: TextInput.Wrap
        text: qsTr("Select a layer")
        font: Theme.defaultFont
        color: Theme.mainTextColor
      }

      ComboBox {
                id: layerSelector
                Layout.fillWidth: true
                model: []                   // model is modified by 'updateLayers' when 'otmfButton' is clicked
                enabled: model.length > 0

                onActivated: index => {

                  mainWindow.displayToast(qsTr("Layer '%1' set as active").arg(layerSelector.currentText))             

                  // mostrare il form corretto per il layer selezionato

                  // salva il contenuto dei campi voluti dall'utente da qualche parte 

                  // crea il nuovo widget
                }
      }
    }
  }

      function updateLayers() {
        var layers = ProjectUtils.mapLayers(qgisProject)
        var editableLayers = []

        for (var id in layers) {
            var layer = layers[id]

            if (layer && layer.supportsEditing && layer.geometryType) {
                editableLayers.push(layer.name)
            }
        }

        editableLayers.sort()
        layerSelector.model = editableLayers
        
    }

  function loadTemplates() {
    
    var rawTemplates = settings.value("project_templates", "{}")
    iface.logMessage("[OTMF] raw templates loaded")
    templates = JSON.parse(rawTemplates)
    iface.logMessage("[OTMF] templates converted to JSON")
  }

  function saveTemplates() {
    settings.setValue("project_templates", JSON.stringify(templates))
    iface.logMessage("[OTMF] templates saved to settings")
  }

  function otmfCreateNewWidget() {

    if(!otmfButton.enabled) {
      return;
    }

    updateLayers()
    otmfNewWidgetDialog.open()
  }
}

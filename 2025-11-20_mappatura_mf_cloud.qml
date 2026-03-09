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
  property var projectInfo: iface.findItemByObjectName('projectInfo')
  property var templates: ({})


  Component.onCompleted: {

    loadTemplates();
    iface.logMessage("[OTMF] templates: %1".arg(JSON.stringify(templates)));

    iface.addItemToPluginsToolbar(otmfButton);
    iface.logMessage("[OTMF] created otfm button");
  }
  
  LayerResolver {
    id: layerResolver
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
    height: 500

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

          // we want to show the correct form given the layer
          let layerName = layerSelector.currentText        
          let currentLayer = qgisProject.mapLayersByName(layerName)[0];
                  
                  //let f = currentLayer.getFeature(1);     // get a feature based on its id
                  //let f2 = LayerUtils.duplicateFeature(currentLayer, f);
                  //let r = LayerUtils.addFeature(currentLayer, f2);                                                                  

          let toolbar = otmfFeatureForm.header.children[0];                                                   
          let titleLabel = toolbar.children[1].children[1];

          titleLabel.text = qsTr("New std. feature for '%1'").arg(layerName);                  
                  
          let fModel = otmfFeatureForm.model.featureModel;

          fModel.currentLayer = currentLayer;

                  // salva il contenuto dei campi voluti dall'utente da qualche parte 

                  // crea il nuovo widget
                }
      }

      QFieldItems.FeatureForm {

        id: otmfFeatureForm
        visible: true
        Layout.fillWidth: true
        topMargin: 20
        bottomMargin: 20
        leftMargin: 20
        rightMargin: 20
        isVertical: true
        isDraggable: true
        state: "Add"
        //z: 10000
        Layout.preferredHeight: 200
        property var toolbar

        model: AttributeFormModel {
          id: attributeFormModel
            featureModel: FeatureModel {
            project: qgisProject
          }
        }


        Component.onCompleted: {
          
          toolbar = otmfFeatureForm.header.children[0];
          let saveButton = toolbar.children[1].children[0];
          saveButton.onClicked.connect(saveNewStdFeature);
          iface.logMessage("[OTMF] form correctly loaded");
        }

        onConfirmed: {
          displayToast(qsTr("If my grandmother had wheels"));
        }
        onCancelled: {
          displayToast(qsTr("she would have been a bike"));
        }

        function saveNewStdFeature() {        
          iface.logMessage("hello i am debug message for saveNewStdFeature");

          // save std feature to 'templates' 

          // create new button and add to plugin toolbar 


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

  // for debugging   https://stackoverflow.com/questions/20293838/qml-list-all-object-members-properties-in-console
  function listProperties(item, childrenOnly=true)
  {
    let str = ""

    for (var p in item)
    {
        if( typeof item[p] != "function" ) {
            
            if(childrenOnly && p != "children")
              continue;
            
            str = str + p + " -> " + item[p] + "\n"
            
        }
    }
    return str;
}
}

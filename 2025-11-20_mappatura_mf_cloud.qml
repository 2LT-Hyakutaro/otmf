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
  property var mapCanvas: iface.mapCanvas()
  property var positionSource: iface.findItemByObjectName('positionSource')
  property var projectInfo: iface.findItemByObjectName('projectInfo')
  property var overlayFeatureFormDrawer: iface.findItemByObjectName('overlayFeatureFormDrawer')
  property var widgets: widgetContainer
  property var gpsWarning: true
  property var templates: ListModel {
    id: templatesModel
  }
  property var globalAttributes: ({})

  Component.onCompleted: {

    // mock feature init
    const semaforo =  
    {        
        "layer_name" : "semafori",
        "layer_color" : "yellow",
        "feature_name" : "sem. completo",
        "attributes" : {
          "tipo" : "a lato + sopra",
          "strada" : "p001"
        }
    }    
    templates.append(semaforo)

    iface.logMessage("[OTMF] 'templates' model created")
    //loadTemplates();

    // load global attributes
    var rawGlobalAttr = settings.value("global_attributes", "{}")    
    globalAttributes = JSON.parse(rawGlobalAttr)
    iface.logMessage("[OTMF] global attributes settings:\n %1".arg(rawGlobalAttr))

    iface.addItemToPluginsToolbar(otmfButton);
  }

  // accessible from "settings > manage plugins"

  function configure() {
    settingsDialog.open();
  }

  QfToolButton {
    id: otmfButton
    //iconSource: 'icon.svg'
    //iconColor: Theme.mainColor
    bgcolor: Theme.lightGray
    round: true
    enabled: true
    text: "otmf"
    

    contentItem: Text {
      text: "OTMF"
      color: "black"
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
    }
    
    onClicked: {      
      plugin.otmfCreateNewWidget();
    }

    onPressAndHold: {
      settingsDialog.open();
    }
  }

  Dialog {
    id: settingsDialog

    parent: plugin.mainWindow.contentItem
    visible: false
    modal: true
    width: Math.min(400, mainWindow ? (mainWindow.width - 20) : 400)
    height: mainWindow.height / 2
    //height: Math.min(implicitHeight, mainWindow ? (mainWindow.height - 20) : implicitHeight)
    title: qsTr("OTMF Plugin Settings")
    standardButtons: Dialog.Ok | Dialog.Cancel
     
            GridLayout {
                id: settingsGrid
                rows: 3
                flow: GridLayout.TopToBottom
                anchors.centerIn: parent                

                property var keys: Object.keys(plugin.globalAttributes)
                property var values: Object.values(plugin.globalAttributes)                
                
                Label { text: qsTr("Field") }
                TextField { 
                  id: field1
                  placeholderText: "Field 1";
                  validator: RegularExpressionValidator{regularExpression: /\S+/}     // field must be non-empty
                  text: settingsGrid.keys[0]                  
                }     
                TextField { 
                  id: field2
                  placeholderText: "Field 2"
                  validator: RegularExpressionValidator{regularExpression: /\S+/}     // field must be non-empty
                  text: settingsGrid.keys[1] 
                }     

                Label { text: qsTr("Value") }
                TextField { id: value1; text: settingsGrid.values[0] }
                TextField { id: value2; text: settingsGrid.values[1] }                
            }

    onAccepted: {  

      let newAttributes = {}

      if(field1.acceptableInput) {
        newAttributes[field1.text] = value1.text
        iface.logMessage("[OTMF] global attr. field (%1) = (%2)".arg(field1.text).arg(value1.text))
      }

      if(field2.acceptableInput) {
      newAttributes[field2.text] = value2.text 
        iface.logMessage("[OTMF] global attr. field (%1) = (%2)".arg(field2.text).arg(value2.text))
      }

      plugin.globalAttributes = newAttributes
      settings.setValue("global_attributes", JSON.stringify(plugin.globalAttributes))
      mainWindow.displayToast("Settings saved!")
      iface.logMessage("[OTMF] new global attributes settings (str):\n %1".arg(JSON.stringify(plugin.globalAttributes)))  
    }
        
  }

  GridLayout {
    id: widgetContainer
    parent: mapCanvas
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    
    Repeater {
      model: plugin.templates
      
      QfToolButton {
        
        id: otmfWidgetButton
        required property var modelData
        bgcolor: modelData["layer_color"]     // altrimenti accedi al ruolo layer_color
        enabled: true        
        round: false        

        contentItem: Text {
          text: otmfWidgetButton.modelData["feature_name"]
          color: "black"
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
        }        

        onClicked: {
          
          iface.logMessage("[OTMF] creating new feature from '%1'".arg(modelData["feature_name"]));

          let layer = qgisProject.mapLayersByName(modelData["layer_name"])[0];
          let geometry;

          if ((!positionSource.active || !positionSource.positionInformation.latitudeValid || !positionSource.positionInformation.longitudeValid)) {

            if(gpsWarning) {
              mainWindow.displayToast(qsTr("You are trying to place an OTMF feature with GPS turned off.\n You won't be warned a second time"))
              gpsWarning = false;
              return
            }
              
            //get geometry from map's cursor

            let cursor = mapCanvas.mapSettings.center
            const wkt = 'POINT(' + cursor.x + ' ' + cursor.y + ')';
            geometry = GeometryUtils.createGeometryFromWkt(wkt)
            
          } else {
            // get current position  (thanks to opengisch/qfield-snap)        
            const pos = GeometryUtils.reprojectPoint(positionSource.projectedPosition, positionSource.coordinateTransformer.destinationCrs, layer.crs);
            const wkt = 'POINT(' + pos.x + ' ' + pos.y + ')';
            geometry = GeometryUtils.createGeometryFromWkt(wkt)
          }
          
          let newFeature = FeatureUtils.createFeature(layer, geometry);  

          iface.logMessage("[OTMF] feature created: \n%1".arg(newFeature));

          // copy attributes from model to new feature
          for (const [prop, value] of Object.entries(modelData["attributes"])) {

            iface.logMessage("[OTMF] copying attribute '%1' -- value: '%2'".arg(prop).arg(value));            
            newFeature.setAttribute(prop, value)
          }          

          overlayFeatureFormDrawer.featureModel.feature = newFeature
          overlayFeatureFormDrawer.featureModel.resetAttributes(true)
          overlayFeatureFormDrawer.state = 'Add'
          overlayFeatureFormDrawer.open()
        }

        Dialog {
          id: deletionDialog
          parent: mainWindow.contentItem
          title: qsTr("Delete std.feature '%1'?".arg(modelData["feature_name"]))
          standardButtons: Dialog.Ok | Dialog.Cancel

          anchors.centerIn: parent
          //width: Math.min(700, parent.width - Theme.popupScreenEdgeMargin * 2)
          //height: 500

          onAccepted: {
            iface.logMessage("[otmf] removing template '%1'".arg(modelData["feature_name"]))
            plugin.removeTemplate(modelData["feature_name"])
          }
        }

        onPressAndHold: {
          id: deletionDialog.open()          
      }
      }

      
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
          mainWindow.displayToast(qsTr("If my grandmother had wheels"));
        }
        onCancelled: {
          mainWindow.displayToast(qsTr("she would have been a bike"));
        }

        function saveNewStdFeature() {        
          iface.logMessage("[OTMF] - hello i am debug message for saveNewStdFeature");


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

  function removeTemplate(id) {
    
    // select template to be removed
    let victim = null;

    for ( let i=0 ; i < templates.count ; i++) {
      
      let t = templates.get(i)

      iface.logMessage("[OTMF] checking element %1".arg(JSON.stringify(t)))

      if(t["feature_name"] === id) {
        victim = i;
        break
      } 
    }

    // remove template from model
    if(victim !== null) {
      templates.remove(victim)
      iface.logMessage("[OTMF] template removed. templates: \n %1".arg(JSON.stringify(templates)))
      mainWindow.displayToast("Template removed!")
    } 
    else {
      iface.logMessage("[OTMF] template NOT removed. no template matching id '%1'".arg(id))
    }   

    
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
  function listProperties(item, childrenOnly=false)
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

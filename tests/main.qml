import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import org.kde.kirigami 2.15 as Kirigami

import org.kde.pipewire 0.1 as PipeWire
import org.kde.pipewire.record 0.1 as PWRec

Kirigami.ApplicationWindow
{
    id: root
    width: 500
    height: 500
    visible: true
    readonly property int cursorMode: cursorCombo.model[cursorCombo.currentIndex].value
    property QtObject app

    function addStream(nodeid, displayText) {
        rep.model.append({nodeId: nodeid, uuid: "", display: displayText})
    }
    function removeStream(nodeid) {
        for(var i=0; i<rep.model.count; ++i) {
            if (rep.model.get(i).nodeId === nodeid) {
               rep.model.remove(i)
                break;
            }
        }
    }

    signal record(int nodeId, bool capture)

    onCursorModeChanged: app.cursorMode = root.cursorMode
    ColumnLayout {
        id: pipes
        anchors.fill: parent

        Button {
            text: "Add Virtual Monitor"
            onClicked: app.createVirtualMonitor()
        }

        ComboBox {
            id: cursorCombo
            Layout.fillWidth: true
            textRole: "text"
            currentIndex: 0
            model: [
                {
                    text: "Hidden",
                    value: PipeWire.Screencasting.Hidden
                }, {
                    text: "Embedded",
                    value: PipeWire.Screencasting.Embedded
                }, {
                    text: "Metadata",
                    value: PipeWire.Screencasting.Metadata
                }
            ]
        }

        Repeater {
            id: rep
            model: ListModel {}

            delegate: Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                PipeWire.PipeWireSourceItem {
                    id: sourceItem
                    nodeId: model.nodeId
                    visible: record.state !== PipeWire.PipeWireRecord.Recording
                    anchors.fill: parent

                }
                Button {
                    id: butt
                    icon.name: "media-record"
                    text: model.display + " " + model.nodeId
                    enabled: checked === (record.state !== PipeWire.PipeWireRecord.Idle)
                    checkable: true

                    PWRec.PipeWireRecord {
                        id: record
                        nodeId: model.nodeId
                        output: "~/clementine.mp4"
                        active: butt.checked
                    }
                }
            }
        }
    }
}

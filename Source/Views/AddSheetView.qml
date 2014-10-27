/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the Sheet application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* WebApp is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.1
import QtQuick.Controls.Styles 1.2

import ZcClient 1.0 as Zc

Item
{
    id : addSheetView
    width: 100
    height: 62

    state : "create"

    signal cancel()
    signal ok()


    property alias title : textField.text
    property alias  description : textArea.text
    property alias  uri : resourceUrl.text
   // property string resourceFileKey : ""
    property string resourceType : "FILE"
    property string key : ""
    property string author : ""
    property bool   resourceModified : false

    function setValues(o)
    {
        title = o.title
        description = o.description
        uri = o.uri
        resourceType = o.resourceType
        key = o.key
        author = o.author

        addSheetView.state = "edit"

        if (resourceType == "FILE")
        {
            ratioButtonFile.checked = true
            icon.source = "image://icons/" + uri;
        }
        else
        {
            ratioButtonUrl.checked = true
            icon.source = "qrc:/Sheet/Resources/addUrl.png"
        }

        addSheetView.resourceModified = false
    }

    function resetValues()
    {
        ratioButtonFile.checked = true
        icon.source = ""
        title = ""
        description = ""
        uri = ""
        //resourceFileKey = ""
        resourceType = "FILE"
        key = ""
        author = ""
        addSheetView.state = "create"
        addSheetView.resourceModified = false
    }

    function getInformation()
    {
        var result = {}
        result.title = addSheetView.title
        result.description = addSheetView.description
        result.uri = addSheetView.uri
        result.resourceType = addSheetView.resourceType
        result.author = addSheetView.author
        result.key = addSheetView.key
        return JSON.stringify(result)
    }

    function generateKey()
    {
        if (key === "")
        {
            key = mainView.context.nickname + "_" + Date.now().toString()
            author = sharedResource.context.nickname
        }
    }

    FileDialog
    {
        id: fileDialog
        nameFilters: [ "Files", "All files (*)" ]
        onAccepted:
        {
            addSheetView.resourceModified = true
            resourceUrl.text = fileUrl
            icon.source = "image://icons/" + fileUrl;
        }
    }

    function setContext(context)
    {
        sharedResource.setAppContext(context)
    }


    function intializeToCreate()
    {
       addSheetView.state = "create"
       addSheetView.key = ""
       addSheetView.resourceType = "FILE"
    }

    Zc.CrowdSharedResource
    {
        id   : sharedResource
        name : "Sheet"


        Zc.StorageQueryStatus
        {
            id : sharedResourceQueryStatus

            onErrorOccured :
            {
                progressbar.visible = false
                addSheetView.cancel();
            }

            onCompleted :
            {
                progressbar.visible = false
                addSheetView.ok();
            }

            onProgress :
            {
                progressbar.value = value;
            }

        }

    }


    Rectangle
    {
        anchors.fill: parent
        color : "lightgrey"
        opacity : 0.3
    }

    Item
    {
        id : panel
        width : parent.width / 2
        height : parent.height /2

        anchors.centerIn: parent

        Rectangle
        {
            anchors.fill: parent
            color : "lightgrey"
            opacity : 0.8
            radius : 5

            border.width: 1
            border.color: "black"
        }


        Column
        {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.bottomMargin: 20

            spacing: 20

            Row
            {
                spacing: 20

                Label
                {
                    height : 20
                    width : 100

                    anchors.verticalCenter: textField.verticalCenter

                    font.pixelSize: 18
                    font.bold: true
                    text : "Title"
                }

                TextField
                {
                    id : textField
                    height : 25
                    width  : panel.width - 150


                    font.pixelSize: 18
                }

            }

            Row
            {
                spacing: 20

                Label
                {
                    height : 20
                    width : 100

                    anchors.verticalCenter: textArea.verticalCenter

                    font.pixelSize: 18
                    font.bold: true

                    text: "Description"
                }

                TextArea
                {
                    id : textArea
                    height : 100
                    width  : panel.width - 150


                    font.pixelSize: 16
                }
            }

            Row {
                ExclusiveGroup { id: group }
                RadioButton {
                    id : ratioButtonFile
                    text: "File"
                    exclusiveGroup: group
                    checked: true

                    onClicked:
                    {
                        resourceType = "FILE"
                        icon.source = ""
                    }
                }
                RadioButton {

                    id : ratioButtonUrl
                    text: "Url"
                    exclusiveGroup: group

                    onClicked:
                    {
                        resourceType = "URL"
                        icon.source = "qrc:/Sheet/Resources/addUrl.png"
                    }
                }
            }

            Row
            {
                spacing: 20

                Image
                {
                    id : icon

                    height : 150
                    width : height
                }

                Column
                {
                    spacing: 20

                    TextField
                    {
                        id : resourceUrl
                        height : 25
                        width  : panel.width - 250

                        enabled: ratioButtonUrl.checked

                        font.pixelSize: 18
                    }

                    Button
                    {
                        visible : !ratioButtonUrl.checked
                        height : 30
                        width : 100
                        text : "Upload"

                        onClicked:
                        {
                            fileDialog.open();
                        }
                    }
                }
            }
        }



        Zc.ResourceDescriptor
        {
            id : zcResourceDescriptor
        }

        Image
        {
            id : next

            anchors.bottom : parent.bottom
            anchors.right  : parent.right
            anchors.bottomMargin: 5
            anchors.rightMargin: 5

            height : 50
            width : height
            source : "qrc:/Sheet/Resources/next.png"

            MouseArea
            {
                anchors.fill: parent


                onClicked:
                {
                    if (addSheetView.state === "create")
                    {
                        addSheetView.generateKey();
                    }


                    if (addSheetView.resourceType === "URL" || resourceUrl.text === "")
                    {
                        addSheetView.ok()
                        return;
                    }


                    if (addSheetView.resourceModified)
                    {
                        zcResourceDescriptor.fromLocalFile(resourceUrl.text);
                        var localFile = addSheetView.uri
                        addSheetView.uri = addSheetView.key + "_" + zcResourceDescriptor.name
                        progressbar.visible  =  true

                        sharedResource.uploadFile(addSheetView.uri,localFile,sharedResourceQueryStatus)
                    }
                    else
                    {
                        addSheetView.ok()
                        return;
                    }
                }
            }
        }

        Image
        {
            anchors.bottom : parent.bottom
            anchors.right  : next.left
            anchors.rightMargin: 5
            anchors.bottomMargin: 5

            height : 50
            width : height
            source : "qrc:/Sheet/Resources/back.png"

            MouseArea
            {
                anchors.fill: parent
                onClicked: addSheetView.cancel()
            }
        }

        Rectangle
        {
            anchors.fill: parent
            color : "lightgrey"
            visible : progressbar.visible
            opacity: 0.9

            MouseArea
            {
                enabled : progressbar.visible
                anchors.fill : parent
                onClicked:
                {

                }
            }
        }

        ProgressBar
        {
            id : progressbar
            width : parent.width - 60
            anchors.centerIn: parent
            height : 40

            minimumValue: 0
            maximumValue: 100

            visible : false
        }


    }


}

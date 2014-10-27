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
import QtQuick.Layouts 1.1

import ZcClient 1.0 as Zc


import "Tools.js" as Tools


Item
{

    id : sheetListView

    property alias items : repeater.model

    anchors.fill: parent


    signal edit(string key)

    Slider
    {
        id              : slider
        anchors.top     : parent.top
        anchors.left    : parent.left
        anchors.right   : parent.right

        height: 30

        value : 1

        maximumValue: 2
        minimumValue: 0.5
        stepSize: 0.1

        orientation : Qt.Horizontal
    }

    //    ZcResourceDescriptor
    //    {
    //        id : zcResourceDescriptor
    //    }

    function setContext(context)
    {
        sharedResource.setAppContext(context)
    }

    Zc.CrowdSharedResource
    {
        id   : sharedResource
        name : "Sheet"
    }


    ScrollView
    {
        id : sheetScrollViewId

        anchors.top: slider.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom


        Flow
        {
            id : listView
            anchors.top  : parent.top
            anchors.left : parent.left

            width : slider.width

            flow : Flow.LeftToRight

            spacing: 10

            Repeater
            {
                id : repeater

                SheetListViewDelegate
                {
                    id : delegateId

                    scale : slider.value
                    width : sheetListView.width / 2 - 10

                    titleText   : model.title
                    descriptionText:  model.description
                    resourceType : model.resourceType
                    key : model.key
                    author : model.author

                    uri: model.uri

                    Component.onCompleted:
                    {
                    }

                    Zc.StorageQueryStatus
                    {
                        id : sharedResourceQueryStatus

                        onErrorOccured :
                        {
                            console.log(">> ERROR OCCURED")
                            //    loaderBusyIndicator.sourceComponent = undefined
                            progressbar.visible = false

                        }

                        onCompleted :
                        {
                            loaderBusyIndicator.sourceComponent = undefined

                            progressbar.visible = false
                            Qt.openUrlExternally(sharedResource.getLocalUrl(uri))
                        }

                        onProgress :
                        {
                            progressbar.value = value;
                        }

                    }

                    ProgressBar
                    {
                        id : progressbar
                        anchors.fill: parent

                        opacity: 0.5
                        //                        width : parent.width
                        //                        height: 30

                        //                        anchors.centerIn: parent

                        visible : false
                        minimumValue: 0
                        maximumValue: 100
                    }


                    onOpenDocument:
                    {
                        if (model.uri === "")
                        {
                            return;
                        }

                        if (model.resourceType === "URL")
                        {
                            var resolvedUri = model.uri
                            if (resolvedUri.indexOf("http" !== 0))
                            {
                                resolvedUri = "http://" + model.uri
                            }

                            Qt.openUrlExternally(resolvedUri)
                        }
                        else
                        {
                            //loaderBusyIndicator.sourceComponent = busyIndicator

                            progressbar.visible = true
                            sharedResource.downloadFile(uri,sharedResourceQueryStatus);
                        }
                    }

                    onRemove :
                    {
                        sheetActivityItems.deleteItem(model.key)
                    }

                    onEdit :
                    {
                        sheetListView.edit(model.key)
                    }
                }
            }
        }
    }


    Component
    {
        id : busyIndicator

        Rectangle
        {
            anchors.fill: parent
            opacity : 0.8
            color : "lightgrey"

            MouseArea
            {
                anchors.fill : parent
                onClicked:
                {

                }
            }

            BusyIndicator
            {
                anchors.centerIn: parent
                running : true
                width : 100
                height : 100
                z : 100
            }
        }

    }

    Loader
    {
        id : loaderBusyIndicator

        anchors.fill: parent

    }


}

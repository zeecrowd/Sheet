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

Item
{
    id : sheetListDelegate
    width: 100
    height: 150 * scale

    Rectangle
    {
        anchors.fill: parent
        opacity: 0.5
        color : "white"
        radius : 5
    }

    property double scale : 1

    property alias imageSource : image.source
    property alias titleText : title.text
    property alias descriptionText : description.text
    property string uri : "XXXX"
    property string resourceType : null
    property string key : null
    property alias author : authorField.text

    onUriChanged:
    {
            if (resourceType === "URL")
            {
                imageSource = "qrc:/Sheet/Resources/addUrl.png"
                uriField.text = uri
            }
            else
            {
                imageSource = "image://icons/" + uri;
                uriField.text = uri.replace(key +"_", "")
            }
    }



    signal openDocument();
    signal remove();
    signal edit();

    Image
    {
        id : image
        width : height - 10
        height : parent.height - 10

        anchors.top  : parent.top
        anchors.left : parent.left
        anchors.topMargin  : 5
        anchors.leftMargin : 5
        anchors.rightMargin : 5

        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
                sheetListDelegate.openDocument();
            }
        }
    }

    Label
    {
        id :title
        anchors.top  : image.top
        anchors.left : image.right
        anchors.leftMargin: 10

        font.bold: true
        font.pixelSize: 16
        color : "black"
    }

    TextArea
    {
        id : description
        anchors.top  : title.bottom
        anchors.bottom  : uriField.top
        anchors.left : image.right
        anchors.right : parent.right
        anchors.topMargin: 5
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin : 10
        font.pixelSize: 12
        textColor: "black"
        readOnly: true
    }

    TextField
    {
        id : uriField
        anchors.bottom  : parent.bottom
        anchors.left : image.right
        anchors.right : authorField.left
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin : 10
        height : 16
        font.pixelSize: 12
        textColor: "black"
        readOnly: true
    }

    Label
    {
        id : authorField
        anchors.bottom  : parent.bottom
        anchors.right : parent.right
        anchors.bottomMargin: 10
        anchors.rightMargin : 10
        height : 16
        width : 150
        font.pixelSize: 12
        font.italic: true
        color: "black"
    }

    Image
    {
        id : bin
        width : 25
        height : width

        anchors.top  : parent.top
        anchors.right : parent.right

        source : "qrc:/Sheet/Resources/bin.png"

        visible : mainView.context.affiliation >= 3 || author === mainView.context.nickname
        enabled : mainView.context.affiliation >= 3 || author === mainView.context.nickname

        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                sheetListDelegate.remove()
            }
        }
    }

    Image
    {
        id : editMode
        width : 25
        height : width

        anchors.top  : parent.top
        anchors.right : bin.left
        anchors.rightMargin : 3

        visible : mainView.context.affiliation >= 3 || author === mainView.context.nickname
        enabled : mainView.context.affiliation >= 3 || author === mainView.context.nickname


        source : "qrc:/Sheet/Resources/editmode.png"

        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                sheetListDelegate.edit()
            }
        }
    }

}

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
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1


import "Tools.js" as Tools
import "Main.js" as Presenter

import ZcClient 1.0 as Zc

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    toolBarActions : [
        Action {
            id: closeAction
            shortcut: "Ctrl+X"
            iconSource: "qrc:/Sheet/Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                mainView.close();
            }
        },
        Action {
            id: addAction
            shortcut: "Ctrl++"
            iconSource: "qrc:/Sheet/Resources/plus.png"
            tooltip : "Add a sheet"
            onTriggered:
            {
                mainView.addSheet();
            }
        }
    ]


    function itemtoItemList(idItem)
    {
        var json = sheetActivityItems.getItem(idItem,"{}")

        var o = JSON.parse(json)

        itemsList.append({"title" : o.title, "description" : o.description, "resourceType" : o.resourceType, "uri" : o.uri, "author" : o.author, "key" : o.key})

    }

    function modifyItem(index,idItem)
    {
        var json = sheetActivityItems.getItem(idItem,"{}")
        var o = JSON.parse(json)

        itemsList.setProperty(index,"title", o.title)
        itemsList.setProperty(index,"description", o.description)
        itemsList.setProperty(index,"resourceType", o.resourceType)
        itemsList.setProperty(index,"uri", o.uri)
        itemsList.setProperty(index,"author", o.author)
        itemsList.setProperty(index,"key", o.key)
    }

    Zc.AppNotification
    {
        id : appNotification
    }

    onIsCurrentViewChanged :
    {
        if (isCurrentView == true)
        {
            appNotification.resetNotification();
        }
    }

    Zc.CrowdActivityItems
     {
       id         : sheetActivityItems
       name       : "SheetList"
       persistent : true

       Zc.QueryStatus
       {
         id : sheetActivityItemsQueryStatus

         onCompleted :
         {
             splashScreenId.visible = false
             var items = sheetActivityItems.getAllItems();

             Tools.forEachInArray(items, function(x)
             {
                 mainView.itemtoItemList(x);
             }

             )
         }

         onErrorOccured :
         {
             console.log(">> ERRROR " + error + " " + errorCause  + " " + errorMessage)
         }
       }


       onItemChanged :
       {
           var find =   Tools.getIndexInListModel(itemsList, function (x) { return x.key === idItem;})
           if (find === -1)
           {
              mainView.itemtoItemList(idItem);
           }
           else
           {
               mainView.modifyItem(find,idItem)
           }

           appNotification.blink();

           if (!mainView.isCurrentView)
           {
               appNotification.incrementNotification();
           }
       }

       onItemDeleted :
       {
          var find =   Tools.removeInListModel(itemsList, function (x) { return x.key === idItem;})
       }

     }


    Zc.CrowdActivity
    {
        id : activity

        onStarted:
        {
            sheetActivityItems.loadItems(
                             sheetActivityItemsQueryStatus);

        }

        onContextChanged :
        {

            addSheetView.setContext(activity.context);
            sheetListview.setContext(activity.context);
        }
    }

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }

    SheetListView
    {
        id : sheetListview
        anchors.fill : parent

        items : itemsList

        onEdit:
        {
            var json = sheetActivityItems.getItem(key,"{}")

            var o = JSON.parse(json)
            mainView.editSheet(o)
        }

    }



    ListModel
    {
        id : itemsList
    }


    AddSheetView
    {
        id : addSheetView
        anchors.fill: parent
        visible : false

        onCancel:
        {
            visible = false
        }

        onOk:
        {
            var info = getInformation();

            var added = sheetActivityItems.getItem(addSheetView.key,"") === "";

            sheetActivityItems.setItem(addSheetView.key,info)
            visible = false

            if (added)
            {
                appNotification.logEvent( Zc.AppNotification.Add,"Resource",addSheetView.title,"")
            }

        }
    }

    function addSheet()
    {
        addSheetView.resetValues()
        addSheetView.visible = true
    }

    function editSheet(o)
    {

        addSheetView.setValues(o)
        addSheetView.visible = true
    }

    onLoaded :
    {
        activity.start();
    }

    onClosed :
    {
        activity.stop();
    }
}

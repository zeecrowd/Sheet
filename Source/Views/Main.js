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

var instance = {}

instance.fileStatus = {}

var maxNbrDomwnload = 5;
var maxNbrUpload = 5;

var uploadRunning = 0;
var downloadRunning = 0;

var filesToDownload = []
var filesToUpload = []

function nextDownload()
{
    if (filesToDownload.length > 0)
    {
        downloadRunning++;
        var file = filesToDownload.pop();
        documentFolder.downloadFile(file.cast)
    }
}

function nextUpload()
{
    if (filesToUpload.length > 0)
    {
        uploadRunning++;
        var file = filesToUpload.pop();


        if (file.path !== "" && file.path !== null && file.path !== undefined)
        {
            documentFolder.importFileToLocalFolder(file.descriptor,file.path)
        }
        else
        {
            documentFolder.uploadFile(file.descriptor)
        }
    }
}

instance.startDownload = function(file)
{
    filesToDownload.push(file)
    if (downloadRunning < maxNbrDomwnload)
    {
        nextDownload();
    }
}


instance.startUpload = function(file,path)
{
    var fd = {}
    fd.descriptor = file;
    fd.path = path

    filesToUpload.push(fd)
    if (uploadRunning < maxNbrUpload)
    {
        nextUpload();
    }
}

instance.uploadFinished = function()
{
    uploadRunning = uploadRunning - 1;
    nextUpload();
}

instance.downloadFinished = function()
{
    downloadRunning--;
    nextDownload();
}

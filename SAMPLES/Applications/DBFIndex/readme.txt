DBF Index Manager
Copyright (c) 2020 by Gilbert Vaillancourt. All Rights Reserved.

Introduction
````````````
DBFIndex (Ver 2.0)

This small utility is intended for index management. It allows to create & generate indexes for an application
under developpement without having to stop developpement of a module because of a missing or need for a
new index. This utility will permit creating on the fly an new index criteria and index the associated database
on the fly.

I have developped this utility a few years ago a it has served me well since it was not necessary to
developpe an indexing routine before developping an application. It allowed me to create, delete, modify and
even reindex if necessary.

It use .DBF databases and generates .CDX indexes.

It permit the use of 5 key fields within a single index.

It will automaticaly detect the type of field and create index using DtoS() for date fields, LtoC() for logic fields
and Str() for numeric fields

It can be called with the working folder as a parameter using a Windows Shortcut. This way the utility will
open using the called working folder.

I have used this utility so many time, and it really saved me a lot of time and labor. Since it's been usefull for
me I thought it could be usefull for someone else. So I decided to include it in the MiniGUI distribution.
Notes:
This utility need the xlib.lib from Harbour.

I use a very special developpement enviroment where network drive must be mapped in a specific way. So
you may have to change the paths in the Compile.bat file to fit with your enviroment.

For now the index filename is limited to 8 characters, but I have the intension of changing this in a near
future. Same has for the databases name wich are also limited to 8 characters in the browse. That will also
be changed in a near future.

Getting Started
```````````````
The utility is quite simple to use. First select the Work folder : by clicking on the folder button and select
the folder where your project database are stored.

The utility will then populate the browses with a list of existing Databases, associated Fields structure and
associated Indexes if any exists.

It will also display the Index Name and the Index key fields for the selected index of the Indexes browse
as the following image shows.

Create Index :
1. Select the database for wich you want to create an index
2. Click 'Create Index' button
3. Capture Index Name (Limited to 8 characters)
4. Select the field(s) you wish the index to be create on by double cliking on the field name row.
   (As many as 5 key fields can be select per index file)
   To change any of the field use the Clear button beside the unwanted key field
   To change all the fields use the Clear All Keysbutton beside Index Name
5. Click Generate Index button to generate index associated to the selected database

Once generated the Indexes browse will display the new associated index

Clicking 'Delete Index' will delete the selected index

It's as easy as that !

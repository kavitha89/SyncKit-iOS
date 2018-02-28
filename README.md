# SyncKit-iOS
SyncKit-iOS

Targeted users here are assumed as,persons who work for mining fields or electrical works and update the status of components like boiler,transformer status.Take  in  the  case  of  field  force applications  wherein  mobile  network  connectivity  is  not an always  available  parameter, so  users  tend  to  make  changes  to  datasets  when  they  are  not  connected  to  the  remote service or the internet and it is really important to persist all of these changes, when there is  connectivity  push  all  of  these  changes  to the  remote  service. 

Components used for network operations is Restkit and parse.com is base where all your data updated/added are synced periodically.

First time sync: User syncs data from server for the first time  
Offline record changes:  Changes  made  by  the  user  in  the documents in offline. 

Second time sync: User syncs for the second time on the delta 
changes made in the server. 

Conflict handling: Handling conflicts on the changes made both by user and at server level. 

Data Sharing between applications: Sharing the synced data 
between applications. 

Google analytics was integrated onto the project to track  
1.Events. 
2.App behavior. 
3.Active Users. 
4.User session. 
5.Exceptions and other catches.

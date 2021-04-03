B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.9
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'ENUM like variables
	Dim Const _
    custOrder_Button=0, _
    custOrder_Elbow=1, _
    custOrder_Textbox=2, _
    custOrder_Slider=3 As String  
	
	'general variables
	Private rp As RuntimePermissions
	Public currDateFormat As String = "dd-MM-yyyy HH:mm"
	Public filesFolder As String
	Public sql As SQL
	Public noFtp As Boolean = True
	Public urlNominatim As String = "https://nominatim.openstreetmap.org/search/"
	
	'FTP variables
	Private FTP As FTP
	Public articleFolder As String
	Public FtpArticleFolder As String = "/user_jongens/data"
	Public ftpFolder As String = "apps.distridata.nl"
	Public ftpPort As Int = 21
	Public ftpName As String = "leverapp"
	Public xFileName As String = "9OaiP6BA"
	
	'driver variables
	Type driverRoute(route As String, chauffeur As String, pin As String)
	Public lstDriverRoute As List
	Public driverId As String
	Public enterPinCount As Int = 0
	Public driverRoutes As String
	Public driverSelectedRoute As String
	Public driverOrderList As List
	
End Sub

Sub Service_Create
	DateTime.DateFormat = currDateFormat
	GetFilesFolder
	SetFileFolders
	InitSql
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub

Private Sub GetFilesFolder
	filesFolder = rp.GetSafeDirDefaultExternal("")
End Sub

Private Sub InitSql
	If File.Exists(filesFolder, "distririjden.db") = False Then
		File.Copy(File.DirAssets, "disrtirijden.db", filesFolder, "distrrijden.db")
	End If
End Sub

Public Sub InitFtp As FTP
	FTP.Initialize("FTP", "apps.distridata.nl", 21, "leverapp", "9OaiP6BA")
	FTP.PassiveMode = True
	FTP.TimeoutMs = 4*1000
	
	Return FTP
End Sub

Private Sub SetFileFolders
	articleFolder = $"${filesFolder}/article/"$
End Sub



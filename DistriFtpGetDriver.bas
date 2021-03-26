B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.7
@EndOfDesignText@
'this file contain as FTP functions
Sub Class_Globals
	Private FTP As FTP
	Private driversFolder As String = "/user_jongens/routes"
	Private localRouteFolder As String = Starter.filesFolder&"/routes/"
	Private currFtpRoute As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Private Sub DeleteRoutes
	If File.IsDirectory(localRouteFolder, "") = False Then
		File.MakeDir(localRouteFolder, "")
	End If
	For Each route As String In File.ListFiles(localRouteFolder)
		File.Delete(localRouteFolder, route)
	Next
End Sub

Public Sub GetDrivers As ResumableSub
	'delete routes in folder
	DeleteRoutes
'	Return
	FTP.Initialize("FTP", Starter.ftpFolder, Starter.ftpPort, Starter.ftpName, Starter.xFileName)
	FTP.PassiveMode = True
	FTP.TimeoutMs = 4*1000
	
	FTP.List(driversFolder)
	Wait For (ProcessDriverFromRoute) complete (done As Boolean)
	Return True
End Sub

Sub FTP_ListCompleted (ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)
'	Log(ServerPath)
	If Success = False Then
		Log(LastException)
	Else
		For i = 0 To Files.Length - 1
			If Files(i).Name.IndexOf("route") = -1 Then
				Continue
			Else
				currFtpRoute = Files(i).Name
				FTP.DownloadFile(driversFolder &"/"& Files(i).Name, False, "", localRouteFolder&currFtpRoute)
				Wait For FTP_DownloadCompleted (ServerPath2 As String, Success As Boolean)
			End If
		Next
	End If
	FTP.Close
	'ProcessDriverFromRoute
End Sub

Sub FTP_DownloadCompleted (ServerPath As String, Success As Boolean) As ResumableSub
	If Success = False Then 
		Log(LastException.Message)
		Return True
	End If
	Return True
End Sub

Private Sub ProcessDriverFromRoute As ResumableSub
	For Each route As String In File.ListFiles(localRouteFolder)
		ParseRouteJsonGetDriver(File.ReadString(localRouteFolder, route))
	Next
	Return True
End Sub

Private Sub ParseRouteJsonGetDriver(routeTxt As String) As ResumableSub
	Dim parser As JSONParser
	parser.Initialize(routeTxt)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
'		Dim route As String = colroot.Get("route")
'		Dim nr As Int = colroot.Get("nr")
'		Dim pin As String = colroot.Get("pin")
		Dim kenteken As String = colroot.Get("kenteken")
		Dim chauffeur As String = colroot.Get("chauffeur")
'		Dim digi As Int = colroot.Get("digi")
		Log($"CHAUFFEUR : ${chauffeur} KENTEKEN : ${kenteken}"$)
	Next
	Return True
End Sub
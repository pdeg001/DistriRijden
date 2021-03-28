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
	Private lstRoutes As List
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
	Dim routeCount, totalRoutes As Int = 0
	Dim lstProgress As List
	
	If Starter.noFtp = False Then ' routes manually put in route folder
	
		'delete routes in folder
		DeleteRoutes
	
	
		FTP = Starter.InitFtp
		Dim sf As Object = FTP.List(driversFolder)
	
		'get files from FTP folder
		Wait For (sf) FTP_ListCompleted (ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)
	
		'process files that starts with "route"
		For i = 0 To Files.Length - 1
			If Files(i).Name.StartsWith("route") =True Then
				totalRoutes = totalRoutes + 1
			End If
		Next
	
		For i = 0 To Files.Length - 1
			If Files(i).Name.StartsWith("route") Then
				'update progressbar on the main screen
				lstProgress.Initialize
				lstProgress.AddAll(Array As String(routeCount, totalRoutes, "routes"))
				CallSub2(Main, "SetProgressBar", lstProgress)

				routeCount = routeCount + 1
			
				'download file and wait for it to complete
				FTP.DownloadFile(File.Combine(driversFolder,Files(i).Name), False, "", $"${localRouteFolder}${Files(i).Name}"$)
				Wait For FTP_DownloadCompleted (ServerPath As String, Success As Boolean)
			End If
		Next
		FTP.Close
'	Sleep(500)
	
		'hide progressbar on the main screen
		lstProgress.Initialize
		lstProgress.AddAll(Array As String(totalRoutes, totalRoutes, "routes"))
		CallSub2(Main, "SetProgressBar", lstProgress)
	End If

	'get the drivers from the route and store them in starter.lstDriverRoute as DriverRoute
	wait for (ProcessDriverFromRoute) Complete (done As Boolean)

	CallSubDelayed(Main, "EndProgressAnimation")
	
	Return True
End Sub

Sub FTP_DownloadCompleted (ServerPath As String, Success As Boolean) As ResumableSub
	Log($"${ServerPath} - ${Success}"$)
	If Success = False Then 
		Log(LastException.Message)
		Return True
	End If
	Return True
End Sub

Private Sub ProcessDriverFromRoute As ResumableSub
	Starter.lstDriverRoute.Initialize
	For Each route As String In File.ListFiles(localRouteFolder)
		ParseRouteJsonGetDriver(File.ReadString(localRouteFolder, route))
	Next
	Return True
End Sub

Private Sub ParseRouteJsonGetDriver(routeTxt As String)' As ResumableSub
	Dim parser As JSONParser
	parser.Initialize(routeTxt)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		Dim route As String = colroot.Get("route")
'		Dim nr As Int = colroot.Get("nr")
		Dim pin As String = colroot.Get("pin")
		Dim kenteken As String = colroot.Get("kenteken")
		Dim chauffeur As String = colroot.Get("chauffeur")
'		Dim digi As Int = colroot.Get("digi")
'		Log($"CHAUFFEUR : ${chauffeur} KENTEKEN : ${kenteken}"$)
		If CheckIfDriverIsInList(chauffeur, route) = False Then
			Starter.lstDriverRoute.Add(CreateDriverRoute (route, chauffeur, pin))
		End If
	Next
	'Return True
End Sub

Private Sub CheckIfDriverIsInList(driver As String, route As String) As Boolean
	For Each checkDriver As DriverRoute In Starter.lstDriverRoute
		'if driver exists add the route to the driver route
		If checkDriver.chauffeur = driver Then
			checkDriver.route = $"${checkDriver.route};${route}"$
			Return True
		End If
	Next
	Return False
End Sub

Private Sub CreateDriverRoute (route As String, chauffeur As String, pin As String) As DriverRoute
	Dim t1 As DriverRoute
	t1.Initialize
	t1.route = route
	t1.chauffeur = chauffeur
	t1.pin = pin
	Return t1
End Sub
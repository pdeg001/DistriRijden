B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10.7
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: true
	#IncludeTitle: false
	
#End Region

Sub Process_Globals
	Private xui as XUI
End Sub

Sub Globals

	Private clvRoutes As CustomListView
	Private lblHeader As Label
	Private lblHeader1 As Label
	Private lblRouteNumber As Label
	Private lblKenteken As Label
	Private lblRouteName As Label
	Private pnlRoute As Panel
	Private lblOrderCount As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("SelectRoute")
	GetDriverRoutes
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetDriverRoutes
	Dim lstDriverRouteNumbers As List
	
	clvRoutes.Clear
	lstDriverRouteNumbers.Initialize
	
	If Starter.driverRoutes.IndexOf("|") <> -1 Then
		lstDriverRouteNumbers = Regex. Split("\|",Starter.driverRoutes)
	Else
		lstDriverRouteNumbers.Add(Starter.driverRoutes)
	End If
	
	For i = 0 To lstDriverRouteNumbers.Size -1
		ParseRoute(File.ReadString(Starter.filesFolder&"/routes", $"route${lstDriverRouteNumbers.Get(i)}.txt"$))
	Next
End Sub

Private Sub ParseRoute(route As String)
	Dim parser As JSONParser
	Dim orderCount As Int = 0
	
	parser.Initialize(route)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		Dim routeNummer As String = colroot.Get("route")
		Dim routeNaam As String = colroot.Get("naam")
		Dim kenteken As String = colroot.Get("kenteken")
		Dim chauffeur As String = colroot.Get("chauffeur")
		
		'count orders
		Dim orders As List = colroot.Get("orders")
		For Each colorders As Map In orders
			orderCount = orderCount + 1
		Next
		
		
		clvRoutes.Add(CreateClvPanel(routeNummer, routeNaam, kenteken, NumberFormat2(orderCount,3,0,0, False)), "")
	Next
End Sub

Private Sub CreateClvPanel(routeNumber As String, routeName As String, plate As String, orderCount As String) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, clvRoutes.AsView.Width, 125dip)
	pnl.LoadLayout("pnlSelectRoute")
	
	pnlRoute.Tag = $"route${routeNumber}.txt"$
	lblRouteNumber.Text = $"Route : ${routeNumber}"$
	If plate.Length > 0 Then
		lblKenteken.Text = $"Kenteken : ${plate}"$
	End If
	lblOrderCount.Text = $"Orders : ${orderCount}"$
	lblRouteName.Text = $"Naam : ${routeName}"$
	
	Return pnl
End Sub


Private Sub pnlRoute_Click
	Dim pnl As Panel = Sender
	Starter.driverSelectedRoute = pnl.Tag
	StartActivity(DriverOrders)
	
End Sub
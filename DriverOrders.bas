B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10.7
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region

Sub Process_Globals
	Private xui as XUI
End Sub

Sub Globals
	Private lblHeader As Label
	Private lblHeader1 As Label
	Private clvOrders As CustomListView
	Private lblAddress As Label
	Private lblBetween As Label
	Private lblCity As Label
	Private lblName As Label
	Private pnlRoute As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("RouteOrder")
	GetSelectedOrder
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Private Sub GetSelectedOrder
	clvOrders.Clear
	Dim orders As String = File.ReadString(Starter.filesFolder&"/routes", $"${Starter.driverSelectedRoute}"$)
	ParseSelectedOrder(orders)
End Sub


Private Sub ParseSelectedOrder (orderlist As String)
	Dim parser As JSONParser
	Dim orderCount As Int = 0
	Dim currKlantNr As String = ""
	
	parser.Initialize(orderlist)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		orderCount = 0
		Dim orders As List = colroot.Get("orders")
		For Each colorders As Map In orders
			Dim klantnr As Int = colorders.Get("klantnr")
			Log(klantnr)
'			Dim begin As String = colorders.Get("begin")
'			Dim eind As String = colorders.Get("eind")
'			Dim naam As String = colorders.Get("naam")
'			Dim adres As String = colorders.Get("adres")
'			Dim postcode As String = colorders.Get("postcode")
'			Dim woonplaats As String = colorders.Get("woonplaats")
'			Dim tel1 As String = colorders.Get("tel1")
'			Dim tel2 As String = colorders.Get("tel2")
'			Dim opm As String = colorders.Get("opm")
			
			'agg. all orders for same customer, add order count
			If currKlantNr = "" Or currKlantNr = klantnr Then
				currKlantNr = klantnr
				orderCount = orderCount + 1
				
				Dim begin As String = colorders.Get("begin")
				Dim eind As String = colorders.Get("eind")
				Dim naam As String = colorders.Get("naam")
				Dim adres As String = colorders.Get("adres")
				Dim postcode As String = colorders.Get("postcode")
				Dim woonplaats As String = colorders.Get("woonplaats")
				Dim tel1 As String = colorders.Get("tel1")
				Dim tel2 As String = colorders.Get("tel2")
				Dim opm As String = colorders.Get("opm")
				
				Continue
			Else
				clvOrders.Add(CreateOrderPanel(currKlantNr, begin, eind, naam, _
				adres, postcode, woonplaats,tel1, tel2, opm, orderCount),"")
				currKlantNr = ""
				orderCount = 0
			End If
						
			Next
			clvOrders.Add(CreateOrderPanel(currKlantNr, begin, eind, naam, _
				adres, postcode, woonplaats,tel1, tel2, opm, orderCount),"")
			currKlantNr = ""
			orderCount = 0
		Next
	End Sub

Private Sub CreateOrderPanel(klantnr As String, begin As String, eind As String, _
	naam As String, adres As String, postcode As String, woonplaats As String, _
	tel1 As String, tel2 As String, opm As String, OrderCount As String) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, clvOrders.AsView.Width, 190dip)
	pnl.LoadLayout("pnlOrder")
	
	lblName.Text = $"${klantnr.SubString2(0,3)}.${klantnr.SubString2(3,6)} ${naam} (${OrderCount})"$
	lblAddress.Text =$"${adres}${CRLF}${postcode} ${woonplaats}${CRLF}${ConcatPhoneNumber(tel1, tel2)}"$
	lblBetween.Text = $"${ConcatBeginEnd(begin, eind)}"$
	lblCity.Text = opm.Replace("|", " ")
	
	Return pnl
End Sub

Private Sub ConcatBeginEnd(begin As String, eind As String) As String
	If begin = "0000" And eind = "0000" Then Return ""
	
	Return $"${begin.SubString2(0,2)}:${begin.SubString2(2,4)} - ${eind.SubString2(0,2)}:${eind.SubString2(2,4)}"$
	
End Sub

Private Sub ConcatPhoneNumber(phone1 As String, phone2 As String) As String
	If phone1 <> "" And phone2 <> "" And phone2 <> phone1 Then
		Return $"${phone1}${CRLF}${phone2}"$
	End If
	
	If phone1 <> "" And phone2 = "" Then
		Return $"${phone1}"$
	End If
	If phone1 = "" And phone2 <> "" Then
		Return $"${phone2}"$
	End If
	
	Return ""
End Sub

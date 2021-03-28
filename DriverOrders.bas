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
	Private lblKlantNumber As Label
	Private lblName As Label
	Private lblOrderNumber As Label
	Private lblPhone1 As Label
	Private lblPhone2 As Label
	Private lblZip As Label
	Private pnlRoute As Panel
	Private lblArticleCount As Label
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
	Dim articleCount As Int
	
	parser.Initialize(orderlist)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		articleCount = 0
		Dim orders As List = colroot.Get("orders")
		For Each colorders As Map In orders
			Dim ordernr As Int = colorders.Get("ordernr")
			Dim klantnr As Int = colorders.Get("klantnr")
			Dim begin As String = colorders.Get("begin")
			Dim eind As String = colorders.Get("eind")
			Dim naam As String = colorders.Get("naam")
			Dim adres As String = colorders.Get("adres")
			Dim postcode As String = colorders.Get("postcode")
			Dim woonplaats As String = colorders.Get("woonplaats")
			Dim tel1 As String = colorders.Get("tel1")
			Dim tel2 As String = colorders.Get("tel2")
			Dim artikelen As List = colorders.Get("artikelen")
			For Each colartikelen As Map In artikelen
				articleCount = articleCount + 1
			Next
			
			clvOrders.Add(CreateOrderPanel(ordernr, klantnr, begin, eind, naam, adres, postcode, woonplaats, _
	tel1, tel2, NumberFormat2(articleCount,3,0,0,False)),"")
		Next
	Next
End Sub

Private Sub CreateOrderPanel(ordernr As String, klantnr As String, begin As String, eind As String, _
	naam As String, adres As String, postcode As String, woonplaats As String, _
	tel1 As String, tel2 As String, articleCOunt As String) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, clvOrders.AsView.Width, 220dip)
	pnl.LoadLayout("pnlOrder")
	
	lblOrderNumber.Text = ordernr
	lblKlantNumber.Text = klantnr
	lblName.Text = naam
	lblAddress.Text = adres
	lblCity.Text = $"${postcode} ${woonplaats}"$
	lblBetween.Text = $"${begin}-${eind}"$
	lblPhone1.Text = tel1
	lblPhone2.Text = tel2
	lblArticleCount.Text = $"Artikelen : ${articleCOunt}"$
	Return pnl
End Sub

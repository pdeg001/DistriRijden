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
	Private xui As XUI
	Public lstCustInfo As List
End Sub

Sub Globals
	'variables
	Private pnlNavButtonsHeight, pnlNavButtonsWidth, navButtonHeight As Int
	Private selectedNavButtonPanel As Panel
	
	'views
	Private lblHeader As Label
	Private lblHeader1 As Label
	Private orderTab As TabStrip
	Private pnlNavButtons As Panel
	Private lblActive As Label
	Private lblCustomerNav As Label
	Private pnlCustomerButton As Panel
	Private customerNumber As String
	Private clvArticle As CustomListView
	Private lblArticleMetadata As Label
	Private lblArticleName As Label
	Private lblARticleQuantity As Label
	Private pnlArticle As Panel
	Private lblOrderNr As Label
	Private pnlOrderNr As Panel
	Private lblRemark As Label
	Private lblArtRowNr As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	customerNumber = Starter.lstSelectedCustInfo.customerNumber
	Activity.LoadLayout("customerOrderMain")
	
	GetButtonPanelDimensions
	CreateNavButtons
	
	orderTab.LoadLayout("tabLeveringInfo", "")
	orderTab.LoadLayout("tabOrder", "")
	
	lblHeader.Text = $"${GenFunctions.FormatCustomerNumber(customerNumber)}${CRLF}${Starter.lstSelectedCustInfo.custormerName}"$
	GetRoute
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetButtonPanelDimensions
	pnlNavButtonsHeight = pnlNavButtons.Height
	pnlNavButtonsWidth = pnlNavButtons.Width
	navButtonHeight = pnlNavButtonsHeight/5
	
'	Log($"button panel heigth : ${pnlNavButtonsHeight}
'	button panel width : ${pnlNavButtonsWidth}
'	button height : ${navButtonHeight}"$)
End Sub

Private Sub CreateNavButtons
	Dim top As Int = 0
	
	'lever info
	top = CreateNavLabel("LeverInfo", "Leverings Info", top, 0, "")
	'Orders
	top = CreateNavLabel("Orders", "Orders", top, 1, $" (${Starter.lstSelectedCustInfo.orderCount})"$)
	'Retour emballage
	top = CreateNavLabel("RetourEmballage", "Retour emballage", top, 2, "")
	'Retouren
	top = CreateNavLabel("Retouren", "Retouren", top, 3, "")
	'Opmerking
	top = CreateNavLabel("Opmerking", "Opmerking", top, 4, "")
End Sub

Private Sub CreateNavLabel (event As String, buttonText As String, top As Int, tag As String, xtraText As String) As Int
	Dim pnl As B4XView = xui.CreatePanel(event)
	pnl.SetLayoutAnimated(0, 0, 0, pnlNavButtonsWidth, navButtonHeight)
	pnl.LoadLayout("customerNaveButton")

	lblActive.Tag = "isActive"
	lblCustomerNav.Text = $"${buttonText}${xtraText}"$
	pnlNavButtons.AddView(pnl, 0dip, top, pnlNavButtonsWidth, navButtonHeight)
	
	If top = 0 Then
		selectedNavButtonPanel = pnl
		lblActive.Visible = True
	Else
		lblActive.Visible = False
	End If
	top = top + navButtonHeight
	
	Return top
End Sub

Private Sub CreateButton(event As String, buttonText As String, top As Int) As Int
	Dim btn As Button
	
	btn.Initialize(event)
	btn.Height = navButtonHeight
	btn.Text = buttonText
	pnlNavButtons.AddView(btn, 0dip, top, pnlNavButtonsWidth, navButtonHeight)
	top = top + navButtonHeight
	
	Return top
End Sub

Sub LeverInfo_Click
	Dim pnl As Panel = Sender
	EnableButtonActive(False)
	selectedNavButtonPanel = pnl
	EnableButtonActive(True)
	orderTab.ScrollTo(0, True)
End Sub

Sub Orders_Click
	Dim pnl As Panel = Sender
	EnableButtonActive(False)
	selectedNavButtonPanel = pnl
	EnableButtonActive(True)
	orderTab.ScrollTo(1, True)
End Sub

Sub RetourEmballage_Click
	Dim pnl As Panel = Sender
	EnableButtonActive(False)
	selectedNavButtonPanel = pnl
	EnableButtonActive(True)
End Sub

Sub Retouren_Click
	Dim pnl As Panel = Sender
	EnableButtonActive(False)
	selectedNavButtonPanel = pnl
	EnableButtonActive(True)
End Sub

Sub Opmerking_Click
	Dim pnl As Panel = Sender
	EnableButtonActive(False)
	selectedNavButtonPanel = pnl
	EnableButtonActive(True)
End Sub

Private Sub SetButtonState(pnl As Panel, buttonState As Boolean)
	
End Sub

Private Sub EnableButtonActive(showActive As Boolean)
	Dim lblActive As Label
	
	For Each v As View In selectedNavButtonPanel.GetAllViewsRecursive
		If v.Tag = "isActive" Then
			lblActive = v
			lblActive.SetVisibleAnimated(300, showActive)
		End If
	Next
End Sub

Private Sub orderTab_PageSelected (Position As Int)
	Log(Position)
End Sub

Private Sub GetRoute
	Dim route As String = Starter.lstSelectedCustInfo.route
	Dim customerNr As String = Starter.lstSelectedCustInfo.customerNumber
	Dim routeJson, currOrderNumber As String
	
	clvArticle.Clear
	
	'check if file exists
	If File.Exists(Starter.filesFolder&"/routes/", route) = False Then
		Log("JJJJJJ")
		Return
	End If
	
	routeJson = File.ReadString(Starter.filesFolder&"/routes/", route)
	
	Dim parser As JSONParser
	parser.Initialize(routeJson)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		Dim route As String = colroot.Get("route")
'		Dim nr As Int = colroot.Get("nr")
'		Dim pin As String = colroot.Get("pin")
'		Dim kenteken As String = colroot.Get("kenteken")
'		Dim chauffeur As String = colroot.Get("chauffeur")
'		Dim digi As Int = colroot.Get("digi")
		Dim orders As List = colroot.Get("orders")
		For Each colorders As Map In orders
			Dim ordernr As Int = colorders.Get("ordernr")
			Dim klantNr As Int = colorders.Get("klantnr")
			Dim opm As String = colorders.Get("opm")
			If klantNr <> customerNumber Then Continue
			
			Dim artikelen As List = colorders.Get("artikelen")
			
			
			If lblRemark.Text = "" Then
				lblRemark.Text = opm
			End If
			
			If currOrderNumber = "" Or currOrderNumber <> ordernr Then
				Dim itemCount As Int = 0
				'****Count items
				For Each colartikelen As Map In artikelen
					itemCount = itemCount + 1
				Next
				currOrderNumber = ordernr
				clvArticle.Add(CreateOrderNrPanel(ordernr, NumberFormat(itemCount, 3, 0)), "")
			End If
			
			
'			Dim tel1 As String = colorders.Get("tel1")
'			Dim tel2 As String = colorders.Get("tel2")
'			Dim contant As Int = colorders.Get("contant")
'			Dim bestordn As String = colorders.Get("bestordn")
'			Dim bedrag As Double = colorders.Get("bedrag")
'			Dim icodes As Int = colorders.Get("icodes")
'			Dim woonplaats As String = colorders.Get("woonplaats")
'			Dim email3 As String = colorders.Get("email3")
'			Dim email2 As String = colorders.Get("email2")
'			Dim agfprijs As Int = colorders.Get("agfprijs")
'			Dim volgnr As Int = colorders.Get("volgnr")
'			Dim artikelen As List = colorders.Get("artikelen")
			
			Dim rowNumber As Int = 0
			For Each colartikelen As Map In artikelen
				rowNumber = rowNumber + 1
'				Dim tht As String = colartikelen.Get("tht")
'				Dim agf As Int = colartikelen.Get("agf")
'				Dim ver As Double = colartikelen.Get("ver")
'				Dim code As String = colartikelen.Get("code")
'				Dim volg As Int = colartikelen.Get("volg")
'				Dim btw As Double = colartikelen.Get("btw")
'				Dim org As Double = colartikelen.Get("org")
'				Dim artnr As String = colartikelen.Get("artnr")
'				Dim sort As String = colartikelen.Get("sort")
'				Dim pack As String = colartikelen.Get("pack")
'				Dim prijs As Double = colartikelen.Get("prijs")
'				Dim vervang As Int = colartikelen.Get("vervang")
'				Dim oms As String = colartikelen.Get("oms")
'				Dim geleverd As Double = colartikelen.Get("geleverd")
'				Dim gew As Int = colartikelen.Get("gew")
'				Dim emb As Int = colartikelen.Get("emb")
'				Dim prbtw As Double = colartikelen.Get("prbtw")
'				Dim statie As Double = colartikelen.Get("statie")
'				Dim afd As Int = colartikelen.Get("afd")
'				Dim besteld As Double = colartikelen.Get("besteld")
				Dim artnr As String = colartikelen.Get("artnr")
				Dim oms As String = colartikelen.Get("oms")
				Dim pack As String = colartikelen.Get("pack")
				clvArticle.Add(CreateArticlePanel(oms, artnr, pack, NumberFormat(rowNumber,3,0)), "")
			Next
'			Dim kopm As List = colorders.Get("kopm")
'			Dim retouren As List = colorders.Get("retouren")
'			Dim emballage As List = colorders.Get("emballage")
'			Dim bestnaam As String = colorders.Get("bestnaam")
'			Dim land As String = colorders.Get("land")
'			Dim adres As String = colorders.Get("adres")
'			Dim prijzen As Int = colorders.Get("prijzen")
'			Dim ordernr As Int = colorders.Get("ordernr")
'			Dim email As String = colorders.Get("email")
'			Dim email5 As String = colorders.Get("email5")
'			Dim email4 As String = colorders.Get("email4")
'			Dim mancos As List = colorders.Get("mancos")
'			Dim postcode As String = colorders.Get("postcode")
'			Dim naam As String = colorders.Get("naam")
'			Dim geenemb As Int = colorders.Get("geenemb")
'			Dim done As Int = colorders.Get("done")
'			Dim opm As String = colorders.Get("opm")
'			Dim maand As List = colorders.Get("maand")
'			For Each colmaand As Map In maand
'				Dim ean As String = colmaand.Get("ean")
'				Dim btw As Double = colmaand.Get("btw")
'				Dim price As Double = colmaand.Get("price")
'				Dim artnr As Int = colmaand.Get("artnr")
'			Next
'			Dim eind As String = colorders.Get("eind")
'			Dim klantNr As Int = colorders.Get("klantnr")
'			Dim begin As String = colorders.Get("begin")
		Next
'		Dim naam As String = colroot.Get("naam")
'		Dim user As String = colroot.Get("user")
	Next
	
	
End Sub

Private Sub CreateOrderNrPanel(orderNr As String, itemCount As String) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, clvArticle.AsView.Width, 30dip)
	pnl.LoadLayout("pnlOrderOrderNr.bal")
	
	lblOrderNr.Text = $"Ordernummer ${GenFunctions.FormatOrderNr(orderNr)} [ ${itemCount} items ]"$
	
	Return pnl
End Sub

Private Sub CreateArticlePanel(oms As String, artnr As String, pack As String, rowNumber As String) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, clvArticle.AsView.Width, 75dip)
	pnl.LoadLayout("pnlOrderArticle")
	
	lblArticleName.Text = oms
	lblARticleQuantity.Text = 1
	lblArticleMetadata.Text = $"${GenFunctions.FormatArticleNumber(artnr)} | ${pack}"$
	lblArtRowNr.Text = rowNumber
	
	Return pnl
End Sub
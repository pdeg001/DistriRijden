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
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("customerOrderMain")
	
	GetButtonPanelDimensions
	CreateNavButtons
	
	
	orderTab.LoadLayout("tabLeveringInfo", "")
	orderTab.LoadLayout("tabOrder", "")

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetButtonPanelDimensions
	pnlNavButtonsHeight = pnlNavButtons.Height
	pnlNavButtonsWidth = pnlNavButtons.Width
	navButtonHeight = pnlNavButtonsHeight/5
	
	Log($"button panel heigth : ${pnlNavButtonsHeight}
	button panel width : ${pnlNavButtonsWidth}
	button height : ${navButtonHeight}"$)
End Sub

Private Sub CreateNavButtons
	Dim top As Int = 0
	
	'lever info
	top = CreateNavLabel("LeverInfo", "Leverings Info", top)
	'Orders
	top = CreateNavLabel("Orders", "Orders", top)
	'Retour emballage
	top = CreateNavLabel("RetourEmballage", "Retour emballage", top)
	'Retouren
	top = CreateNavLabel("Retouren", "Retouren", top)
	'Opmerking
	top = CreateNavLabel("Opmerking", "Opmerking", top)
End Sub

Private Sub CreateNavLabel (event As String, buttonText As String, top As Int) As Int
	Dim pnl As B4XView = xui.CreatePanel(event)
	pnl.SetLayoutAnimated(0, 0, 0, pnlNavButtonsWidth, navButtonHeight)
	pnl.LoadLayout("customerNaveButton")

	lblActive.Tag = "isActive"
	lblCustomerNav.Text = buttonText
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
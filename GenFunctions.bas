B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10.7
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals

End Sub

'get address coords from https://nominatim.openstreetmap.org using passed address
'https://nominatim.openstreetmap.org/search/handelsstraat 1704A heerhugowaard?format=json&addressdetails=1&limit=1
Public Sub ParseAddressCoords(addressData As String) As Boolean
	Dim parser As JSONParser
	Dim gMapIntent As Intent
	
	parser.Initialize(addressData)
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
#region maybeUseThisLater		
'		Dim osm_id As Int = colroot.Get("osm_id")
'		Dim licence As String = colroot.Get("licence")
'		Dim boundingbox As List = colroot.Get("boundingbox")
'		For Each colboundingbox As String In boundingbox
'			
'			Log(colboundingbox)
'		Next
'		Dim address As Map = colroot.Get("address")
'		Dim country As String = address.Get("country")
'		Dim country_code As String = address.Get("country_code")
'		Dim town As String = address.Get("town")
'		Dim road As String = address.Get("road")
'		Dim amenity As String = address.Get("amenity")
'		Dim neighbourhood As String = address.Get("neighbourhood")
'		Dim postcode As String = address.Get("postcode")
'		Dim house_number As String = address.Get("house_number")
'		Dim state As String = address.Get("state")
'		Dim region As String = address.Get("region")
'		Dim importance As Double = colroot.Get("importance")
'		Dim icon As String = colroot.Get("icon")
'		Dim display_name As String = colroot.Get("display_name")
'		Dim Type As String = colroot.Get("type")
'		Dim osm_type As String = colroot.Get("osm_type")
'		Dim class As String = colroot.Get("class")
'		Dim place_id As Int = colroot.Get("place_id")
#end region
		Dim lon As String = colroot.Get("lon")
		Dim lat As String = colroot.Get("lat")
	Next
	
	If lon.Length > 0 Then
		Dim uri As String = $"geo:${lat}, ${lon}?q=${lat}, ${lon},18z/data=!5m1!1e1"$
		gMapIntent.Initialize(gMapIntent.ACTION_VIEW,uri)
		gMapIntent.SetComponent("googlemaps")
		StartActivity(gMapIntent)
		Return True
	Else
		createCustomToast("Kan locatie niet bepalen", Colors.Red)
		Return False
	End If
	
	
End Sub

Sub createCustomToast(txt As String, color As String)
	Dim cs As CSBuilder
	cs.Initialize.Typeface(Typeface.LoadFromAssets("galanogrotesquemedium.ttf")).Color(Colors.White).Size(16).Append(txt).PopAll
	ShowCustomToast(cs, False, color)
End Sub

Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	'uncomment to show toast in the center:
	'  toast.RunMethod("setGravity", Array( _
	' Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
End Sub

Sub FormatOrderNr(orderNr As String) As String
	If orderNr.Length < 6 Then orderNr = $"0${orderNr}"$
	Return $"${orderNr.SubString2(0,3)}.${orderNr.SubString2(3,6)}"$
End Sub

Sub FormatArticleNumber(articleNr As String) As String
	If articleNr.Length < 7 Then articleNr = $"0${articleNr}"$
	Return $"${articleNr.SubString2(0,2)}.${articleNr.SubString2(2,5)}.${articleNr.SubString2(5,7)}"$
End Sub

Sub FormatCustomerNumber(customerNr As String) As String
	if customerNr = "" then Return ""
	If customerNr.Length < 6 Then customerNr = $"0${customerNr}"$
	Return $"${customerNr.SubString2(0,3)}.${customerNr.SubString2(3,6)}"$
End Sub

Sub CopyFolder(Source As String, targetFolder As String)
	If File.Exists(targetFolder, "") = False Then File.MakeDir(targetFolder, "")
	For Each f As String In File.ListFiles(Source)
		If File.IsDirectory(Source, f) Then
			CopyFolder(File.Combine(Source, f), File.Combine(targetFolder, f))
			Continue
		End If
		File.Copy(Source, f, targetFolder, f)
	Next
End Sub

Sub DeleteFolder (folder As String)
	For Each f As String In File.ListFiles(folder)
		If File.IsDirectory(folder, f) Then
			DeleteFolder(File.Combine(folder, f))
		End If
		File.Delete(folder, f)
	Next
End Sub

Sub CopyDevRoutes As ResumableSub
	Dim devRoutePath As String = File.DirAssets
	
	For Each f As String In File.ListFiles(devRoutePath)
		If f.StartsWith("route") And f.EndsWith(".txt") Then
			File.Copy(File.DirAssets, f, Starter.routesFolder, f)
		End If
	Next
	
	Return True
End Sub
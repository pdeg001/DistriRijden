B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.7
@EndOfDesignText@
Sub Class_Globals
	Private FTP As FTP
	Private FtpArticleFolder As String = "/user_jongens/data"
	Private localArticleFolder As String = Starter.filesFolder&"/article/"
	Private fileName As String = "artikel.json"
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	If File.Exists("", localArticleFolder) = False Then
		File.MakeDir("", localArticleFolder)
	End If
End Sub

Public Sub GetArticles As ResumableSub
	FTP.Initialize("FTP", "apps.distridata.nl", 21, "leverapp", "9OaiP6BA")
	FTP.PassiveMode = True
	FTP.TimeoutMs = 4*1000
	
'	wait for (FTP.List(FtpArticleFolder)) Complete (ready As Boolean)
	FTP.List(FtpArticleFolder)
	wait for (ProcessArtikelJson) complete (ready As Boolean)
	Return True
End Sub

Sub FTP_ListCompleted (ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)As ResumableSub
'	Log(ServerPath)
	If Success = False Then
		Log(LastException)
	Else
		For i = 0 To Files.Length - 1
			If Files(i).Name.IndexOf("artikel.json") = -1 Then
				Continue
			Else
				FTP.DownloadFile(FtpArticleFolder &"/"& Files(i).Name, False, "", localArticleFolder&Files(i).Name)
				Wait For FTP_DownloadCompleted (ServerPath2 As String, Success As Boolean)
			End If
		Next
	End If
	FTP.Close
'	wait for (ProcessArtikelJson) complete (ready As Boolean)
Return True
End Sub

Sub FTP_DownloadCompleted (ServerPath As String, Success As Boolean) As ResumableSub
	If Success = False Then
		Log(LastException.Message)
		Return True
	End If
	Return True
End Sub

Private Sub ProcessArtikelJson As ResumableSub
	If File.Exists(localArticleFolder, fileName) = False Then
		Return True
	End If
	
	If Starter.sql.IsInitialized = False Then
		Starter.sql.Initialize(Starter.filesFolder, "distrrijden.db", False)
	End If
	
	Starter.sql.ExecNonQuery("DELETE FROM artikel")
	
	Dim qry As String = $"INSERT INTO artikel (artnr, omschrijving, alfa, pack, statie, ean1, ean2, ean3) 
	VALUES (?, ?, ?, ?, ?, ?, ?, ?)"$
	
	Starter.sql.BeginTransaction
	Dim parser As JSONParser
	parser.Initialize(File.ReadString(localArticleFolder, fileName))
	Dim root As Map = parser.NextObject
	Dim artikelen As List = root.Get("artikelen")
	For Each colartikelen As Map In artikelen
		Dim ean1 As String = colartikelen.Get("ean1")
		Dim oms As String = colartikelen.Get("oms")
		Dim artnr As Int = colartikelen.Get("artnr")
		Dim alfa As String = colartikelen.Get("alfa")
		Dim pack As String = colartikelen.Get("pack")
		Dim statie As Int = colartikelen.Get("statie")
		Dim ean3 As String = colartikelen.Get("ean3")
		Dim ean2 As String = colartikelen.Get("ean2")
		
		Starter.sql.ExecNonQuery2(qry, Array As String(artnr, oms, alfa, pack, statie, ean1, ean2, ean3))
		'Log($"${artnr} ${oms}"$)
	Next
	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
'	Dim emballage As List = root.Get("emballage")
'	For Each colemballage As Map In emballage
'		Dim oms As String = colemballage.Get("oms")
'		Dim artnr As Int = colemballage.Get("artnr")
'		Dim toon As Int = colemballage.Get("toon")
'		Dim prijs As Double = colemballage.Get("prijs")
'	Next
'	Dim reden As List = root.Get("reden")
'	For Each colreden As String In reden
'	Next
	
	Return True
End Sub
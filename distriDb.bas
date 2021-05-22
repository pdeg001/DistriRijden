B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.7
@EndOfDesignText@
Sub Class_Globals
	Private sql As SQL
	Private qry As String
	Private rs As ResultSet
End Sub

Public Sub Initialize
	sql = Starter.sql
End Sub

Private Sub IsDbInitialized
	If Starter.sql.IsInitialized = False Then
		Starter.sql.Initialize(Starter.filesFolder, "distrrijden.db", False)
	End If
End Sub



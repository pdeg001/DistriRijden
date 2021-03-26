B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.7
@EndOfDesignText@
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Private Sub IsDbInitialized
	If Starter.sql.IsInitialized = False Then
		Starter.sql.Initialize(Starter.filesFolder, "distrrijden.db", False)
	End If
End Sub
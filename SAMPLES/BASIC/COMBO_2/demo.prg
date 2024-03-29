#Include "minigui.ch"

* When ITEMSOURCE property is set to a fieldname, 'Value' property 
* uses the physical record number, as in browse.
* If you set the VALUESOURCE property to a fieldname, its containt is
* returned instead the physical record number.

Function Main() 		

	DEFINE WINDOW Form_1			;
		AT 0,0				;
		WIDTH 365			;  
		HEIGHT 120			;
		TITLE "Exemplos ComboBox 1"	;		
		MAIN				;      
		NOMAXIMIZE			;
		NOSIZE				;
		ON INIT OpenTables()		;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU
			DEFINE POPUP '&Test'
				MENUITEM 'Get Value' ACTION MsgInfo( Str ( Form_1.Combo_1.Value ) )
				MENUITEM 'Set Value' ACTION Form_1.Combo_1.Value := 2
				MENUITEM 'Refresh' ACTION Form_1.Combo_1.Refresh
				MENUITEM 'Item Content' ACTION MsgInfo ( Form_1.Combo_1.DisplayValue )
			END POPUP
		END MENU

		@010,010 COMBOBOX Combo_1		;
			ITEMSOURCE CIDADES->DESCRICAO	; 
			VALUE 5				;
			WIDTH 200 HEIGHT 100		;
			FONT "Arial" SIZE 9		;
			TOOLTIP "Combo Cidades" 

	END WINDOW		

	CENTER WINDOW   Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Procedure Opentables()

	Use Cidades Alias Cidades Shared New
	Index On Field->Descricao To Cidades1

Return

Procedure CloseTables()

	Use
	Ferase("Cidades1.ntx")

Return

#SingleInstance, Force
#NoEnv

;---------Make Sample Source----------

data1a := "TitleOne"
data2a := "Second Title"
data3a := "Header 3"
data4a := "4th Header"
data5a := "A Title"

data1b := "What??????????????"
data2b := "Nothing to see here!"
data3b := "A quick brown fox jumped over the lazy dog."
data4b := "Hello, world"
data5b := "Testing one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen"

data1c := "Hello"
data2c := "Nothing to see here either!"
data3c := "A banana fruit jumped over the lazy bowl"
data4c := "Hello, you!"
data5c := "Testing one two three four five six seven eight nine ten eleven twelve thirteen fourteen and end."

sourceArray1 := [data1a,data2a,data3a,data4a,data5a]
sourceArray2 := [data1b,data2b,data3b,data4b,data5b]
sourceArray3 := [data1c,data2c,data3c,data4c,data5c]

source := [sourceArray1,sourceArray2,sourceArray3]

;------------Set Params and Format Data------------

formatType := "grid" ; "simple"
cellCharLimit := 200
outputPageMaxCharWidth := 110

colWidthDic := dynamicCols(source,outputPageMaxCharWidth) ;{1:8,2:20,3:28,4:16,5:38} ; optional custom col widths

outVar := ""
outVar := formatData(source,outVar,colWidthDic,cellCharLimit,formatType)

;----------Make File------------

tempPath := A_ScriptDir "\outTest.txt"

If FileExist(tempPath)
	FileDelete,%tempPath%

FileAppend, %outVar%, %tempPath%
run, %tempPath%

;------------Exit------------------------

ESC::ExitApp

;------------Format Data Function------------

formatData(source,outVar,colWidthDic,cellCharLimit,formatType) {
	
	colDelim := " | "
			
	if (formatType = "grid")
		{
		dividerDelim := "-+-"
		for k, v in colWidthDic
			{
			headerUnderLine .= dividerDelim
			loop % v
				headerUnderLine .= "-"
			
			}
		headerUnderLine := SubStr(headerUnderLine,4)
		}
	
	if (formatType = "simple")
		headerUnderLine := ""
		dividerDelim := A_Space A_Space A_Space

	for rowNum, rowContent in source
		{
		
		tempDataLen := 0
		tempRowArray := {}
		isMaxRow := 1
		
		for columnNum, columnContent in rowContent
			{
			tempColumn := columnContent
			tempDataLen := StrLen(columnContent)
			tempMaxWidth := colWidthDic[columnNum]
			tempStartPos := 1
			
			tempFill := ""
			
			maxColCheck := ceil(tempDataLen/tempMaxWidth)
			
			if (maxColCheck > isMaxRow)
				isMaxRow := maxColCheck
			
			if (tempDataLen < cellCharLimit)
				{
				fillBy := cellCharLimit - tempDataLen
				Loop % fillBy
					tempFill .= A_Space
				
				columnContent := columnContent tempFill
				}
			else
				columnContent := SubStr(columnContent,1,cellCharLimit)
			
			tempDataLen := StrLen(columnContent)
			
			while (tempDataLen > tempMaxWidth)
				{
				tempDataSection := SubStr(columnContent,tempStartPos,tempMaxWidth)
		
				tempColumn := SubStr(columnContent,tempStartPos)
				tempDataLen := StrLen(tempColumn)
				
				tempStartPos += tempMaxWidth
				
				tempRowArrayIndex := floor(tempStartPos/tempMaxWidth)
				
				if (formatType = "grid")
					tempRowArray[tempRowArrayIndex] .= colDelim tempDataSection
				
				if (formatType = "simple")
					{
					if (tempRowArrayIndex = 1) && (rowNum != 1)
						tempRowArray[tempRowArrayIndex] .= colDelim tempDataSection
					else
						tempRowArray[tempRowArrayIndex] .= dividerDelim tempDataSection
					}
				}
			}
			
			Loop % isMaxRow
				outVar .= SubStr(tempRowArray[A_Index],4) "`n"
			
			if (rowNum != source.Length())
				outVar .= headerUnderLine "`n"

		}
	Return outVar
	}

;-------------------

dynamicCols(source,outputPageMaxCharWidth){

	totalCol := 0

	for e, r in source
		for i, c in r
			if (e = 1)
				totalCol++
	
	spacerCount := (totalCol - 1) * 3
	outputPageMaxCharWidth := outputPageMaxCharWidth - spacerCount
	
	if (totalCol = 0) || (outputPageMaxCharWidth < totalCol)
		return

	averageColWidth := floor(outputPageMaxCharWidth / totalCol)
	colWidthDic := {}
	
	for e, r in source
		for i, c in r
			colWidthDic[i] := averageColWidth
	
	return colWidthDic
	}
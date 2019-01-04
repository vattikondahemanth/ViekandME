private DataTable ConvertExcelToDataTable(string FilePath)
        {
            FileInfo fileread = new FileInfo(FilePath);
            ExcelPackage exlpakage = new ExcelPackage(fileread);
            ExcelWorksheet worksheet = exlpakage.Workbook.Worksheets[1];

            //Excel.Application xlApp = new Excel.Application();
            //Excel.Workbook xlWorkbook = xlApp.Workbooks.Open(FilePath, 0, true, 5, "", "", true, Excel.XlPlatform.xlWindows, "\t", false, false, 0, true, 1, 0);
            //Excel.Worksheet xlWorksheet = (Excel.Worksheet)xlWorkbook.Sheets[1];
            //Excel.Range xlRange = xlWorksheet.UsedRange;
            DataTable dt = new DataTable();
            int colCount = worksheet.Dimension.Columns;
            int rowCount = worksheet.Dimension.Rows;
            int startRow = ExcelTemplate[1].StartRow ?? 1;
            for (int i = 1; i <= rowCount; i++)
            {
                DataRow dr = dt.NewRow();
                for (int j = 1; j <= colCount; j++)
                {
                    if (i == startRow)
                    {
                        dt.Columns.Add(Convert.ToString(worksheet.Cells[i, j].Value.ToString().Trim()));
                    }
                    else
                    {
                        dynamic cellvalue = "";
                        try
                        {
                            if (worksheet.Cells[i, j].Value != null && !String.IsNullOrEmpty((worksheet.Cells[i, j].Value.ToString())))
                            {
                                if (worksheet.Cells[i, j].Style.Numberformat.Format == "mm-dd-yy")
                                {
                                    cellvalue = Convert.ToDateTime(worksheet.Cells[i, j].Value).ToString("MM/dd/yyyy").Trim();
                                }
                                if (worksheet.Cells[i, j].Style.Numberformat.Format == "General")
                                {
                                    cellvalue = worksheet.Cells[i, j].Value.ToString().Trim();
                                }
                                if (worksheet.Cells[i, j].Style.Numberformat.Format == "0%" || worksheet.Cells[i, j].Style.Numberformat.Format == "0.00%")
                                {
                                    cellvalue = Convert.ToDouble(worksheet.Cells[i, j].Value) * 100 + "%";
                                }
                                if (worksheet.Cells[i, j].Style.Numberformat.Format == "h:mm:ss")
                                {
                                    cellvalue = Convert.ToDateTime(worksheet.Cells[i, j].Value).ToString("HH:mm:ss").Trim();
                                }
                            }
                        }
                        catch (Exception e)
                        {

                            continue;
                        }
                       
                   
                       

                        dr[j - 1] = Convert.ToString(cellvalue);
                        
                    }
                }
                if (i != startRow) dt.Rows.Add(dr);

            }
            return dt;
          
 
        }

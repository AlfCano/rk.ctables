// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        
        var df = '';
        var raw_col = '';
        
        if (fullPath.indexOf('[[') > -1) {
            var parts = fullPath.split('[[');
            df = parts[0];
            var inner = parts[1].replace(']]', '');
            raw_col = inner.replace(/["']/g, ''); 
        } else if (fullPath.indexOf('$') > -1) {
            var parts = fullPath.split('$');
            df = parts[0];
            raw_col = parts[1];
        } else {
            raw_col = fullPath;
        }
        return { 
            df: df, 
            col: '\"' + raw_col + '\"', 
            raw_col: raw_col 
        };
    }
  
    var rows = getValue("ct_rows");
    var cols = getValue("ct_cols");
    var weight = getValue("ct_weight");
    
    // Stats
    var s_cases = getValue("stat_cases");
    var s_cpct = getValue("stat_cpct");
    var s_rpct = getValue("stat_rpct");
    
    // Options
    var tot_lbl = getValue("ct_total_lbl");
    var tot_pos = getValue("ct_pos_total");
    
    // 1. Parse Dataframe from Rows
    var varList = rows.split("\n");
    var dfName = "";
    var rowList = [];
    
    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        rowList.push(p.raw_col); 
    }
    
    // 2. Parse Cols
    var colList = [];
    if (cols != "") {
        var cList = cols.split("\n");
        for (var i = 0; i < cList.length; i++) {
            colList.push(parseVar(cList[i]).raw_col);
        }
    }
    
    // 3. Start building expss chain
    if (dfName == "") {
        var cmd = "";
    } else {
        var cmd = dfName + " %>% ";
        
        // 4. Tab Cells (Rows)
        cmd += "expss::tab_cells(" + rowList.join(", ") + ") %>% ";
        
        // 5. Tab Cols (Columns/Nesting)
        var total_syntax = "expss::total(label = \"" + tot_lbl + "\")";
        
        if (colList.length > 0) {
            var col_args = colList.join(", ");
            
            if (tot_pos == "before") {
                cmd += "expss::tab_cols(" + total_syntax + ", " + col_args + ") %>% ";
            } else if (tot_pos == "after") {
                cmd += "expss::tab_cols(" + col_args + ", " + total_syntax + ") %>% ";
            } else {
                cmd += "expss::tab_cols(" + col_args + ") %>% ";
            }
        } else {
             cmd += "expss::tab_cols(" + total_syntax + ") %>% ";
        }
        
        // 6. Weight
        if (weight != "") {
            cmd += "expss::tab_weight(" + weight + ") %>% ";
        }
        
        // 7. Statistics
        if (s_cases == "1") cmd += "expss::tab_stat_cases() %>% ";
        if (s_cpct == "1") cmd += "expss::tab_stat_cpct() %>% ";
        if (s_rpct == "1") cmd += "expss::tab_stat_rpct() %>% ";
        
        // 8. Finalize
        cmd += "expss::tab_pivot()";
    }
  
    echo("require(expss)\n");
    if(cmd != "") echo("preview_data <- " + cmd + "\n");
  
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(expss)){stop(" + i18n("Preview not available, because package expss is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(expss)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        
        var df = '';
        var raw_col = '';
        
        if (fullPath.indexOf('[[') > -1) {
            var parts = fullPath.split('[[');
            df = parts[0];
            var inner = parts[1].replace(']]', '');
            raw_col = inner.replace(/["']/g, ''); 
        } else if (fullPath.indexOf('$') > -1) {
            var parts = fullPath.split('$');
            df = parts[0];
            raw_col = parts[1];
        } else {
            raw_col = fullPath;
        }
        return { 
            df: df, 
            col: '\"' + raw_col + '\"', 
            raw_col: raw_col 
        };
    }
  
    var rows = getValue("ct_rows");
    var cols = getValue("ct_cols");
    var weight = getValue("ct_weight");
    
    // Stats
    var s_cases = getValue("stat_cases");
    var s_cpct = getValue("stat_cpct");
    var s_rpct = getValue("stat_rpct");
    
    // Options
    var tot_lbl = getValue("ct_total_lbl");
    var tot_pos = getValue("ct_pos_total");
    
    // 1. Parse Dataframe from Rows
    var varList = rows.split("\n");
    var dfName = "";
    var rowList = [];
    
    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        rowList.push(p.raw_col); 
    }
    
    // 2. Parse Cols
    var colList = [];
    if (cols != "") {
        var cList = cols.split("\n");
        for (var i = 0; i < cList.length; i++) {
            colList.push(parseVar(cList[i]).raw_col);
        }
    }
    
    // 3. Start building expss chain
    if (dfName == "") {
        var cmd = "";
    } else {
        var cmd = dfName + " %>% ";
        
        // 4. Tab Cells (Rows)
        cmd += "expss::tab_cells(" + rowList.join(", ") + ") %>% ";
        
        // 5. Tab Cols (Columns/Nesting)
        var total_syntax = "expss::total(label = \"" + tot_lbl + "\")";
        
        if (colList.length > 0) {
            var col_args = colList.join(", ");
            
            if (tot_pos == "before") {
                cmd += "expss::tab_cols(" + total_syntax + ", " + col_args + ") %>% ";
            } else if (tot_pos == "after") {
                cmd += "expss::tab_cols(" + col_args + ", " + total_syntax + ") %>% ";
            } else {
                cmd += "expss::tab_cols(" + col_args + ") %>% ";
            }
        } else {
             cmd += "expss::tab_cols(" + total_syntax + ") %>% ";
        }
        
        // 6. Weight
        if (weight != "") {
            cmd += "expss::tab_weight(" + weight + ") %>% ";
        }
        
        // 7. Statistics
        if (s_cases == "1") cmd += "expss::tab_stat_cases() %>% ";
        if (s_cpct == "1") cmd += "expss::tab_stat_cpct() %>% ";
        if (s_rpct == "1") cmd += "expss::tab_stat_rpct() %>% ";
        
        // 8. Finalize
        cmd += "expss::tab_pivot()";
    }
  
    if(cmd != "") {
        echo("custom_table <- " + cmd + "\n");
    } else {
        echo("stop(\"Please select at least one row variable.\")\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Custom Table Builder results")).print();	
	}
    if (typeof is_preview === "undefined" || !is_preview) {
        echo("rk.header(\"Custom Table\", level=3);\n");
        echo("print(expss::htmlTable(custom_table))\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var ctSaveObj = getValue("ct_save_obj");
		var ctSaveObjActive = getValue("ct_save_obj.active");
		var ctSaveObjParent = getValue("ct_save_obj.parent");
		// assign object to chosen environment
		if(ctSaveObjActive) {
			echo(".GlobalEnv$" + ctSaveObj + " <- custom_table\n");
		}	
	}

}


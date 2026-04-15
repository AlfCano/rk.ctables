local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.ctables",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin package for creating SPSS-style Custom Tables (Stacking and Nesting) using the 'expss' library.",
      version = "0.0.2", # FOR TRANSLATION FILES
      url = "https://github.com/AlfCano/rk.ctables",
      license = "GPL (>= 3)"
    )
  )

  # Menu Hierarchy: Analysis -> Custom Tables
  common_hierarchy <- list("analysis", "Custom Tables (expss)")

  # =========================================================================================
  # 2. JS Helper
  # =========================================================================================
  js_parse_helper <- "
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};

        var df = '';
        var raw_col = '';

        if (fullPath.indexOf('[[') > -1) {
            var parts = fullPath.split('[[');
            df = parts[0];
            var inner = parts[1].replace(']]', '');
            raw_col = inner.replace(/[\"']/g, '');
        } else if (fullPath.indexOf('$') > -1) {
            var parts = fullPath.split('$');
            df = parts[0];
            raw_col = parts[1];
        } else {
            raw_col = fullPath;
        }
        return {
            df: df,
            col: '\\\"' + raw_col + '\\\"',
            raw_col: raw_col
        };
    }
  "

  # =========================================================================================
  # COMPONENT 1: Custom Table Builder (MAIN PLUGIN)
  # =========================================================================================

  help_ctable <- rk.rkh.doc(
    title = rk.rkh.title(text = "Custom Tables (SPSS Style)"),
    summary = rk.rkh.summary(text = "Create complex hierarchical tables with stacking and nesting logic using 'expss'. equivalent to SPSS CTABLES."),
    usage = rk.rkh.usage(text = "Select Row variables (Stacked) and Column variables (Nested). Apply weights and select statistics.")
  )

  ct_selector <- rk.XML.varselector(id.name = "ct_selector")

  # Tab 1: Layout
  ct_rows <- rk.XML.varslot(label = "Rows (Stacked Variables)", source = "ct_selector", multi = TRUE, required = TRUE, id.name = "ct_rows")
  ct_cols <- rk.XML.varslot(label = "Columns (Grouping/Nesting)", source = "ct_selector", multi = TRUE, id.name = "ct_cols")
  ct_weight <- rk.XML.varslot(label = "Weight Variable (Optional)", source = "ct_selector", classes = "numeric", id.name = "ct_weight")

  # Tab 2: Statistics
  ct_stats <- rk.XML.col(
      rk.XML.text("Select statistics to calculate:"),
      rk.XML.cbox(label = "Counts (Cases)", value = "1", id.name = "stat_cases"),
      rk.XML.cbox(label = "Column Percent %", value = "1", chk = TRUE, id.name = "stat_cpct"),
      rk.XML.cbox(label = "Row Percent %", value = "1", id.name = "stat_rpct"),
      rk.XML.stretch()
  )

  # Tab 3: Options
  ct_total_label <- rk.XML.input(label = "Label for Total column", initial = "Total", id.name = "ct_total_lbl")
  ct_pos_total <- rk.XML.dropdown(label = "Total Position", options = list(
      "Before (Left/Top)" = list(val = "before"),
      "After (Right/Bottom)" = list(val = "after", chk = TRUE),
      "None" = list(val = "none")
  ), id.name = "ct_pos_total")

  ct_save <- rk.XML.saveobj(label = "Save table as", chk = FALSE, initial = "custom_table", id.name = "ct_save_obj")
  ct_preview <- rk.XML.preview(mode = "data")

  dialog_ctable <- rk.XML.dialog(
    label = "Custom Tables Builder",
    child = rk.XML.row(
        ct_selector,
        rk.XML.col(
            rk.XML.tabbook(tabs = list(
                "Layout" = rk.XML.col(ct_rows, ct_cols, ct_weight),
                "Statistics" = rk.XML.col(ct_stats),
                "Options" = rk.XML.col(ct_total_label, ct_pos_total, ct_save, ct_preview)
            ))
        )
    )
  )

  js_body_ctable <- paste0(js_parse_helper, '
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
    var varList = rows.split("\\n");
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
        var cList = cols.split("\\n");
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
        var total_syntax = "expss::total(label = \\\"" + tot_lbl + "\\\")";

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
  ')

  js_calc_ctable <- paste0(js_body_ctable, '
    if(cmd != "") {
        echo("custom_table <- " + cmd + "\\n");
    } else {
        echo("stop(\\\"Please select at least one row variable.\\\")\\n");
    }
  ')

  js_preview_ctable <- paste0(js_body_ctable, '
    echo("require(expss)\\n");
    if(cmd != "") echo("preview_data <- " + cmd + "\\n");
  ')

  # For printout, use expss::htmlTable for pretty HTML in Output Window
  js_print_ctable <- '
    if (typeof is_preview === "undefined" || !is_preview) {
        echo("rk.header(\\"Custom Table\\", level=3);\\n");
        echo("print(expss::htmlTable(custom_table))\\n");
    }
  '

  # NOTE: Defined but NOT included in 'components' list (Main Plugin)
  component_ctable <- rk.plugin.component(
    "CustomTableBuilder",
    xml = list(dialog = dialog_ctable),
    js = list(require="expss", calculate = js_calc_ctable, preview = js_preview_ctable, printout = js_print_ctable),
    hierarchy = common_hierarchy,
    rkh = list(help = help_ctable)
  )

  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    # Main Plugin defined here
    xml = list(dialog = dialog_ctable),
    js = list(
        require = "expss",
        calculate = js_calc_ctable,
        printout = js_print_ctable,
        preview = js_preview_ctable
    ),
    rkh = list(help = help_ctable),
    # Empty components list to avoid duplication
    components = list(),
    pluginmap = list(
        name = "Custom Table Builder",
        hierarchy = common_hierarchy
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.ctables' (v0.0.1) generated successfully.\n")
  cat("To complete installation:\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})

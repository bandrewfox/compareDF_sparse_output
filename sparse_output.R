#' @title Convert to sparse format
#' @description Each row of the output sparse data frame has an individual value which has
#' been changed. This is useful for really wide data frames when only a few values
#' have changed. It can be easier in some cases to have a table of changes. The
#' output columns are: group.name, change_type, column, old_value, new_value
#' @param comparison_output Output from the comparison Table functions
#' @param orig_group_cols Vector of the same column names use used in group_col
#' when making the comparison_output object.
#' @export
create_sparse_output <- function(comparison_output, orig_group_cols=NULL) {
  # find all the changes and changes them to a simple table for non data scientists
  out.rows = NULL

  ctable = comparison_output

  group_col = ctable$group_col
  new_marker = ctable$change_markers[1]
  old_marker = ctable$change_markers[2]

  # make sure orig_group_cols kind of matches the original group_col as best as we can infer
  if (! is.null(orig_group_cols)) {
    if (length(orig_group_cols) == 1) {
      stop("Error: can only use orig_group_cols if you have more than one column name to specify")
    }
    if (! all(orig_group_cols %in% colnames(ctable$comparison_df))) {
      stop(paste("Error: not all columns specified in orig_group_cols are valid:",
                 paste(orig_group_cols[! orig_group_cols %in% colnames(ctable$comparison_df)], collapse=",")))
    }
    if (group_col != "grp") {
      stop(paste("Error: you requested multiple orig_group_cols, but
                 the saved group_col is not 'grp' which implies the saved
                 ctable may not have used orig_group_cols"))
    }

    # make a df with the grp and build the group.name
    group.name.df = ctable$comparison_df[, c("grp", orig_group_cols)]
    group.name.df = group.name.df[! duplicated(group.name.df$grp),]
    group.name.df$group.name = apply(group.name.df[, orig_group_cols], 1, paste, collapse = ",")

    # make sure that the values for each group.name are unique
    if (any(duplicated(group.name.df$group.name))) {
      stop("Error: the column names made by pasting orig_group_cols
           do not match the group ids uniquely. This usually means that
           the 'orig_group_cols' do not match the 'group_col' when you
           originally made the ctable.")
    }
  }

  # find all the changes
  changed_groups = ctable$change_count[ctable$change_count$changes >= 1, group_col]
  df.data = ctable$comparison_df
  df.markers = ctable$comparison_table_diff
  for (cur.group in changed_groups) {
    # get all the columns in this group with a change

    # first find the rows in the comparison_df table
    rows.mask = df.data[,group_col] == cur.group
    cur.rows.data = df.data[rows.mask,]
    cur.rows.markers = df.markers[rows.mask,]

    # then check the comparison_table_diff for the old and new values
    for (cur.colname in colnames(ctable$comparison_table_diff)) {
      if (! cur.colname %in% c(group_col, "chng_type")) {
        rows.with.new.data = which(cur.rows.markers[,cur.colname] == new_marker)
        rows.with.old.data = which(cur.rows.markers[,cur.colname] == old_marker)

        if (length(rows.with.new.data) > 0) {
          # get the old and new values
          new.data = paste(cur.rows.data[rows.with.new.data, cur.colname], collapse=",")
          old.data = paste(cur.rows.data[rows.with.old.data, cur.colname], collapse=",")
        } else {
          # no changes in this column
          new.data = NULL
          old.data = NULL
        }

        if (!is.null(new.data)) {
          one_row = data.frame(group=cur.group, change_type="value_change", column=cur.colname,
                               old_value=old.data, new_value=new.data,
                               stringsAsFactors = F)
          if (is.null(out.rows)) {
            out.rows = one_row
          } else {
            out.rows = rbind(out.rows, one_row)
          }
        }
      }
    }
  }

  # get all the added rows
  new_groups = ctable$change_count[ctable$change_count$additions >= 1, group_col]
  if (length(new_groups) > 0) {
    new_or_removed_rows = data.frame(group=new_groups, change_type="row_added", column=NA, old_value=NA, new_value=NA, stringsAsFactors = F)
    if (is.null(out.rows)) {
      out.rows = new_or_removed_rows
    } else {
      out.rows = rbind(out.rows, new_or_removed_rows)
    }
  }

  # and the deleted rows
  removed_groups = ctable$change_count[ctable$change_count$removals >= 1, group_col]
  if (length(removed_groups) > 0) {
    new_or_removed_rows = data.frame(group=removed_groups, change_type="row_deleted", column=NA, old_value=NA, new_value=NA, stringsAsFactors = F)
    if (is.null(out.rows)) {
      out.rows = new_or_removed_rows
    } else {
      out.rows = rbind(out.rows, new_or_removed_rows)
    }
  }

  if (! is.null(out.rows)) {
    if (!is.null(orig_group_cols) & length(orig_group_cols) > 1) {
      # if orig_group_cols has multiple column names, then rename the groups
      merged.df = merge(group.name.df[,c("grp", "group.name")], out.rows,
                        by.x="grp", by.y=colnames(out.rows)[1], all.y=T)

      # copy back to out.rows
      out.rows = merged.df[order(merged.df$grp),]

      # also rename the column name (should be column 2)
      colnames(out.rows)[which(colnames(out.rows) == "group.name")] = paste(orig_group_cols, collapse=":")
    } else {
      colnames(out.rows)[1] = group_col
    }
  }

  return(out.rows)
}

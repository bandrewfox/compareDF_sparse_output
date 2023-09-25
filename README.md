# compareDF_sparse_output
Make a table of changes from a compareDF object.

A new type of output from a standard compareDF object.

Example usage:

    library(compareDF)
    source("sparse_output.R")

    # if you are using a single column as the key
    ctable_student = compare_df(results_2011, results_2010, c("Student"))
    create_sparse_output(ctable_student)

    # if you are using a multiple columns as the key
    ctable_student_div = compare_df(results_2011, results_2010, c("Student", "Division"))
    # then you need to use those same column names in the function call
    create_sparse_output(ctable_student_div, orig_group_cols = c("Student", "Division"))

The output for the second one is:

       grp Student:Division  change_type     column old_value new_value
    1    1         Akshay,A value_change Discipline         B         A
    2    2         Ananth,A value_change      Maths        99        78
    3    3          Bulla,B value_change      Maths        84        97
    4    4        DIkChik,B    row_added       <NA>      <NA>      <NA>
    5    5        Dhakkan,B  row_deleted       <NA>      <NA>      <NA>
    6    6          Isaac,A value_change Discipline         B         A
    7    7           Jojy,B value_change      Maths        67        99
    8    8          Katti,B value_change      Maths        90        78
    9   10         Mugger,B  row_deleted       <NA>      <NA>      <NA>
    10  11          Rohit,A value_change      Maths        95        94
    11  11          Rohit,A value_change Discipline         C         D
    12  12          Rohit,B    row_added       <NA>      <NA>      <NA>
    13  13           Venu,A value_change      Maths        99       100
    14  14         Vikram,B    row_added       <NA>      <NA>      <NA>
    15  15        Vishwas,A value_change      Maths        93        82
    16  15        Vishwas,A value_change Discipline         A         B



See conversation over here for alternatives to using this function:
https://github.com/alexsanjoseph/compareDF/issues/53

**Is your feature request related to a problem? Please describe.**
I was using compareDF to compare data frames, but my DFs were more than 50 columns wide and 250+ rows. I wanted to have a easy way to see all the changes across the data frames without trying to carefully look for different colored text in the very wide html output.

**Describe the solution you'd like**
The desired output format would be "sparse" -- which means that each change of a value would be a row in the output table. So then I could see all the changes. The column names of the output table could be: id/group, change_type, column_with_change, old_value, new_value. I am aiming to have a "change table" where each row refers to a single element in the data frame which was changed from the old to new version. That is why I am calling it "sparse" -- since it is just picking out various elements of interest from the full data frame. I can imagine a large table with a couple changes per row, and this sparse format would be much more concise.

For context to my process, the next step in my data reconciliation process is to save this "change table" to Excel and then add a new column called "comment" and then the user who is responsible for the data can document why they made each specific change from the prior version so that we can track all changes and the reasons.



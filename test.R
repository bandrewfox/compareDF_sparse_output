library(compareDF)
source("sparse_output.R")

context("fnsOutputs: Sparse Output")

old_df = data.frame(var1 = c("A", "B", "C", "C"),
                    var2 = c("Z", "X", "X", "W"),
                    val1 = c(1, 2, 3, 4),
                    val2 = c("A1", "B1", "C1", "C1")
)

new_df = data.frame(var1 = c("A", "B", "C", "D", "F"),
                    var2 = c("Z", "X", "X", "X", "X"),
                    val1 = c(1, 2, 3, 5, 6),
                    val2 = c("A1", "B1", "C2", "D2", "F2")
)

compare_output = compareDF::compare_df(new_df, old_df, 'var1')

test_that("compare_df: 1 column in group_col", {
  out = create_sparse_output(compare_output)
  expect_true(all(out[1,] == c("C", "value_change", "var2", "X,W", "X")))
  expect_true(all(out[2,] == c("C", "value_change", "val1", "3,4", "3")))
  expect_true(all(out[3,] == c("C", "value_change", "val2", "C1,C1", "C2")))
  expect_true(all(out[4,] == c("D", "row_added", NA, NA, NA), na.rm=T))
  expect_true(all(out[5,] == c("F", "row_added", NA, NA, NA), na.rm=T))
  expect_true(all(out[6,] == c("C", "row_deleted", NA, NA, NA), na.rm=T))
})

compare_output = compareDF::compare_df(new_df, old_df, c('var1', 'var2'))

test_that("compare_df: 2 columns in orig_group_cols", {
  out = create_sparse_output(compare_output, orig_group_cols = c('var1', 'var2'))
  expect_true(all(out[1,] == c(3, "C,W", "row_deleted", NA, NA, NA), na.rm=T))
  expect_true(all(out[2,] == c(4, "C,X", "value_change", "val2", "C1", "C2")))
  expect_true(all(out[3,] == c(5, "D,X", "row_added", NA, NA, NA), na.rm=T))
  expect_true(all(out[4,] == c(6, "F,X", "row_added", NA, NA, NA), na.rm=T))
})

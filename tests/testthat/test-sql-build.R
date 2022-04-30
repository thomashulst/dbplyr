test_that("rendering table wraps in SELECT x", {
  out <- copy_to_test("sqlite", tibble(x = 1), name = "test-sql-build")
  expect_snapshot(out %>% sql_render())
  expect_equal(out %>% collect(), tibble(x = 1))

  out <- tbl(src_test("sqlite"), "bogus", vars = c("do", "not", "exist"))
  expect_snapshot(out %>% sql_render())
})

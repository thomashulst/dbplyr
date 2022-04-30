# rendering table wraps in SELECT x

    Code
      out %>% sql_render()
    Output
      <SQL> SELECT `x`
      FROM `test-sql-build`

---

    Code
      out %>% sql_render()
    Output
      <SQL> SELECT `do`, `not`, `exist`
      FROM `bogus`


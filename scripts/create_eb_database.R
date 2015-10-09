#### Create SQLite database, copy DF to it
eb_sql <- src_sqlite("data_clean/eb.sqlite", TRUE)

copy_to(eb_sql, df, temporary = FALSE, name = "ZA0986")

tbl(eb_sql, "ZA0986")

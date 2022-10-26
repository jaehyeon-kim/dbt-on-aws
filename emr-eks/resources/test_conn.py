from pyhive import hive
import pandas as pd

conn = hive.connect(
    host="af492d74a126f4d4b84a3140159b1ea0-2028170164.ap-southeast-2.elb.amazonaws.com",
    port=10001,
    username="hadoop",
    auth=None
    )

pd.read_sql(con=conn, sql="show databases")

pd.read_sql(con=conn, sql="select * from imdb_analytics.titles limit 10")

conn.close()

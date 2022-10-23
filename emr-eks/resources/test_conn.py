from pyhive import hive
import pandas as pd

conn = hive.connect(
    host="a1f8716d2f8ca47a9b8d6d90a35394b3-1445308496.ap-southeast-2.elb.amazonaws.com",
    port=10001,
    username="hadoop",
    auth=None
    )

conn.close()

pd.read_sql(con=conn, sql="show databases")

conn = hive.connect(
    host="a1f8716d2f8ca47a9b8d6d90a35394b3-1445308496.ap-southeast-2.elb.amazonaws.com",
    port=10001,
    username="hadoop",
    database="tripdata",
    auth=None
    )

pd.read_sql(con=conn, sql="select * from ny_taxi limit 10")
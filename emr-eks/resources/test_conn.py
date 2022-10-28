from pyhive import hive
import pandas as pd

conn = hive.connect(
    host="acb9357efbcf641a6b05c63f856c7a29-1443663997.ap-southeast-2.elb.amazonaws.com",
    port=10001,
    username="hadoop",
    auth=None
    )
print(pd.read_sql(con=conn, sql="show databases"))
conn.close()

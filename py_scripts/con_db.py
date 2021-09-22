def con_db(query: str):
    from psycopg2 import connect
    from psycopg2.extras import DictCursor
    try:
        con = connect(
            host="192.168.100.3",
            database="Proyecto1GIS",
            user="postgres",
            password="postgres",
            cursor_factory=DictCursor)

        cur = con.cursor()
        cur.execute(query)
        retornar = cur.fetchall()
    except:
        retornar = None
    finally:
        con.close()
        #cur.close()
        return retornar

if(__name__ == '__main__'):
    print(con_db('SELECT cultivo FROM productos GROUP BY cultivo ORDER BY cultivo asc'))
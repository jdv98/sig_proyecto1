def con_db(query: str):
    from psycopg2 import connect
    from psycopg2.extras import DictCursor
    from configparser import ConfigParser
    from qgis.core import QgsProject
    try:
        cp=ConfigParser()
        cp.read(QgsProject.instance().readPath("./")+'/database.ini')
        con = connect(
            host=cp._sections['postgresql']['host'],
            database=cp._sections['postgresql']['database'],
            user=cp._sections['postgresql']['user'],
            password=cp._sections['postgresql']['password'],
            cursor_factory=DictCursor)

        cur = con.cursor()
        cur.execute(query)
        retornar = cur.fetchall()
        cur.close()
        con.close()
    except:
        retornar = [[""]]
    finally:
        return retornar

if(__name__ == '__main__'):
    print(con_db('SELECT cultivo FROM productos GROUP BY cultivo ORDER BY cultivo asc'))
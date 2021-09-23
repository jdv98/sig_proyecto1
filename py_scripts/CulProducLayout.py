from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *


class CulProduc(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.build()
    
    def build(self):
        self.combo_cultivos = self.query_fill_combo(QComboBox(self.widgetParent),'SELECT cultivo FROM productos GROUP BY cultivo ORDER BY cultivo asc')
        self.addWidget(self.combo_cultivos)

    def query_fill_combo(self,combo_box,query : str):
        from .con_db import con_db
        results =con_db(query)
        
        try:
            for result in results:
                combo_box.addItem(result[0])
        except:
            pass
        finally:
            return combo_box
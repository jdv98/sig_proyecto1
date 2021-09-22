from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *


class Gui(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
    
    def build(self):
        self.window =  QWidget()
        self.layout =  QVBoxLayout()
        self.window.setLayout(self.layout)
        self.window.show()
        self.setCentralWidget(self.window)
        self.combo_cultivos = self.query_fill_combo(QComboBox(self),'SELECT cultivo FROM productos GROUP BY cultivo ORDER BY cultivo asc')
        self.layout.addWidget(self.combo_cultivos)

    def closeEvent(self, event):
        for i in reversed(range(self.layout.count())): 
            self.layout.itemAt(i).widget().deleteLater()
        self.window.close()
        self.close()

    def showEvent(self,event):
        self.build()

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
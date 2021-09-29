import sys
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *

class Ingredientes(QHBoxLayout):
    def __init__(self,widgetParent,cultivo):
        QHBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.cultivo=cultivo
        self.build()
    
    def build(self):
        self.combo_cultivos = self.query_fill_combo(QComboBox(self.widgetParent),"SELECT ingredientes('"+self.cultivo+"')")
        self.qspinbox=QDoubleSpinBox(self.widgetParent)
        self.qspinbox.setSingleStep(.01)
        self.button=QPushButton("--", self.widgetParent)
        self.button.setFixedWidth(20)


        self.addWidget(self.combo_cultivos)
        self.addWidget(self.qspinbox)
        self.addWidget(self.button)

        self.button.clicked.connect(self.delete)
        self.combo_cultivos.currentTextChanged.connect(self.combobox_change_func)

    def query_fill_combo(self,combo_box,query : str):
        from .con_db import con_db
        results =con_db(query)
        combo_box.addItem("")
        
        try:
            for result in results:
                combo_box.addItem(result[0])
        except:
            pass
        finally:
            return combo_box
    def combobox_change_func(self,value):
        from .con_db import con_db
        results=con_db("SELECT * FROM dosis_ingredientes('"+self.cultivo+"','"+value+"')")[0]
        self.qspinbox.setMinimum(results[0])
        self.qspinbox.setValue(results[1])
        self.qspinbox.setMaximum(results[2])
        self.qspinbox.setSuffix(results[3])
    def delete(self):
        for i in reversed(range(self.count())): 
                self.itemAt(i).widget().deleteLater()
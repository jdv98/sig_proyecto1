import sys
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
import re

class Ingredientes(QHBoxLayout):
    def __init__(self,widgetParent,parentLayout):
        QHBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.parentLayout=parentLayout
        self.cultivo=parentLayout.value
        self.build()
    
    def build(self):#Agrega todos los widgets y funciones a los mismos
        self.combo_ingredientes = self.query_fill_combo(QComboBox(self.widgetParent),"SELECT ingredientes('"+self.cultivo+"')")
        self.qspinbox=QDoubleSpinBox(self.widgetParent)
        self.qspinbox.setSingleStep(.01)
        self.button=QPushButton("--", self.widgetParent)
        self.button.setFixedWidth(20)

        self.addWidget(self.combo_ingredientes)
        self.addWidget(self.qspinbox)
        self.addWidget(self.button)

        self.button.clicked.connect(self.delete)
        self.combo_ingredientes.currentTextChanged.connect(self.combobox_change_func)

    ##Llena un combobox
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

    ##Obtiene la dosis y el tipo de medida
    def combobox_change_func(self,value):
        if(self.combo_ingredientes.currentIndex()==0):
            return
        from .con_db import con_db
        self.dosis_medida=con_db("SELECT * FROM dosis_ingredientes('"+self.cultivo+"','"+value+"')")[0]
        self.qspinbox.setMinimum(self.dosis_medida[0])
        self.qspinbox.setValue(self.dosis_medida[1])
        self.qspinbox.setMaximum(self.dosis_medida[2])
        self.qspinbox.setSuffix(self.dosis_medida[3])

    ##Se elimina a si mismo al quitar los widgets que le componen
    def delete(self):
        self.parentLayout.ingredientes.remove(self) ##Se elimina de la lista de su padre
        for i in reversed(range(self.count())): 
                self.itemAt(i).widget().deleteLater()

    def obtenerInfo(self):
        if(self.combo_ingredientes.currentIndex()>0):
            dosis=self.qspinbox.value()
            if(re.search('ml/ha', self.dosis_medida[3], re.IGNORECASE) ): #Hace conversion de ml a litros
                dosis=dosis/1000
            return {'Ingrediente':self.combo_ingredientes.currentText(),'dosis':dosis}
        return None
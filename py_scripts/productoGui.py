from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .ingredientesGui import Ingredientes

class Producto(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.value=''
        self.ingredientes=[]
        self.build()
    
    def build(self):
        self.combo_cultivos = self.query_fill_combo(QComboBox(self.widgetParent),'SELECT * FROM cultivos()')
        self.combo_cultivos.currentTextChanged.connect(self.combobox_change_func)

        self.button_agregar=QPushButton('Agregar ingrediente',self.widgetParent)
        self.button_agregar.clicked.connect(self.agregarIngredientes)

        self.addWidget(self.combo_cultivos)
        self.addWidget(self.button_agregar)

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
        for ingrediente in self.ingredientes:
            for i in reversed(range(ingrediente.count())): 
                ingrediente.itemAt(i).widget().deleteLater()
        self.value=value
        self.agregarIngredientes()

    def agregarIngredientes(self):
        self.ingredientes.append(Ingredientes(self.widgetParent,self.value))
        self.insertLayout(self.count()-1,self.ingredientes[-1])

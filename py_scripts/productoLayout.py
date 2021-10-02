from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from qgis.core import Qgis
import qgis
from .ingredientesLayout import Ingredientes

class Producto(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.value=''
        self.ingredientes=[]
        self.build()
    
    def build(self): #agrega todos los widgets al layout
        self.label = QLabel(self.widgetParent)
        self.label.setText("Producto")
        self.addWidget(self.label)

        self.combo_cultivos = self.query_fill_combo(QComboBox(self.widgetParent),'SELECT * from cultivos()')
        self.combo_cultivos.currentTextChanged.connect(self.combobox_change_func)

        self.button_agregar=QPushButton('Agregar ingrediente',self.widgetParent)
        self.button_agregar.clicked.connect(self.agregarIngredientes)

        self.addWidget(self.combo_cultivos)
        self.addWidget(self.button_agregar)

    # Llena un combobox con un query
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

    #Al cambiar de cultivo elimina todos los ingredientes y pone uno vacio
    def combobox_change_func(self,value):
        for ingrediente in self.ingredientes:
            for i in reversed(range(ingrediente.count())): 
                ingrediente.itemAt(i).widget().deleteLater()
        self.ingredientes=[]
        self.value=value
        self.agregarIngredientes()

    #funcion para agregar ingredientes
    def agregarIngredientes(self):
        self.ingredientes.append(Ingredientes(self.widgetParent,self))
        self.insertLayout(self.count()-1,self.ingredientes[-1])

    #devuelve el cultivo con la lista de ingredientes seleccionados
    def obtenerInfo(self):
        if(self.combo_cultivos.currentIndex()==0):
            qgis.utils.iface.messageBar().pushMessage("Error", "Se debe seleccionar un cultivo", level=Qgis.Critical)
            return None
        listaIngredientes=[]
        for ingrediente in self.ingredientes:
            ing=ingrediente.obtenerInfo()
            if(ing is None):
                return None
            listaIngredientes.append(ing) ##Lista de diccionarios
        if(len(listaIngredientes)>0):
            return {'cultivo':self.combo_cultivos.currentText(),'Ingredientes':listaIngredientes}
        else:
            qgis.utils.iface.messageBar().pushMessage("Error", "Se debe seleccionar al menos un ingrediente para el cultivo", level=Qgis.Critical)
            return None
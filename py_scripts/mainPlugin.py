from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .mainGui import Gui
from .qgis_layer import QgisLayer

class Main:
    def __init__(self, iface):
        self.iface = iface

    def initGui(self):
        self.action = QAction('Calculos fumigacion')
        self.action.setObjectName("calculoFumigacion")
        self.gui=Gui()
        self.action.triggered.connect(self.showGui)


        self.iface.addToolBarIcon(self.action)
        self.iface.addPluginToMenu("&Proyecto 1", self.action)

    def unload(self):
        self.iface.removePluginMenu("&Proyecto 1", self.action)
        self.iface.removeToolBarIcon(self.action)
    
    def showGui(self):
        if(QgisLayer(self.iface).sridValida()):
            self.gui.show()

from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .mainGui import Gui

class Main:
    def __init__(self, iface):
        # save reference to the QGIS interface
        self.iface = iface

    def initGui(self):
        # create action that will start plugin configuration
        self.action = QAction('Registros por fecha')
        self.action.setObjectName("testAction")
        self.action.setWhatsThis("Configuration for test plugin")
        self.action.setStatusTip("This is status tip")
        self.gui=Gui()
        self.action.triggered.connect(self.gui.show)

        # add toolbar button and menu item
        self.iface.addToolBarIcon(self.action)
        self.iface.addPluginToMenu("&Proyecto 1", self.action)

    def unload(self):
        # remove the plugin menu item and icon
        self.iface.removePluginMenu("&Proyecto 1", self.action)
        self.iface.removeToolBarIcon(self.action)

    #def run(self):
        # create and show a configuration dialog or something similar
        #print("TestPlugin: run called!")
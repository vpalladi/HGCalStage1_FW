from mp7.cli_plugins import DevicePlugin, _log

from calol2 import CaloL2Controller
#---
class CaloL2Plugin(DevicePlugin):

    def __init__(self, *args, **kwargs):
        super(CaloL2Plugin,self).__init__(*args, **kwargs)

    @classmethod
    def _addArgs(cls, subp):
        _log.debug(" > Entering:  CaloL2Plugin._addArgs")
        super(CaloL2Plugin, cls)._addArgs(subp)
        _log.debug(" > Meat of :  CaloL2Plugin._addArgs")
        _log.debug(" > Exiting :  CaloL2Plugin._addArgs")

    @classmethod
    def prepare(cls, kwargs):
        _log.debug(" > Entering:  CaloL2Plugin.prepare")
        super(CaloL2Plugin, cls).prepare(kwargs)
        _log.debug(" > Meat of :  CaloL2Plugin.prepare")

        # Create the subject
        board = CaloL2Controller( kwargs['board'] )

        # Replace board id with the controller itself
        kwargs['board'] = board

        _log.debug(" > Exiting :  CaloL2Plugin.prepare")
        board.identify()
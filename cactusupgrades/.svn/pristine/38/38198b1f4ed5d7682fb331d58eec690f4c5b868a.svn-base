import mp7.cmds

from calol2.cli_plugins import CaloL2Plugin

import algo


plugins = mp7.cmds.Factory.makeMP7(CaloL2Plugin)


plugins += [
    CaloL2Plugin('funkyinfo', 'Read Funky Minibus Infospace ', algo.FunkyInfo()),
    CaloL2Plugin('funkyread', 'Read Funky Minibus Endpoints ', algo.FunkyRead()),
    CaloL2Plugin('funkyzeros', 'Zero all Funky Minibus Endpoints ', algo.FunkyZeros()),
    CaloL2Plugin('funkyrecovery', 'Reloads endpoints from file ', algo.FunkyRecovery()),

]
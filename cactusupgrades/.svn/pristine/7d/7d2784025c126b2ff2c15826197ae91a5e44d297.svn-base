import mp7


#    __  ___              ___ 
#   /  |/  /__ ___  __ __/ _ |
#  / /|_/ / -_) _ \/ // / __ |
# /_/  /_/\__/_//_/\_,_/_/ |_|
                            


# 1 mode, 1 capture
# No delay
menuA = mp7.ReadoutMenu(4,2,4)

menuA.bank(1).wordsPerBx = 6

# Triggers on every event
mode = menuA.mode(0)

mode.eventSize = 0
mode.eventToTrigger = 1
mode.eventType = 0xc0
mode.tokenDelay = 70

# Even, bank id 1, +0bx
c = mode[0]
c.enable = True
c.id = 0x1
c.bankId = 0x1
c.length = 1
c.delay = 0
c.readoutLength = 6



#    __  ___              ___   ____     __ 
#   /  |/  /__ ___  __ __/ _ | / __/__ _/ /_
#  / /|_/ / -_) _ \/ // / __ |/ _// _ `/ __/
# /_/  /_/\__/_//_/\_,_/_/ |_/_/  \_,_/\__/ 
                                          
# 1 bank, 1 mode, 1 capture
# No delay
menuAFat = mp7.ReadoutMenu(4,2,4)

menuAFat.bank(1).wordsPerBx = 6


# First Mode
# Triggers on every event
mode = menuAFat.mode(0)

mode.eventSize = 0
mode.eventToTrigger = 1
mode.eventType = 0xfa
mode.tokenDelay = 70


# Even, bank id 1, +0bx
c = mode[0]
c.enable = True
c.id = 0x1
c.bankId = 0x1
c.length = 3
c.delay = 0
c.readoutLength = 18


#    __  ___              ___ 
#   /  |/  /__ ___  __ __/ _ )
#  / /|_/ / -_) _ \/ // / _  |
# /_/  /_/\__/_//_/\_,_/____/ 

# Menu B
# 2 banks, 1 mode, 2 captures
# No delay
menuB = mp7.ReadoutMenu(4,2,4)

menuB.bank(1).wordsPerBx = 6
menuB.bank(2).wordsPerBx = 6

# First Mode
# Triggers every other event
mode = menuB.mode(0)

mode.eventSize = 0
mode.eventToTrigger = 1
mode.eventType = 0xc0
mode.tokenDelay = 70


# Even, bank id 1, +0bx
c = mode[0]
c.enable = True
c.id = 0x1
c.bankId = 0x1
c.length = 1
c.delay = 0
c.readoutLength = 6

c = mode[1]
c.enable = True
c.id = 0x2
c.bankId = 0x2
c.length = 1
c.delay = 0
c.readoutLength = 6


#    __  ___              _____
#   /  |/  /__ ___  __ __/ ___/
#  / /|_/ / -_) _ \/ // / /__  
# /_/  /_/\__/_//_/\_,_/\___/  

# 2 band ids                         
# 2 modes
# - mode 0 even events
# - mode 1 all events
# 2 bx delay for all captures (stage1 style)
menuC = mp7.ReadoutMenu(4,2,4)

menuC.bank(1).wordsPerBx = 6
menuC.bank(2).wordsPerBx = 6

# First Mode
# Triggers every other event
mode = menuC.mode(0)

mode.eventSize = 0
mode.eventToTrigger = 2
mode.eventType = 0xc0
mode.tokenDelay = 70


# Even, bank id 1, +0bx
c = mode[0]
c.enable = True
c.id = 0x1
c.bankId = 0x1
c.length = 1
c.delay = 2 #2 # 0+2 bx
c.readoutLength = 6

c = mode[1]
c.enable = True
c.id = 0x2
c.bankId = 0x2
c.length = 1
c.delay = 2 # 2 # 0+2 bx
c.readoutLength = 6


# Second Mode
mode = menuC.mode(1)

mode.eventSize = 0
mode.eventToTrigger = 1
mode.eventType = 0xde
mode.tokenDelay = 70


# Even, bank id 1, +0bx
c = mode[0]
c.enable = True
c.id = 0x1
c.bankId = 0x1
c.length = 1
c.delay = 2 #2 # 0+2 bx
c.readoutLength = 6

c = mode[1]
c.enable = True
c.id = 0x2
c.bankId = 0x2
c.length = 1
c.delay = 2 # 2 # 0+2 bx
c.readoutLength = 6





# baseMode = mp7.ReadoutMenu.Mode(4)

# # Common parameters
# # -----------------

# # Even, bank id 1, +0bx
# c = baseMode[0]
# c.enable = True
# c.bankId = 1
# c.id = 0

# # Odd, bank id 2, +0bx
# c = baseMode[1]
# c.enable = True
# c.bankId = 2
# c.id = 0

# # Odd, bank id 2, +9bx
# c = baseMode[2]
# c.enable = True
# c.bankId = 2
# c.id = 1

# # Outs, bank id 2, +0bx
# c = baseMode[3]
# c.enable = True
# c.bankId = 3
# c.id = 2

# s1test = mp7.ReadoutMenu(4,2,4)

# # Even inputs, 6 w per bx
# s1test.bank(1).wordsPerBx = 6
# # Odd inputs, 6 w per bx
# s1test.bank(2).wordsPerBx = 6
# # Outputs, 2 w per bx
# s1test.bank(3).wordsPerBx = 2

# s1test.setMode(0,baseMode)
# # s1test.setMode(1,baseMode)

# # First trigger mode, Validation events
# # -------------------------------------

# # m = s1test.mode(0)
# # m.eventSize = 0
# # m.eventToTrigger = 107
# # m.eventType = 0x1
# # m.tokenDelay = 35

# # # Even, bank id 1, +0bx
# # c = s1test.capture(0,0)
# # c.delay = 0
# # c.length = 5
# # c.readoutLength = 30

# # # Odd, bank id 2, +0bx
# # c = s1test.capture(0,1)
# # c.delay = 0
# # c.length = 5
# # c.readoutLength = 30

# # # Odd, bank id 2, +9bx
# # c = s1test.capture(0,2)
# # c.delay = 9
# # c.length = 5
# # c.readoutLength = 30

# # # Outs, bank id 2, +0bx
# # c = s1test.capture(0,3)
# # c.delay = 0
# # c.length = 5
# # c.readoutLength = 10


# # Second trigger mode, standard events
# # ------------------------------------

# m = s1test.mode(0)
# m.eventSize = 0
# m.eventToTrigger = 1
# m.eventType = 0x0
# m.tokenDelay = 70

# # Even, bank id 1, +0bx
# c = s1test.capture(0,0)
# c.delay = 2 # 0+2 bx
# c.length = 1
# c.readoutLength = 6

# # Odd, bank id 2, +0bx
# c = s1test.capture(0,1)
# c.delay = 2 # 0+2bx
# c.length = 1
# c.readoutLength = 6

# # Odd, bank id 2, +9bx
# c = s1test.capture(0,2)
# c.delay = 11 # 9+2bx
# c.length = 1
# c.readoutLength = 6

# # Outs, bank id 2, +0bx
# c = s1test.capture(0,3)
# c.delay = 0
# c.length = 1
# c.readoutLength = 2

import numpy as np
import logging
import os
 
class Utilities(object):

    def parse_state(self, state):
        if   (state['light'] == 'green' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] == None ): return 0
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] =='right' ): return 1
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] =='left' ): return 2
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] =='forward' ): return 3
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] == None ): return 4
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] =='right' ): return 5
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] =='left' ): return 6
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 7
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] == None ): return 8
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] =='right' ): return 9
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] =='left' ): return 10
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 11
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] == None ): return 12
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 13
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 14
        elif (state['light'] == 'green' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 15
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] == None ): return 16
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] =='right' ): return 17
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] =='left' ): return 18
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] =='forward' ): return 19
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] == None ): return 20
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] =='right' ): return 21
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] =='left' ): return 22
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 23
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] == None ): return 24
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] =='right' ): return 25
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] =='left' ): return 26
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 27
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] == None ): return 28
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 29
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 30
        elif (state['light'] == 'green' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 31
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] == None ): return 32
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] =='right' ): return 33
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] =='left' ): return 34
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] =='forward' ): return 35
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] == None ): return 36
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] =='right' ): return 37
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] =='left' ): return 38
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 39
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] == None ): return 40
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] =='right' ): return 41
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] =='left' ): return 42
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 43
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] == None ): return 44
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 45
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 46
        elif (state['light'] == 'green' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 47
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] == None ): return 48
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] =='right' ): return 49
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] =='left' ): return 50
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] =='forward' ): return 51
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] == None ): return 52
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] =='right' ): return 53
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] =='left' ): return 54
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 55
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] == None ): return 56
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] =='right' ): return 57
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] =='left' ): return 58
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 59
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] == None ): return 60
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 61
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 62
        elif (state['light'] == 'green' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 63
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] == None ): return 64
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] =='right' ): return 65
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] =='left' ): return 66
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] == None and state['next_waypoint'] =='forward' ): return 67
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] == None ): return 68
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] =='right' ): return 69
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] =='left' ): return 70
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 71
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] == None ): return 72
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] =='right' ): return 73
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] =='left' ): return 74
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 75
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] == None ): return 76
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 77
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 78
        elif (state['light'] == 'red' and state['oncoming'] == None and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 79
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] == None ): return 80
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] =='right' ): return 81
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] =='left' ): return 82
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] == None and state['next_waypoint'] =='forward' ): return 83
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] == None ): return 84
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] =='right' ): return 85
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] =='left' ): return 86
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 87
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] == None ): return 88
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] =='right' ): return 89
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] =='left' ): return 90
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 91
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] == None ): return 92
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 93
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 94
        elif (state['light'] == 'red' and state['oncoming'] =='left' and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 95
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] == None ): return 96
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] =='right' ): return 97
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] =='left' ): return 98
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] == None and state['next_waypoint'] =='forward' ): return 99
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] == None ): return 100
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] =='right' ): return 101
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] =='left' ): return 102
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 103
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] == None ): return 104
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] =='right' ): return 105
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] =='left' ): return 106
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 107
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] == None ): return 108
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 109
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 110
        elif (state['light'] == 'red' and state['oncoming'] =='right' and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 111
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] == None ): return 112
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] =='right' ): return 113
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] =='left' ): return 114
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] == None and state['next_waypoint'] =='forward' ): return 115
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] == None ): return 116
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] =='right' ): return 117
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] =='left' ): return 118
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='right' and state['next_waypoint'] =='forward' ): return 119
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] == None ): return 120
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] =='right' ): return 121
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] =='left' ): return 122
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='left' and state['next_waypoint'] =='forward' ): return 123
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] == None ): return 124
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] =='right' ): return 125
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] =='left' ): return 126
        elif (state['light'] == 'red' and state['oncoming'] =='forward' and state['left'] =='forward' and state['next_waypoint'] =='forward' ): return 127
        else:
            print 'ERROR **********: light: ',  state['light'],  ' - oncoming', state['oncoming'],  'left: ',  state['left'],'next_waypoint: ',  state['next_waypoint'], ' NOT SUPPORTED'

    def parse_action(self, action_index):
        if (action_index == 0):
            return None
        elif (action_index == 1):
            return 'left'
        elif (action_index == 2):
            return 'forward'
        elif (action_index == 3):
            return 'right'
        else:
            print 'action index: ' + action_index  + ' NOT SUPPORTED'            
        
    def get_reward_matrix(self):
        reward_matrix = np.zeros((128,4), dtype=np.float)
        reward_matrix[0,0] = 1 ;reward_matrix[0,1] = 0.5 ;reward_matrix[0,2] = 0.5 ;reward_matrix[0,3] = 0.5
        reward_matrix[1,0] = 1 ;reward_matrix[1,1] = 0.5 ;reward_matrix[1,2] = 0.5 ;reward_matrix[1,3] = 2
        reward_matrix[2,0] = 1 ;reward_matrix[2,1] = 2 ;reward_matrix[2,2] = 0.5 ;reward_matrix[2,3] = 0.5
        reward_matrix[3,0] = 1 ;reward_matrix[3,1] = 0.5 ;reward_matrix[3,2] = 2 ;reward_matrix[3,3] = 0.5
        reward_matrix[4,0] = 1 ;reward_matrix[4,1] = 0.5 ;reward_matrix[4,2] = 0.5 ;reward_matrix[4,3] = 0.5
        reward_matrix[5,0] = 1 ;reward_matrix[5,1] = 0.5 ;reward_matrix[5,2] = 0.5 ;reward_matrix[5,3] = 2
        reward_matrix[6,0] = 1 ;reward_matrix[6,1] = 2 ;reward_matrix[6,2] = 0.5 ;reward_matrix[6,3] = 0.5
        reward_matrix[7,0] = 1 ;reward_matrix[7,1] = 0.5 ;reward_matrix[7,2] = 2 ;reward_matrix[7,3] = 0.5
        reward_matrix[8,0] = 1 ;reward_matrix[8,1] = 0.5 ;reward_matrix[8,2] = 0.5 ;reward_matrix[8,3] = 0.5
        reward_matrix[9,0] = 1 ;reward_matrix[9,1] = 0.5 ;reward_matrix[9,2] = 0.5 ;reward_matrix[9,3] = 2
        reward_matrix[10,0] = 1 ;reward_matrix[10,1] = 2 ;reward_matrix[10,2] = 0.5 ;reward_matrix[10,3] = 0.5
        reward_matrix[11,0] = 1 ;reward_matrix[11,1] = 0.5 ;reward_matrix[11,2] = 2 ;reward_matrix[11,3] = 0.5
        reward_matrix[12,0] = 1 ;reward_matrix[12,1] = 0.5 ;reward_matrix[12,2] = 0.5 ;reward_matrix[12,3] = 0.5
        reward_matrix[13,0] = 1 ;reward_matrix[13,1] = 0.5 ;reward_matrix[13,2] = 0.5 ;reward_matrix[13,3] = 2
        reward_matrix[14,0] = 1 ;reward_matrix[14,1] = 2 ;reward_matrix[14,2] = 0.5 ;reward_matrix[14,3] = 0.5
        reward_matrix[15,0] = 1 ;reward_matrix[15,1] = 0.5 ;reward_matrix[15,2] = 2 ;reward_matrix[15,3] = 0.5
        reward_matrix[16,0] = 1 ;reward_matrix[16,1] = 0.5 ;reward_matrix[16,2] = 0.5 ;reward_matrix[16,3] = 0.5
        reward_matrix[17,0] = 1 ;reward_matrix[17,1] = 0.5 ;reward_matrix[17,2] = 0.5 ;reward_matrix[17,3] = 2
        reward_matrix[18,0] = 1 ;reward_matrix[18,1] = 2 ;reward_matrix[18,2] = 0.5 ;reward_matrix[18,3] = 0.5
        reward_matrix[19,0] = 1 ;reward_matrix[19,1] = 0.5 ;reward_matrix[19,2] = 2 ;reward_matrix[19,3] = 0.5
        reward_matrix[20,0] = 1 ;reward_matrix[20,1] = 0.5 ;reward_matrix[20,2] = 0.5 ;reward_matrix[20,3] = 0.5
        reward_matrix[21,0] = 1 ;reward_matrix[21,1] = 0.5 ;reward_matrix[21,2] = 0.5 ;reward_matrix[21,3] = 2
        reward_matrix[22,0] = 1 ;reward_matrix[22,1] = 2 ;reward_matrix[22,2] = 0.5 ;reward_matrix[22,3] = 0.5
        reward_matrix[23,0] = 1 ;reward_matrix[23,1] = 0.5 ;reward_matrix[23,2] = 2 ;reward_matrix[23,3] = 0.5
        reward_matrix[24,0] = 1 ;reward_matrix[24,1] = 0.5 ;reward_matrix[24,2] = 0.5 ;reward_matrix[24,3] = 0.5
        reward_matrix[25,0] = 1 ;reward_matrix[25,1] = 0.5 ;reward_matrix[25,2] = 0.5 ;reward_matrix[25,3] = 2
        reward_matrix[26,0] = 1 ;reward_matrix[26,1] = 2 ;reward_matrix[26,2] = 0.5 ;reward_matrix[26,3] = 0.5
        reward_matrix[27,0] = 1 ;reward_matrix[27,1] = 0.5 ;reward_matrix[27,2] = 2 ;reward_matrix[27,3] = 0.5
        reward_matrix[28,0] = 1 ;reward_matrix[28,1] = 0.5 ;reward_matrix[28,2] = 0.5 ;reward_matrix[28,3] = 0.5
        reward_matrix[29,0] = 1 ;reward_matrix[29,1] = 0.5 ;reward_matrix[29,2] = 0.5 ;reward_matrix[29,3] = 2
        reward_matrix[30,0] = 1 ;reward_matrix[30,1] = 2 ;reward_matrix[30,2] = 0.5 ;reward_matrix[30,3] = 0.5
        reward_matrix[31,0] = 1 ;reward_matrix[31,1] = 0.5 ;reward_matrix[31,2] = 2 ;reward_matrix[31,3] = 0.5
        reward_matrix[32,0] = 1 ;reward_matrix[32,1] = 0.5 ;reward_matrix[32,2] = 0.5 ;reward_matrix[32,3] = 0.5
        reward_matrix[33,0] = 1 ;reward_matrix[33,1] = 0.5 ;reward_matrix[33,2] = 0.5 ;reward_matrix[33,3] = 2
        reward_matrix[34,0] = 1 ;reward_matrix[34,1] = 2 ;reward_matrix[34,2] = 0.5 ;reward_matrix[34,3] = 0.5
        reward_matrix[35,0] = 1 ;reward_matrix[35,1] = 0.5 ;reward_matrix[35,2] = 2 ;reward_matrix[35,3] = 0.5
        reward_matrix[36,0] = 1 ;reward_matrix[36,1] = 0.5 ;reward_matrix[36,2] = 0.5 ;reward_matrix[36,3] = 0.5
        reward_matrix[37,0] = 1 ;reward_matrix[37,1] = 0.5 ;reward_matrix[37,2] = 0.5 ;reward_matrix[37,3] = 2
        reward_matrix[38,0] = 1 ;reward_matrix[38,1] = 2 ;reward_matrix[38,2] = 0.5 ;reward_matrix[38,3] = 0.5
        reward_matrix[39,0] = 1 ;reward_matrix[39,1] = 0.5 ;reward_matrix[39,2] = 2 ;reward_matrix[39,3] = 0.5
        reward_matrix[40,0] = 1 ;reward_matrix[40,1] = 0.5 ;reward_matrix[40,2] = 0.5 ;reward_matrix[40,3] = 0.5
        reward_matrix[41,0] = 1 ;reward_matrix[41,1] = 0.5 ;reward_matrix[41,2] = 0.5 ;reward_matrix[41,3] = 2
        reward_matrix[42,0] = 1 ;reward_matrix[42,1] = 2 ;reward_matrix[42,2] = 0.5 ;reward_matrix[42,3] = 0.5
        reward_matrix[43,0] = 1 ;reward_matrix[43,1] = 0.5 ;reward_matrix[43,2] = 2 ;reward_matrix[43,3] = 0.5
        reward_matrix[44,0] = 1 ;reward_matrix[44,1] = 0.5 ;reward_matrix[44,2] = 0.5 ;reward_matrix[44,3] = 0.5
        reward_matrix[45,0] = 1 ;reward_matrix[45,1] = 0.5 ;reward_matrix[45,2] = 0.5 ;reward_matrix[45,3] = 2
        reward_matrix[46,0] = 1 ;reward_matrix[46,1] = 2 ;reward_matrix[46,2] = 0.5 ;reward_matrix[46,3] = 0.5
        reward_matrix[47,0] = 1 ;reward_matrix[47,1] = 0.5 ;reward_matrix[47,2] = 2 ;reward_matrix[47,3] = 0.5
        reward_matrix[48,0] = 1 ;reward_matrix[48,1] = 0.5 ;reward_matrix[48,2] = 0.5 ;reward_matrix[48,3] = 0.5
        reward_matrix[49,0] = 1 ;reward_matrix[49,1] = 0.5 ;reward_matrix[49,2] = 0.5 ;reward_matrix[49,3] = 2
        reward_matrix[50,0] = 1 ;reward_matrix[50,1] = 2 ;reward_matrix[50,2] = 0.5 ;reward_matrix[50,3] = 0.5
        reward_matrix[51,0] = 1 ;reward_matrix[51,1] = 0.5 ;reward_matrix[51,2] = 2 ;reward_matrix[51,3] = 0.5
        reward_matrix[52,0] = 1 ;reward_matrix[52,1] = 0.5 ;reward_matrix[52,2] = 0.5 ;reward_matrix[52,3] = 0.5
        reward_matrix[53,0] = 1 ;reward_matrix[53,1] = 0.5 ;reward_matrix[53,2] = 0.5 ;reward_matrix[53,3] = 2
        reward_matrix[54,0] = 1 ;reward_matrix[54,1] = 2 ;reward_matrix[54,2] = 0.5 ;reward_matrix[54,3] = 0.5
        reward_matrix[55,0] = 1 ;reward_matrix[55,1] = 0.5 ;reward_matrix[55,2] = 2 ;reward_matrix[55,3] = 0.5
        reward_matrix[56,0] = 1 ;reward_matrix[56,1] = 0.5 ;reward_matrix[56,2] = 0.5 ;reward_matrix[56,3] = 0.5
        reward_matrix[57,0] = 1 ;reward_matrix[57,1] = 0.5 ;reward_matrix[57,2] = 0.5 ;reward_matrix[57,3] = 2
        reward_matrix[58,0] = 1 ;reward_matrix[58,1] = 2 ;reward_matrix[58,2] = 0.5 ;reward_matrix[58,3] = 0.5
        reward_matrix[59,0] = 1 ;reward_matrix[59,1] = 0.5 ;reward_matrix[59,2] = 2 ;reward_matrix[59,3] = 0.5
        reward_matrix[60,0] = 1 ;reward_matrix[60,1] = 0.5 ;reward_matrix[60,2] = 0.5 ;reward_matrix[60,3] = 0.5
        reward_matrix[61,0] = 1 ;reward_matrix[61,1] = 0.5 ;reward_matrix[61,2] = 0.5 ;reward_matrix[61,3] = 2
        reward_matrix[62,0] = 1 ;reward_matrix[62,1] = 2 ;reward_matrix[62,2] = 0.5 ;reward_matrix[62,3] = 0.5
        reward_matrix[63,0] = 1 ;reward_matrix[63,1] = 0.5 ;reward_matrix[63,2] = 2 ;reward_matrix[63,3] = 0.5
        reward_matrix[64,0] = 1 ;reward_matrix[64,1] = -1 ;reward_matrix[64,2] = -1 ;reward_matrix[64,3] = 0.5
        reward_matrix[65,0] = 1 ;reward_matrix[65,1] = -1 ;reward_matrix[65,2] = -1 ;reward_matrix[65,3] = 2
        reward_matrix[66,0] = 1 ;reward_matrix[66,1] = -1 ;reward_matrix[66,2] = -1 ;reward_matrix[66,3] = 0.5
        reward_matrix[67,0] = 1 ;reward_matrix[67,1] = -1 ;reward_matrix[67,2] = -1 ;reward_matrix[67,3] = 0.5
        reward_matrix[68,0] = 1 ;reward_matrix[68,1] = -1 ;reward_matrix[68,2] = -1 ;reward_matrix[68,3] = 0.5
        reward_matrix[69,0] = 1 ;reward_matrix[69,1] = -1 ;reward_matrix[69,2] = -1 ;reward_matrix[69,3] = 2
        reward_matrix[70,0] = 1 ;reward_matrix[70,1] = -1 ;reward_matrix[70,2] = -1 ;reward_matrix[70,3] = 0.5
        reward_matrix[71,0] = 1 ;reward_matrix[71,1] = -1 ;reward_matrix[71,2] = -1 ;reward_matrix[71,3] = 0.5
        reward_matrix[72,0] = 1 ;reward_matrix[72,1] = -1 ;reward_matrix[72,2] = -1 ;reward_matrix[72,3] = 0.5
        reward_matrix[73,0] = 1 ;reward_matrix[73,1] = -1 ;reward_matrix[73,2] = -1 ;reward_matrix[73,3] = 2
        reward_matrix[74,0] = 1 ;reward_matrix[74,1] = -1 ;reward_matrix[74,2] = -1 ;reward_matrix[74,3] = 0.5
        reward_matrix[75,0] = 1 ;reward_matrix[75,1] = -1 ;reward_matrix[75,2] = -1 ;reward_matrix[75,3] = 0.5
        reward_matrix[76,0] = 1 ;reward_matrix[76,1] = -1 ;reward_matrix[76,2] = -1 ;reward_matrix[76,3] = 0.5
        reward_matrix[77,0] = 1 ;reward_matrix[77,1] = -1 ;reward_matrix[77,2] = -1 ;reward_matrix[77,3] = -1
        reward_matrix[78,0] = 1 ;reward_matrix[78,1] = -1 ;reward_matrix[78,2] = -1 ;reward_matrix[78,3] = -1
        reward_matrix[79,0] = 1 ;reward_matrix[79,1] = -1 ;reward_matrix[79,2] = -1 ;reward_matrix[79,3] = -1
        reward_matrix[80,0] = 1 ;reward_matrix[80,1] = -1 ;reward_matrix[80,2] = -1 ;reward_matrix[80,3] = 0.5
        reward_matrix[81,0] = 1 ;reward_matrix[81,1] = -1 ;reward_matrix[81,2] = -1 ;reward_matrix[81,3] = 2
        reward_matrix[82,0] = 1 ;reward_matrix[82,1] = -1 ;reward_matrix[82,2] = -1 ;reward_matrix[82,3] = 0.5
        reward_matrix[83,0] = 1 ;reward_matrix[83,1] = -1 ;reward_matrix[83,2] = -1 ;reward_matrix[83,3] = 0.5
        reward_matrix[84,0] = 1 ;reward_matrix[84,1] = -1 ;reward_matrix[84,2] = -1 ;reward_matrix[84,3] = 0.5
        reward_matrix[85,0] = 1 ;reward_matrix[85,1] = -1 ;reward_matrix[85,2] = -1 ;reward_matrix[85,3] = 2
        reward_matrix[86,0] = 1 ;reward_matrix[86,1] = -1 ;reward_matrix[86,2] = -1 ;reward_matrix[86,3] = 0.5
        reward_matrix[87,0] = 1 ;reward_matrix[87,1] = -1 ;reward_matrix[87,2] = -1 ;reward_matrix[87,3] = 0.5
        reward_matrix[88,0] = 1 ;reward_matrix[88,1] = -1 ;reward_matrix[88,2] = -1 ;reward_matrix[88,3] = 0.5
        reward_matrix[89,0] = 1 ;reward_matrix[89,1] = -1 ;reward_matrix[89,2] = -1 ;reward_matrix[89,3] = 2
        reward_matrix[90,0] = 1 ;reward_matrix[90,1] = -1 ;reward_matrix[90,2] = -1 ;reward_matrix[90,3] = 0.5
        reward_matrix[91,0] = 1 ;reward_matrix[91,1] = -1 ;reward_matrix[91,2] = -1 ;reward_matrix[91,3] = 0.5
        reward_matrix[92,0] = 1 ;reward_matrix[92,1] = -1 ;reward_matrix[92,2] = -1 ;reward_matrix[92,3] = 0.5
        reward_matrix[93,0] = 1 ;reward_matrix[93,1] = -1 ;reward_matrix[93,2] = -1 ;reward_matrix[93,3] = -1
        reward_matrix[94,0] = 1 ;reward_matrix[94,1] = -1 ;reward_matrix[94,2] = -1 ;reward_matrix[94,3] = -1
        reward_matrix[95,0] = 1 ;reward_matrix[95,1] = -1 ;reward_matrix[95,2] = -1 ;reward_matrix[95,3] = -1
        reward_matrix[96,0] = 1 ;reward_matrix[96,1] = -1 ;reward_matrix[96,2] = -1 ;reward_matrix[96,3] = -1
        reward_matrix[97,0] = 1 ;reward_matrix[97,1] = -1 ;reward_matrix[97,2] = -1 ;reward_matrix[97,3] = -1
        reward_matrix[98,0] = 1 ;reward_matrix[98,1] = -1 ;reward_matrix[98,2] = -1 ;reward_matrix[98,3] = -1
        reward_matrix[99,0] = 1 ;reward_matrix[99,1] = -1 ;reward_matrix[99,2] = -1 ;reward_matrix[99,3] = -1
        reward_matrix[100,0] = 1 ;reward_matrix[100,1] = -1 ;reward_matrix[100,2] = -1 ;reward_matrix[100,3] = -1
        reward_matrix[101,0] = 1 ;reward_matrix[101,1] = -1 ;reward_matrix[101,2] = -1 ;reward_matrix[101,3] = -1
        reward_matrix[102,0] = 1 ;reward_matrix[102,1] = -1 ;reward_matrix[102,2] = -1 ;reward_matrix[102,3] = -1
        reward_matrix[103,0] = 1 ;reward_matrix[103,1] = -1 ;reward_matrix[103,2] = -1 ;reward_matrix[103,3] = -1
        reward_matrix[104,0] = 1 ;reward_matrix[104,1] = -1 ;reward_matrix[104,2] = -1 ;reward_matrix[104,3] = -1
        reward_matrix[105,0] = 1 ;reward_matrix[105,1] = -1 ;reward_matrix[105,2] = -1 ;reward_matrix[105,3] = -1
        reward_matrix[106,0] = 1 ;reward_matrix[106,1] = -1 ;reward_matrix[106,2] = -1 ;reward_matrix[106,3] = -1
        reward_matrix[107,0] = 1 ;reward_matrix[107,1] = -1 ;reward_matrix[107,2] = -1 ;reward_matrix[107,3] = -1
        reward_matrix[108,0] = 1 ;reward_matrix[108,1] = -1 ;reward_matrix[108,2] = -1 ;reward_matrix[108,3] = -1
        reward_matrix[109,0] = 1 ;reward_matrix[109,1] = -1 ;reward_matrix[109,2] = -1 ;reward_matrix[109,3] = -1
        reward_matrix[110,0] = 1 ;reward_matrix[110,1] = -1 ;reward_matrix[110,2] = -1 ;reward_matrix[110,3] = -1
        reward_matrix[111,0] = 1 ;reward_matrix[111,1] = -1 ;reward_matrix[111,2] = -1 ;reward_matrix[111,3] = -1
        reward_matrix[112,0] = 1 ;reward_matrix[112,1] = -1 ;reward_matrix[112,2] = -1 ;reward_matrix[112,3] = -1
        reward_matrix[113,0] = 1 ;reward_matrix[113,1] = -1 ;reward_matrix[113,2] = -1 ;reward_matrix[113,3] = -1
        reward_matrix[114,0] = 1 ;reward_matrix[114,1] = -1 ;reward_matrix[114,2] = -1 ;reward_matrix[114,3] = -1
        reward_matrix[115,0] = 1 ;reward_matrix[115,1] = -1 ;reward_matrix[115,2] = -1 ;reward_matrix[115,3] = -1
        reward_matrix[116,0] = 1 ;reward_matrix[116,1] = -1 ;reward_matrix[116,2] = -1 ;reward_matrix[116,3] = -1
        reward_matrix[117,0] = 1 ;reward_matrix[117,1] = -1 ;reward_matrix[117,2] = -1 ;reward_matrix[117,3] = -1
        reward_matrix[118,0] = 1 ;reward_matrix[118,1] = -1 ;reward_matrix[118,2] = -1 ;reward_matrix[118,3] = -1
        reward_matrix[119,0] = 1 ;reward_matrix[119,1] = -1 ;reward_matrix[119,2] = -1 ;reward_matrix[119,3] = -1
        reward_matrix[120,0] = 1 ;reward_matrix[120,1] = -1 ;reward_matrix[120,2] = -1 ;reward_matrix[120,3] = -1
        reward_matrix[121,0] = 1 ;reward_matrix[121,1] = -1 ;reward_matrix[121,2] = -1 ;reward_matrix[121,3] = -1
        reward_matrix[122,0] = 1 ;reward_matrix[122,1] = -1 ;reward_matrix[122,2] = -1 ;reward_matrix[122,3] = -1
        reward_matrix[123,0] = 1 ;reward_matrix[123,1] = -1 ;reward_matrix[123,2] = -1 ;reward_matrix[123,3] = -1
        reward_matrix[124,0] = 1 ;reward_matrix[124,1] = -1 ;reward_matrix[124,2] = -1 ;reward_matrix[124,3] = -1
        reward_matrix[125,0] = 1 ;reward_matrix[125,1] = -1 ;reward_matrix[125,2] = -1 ;reward_matrix[125,3] = -1
        reward_matrix[126,0] = 1 ;reward_matrix[126,1] = -1 ;reward_matrix[126,2] = -1 ;reward_matrix[126,3] = -1
        reward_matrix[127,0] = 1 ;reward_matrix[127,1] = -1 ;reward_matrix[127,2] = -1 ;reward_matrix[127,3] = -1
        
        return reward_matrix  
 
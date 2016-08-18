import numpy as np 

class QTable(object):
    """The QTable class contains all required behaviours to CRUD a new table """
    def __init__(self, rtable):
        state_count = len(rtable.get_rtable())
        self.action_count = len(rtable.get_rtable().T)
        self.queue_matrix = np.zeros((state_count,self.action_count), dtype=np.float)

    def get_qtable(self):
        return self.queue_matrix
    
    def get_qtable_element(self, state_index, action_index):
        return self.queue_matrix[state_index, action_index]
        
    def set_qtable_element(self, state_index, action_index, value):
        self.queue_matrix[state_index, action_index] =  value
    
    def get_qtable_max_value(self, state_index):
        return np.max(self.queue_matrix[state_index])
    
    def get_qtable_best_action(self, state_index):
        row = self.queue_matrix[state_index]
        max_queue = np.max(row)
        possible_actions_index = []
        for colIdx in range(len(row)):
            if row[colIdx] == max_queue:
                possible_actions_index.append(colIdx)
        #when more than one action is possible, then return one randomly            
        return np.random.choice(possible_actions_index)
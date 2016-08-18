import numpy as np

class RTable(object):
    """The RTable class contains all required behaviours to CRUD a new table """
    def __init__(self, reward_matrix):
        self.reward_matrix = reward_matrix
       
    def get_rtable(self):
        return self.reward_matrix

    def get_rtable_element(self, state_index, action_index):
        return self.reward_matrix.item((state_index, action_index))
    
    def get_rtable_max_reward(self, state_index):
        row = self.reward_matrix[state_index]
        max_queue = np.max(row)
        possible_actions_index = []
        for colIdx in range(len(row)):
            if row[colIdx] == max_queue:
                possible_actions_index.append(colIdx)
        #when more than one action is possible, then return one randomly            
        return np.random.choice(possible_actions_index)
    
        #we should never get there...
        raise ValueError("RTable->get_qtable_max_reward ->  colIdx not found for state_index:" + str(state_index))
    
        
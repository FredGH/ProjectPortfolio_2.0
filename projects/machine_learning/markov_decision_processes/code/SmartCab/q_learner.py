import numpy as np
from q_table import QTable
from utils import Utilities 

class QLearner(object):
    """The QLearner class contains all required behaviours update the QTable
       rTable: the reward table 
       gamma: the learning rate
       discount_factor: the discount factor
       None means the object is not instantiated for unit testing """
    def __init__(self, rTable, learning_rate = 0.5,discount_factor=0.5,epsilon=0.5):
        self.rTable = rTable
        self.qTable = QTable(rTable)
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.epsilon = epsilon 
        self.states = list(range(len(self.qTable.get_qtable())))
        self.actions = list(range(len(self.qTable.get_qtable().T)))

    def get_all_states(self):
        return self.states
    
    def run_step(self, current_state,use_epsilon_greedy=False,currrent_action_idx =-1, rdm_next_state_idx=-1):
        #set the rdm_currrent_state_idx
        currrent_state_idx =  current_state
        #randomly select the next state
        if (rdm_next_state_idx == -1):
            rdm_next_state_idx =  self.get_next_state_index()
        #select the action_idx 
        if (use_epsilon_greedy == False):
            #randomly select one possible action for the selected state
            if (currrent_action_idx == -1):
                currrent_action_idx = self.get_action_index()
        else:
            if np.random.random() < self.epsilon:
                #select a random action with epsilon probability
                currrent_action_idx = self.get_action_index()
            else:
                #select an action with 1-epsilon probability that gives maximum reward in given state
                currrent_action_idx = self.rTable.get_rtable_max_reward(currrent_state_idx)
        #compute the  Q(state, action)  
        q, old_value, learning_rate, reward, discount_factor, estimate_optional_future_value = self.generate_entry_for_qtable(currrent_state_idx, rdm_next_state_idx, currrent_action_idx)
        #update the qTable for the next run
        self.qTable.set_qtable_element(currrent_state_idx, currrent_action_idx,q)
        return q, old_value, learning_rate, reward, discount_factor, estimate_optional_future_value
        
    def generate_entry_for_qtable(self,current_state_index,next_state_index, action_index):
        old_value = self.qTable.get_qtable_element(current_state_index, action_index)
        learning_rate = self.learning_rate
        reward = self.rTable.get_rtable_element(current_state_index, action_index)
        discount_factor = self.discount_factor
        estimate_optional_future_value = self.qTable.get_qtable_max_value(next_state_index)
        q = old_value + (learning_rate * (reward  + (discount_factor * estimate_optional_future_value) - old_value))
        return q, old_value, learning_rate, reward, discount_factor, estimate_optional_future_value
    
    def get_qtable_best_action(self, state_index):
        return self.qTable.get_qtable_best_action(state_index)
    
    def get_next_state_index(self):
        return np.random.choice(self.states) 
    
    def get_action_index(self):
        return np.random.choice(self.actions) 

    def get_qtable(self):
        return self.qTable

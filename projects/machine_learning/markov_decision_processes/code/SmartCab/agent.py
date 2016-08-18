import random
from environment import Agent, Environment
from planner import RoutePlanner
from simulator import Simulator
from r_table import RTable
from q_learner import QLearner
from utils import Utilities
    
class LearningAgent(Agent):
    
    """An agent that learns to drive in the smartcab world."""
    def __init__(self, env):
        super(LearningAgent, self).__init__(env)  # sets self.env = env, state = None, next_waypoint = None, and a default color
        self.color = 'red'  # override color
        self.planner = RoutePlanner(self.env, self)  # simple route planner to get next_waypoint
        # TODO: Initialize any additional variables here
        #instantiate the reward and the learner objects
        self.rt = RTable (Utilities().get_reward_matrix())
        #self.ql = QLearner(self.rt, 0.5,0.5,0.5)
        #self.ql = QLearner(self.rt, 0.1,0.9,0.5)
        self.ql = QLearner(self.rt, 0.9,0.1,0.5)    
        
    def reset(self, destination=None):
        self.planner.route_to(destination)
        # TODO: Prepare for a new trip; reset any variables here, if required
        self.state = 'None'
        #instantiate the reward and the learner objects
        self.rt = RTable (Utilities().get_reward_matrix())
        #self.ql = QLearner(self.rt, 0.5,0.5,0.5)
        #self.ql = QLearner(self.rt, 0.1,0.9,0.5)
        self.ql = QLearner(self.rt, 0.9,0.1,0.5)
        
    def set_agent_type(self, type):
        self.__type = type

    def update(self, t):
        # Gather inputs        
        self.next_waypoint = self.planner.next_waypoint()  # From route planner, also displayed by simulator
        inputs = self.env.sense(self)
        deadline = self.env.get_deadline(self)
        action = None
        # Select action according to your policy
        if (self.__type == 'random'):
            action = random.choice(Environment.valid_actions[1:]) #get random action
            self.state = self.env.sense(self) #update state
        elif (self.__type == 'identify_and_update_state'):
            #get the intial state 
            self.state = {'next_waypoint': str(self.next_waypoint), 'light': inputs['light'], 'oncoming': inputs['oncoming'], 'left': inputs['left']}
            #update the action
            action_okay = True
            if self.next_waypoint == 'right':
                if inputs['light'] == 'red' and inputs['left'] == 'forward':
                    action_okay = False
            elif self.next_waypoint == 'forward':
                if inputs['light'] == 'red':
                    action_okay = False
            elif self.next_waypoint == 'left':
                if inputs['light'] == 'red' or (inputs['oncoming'] == 'forward' or inputs['oncoming'] == 'right'):
                    action_okay = False
            if action_okay == False:
                action = None
        elif (self.__type == 'q_learning'):
            #get the initial state
            self.state = {'next_waypoint': str(self.next_waypoint), 'light': inputs['light'], 'oncoming': inputs['oncoming'], 'left': inputs['left']}
            #find the corresponding state index
            state_idx = Utilities().parse_state(self.state)
            #learn... i.e compute q and update the q_table
            self.ql.run_step(state_idx,False)
            #update the action
            action = Utilities().parse_action(self.ql.get_qtable_best_action(state_idx))
        elif (self.__type == 'enhanced_q_learning'):
            #get the initial state
            self.state = {'next_waypoint': str(self.next_waypoint), 'light': inputs['light'], 'oncoming': inputs['oncoming'], 'left': inputs['left']}
            #find the corresponding state index
            state_idx = Utilities().parse_state(self.state)
            #learn... i.e compute q and update the q_table
            self.ql.run_step(state_idx,True)
            #update the action
            action = Utilities().parse_action(self.ql.get_qtable_best_action(state_idx))
        else:
            print "Type not supported: " + str(self.__type)     
        
        # TODO: Learn policy based on state, action, reward
        inputs = self.env.sense(self)

        # Execute action and get reward
        reward = self.env.act(self, action)
        #print "DummyAgent.update(): t = {}, inputs = {}, action = {}, reward = {}".format(t, inputs, action, reward)  # [debug]
        #print "DummyAgent.update(): next_waypoint = {}".format(self.next_waypoint)  # [debug]

        print "LearningAgent.update(): deadline = {}, inputs = {}, action = {}, reward = {}".format(deadline, inputs, action, reward)  # [debug]
        

def run():
    """Run the agent for a finite number of trials."""
    # Set up environment and  agent
    e = Environment()  # create environment (also adds some dummy traffic)
    a = e.create_agent(LearningAgent)  # create agent
    #choose the state policy based on the different example ('random','identify_and_update_state','q_learning','enhanced_q_learning')
    agent_type = 'enhanced_q_learning'
    #default params
    agent_n_trials=10
    agent_enforce_deadline= False
    #override default params
    if (agent_type ==  'q_learning' or agent_type ==  'enhanced_q_learning') :
        agent_enforce_deadline= True
    if (agent_type ==  'enhanced_q_learning'):
        agent_n_trials=100
    
    print "******** run *********"
    print "agent_n_trials: " + str(agent_n_trials)
    print "agent_enforce_deadline: " + str(agent_enforce_deadline)
    
    a.set_agent_type(agent_type)
    e.set_primary_agent(a, enforce_deadline=agent_enforce_deadline)  # set agent to track

    # Now simulate it
    sim = Simulator(e, update_delay=0.1)  # reduce update_delay to speed up simulation
    sim.run(n_trials=agent_n_trials)  # press Esc or close pygame window to quit

if __name__ == '__main__':
    run()
    
    
            

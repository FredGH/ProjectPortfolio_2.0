import unittest
from  SmartCab.r_table import RTable
from  SmartCab.q_learner import QLearner
from  SmartCab.utils import Utilities
  
class QLearnerTest(unittest.TestCase): #sub classing 
    """Tests for the QLearner """
    def setUp(self):
        """Fixture that create required objects or conn for below tests """
        pass
     
    def tearDown(self):
        """Fixture that deletes  objects or conn once tests are completed """
        try:
            """code here """    
        except:
            pass
     
    def testQLearnerCreation(self):
        #print ("########## Start Testing testQLearnerCreation ##########")
        state = {'next_waypoint': 'left', 'light': 'red', 'oncoming': None, 'left': None}
        rt = RTable (Utilities().get_reward_matrix())
        ql = QLearner(rt, 0.5,0.5)
        state_idx = Utilities().parse_state(self.state)
        q, old_value, learning_rate, reward, discount_factor, estimate_optional_future_value = ql.run_step(state_idx, rdm_currrent_action_idx =2, rdm_next_state_idx=3)
        
        #self.assertEqual(0.0, q)
        #self.assertEqual(0.0, old_value)
        #self.assertEqual(0.5, learning_rate)
        #self.assertEqual(0.5, reward)
        #self.assertEqual(0.0, discount_factor)
        #self.assertEqual(0.0, estimate_optional_future_value)
        
        
#     def testQLearnerLimitedRun(self):
#         print ("########## Start Testing testQLearnerLimitedRun ##########")
#         rt = RTable (Utilities().get_reward_matrix())
#         qltp = QLearnerTestParam(15,1,3) #test_current_state_idx,#test_next_state_idx, test_action_idx
#         ql = QLearner(rt, 0.5, 12, qltp)
#         ql.run()
#         
#         qtable = ql.get_qtable()
#  
#         print qtable       
#         self.assertEqual(0.0, qtable.get_qtable_element(1,0))
#         self.assertEqual(0.0, qtable.get_qtable_element(1,1)) 
#         self.assertEqual(0.0, qtable.get_qtable_element(1,2)) 
#         self.assertEqual(12.0, qtable.get_qtable_element(1,3)) 
#         
#         self.assertEqual(0.0, qtable.get_qtable_element(15,0)) 
#         self.assertEqual(0.0, qtable.get_qtable_element(15,1)) 
#         self.assertEqual(0.0, qtable.get_qtable_element(15,2)) 
#         self.assertEqual(1.5, qtable.get_qtable_element(15,3)) 
#         
#         #ensure only two items exist in the list
#         qtable = ql.get_qtable().get_qtable()
#         print qtable
#         self.assertEqual(16, len(qtable))
# 
#     def testQLearnerFullRun(self):
#         print ("########## Start Testing testQLearnerFullRun ##########")
#         rt = RTable (Utilities().get_reward_matrix())
#         ql = QLearner(rt, 0.5, 12, None)
#         ql.run()
#         
#         #ensure there is a least one step...
#         qtable= ql.get_qtable().get_qtable()
#         print qtable 
#         self.assertEqual(16, len(qtable))
#         
#     def testFileDeletionAndLogging(self):
#         print ("########## Start test  ##########")
#         filePath = 'C:\\temp\\log.csv'
#         Utilities().delete_file(filePath)
#         lgr = Utilities().log('TestLogger', filePath)
#         
#         # You can now start issuing logging statements in your code
#         #lgr.debug('a debug message')y
#         #lgr.info('an info message')
#         lgr.warn('A Checkout this warning.')
#         #lgr.error('An error written here.')
#         #lgr.critical('Test1 Something very critical happened.')
#   
if __name__ == "__main__":
    unittest.main()
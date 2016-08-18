import unittest
import numpy as np
from  SmartCab.q_table import QTable
from  SmartCab.r_table import RTable
 
class QTableTests(unittest.TestCase): #sub classing 
    """Tests for the QTable """
    def setUp(self):
        """Fixture that create required objects or conn for below tests """
        pass
    
    def tearDown(self):
        """Fixture that deletes  objects or conn once tests are completed """
        try:
            """code here """    
        except:
            pass
    
    def testQTableCreation(self):
        print ("########## Start Testing testQTableCreation ##########")
        reward_matrix = np.zeros((4,4), dtype=np.float)
        rt = RTable (reward_matrix)
        qt = QTable(rt)
        
        expected_qtable = np.zeros((4,4), dtype=np.float)
        
        print qt.get_qtable()
        self.assertTrue (np.alltrue(expected_qtable == qt.get_qtable()))
        
        
    def testGetSetQTableElement(self):
        print ("########## Start Testing testGetSetQTableElement ##########")
        reward_matrix = np.zeros((4,4), dtype=np.float)
        rt = RTable (reward_matrix)
        qt = QTable(rt)
        
        value = 100.0
        qt.set_qtable_element(2, 1, value)
        
        print qt.get_qtable()
        self.assertTrue (value, qt.get_qtable_element(2, 1))
        
        
    def testGetQTableMax(self):
        print ("########## Start Testing testGetQTableMax ##########")
        reward_matrix = np.zeros((4,4), dtype=np.float)
        rt = RTable (reward_matrix)
        qt = QTable(rt)
        
        value = 100.0
        state_index = 2
        qt.set_qtable_element(state_index, 1, value)
        max_value = qt.get_qtable_max_value(2)
        
        print max_value
        self.assertEqual (value, max_value, "The max value is incorrect (expected 100) actual value: " + str(max_value) )
  
if __name__ == "__main__":
    unittest.main()
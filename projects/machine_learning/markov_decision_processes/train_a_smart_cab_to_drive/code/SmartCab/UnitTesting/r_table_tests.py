import unittest
import numpy as np
from  SmartCab.r_table import RTable
 
class RTableTests(unittest.TestCase): #sub classing 
    """Tests for the RTable """
    def setUp(self):
        """Fixture that create required objects or conn for below tests """
        pass
    
    def tearDown(self):
        """Fixture that deletes  objects or conn once tests are completed """
        try:
            """code here """    
        except:
            pass
    
    def testRTableCreation(self):
        print ("########## Start Testing testRTableCreation ##########")
        reward_matrix = np.zeros((4,4), dtype=np.float)
        rt = RTable(reward_matrix)
        
        print ("### Start Testing reward_matrix ####")
        expected_reward_table = reward_matrix
        
        print  rt.get_rtable()
        self.assertTrue (np.alltrue(expected_reward_table == rt.get_rtable()))
        
    
    def testGetRTableElement(self):
        print ("########## Start Testing testGetRTableElement ##########")
        reward_matrix = np.zeros((4,4), dtype=np.float)
        rt = RTable(reward_matrix)
        
        print rt.get_rtable()
        self.assertEqual(0.0, rt.get_rtable_element(2, 1))
  
if __name__ == "__main__":
    unittest.main()
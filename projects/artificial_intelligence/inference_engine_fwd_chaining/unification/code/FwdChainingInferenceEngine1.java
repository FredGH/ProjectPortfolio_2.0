//*****************
//***************** Forward Chaining Inference Algorithm
//***************** Created By Frederic Marechal on 11/01/2017
//*****************
package AI;
import java.util.*;

public class FwdChainingInferenceEngine1 {

	final int ruleIdNotFound =-1;
	static Boolean goalIsReached = false;
	static boolean countCheck = true; 
	static int count = 0;

	//Contains the list of rules with all variable replacement when a this is required, 
	//i.e. when List<RuleVariableValue> contains a non empty list of elements.
	//When a rule is mapped against an empty List<RuleVariableValue>, then no variable replacement is required. 
	//Key= RuleName, Value is a RuleVariableValue tuple => a variable against a value
	//For a given rule, more than one variable could have more than one value
	static Hashtable<Integer, ArrayList<ArrayList<RuleVariableValue>>>  htRulesValues; 
	static List<Integer>  visitedRuleIds; 
	
	private static void print(String message)
	{
		System.out.println(message);
	}
	
	@SuppressWarnings({ "serial", "unused" })
	private static InferenceEngineInputTuple simpleCaseExample (final FwdChainingInferenceEngine1 fcie) throws Exception
	{
		print ("");
		print ("***********");
		print ("Coursework Case");
		print ("***********");
		print ("");
		
		countCheck = false;
		
		final Item item0 = fcie.new Item(0,"f");
		final Item item1 = fcie.new Item(1,"?");
		final Item item2 = fcie.new Item(2,"h");
		final Item item3 = fcie.new Item(3,"a");
		final Item item4 = fcie.new Item(4,"c");
		final Item item5 = fcie.new Item(5,"b");
		final Item item6 = fcie.new Item(6,"g");
		final Item item7 = fcie.new Item(7,"n");
		final Item item8 = fcie.new Item(8,"s");
		final Item item9 = fcie.new Item(9,"e");
		final Item item10 = fcie.new Item(10,"m");
		final Item item11 = fcie.new Item(11,"r");
		final Item item12 = fcie.new Item(12,"t");
		final Item item13 = fcie.new Item(13,"d");
		final Item item14 = fcie.new Item(14,"j");
		final Item item15 = fcie.new Item(15,"k");
		final Item item16 = fcie.new Item(16,"i");
		final Item item17 = fcie.new Item(17,"p");
		final Item item18 = fcie.new Item(18,"q");
		final Item item19 = fcie.new Item(19,"u");
		final Item item20 = fcie.new Item(20,"v");
		//final Item item21 = fcie.new Item(21,"z");
		print("");
		print("***Create the fact list");
		final Fact fact1 = new Fact(1, new ArrayList<Item>(){{add(item1.deepCopy());add(item2);/*add(item21);*/}}); //? h
		final Fact fact2 = new Fact(2, new ArrayList<Item>(){{add(item3);add(item4);}}); // a c
		final Fact fact3 = new Fact(3, new ArrayList<Item>(){{add(item7);add(item8);}}); // n s 
		final Fact fact4 = new Fact(4, new ArrayList<Item>(){{add(item11);add(item1.deepCopy());}}); // r ?
		final Fact fact5 = new Fact(5, new ArrayList<Item>(){{add(item1.deepCopy());add(item14);/*add(item21);*/}}); // ? j
		final Fact fact6 = new Fact(6, new ArrayList<Item>(){{add(item9);add(item10);}}); // e m
		final Fact fact7 = new Fact(7, new ArrayList<Item>(){{add(item15);add(item16);}}); // k i
		final Fact fact8 = new Fact(8, new ArrayList<Item>(){{add(item17);add(item1.deepCopy());}}); // p ?
		final Fact fact9 = new Fact(9, new ArrayList<Item>(){{add(item1.deepCopy());add(item20);}}); // ? v
		print("");
		print("***Create the consequent list");
		final Consequent consequent1 = fcie.new Consequent(100, new ArrayList<Item>(){{add(item5);add(item6);}}); //b g
		final Consequent consequent2 = fcie.new Consequent(6, new ArrayList<Item>(){{add(item9);add(item10);}}); //e m
		final Consequent consequent3 = fcie.new Consequent(8, new ArrayList<Item>(){{add(item17);add(item18);}}); // p q
		final Consequent consequent4 = fcie.new Consequent(2, new ArrayList<Item>(){{add(item3);add(item4);}}); //a c
		final Consequent consequent5 = fcie.new Consequent(3, new ArrayList<Item>(){{add(item7);add(item8);}}); // n s 
		final Consequent consequent6 = fcie.new Consequent(7, new ArrayList<Item>(){{add(item15);add(item16);}}); // k i   
		print("");
		print("***Create the RuleBase data structure and add rules");
		RuleBase ruleBase = fcie.new RuleBase();
		ruleBase.addRule(fcie.new Rule(1, new ArrayList<Fact>(){{add(fact1);add(fact2);}}, consequent1)); 
		ruleBase.addRule(fcie.new Rule(2, new ArrayList<Fact>(){{add(fact3);}}, consequent2));
		ruleBase.addRule(fcie.new Rule(3, new ArrayList<Fact>(){{add(fact4);}}, consequent3));
		ruleBase.addRule(fcie.new Rule(4, new ArrayList<Fact>(){{add(fact5);add(fact6);add(fact7);}}, consequent4));
		ruleBase.addRule(fcie.new Rule(5, new ArrayList<Fact>(){{add(fact8);}}, consequent5));
		ruleBase.addRule(fcie.new Rule(6, new ArrayList<Fact>(){{add(fact9);}}, consequent6));
		print("");
		print("***Create the WorkingMemory and add facts");
		WorkingMemory workingMemory = fcie.new WorkingMemory();
		workingMemory.addFact(new Fact(1, new ArrayList<Item>(){{add(item0);add(item2);}})); // f h
		workingMemory.addFact(new Fact(5, new ArrayList<Item>(){{add(item13);add(item14);/*add(item21);*/}})); // d j
		workingMemory.addFact(new Fact(9, new ArrayList<Item>(){{add(item19);add(item20);}})); // u v
		workingMemory.addFact(new Fact(4, new ArrayList<Item>(){{add(item11);add(item12);}})); // r t
		
		return new InferenceEngineInputTuple(ruleBase, workingMemory);
	}
	
	@SuppressWarnings({ "serial", "unused" })
	private static InferenceEngineInputTuple block3Example (final FwdChainingInferenceEngine1 fcie) throws Exception
	{
		print ("");
		print ("***********");
		print ("Block3 Case");
		print ("***********");
		print ("");
		
		countCheck = true;
		
		print("***Create the item list");
		final Item item1 = fcie.new Item(1,"clear A");
		final Item item2 = fcie.new Item(2,"A on B");
		final Item item3 = fcie.new Item(3,"B on C");
		final Item item4 = fcie.new Item(4,"C on table");
		final Item item5 = fcie.new Item(5, "?x on ?y");
		final Item item6 = fcie.new Item(6,"clear ?x");
		final Item item7 = fcie.new Item(7,"clear ?z");
		final Item item8 = fcie.new Item(8,"clear ?y");
		final Item item9 = fcie.new Item(9,"?x on table");
		final Item item10 = fcie.new Item(10,"?x on ?z") ;
		final Item item11 = fcie.new Item(11,"A on table");
		final Item item12 = fcie.new Item(12,"clear B");
		final Item item13 = fcie.new Item(13,"B on table");
		final Item item14 = fcie.new Item(14,"clear C");
		final Item item15 = fcie.new Item(15,"C on table");
		print("");
		print("***Create the fact list");
		final Fact fact1 = new Fact(1, new ArrayList<Item>(){{add(item5.deepCopy());}}); //(?x on ?y) 
		final Fact fact2 = new Fact(2, new ArrayList<Item>(){{add(item6.deepCopy());}}); //(clear ?x) 
		final Fact fact3 = new Fact(3, new ArrayList<Item>(){{add(item7.deepCopy());}}); //(clear ?z)
		final Fact fact4 = new Fact(4, new ArrayList<Item>(){{add(item9.deepCopy());}}); //(?x on table)
		final Fact fact5 = new Fact(5, new ArrayList<Item>(){{add(item10.deepCopy());}}); //(?x on ?z) 
		print("");
		print("***Create the consequent list");
		final Consequent consequent1 = fcie.new Consequent(1, new ArrayList<Item>(){{
															add(fcie.new Item(Action.DELETE,item5.getId(), item5.getLabel())); //DELETE (?x on ?y)
															add(fcie.new Item(Action.DELETE,item7.getId(), item7.getLabel())); //DELETE  (clear ?z)
															add(fcie.new Item(Action.ADD,item10.getId(), item10.getLabel()));  //ADD (?x on ?z)
															add(fcie.new Item(Action.ADD,item8.getId(), item8.getLabel()));    //ADD  (clear ?y) 
															}});
		final Consequent consequent2 = fcie.new Consequent(2, new ArrayList<Item>(){{
															add(fcie.new Item(Action.DELETE,item5.getId(), item5.getLabel())); //DELETE (?x on ?y)
															add(fcie.new Item(Action.ADD,item9.getId(), item9.getLabel())); //ADD (?x on table)
															add(fcie.new Item(Action.ADD,item8.getId(), item8.getLabel())); //ADD (clear ?y)
															}});
		final Consequent consequent3 = fcie.new Consequent(3, new ArrayList<Item>(){{
															add(fcie.new Item(Action.DELETE,item9.getId(), item9.getLabel())); //DELETE (?x on table)
															add(fcie.new Item(Action.DELETE,item7.getId(), item7.getLabel())); //DELETE (clear ?z)
															add(fcie.new Item(Action.ADD,item10.getId(), item10.getLabel())); //ADD (?x on ?z)
															}});
		print("");
		print("***Create the RuleBase data structure and add rules");
		RuleBase ruleBase = fcie.new RuleBase();
		ruleBase.addRule(fcie.new Rule(1, new ArrayList<Fact>(){{add(fact1);add(fact2);add(fact3);}}, consequent1));
		ruleBase.addRule(fcie.new Rule(2, new ArrayList<Fact>(){{add(fact1);add(fact2);}}, consequent2));
		ruleBase.addRule(fcie.new Rule(3, new ArrayList<Fact>(){{add(fact4);add(fact2);add(fact3);}}, consequent3)); 
		print("");
		print("***Create the WorkingMemory and add facts");
		WorkingMemory workingMemory = fcie.new WorkingMemory();
		workingMemory.addFact(new Fact(1, new ArrayList<Item>(){{add(item1);}})); //clear A
		workingMemory.addFact(new Fact(2, new ArrayList<Item>(){{add(item2);;}})); //A on B
		workingMemory.addFact(new Fact(3, new ArrayList<Item>(){{add(item3);}})); //B on C
		workingMemory.addFact(new Fact(4, new ArrayList<Item>(){{add(item4);}})); //C on table
		
		return new InferenceEngineInputTuple(ruleBase, workingMemory);
	}
	
	@SuppressWarnings({ "serial", "unused" })
	private static InferenceEngineInputTuple block4Example (final FwdChainingInferenceEngine1 fcie) throws Exception
	{
		print ("");
		print ("***********");
		print ("Block4 Case");
		print ("***********");
		print ("");
		
		countCheck = true;
		
		print("***Create the item list");
		final Item item1 = fcie.new Item(1,"clear A");
		final Item item2 = fcie.new Item(2,"A on B");
		final Item item3 = fcie.new Item(3,"B on C");
		final Item item4 = fcie.new Item(4,"C on table");
		final Item item5 = fcie.new Item(5, "?x on ?y");
		final Item item6 = fcie.new Item(6,"clear ?x");
		final Item item7 = fcie.new Item(7,"clear ?z");
		final Item item8 = fcie.new Item(8,"clear ?y");
		final Item item9 = fcie.new Item(9,"?x on table");
		final Item item10 = fcie.new Item(10,"?x on ?z") ;
		final Item item11 = fcie.new Item(11,"A on table");
		final Item item12 = fcie.new Item(12,"clear B");
		final Item item13 = fcie.new Item(13,"B on table");
		final Item item14 = fcie.new Item(14,"clear C");
		final Item item15 = fcie.new Item(15,"C on table");			
		final Item item16 = fcie.new Item(16,"A on C");
		final Item item17 = fcie.new Item(17,"clear D");
		final Item item18 = fcie.new Item(18,"D on B");
		print("");
		print("***Create the fact list");
		final Fact fact1 = new Fact(1, new ArrayList<Item>(){{add(item5.deepCopy());}}); //(?x on ?y) 
		final Fact fact2 = new Fact(2, new ArrayList<Item>(){{add(item6.deepCopy());}}); //(clear ?x) 
		final Fact fact3 = new Fact(3, new ArrayList<Item>(){{add(item7.deepCopy());}}); //(clear ?z)
		final Fact fact4 = new Fact(4, new ArrayList<Item>(){{add(item9.deepCopy());}}); //(?x on table)
		final Fact fact5 = new Fact(5, new ArrayList<Item>(){{add(item10.deepCopy());}}); //(?x on ?z) 
		print("");
		print("***Create the consequent list");
		final Consequent consequent1 = fcie.new Consequent(1, new ArrayList<Item>(){{
															add(fcie.new Item(Action.DELETE,item5.getId(), item5.getLabel())); //DELETE (?x on ?y)
															add(fcie.new Item(Action.DELETE,item7.getId(), item7.getLabel())); //DELETE  (clear ?z)
															add(fcie.new Item(Action.ADD,item10.getId(), item10.getLabel()));  //ADD (?x on ?z)
															add(fcie.new Item(Action.ADD,item8.getId(), item8.getLabel()));    //ADD  (clear ?y) 
															}});
		final Consequent consequent2 = fcie.new Consequent(2, new ArrayList<Item>(){{
															add(fcie.new Item(Action.DELETE,item5.getId(), item5.getLabel())); //DELETE (?x on ?y)
															add(fcie.new Item(Action.ADD,item9.getId(), item9.getLabel())); //ADD (?x on table)
															add(fcie.new Item(Action.ADD,item8.getId(), item8.getLabel())); //ADD (clear ?y)
															}});
		final Consequent consequent3 = fcie.new Consequent(3, new ArrayList<Item>(){{
															add(fcie.new Item(Action.DELETE,item9.getId(), item9.getLabel())); //DELETE (?x on table)
															add(fcie.new Item(Action.DELETE,item7.getId(), item7.getLabel())); //DELETE (clear ?z)
															add(fcie.new Item(Action.ADD,item10.getId(), item10.getLabel())); //ADD (?x on ?z)
															}});
		print("");
		print("***Create the RuleBase data structure and add rules");
		RuleBase ruleBase = fcie.new RuleBase();
		ruleBase.addRule(fcie.new Rule(1, new ArrayList<Fact>(){{add(fact1);add(fact2);add(fact3);}}, consequent1));
		ruleBase.addRule(fcie.new Rule(2, new ArrayList<Fact>(){{add(fact1);add(fact2);}}, consequent2));
		ruleBase.addRule(fcie.new Rule(3, new ArrayList<Fact>(){{add(fact4);add(fact2);add(fact3);}}, consequent3)); 
		print("");
		print("***Create the WorkingMemory and add facts");
		WorkingMemory workingMemory = fcie.new WorkingMemory();
		workingMemory.addFact(new Fact(1, new ArrayList<Item>(){{add(item16);}})); //A on C
		workingMemory.addFact(new Fact(2, new ArrayList<Item>(){{add(item4);}})); //C on table
		workingMemory.addFact(new Fact(3, new ArrayList<Item>(){{add(item1);}})); //clear A
		workingMemory.addFact(new Fact(4, new ArrayList<Item>(){{add(item17);}})); //clear D
		workingMemory.addFact(new Fact(5, new ArrayList<Item>(){{add(item18);}})); //D on B
		workingMemory.addFact(new Fact(5, new ArrayList<Item>(){{add(item13);}})); //B on table
		
		return new InferenceEngineInputTuple(ruleBase, workingMemory);
	}

	public static void main(String[] args) {
		try {
			final FwdChainingInferenceEngine1 fcie = new FwdChainingInferenceEngine1();
			
			InferenceEngineInputTuple inferenceEngineInputTuple = null;
			
			//inferenceEngineInputTuple = simpleCaseExample(fcie);
			inferenceEngineInputTuple = block3Example(fcie);
			//inferenceEngineInputTuple = block4Example(fcie);
			
			print("");
			print("***Create InferenceEngine and start the inference process");
			visitedRuleIds =  new ArrayList<Integer>();
			
			InferenceEngine inferenceEngine = fcie.new InferenceEngine(	inferenceEngineInputTuple.getRuleBase(),
																		inferenceEngineInputTuple.getWorkingMemory() );
			boolean res = inferenceEngine.execute();
			//Stop, as inference could not be proven!
			if (res == false){
				print("FAILURE");
				return;
			}
			//Success!	
			print("SUCCESS / ALL RULES HAVE BEEN PROVEN!");
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public class InferenceEngine {

		private RuleBase ruleBase; 
		private WorkingMemory workingMemory;
		
		public InferenceEngine(RuleBase ruleBase, WorkingMemory workingMemory ) throws Exception{
			this.ruleBase = ruleBase;
			this.workingMemory = workingMemory;
			
			if (this.ruleBase == null) {throw new Exception ("InferenceEngine -> The ruleBase cannot be null" );}
		}
		
		//Starts the engine
		public boolean execute()
		{
			try {

				print("***The 'infer' method is executed");
				return infer();
				
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			return false;
		}
		
		//Infer does the match, select and act recursively
		private boolean infer() throws Exception {
			
			htRulesValues = new Hashtable<Integer, ArrayList<ArrayList<RuleVariableValue>>>();
			
			print("***MATCH Rule with antecedent");
			int ruleId =  this.getRuleId(this.workingMemory);
			if (ruleId == ruleIdNotFound){
				return false;
			}

			print("***SELECT a rule");
			Rule rule = this.select (ruleId);
			print("Rule selected: " + rule.id );
			
			print("***Unify rule variables (binds variables with constants)");
			Rule unifiedRule = this.unify(rule, 0);
			print("Rule Unified: " + rule.id );
			
			print ("***ACT - Attempt to add Fact to working memory");
			act(unifiedRule.getConsequent());
						
			if (count < this.ruleBase.getRulesCount()-1){
				count++;
				Boolean res = infer();
				if (res == false){
					return false;
				}
			}
			return true;
		}

		public int getRuleId(WorkingMemory workingMemory){ 
			int ruleId = this.ruleBase.getRuleId(workingMemory);
			if (ruleId <0){
				print ("No Rule id cannot be found that matches the working memory.");
			}
			return ruleId;
		}
		
		public List<Fact> matchASubGoalWithAntecedents(Rule rule) throws Exception{
			List<Fact> antecedents = rule.getAntecedents();
			if (rule.getAntecedents() ==null){
				throw new Exception ("There is no antecedant for rule id: " + rule.getId() );
			}
			return antecedents;
		}

		public Rule select(int ruleId) throws Exception{
			Rule rule = this.ruleBase.getRule(ruleId);
			return rule;
		}
		
		public Rule unify(Rule rule, int index) throws Exception{
			return ruleBase.unify (rule, 0, htRulesValues);
		}
		
		public void act(Consequent consequent) throws Exception{
			for (int i =0; i<consequent.getItems().size(); i++){
				Item itemConsequent  = consequent.getItems().get(i);
				if (itemConsequent.getAction() != Action.NONE){
					int randFactId = (int) (System.currentTimeMillis() & 0xfffffff);
					List<Item> items =new ArrayList<Item>();
					items.add(itemConsequent);
					if (itemConsequent.getAction() == Action.ADD){
						this.workingMemory.addFact(new Fact(randFactId, items));
					}else if (itemConsequent.getAction() == Action.DELETE){
						this.workingMemory.removeFact(new Fact(randFactId, items));
					}
					else {
						throw new Exception ("InferenceEngine -> act -  consequent key: " + consequent.getId() +" 'action' not supported (only ADD and DELETE supported)");
					}
				}
				else{
					this.workingMemory.addFact(consequent);
					break;
				}
			}
		}
	}
	
	public class WorkingMemory{
		private ArrayList<Fact> facts;
		
		public WorkingMemory (){
			this.facts = new ArrayList<Fact>();
		}
		
		public ArrayList<Fact> getFacts(){ return this.facts;}
		
		public void addFact(Fact fact) throws Exception{
			WorkingMemoryFactInfo workingMemoryFactInfo = this.getFactInfo(fact);
			if (workingMemoryFactInfo.getExistsFlag()){
				print ("WorkingMemory -> addFact - labels: " + fact.getLabelsNoAction() +" already contained in the working memory.");
			}
		
			facts.add(fact);
			print("WorkingMemory -> addFact - key: " + fact.id + " - Fact:" + fact.getLabelsNoAction());
			display();
		}
		
		public void removeFact(Fact fact) throws Exception{
			WorkingMemoryFactInfo workingMemoryFactInfo = this.getFactInfo(fact);
			if ( workingMemoryFactInfo.getExistsFlag()){
				facts.remove( workingMemoryFactInfo.getIndex());
				print("WorkingMemory -> removeFact - key: " + fact.id + " - Fact:" + fact.getLabels());
				display();
				return;
			}
			
			throw new Exception ("WorkingMemory -> removeFact - labels: " + fact.getLabels() +" cannot be removed as it does not exists in the working memory.");
		}
		
		public WorkingMemoryFactInfo getFactInfo(Fact fact){
			for (int i = 0; i< this.facts.size(); i++){
				if (Fact.areEqual(this.facts.get(i), fact)){
					return new WorkingMemoryFactInfo(true, i);
				}
			}
			return new WorkingMemoryFactInfo(false, -1);
		}
		
		public class WorkingMemoryFactInfo {
		    public boolean exists; // indicates where the fact exists in the working memory
		    public int index; //position in the working memory

		    public WorkingMemoryFactInfo(boolean exists, int index) {
		        this.exists = exists;
		        this.index = index;
		    }
		    
		    public boolean getExistsFlag() {return this.exists;}
		    public int getIndex() {return this.index;}
		}
		
		private void display(){
			StringBuilder sb = new StringBuilder(); 
			String factLabel = null;
			sb.append("Working Memory State: ( ");
			for (int i = 0; i< facts.size(); i++){
				factLabel = facts.get(i).getLabelsNoAction();
				sb.append(factLabel);
			}
			print(sb.toString() + " )");
		}
	}
	
	public class RuleBase{
		
		private Hashtable<Integer, Rule> rules;
		
		public RuleBase (){
			this.rules = new Hashtable<Integer, Rule>();
		}
		
		public void addRule(Rule rule ) throws Exception{
			if (this.rules.containsKey(rule.getId())){
				throw new Exception ("RuleBase -> addRules - key: " + rule.getId() +" already contained in hashtable.");
			}
				
			rules.put(rule.getId(), rule);
			print("RuleBase -> addRules - key: " + rule.getId());
		}
		
		public Rule getRule(int ruleId){
			return rules.get(ruleId);
		}
		
		public int getRulesCount(){
			return rules.size();
		}
		
		//http://www.doc.ic.ac.uk/~sgc/teaching/pre2012/v231/lecture8.html
		public Rule unify(Rule rule, int index, Hashtable<Integer,ArrayList<ArrayList<RuleVariableValue>>> htRulesValues){
			Rule copyRule = rule.deepCopy();
			ArrayList<RuleVariableValue> unifiedlist = new ArrayList<RuleVariableValue>(); 
			ArrayList<ArrayList<RuleVariableValue>> list = htRulesValues.get(copyRule.getId());
			if (list!=null){
				Hashtable<String, RuleVariableValueCount> ht = new Hashtable<String, RuleVariableValueCount>();
				int countVariables = list.get(index).size();
				int m = 0;
				while (m < countVariables)
				{
					for (int k=0; k<list.size(); k++){
						ArrayList<RuleVariableValue> currentRuleVariableValues  = list.get(k);
						if (currentRuleVariableValues.size() == countVariables){
							String variableName = currentRuleVariableValues.get(m).getVariableName();
							RuleVariableValueCount ruleVariableValueCount;
							if (!ht.containsKey(variableName)){
								ruleVariableValueCount = new RuleVariableValueCount (currentRuleVariableValues.get(m), 1);
								ht.put(variableName, ruleVariableValueCount);
							}else{
								ruleVariableValueCount = ht.get(variableName);
								ht.remove(variableName);
								ruleVariableValueCount = new RuleVariableValueCount (ruleVariableValueCount.getRuleVariableValue(), ruleVariableValueCount.getCount()+1);
								ht.put(variableName, ruleVariableValueCount);
							}
						}
					}
					//Find the variableName Vs variableValue that occurs the most often
					int maxFreq = 0;
					String maxKey = "";
					if (ht.size() > 0){
						for (String key: ht.keySet()){
							RuleVariableValueCount currentRuleVariableValue = ht.get(key);
							int currentCount = currentRuleVariableValue.getCount();
							if (maxFreq < currentCount){
								maxFreq = currentCount;
								maxKey = key;
							}
						}
						unifiedlist.add(ht.get(maxKey).getRuleVariableValue());
					}
					m++;
				}
				
				ArrayList<RuleVariableValue> ruleVariableValues = unifiedlist;
				//ruleVariableValues = list.get(index);
				if (ruleVariableValues.size() > 0){
					//case where one or more variable(s) replacement is needed
					for (int i=0; i<ruleVariableValues.size(); i++){
						RuleVariableValue ruleVariableValue = ruleVariableValues.get(i).deepCopy();
						replaceVariableByConstant(ruleVariableValue.variableName, ruleVariableValue.variableValue, copyRule);
					}
				}
			}
			return copyRule;
		}
		
		private int expectedVariableCount(String[] splits){
			int count = 0;
			for (String str : splits){ 
			    if (str.contains("?"))
			        count++;
			}
			return count;
		}
		
		private int workingMemoryValueCount(String[] splits){
			int count = 0;
			for (String str : splits){
				str = str.trim().toLowerCase();
			    if (str.equals("on") || str.equals("table") || str.equals("clear"))
			        count++;
			}
			return splits.length - count;
		}
		
		private int getBranchIndex(ArrayList<ArrayList<RuleVariableValue>> list,String antecedentElem ){
			int index = 0;
			for (ArrayList<RuleVariableValue> rvvs :list){
				for (RuleVariableValue rvv :rvvs){
					if (rvv.getVariableName().equals(antecedentElem)){
						index++;
						break;
					}
				}
			}
			return index;
		}
		
		private Boolean isVariableAlreadyMappedToGivenValue(ArrayList<ArrayList<RuleVariableValue>> list,
															String antecedentElem, String wmElem ){
			if (list !=null){
				for (ArrayList<RuleVariableValue> rvvs :list){
					for (RuleVariableValue rvv :rvvs){
						if (rvv.getVariableName().equals(antecedentElem) &&
							rvv.getVariableValue().equals(wmElem)	){
							return true;
						}
					}
				}
			}
			return false;
		}
		
		@SuppressWarnings({ "unchecked","rawtypes" })
		private Boolean isVariablesValueUnique(ArrayList<RuleVariableValue> ruleVariableValues){
			Set set = new HashSet();
			for (RuleVariableValue ruleVariableValue:ruleVariableValues){
				set.add(ruleVariableValue.getVariableValue());
			}
			return (ruleVariableValues.size() == set.size());
		}
		
		private Boolean canContinue(String[] antecedentSplits, String[] wmSplits, Boolean countCheck){
			
			int countExpectedVariables =  expectedVariableCount(antecedentSplits);
			int countExpectedValues = workingMemoryValueCount(wmSplits);
			if(countCheck){
				return (wmSplits.length == antecedentSplits.length && 
						countExpectedVariables == countExpectedValues);
			}
			return (wmSplits.length == antecedentSplits.length);
		}
		
		private Boolean isValueInWM(String antecedentLabels, WorkingMemory workingMemory){
			for(Fact fact: workingMemory.getFacts()){
				if (antecedentLabels.equals(fact.getRawLabels()))
					return true;
			}
			return false;
		}
		
		public int getRuleId(WorkingMemory workingMemory){
			for ( int i =1; i <= this.rules.size(); i++){
				Rule rule = this.rules.get(i);
				Integer ruleId = rule.getId();
				//Check to avoid infinite loop
				if (visitedRuleIds.contains(ruleId)){continue;}
				//If no variable in antecedent list, the check all items are present in the WM.
				//if 'yes' return the rule, else 'continue'
				Integer foundRuleId = matchWorkingMemoryWithAntecedent(rule, workingMemory);
				if (foundRuleId != ruleIdNotFound){
					return foundRuleId;
				}
				List<Fact> antecedents= rule.getAntecedents();
				for ( int f =0; f < antecedents.size(); f++){
					int branchId = 0;
					String antecedentLabels  = antecedents.get(f).getRawLabels();
					if (!antecedentLabels.contains("?")){
						if (!isValueInWM(antecedentLabels, workingMemory)){
							if(htRulesValues.containsKey(ruleId)){
								htRulesValues.remove(ruleId);
								break;
							}
						}
					}
					//This section relates to going through the list of antecedents (for a given rule)
					//and map each variable with a constant. A rule may have more than one mapping.
					//The mapping is stored in the htRulesValues table. 
					String[] antecedentSplits = antecedentLabels.split(" ");
					for (int k=0; k<workingMemory.getFacts().size(); k++){
						String wmLabels = workingMemory.getFacts().get(k).getRawLabels();
						String[] wmSplits = wmLabels.split(" ");
						if (canContinue(antecedentSplits,wmSplits, countCheck )){
							for (int idx=0; idx<wmSplits.length; idx++){
								String antecedentElem = antecedentSplits[idx];
								final String wmElem = wmSplits[idx];
								if (antecedentElem.contains("?")){
									RuleVariableValue ruleVariableValue = new RuleVariableValue(antecedentElem,wmElem);
									ArrayList<ArrayList<RuleVariableValue>> list = htRulesValues.get(ruleId);
									//only analyse unmapped variable with a different value from previous cases  
									if (!isVariableAlreadyMappedToGivenValue(list, antecedentElem,wmElem)){
										ArrayList<RuleVariableValue> ruleVariableValues;
										if (list!=null){
											//get the next branch
											branchId = getBranchIndex(list, antecedentElem);
											if (list.size()-1 < branchId){
												//add branching for a rule
												ruleVariableValues = new ArrayList<RuleVariableValue>();
												ruleVariableValues.add(ruleVariableValue);
												list.add((ArrayList<RuleVariableValue>) ruleVariableValues);
											}
											else{
												//update an existing branch of a rule
												ruleVariableValues = list.get(branchId); 
												if (ruleVariableValues!=null){
													//There is at least one variable set in this rule... update
													ruleVariableValues.add(ruleVariableValue);
													htRulesValues.remove(ruleId);
												}
											}
										}
										else{
											//Create a new entry in the current rule
											ruleVariableValues = new ArrayList<RuleVariableValue>();
											ruleVariableValues.add(ruleVariableValue);
											list = new ArrayList<ArrayList<RuleVariableValue>>();
											list.add((ArrayList<RuleVariableValue>) ruleVariableValues);
										}
										htRulesValues.put(ruleId,list);
									}
								}
							}
						}
					}
				}
				if (htRulesValues.size() >0){
					//All variables have been unified, so we can use this use
					if (htRulesValues.get(ruleId).get(0).size() == rule.getAntecedentUniqueVariablesCount() &&
						isVariablesValueUnique(htRulesValues.get(ruleId).get(0))){
						//Furthermore this rule has not been triggered in the past... so use it...else we could have an infinite loop
						if (!visitedRuleIds.contains(ruleId)){
							visitedRuleIds.add(ruleId);
							return ruleId;
						}
					}
					else{
						//Unification has failed for this rule, remove the rule
						htRulesValues.remove(ruleId);
					}
				}
			}
			return ruleIdNotFound;
		}
		
		private int matchWorkingMemoryWithAntecedent(Rule rule, WorkingMemory workingMemory){
			Integer ruleId = rule.getId();
			//If no variable in antecedent list, then 
			//check all items are present in the WM.
			//if 'yes' return the rule, else 'continue'
			if (rule.getAntecedentUniqueVariablesCount() == 0){
				for (Fact antecedent : rule.getAntecedents()){
					for (Fact fact : workingMemory.getFacts()){
						if (antecedent.getRawLabels().equals(fact.getRawLabels())){
							if (!visitedRuleIds.contains(ruleId)){
								visitedRuleIds.add(ruleId);
								return ruleId;
							}
							else
								return ruleIdNotFound;
						}
					}
				}
				//the antecedent is not in the WM... continue
				return ruleIdNotFound;
			}
			
			return ruleIdNotFound;
		}
		
		//Replace all instance of variable name in an item list by a given value 
		private void replaceVariableByConstant (	String variableName, 
													String constantValue,
													Rule rule){
	
			//replace the antecedent variable with corresponding value
			for (int i=0; i<rule.getAntecedents().size(); i++){
				Fact antecedent = rule.getAntecedents().get(i).deepCopy();
				for (int j=0; j<antecedent.items.size(); j++){
					Item item = antecedent.items.get(j).deepCopy();
					String label = item.getLabel().replace(variableName, constantValue);
					rule.getAntecedents().get(i).items.get(j).setLabel(label);
					print( "Rule Id: " + rule.getId() + " - " +
						   "Antecedent " + label + " - " + 
							variableName + " set to " + constantValue);
				}
			}
	
			//replace the consequent variable with corresponding value
			for (int i=0; i<rule.getConsequent().getItems().size();i++){
				Item item = rule.getConsequent().getItems().get(i).deepCopy();
				String label = item.getLabel();
				if (label.contains(variableName)){
					label = label.replace(variableName, constantValue);
					item.setLabel(label);
					rule.getConsequent().getItems().get(i).setLabel(label);
					print( "Rule Id: " + rule.getId() + " - " +
						   "Consequent " + label + " - " + 
							variableName + " set to " + constantValue);
				}
			}
		}		
	}
	
	public class Rule{
		private Integer id;
		private List<Fact> antecedents;
		private Consequent consequent;
		
		public Rule (Integer id, List<Fact> antecedents, Consequent consequent){
			this.id = id;
			this.antecedents = antecedents;
			this.consequent = consequent;
		}
		
		public Integer getId() {return this.id;}
		public List<Fact> getAntecedents() {return this.antecedents;}
		public Consequent getConsequent() {return this.consequent;}
		
		public void setAntecedents(List<Fact> antecedents){this.antecedents=antecedents;}
		
		public String getLabels()
		{
			StringBuilder sb = new StringBuilder();
			sb.append("RuleId :  ");
			sb.append(this.id);
			sb.append(" ");
			sb.append("Antecedent List:  ");
			for (int i = 0; i< this.antecedents.size();i++){
				sb.append(this.antecedents.get(i).getLabels());
			}
			sb.append("Consequent List:  ");
			for (int i = 0; i< this.consequent.getItems().size();i++){
				sb.append(this.consequent.getItems().get(i).getLabel());
				sb.append(" ");				
			}
			return sb.toString();
		}
		
		public int getAntecedentUniqueVariablesCount(){
			return getAntecedentUniqueVariables().size();
		}
		
		@SuppressWarnings({ "rawtypes", "unchecked" })
		public Set getAntecedentUniqueVariables(){
			Set finalSet = new HashSet();
			for (int j=0; j< this.antecedents.size(); j++){
				Fact fact = this.antecedents.get(j);
				String[] splits = fact.getLabels().split(" ");
				for (int k=0; k<splits.length; k++){
					String split = splits[k].toString();
					if (split.contains("?")){
						finalSet.add(split);
					}
				}
			}
			return finalSet;
		}
		
		public Rule deepCopy(){
			
			List<Fact> antecedentsDeepCopy = new ArrayList<Fact>();
			for (Fact a : antecedents){
				antecedentsDeepCopy.add(a.deepCopy());
			}
			
			return new Rule(this.id, antecedentsDeepCopy, this.consequent.deepCopy());
		}
	}
	
	public static class Fact{
		private Integer id;
		private List<Item> items;
		
		public static Boolean areEqual(Fact fact1, Fact fact2){
			List<Item> fact1Items = fact1.getItems();
			int fact1Size = fact1Items.size();
			//check the items have the same id
			for (int k = 0; k<fact1Size;k++){
				//the
				if (fact1Items.get(k).getLabel().equals(fact2.getItems().get(k).getLabel())){
					return true;
				}
			}
			return false;
		}
		
		public Fact (Integer id, List<Item> Items){
			this(id, Items, false);	
		}
		
		public Fact (Integer id, List<Item> items, Boolean proven){
			this.id = id;
			this.items = items;
			display();
		}

		public Integer getId() {return this.id;}
		public List<Item> getItems() {return this.items;}
				
		public String getLabels()
		{
			StringBuilder sb = new StringBuilder();
			sb.append("(");
			for (int i=0; i < this.items.size() ;i++){
				sb.append(" ");
				sb.append(items.get(i).getLabel());
				sb.append(" ");
			}
			sb.append(") ");
			
			return sb.toString();
		}
		
		public String getLabelsNoAction()
		{
			return this.getLabels(); 
		}
				
		public String getRawLabels()
		{
			StringBuilder sb = new StringBuilder();
			for (int i=0; i < this.items.size() ;i++)
			{
				sb.append(this.items.get(i).getLabel());
				sb.append(" ");
			}
			return sb.toString();
		}
		
		protected void display() {
			print("Fact - key: " + id +" - label: " + this.getLabels());
		}
		
		public Fact deepCopy(){
			List<Item> itemsDeepCopy = new ArrayList<Item>();
			for (Item a : this.items){
				itemsDeepCopy.add(a.deepCopy());
			}
			return new Fact(this.id, itemsDeepCopy);
		}
	}
	
	public class Consequent extends Fact {

		public Consequent (Integer id, List<Item> items){
			super(id, items, false);
		}
		
		public String getLabels()
		{
			StringBuilder sb = new StringBuilder();
			for (int i=0; i < super.items.size();i++){
				Item item =  super.items.get(i);
				sb.append(item.getAction());
				sb.append(" ( ");
				sb.append(item.getLabel());
				sb.append(" ) ");
				if (i<super.items.size()-1){
					sb.append("& ");
				}
			}
			return sb.toString();
		}
		
		public String getLabelsNoAction()
		{
			return super.getLabels(); 
		}
		
		protected void display() {
			print("Consequent - key: " + super.getId() +" - label: " + this.getLabels());
		}
		
		public Consequent deepCopy(){
			List<Item> itemsDeepCopy = new ArrayList<Item>();
			for (Item i : super.items){
				itemsDeepCopy.add(i.deepCopy());
			}
			return new Consequent(super.id, itemsDeepCopy);
		}
	}
	
	public class Goal extends Fact{ 
		
		public Goal (Integer id, List<Item> items){
			super(id, items);
		}
		
		protected void display() {
			print("Goal (or Sub Goal) - key: " + super.getId() +" - label: " + super.getLabels());
		}
	}
	
	public class Item{
		
		private Integer id;
		private String label;
		private Action action;
		
		public Item (Action action, Integer id, String label){
			
			this.id = id;
			this.label = label;
			this.action = action;
		}
		
		public Item (Integer id, String label){
			this (Action.NONE, id, label);
		}
		
		public Integer getId() {return this.id;}
		public String getLabel(){return this.label;}
		public void setLabel(String label){this.label = label;}
		public Action getAction(){return this.action;}	
		
		public Item deepCopy(){
			return new Item(this.action, this.id, this.label);
		}
	}
	
	public class RuleVariableValue {
		
		String variableName;
		String variableValue;
		
		public RuleVariableValue(String variableName, String variableValue){
			this.variableName = variableName;
			this.variableValue = variableValue;
		}
		
		public String getVariableName(){
			return this.variableName;
		}
		
		public String getVariableValue(){
			return this.variableValue;
		}
		
		public RuleVariableValue deepCopy(){
			return new RuleVariableValue(this.variableName, this.variableValue);
		}
	}
	
	public class RuleVariableValueCount {
		
		RuleVariableValue ruleVariableValue;
		int count;
		
		public RuleVariableValueCount(RuleVariableValue ruleVariableValue, int count){
			this.ruleVariableValue = ruleVariableValue;
			this.count = count;
		}
		
		public RuleVariableValue getRuleVariableValue(){
			return this.ruleVariableValue;
		}
		
		public Integer getCount(){
			return this.count;
		}
		
		public String toString(){
			return this.ruleVariableValue.getVariableName() + "=" + this.ruleVariableValue.getVariableValue();
		}
		

	}
	
	public static class InferenceEngineInputTuple {
	
		Goal goal;
		RuleBase ruleBase;
		WorkingMemory workingMemory;
	
		public InferenceEngineInputTuple(RuleBase ruleBase, WorkingMemory workingMemory){
			this.ruleBase = ruleBase;
			this.workingMemory = workingMemory;
		}
		
		public RuleBase getRuleBase(){
			return this.ruleBase;
		}
		
		public WorkingMemory getWorkingMemory(){
			return this.workingMemory;
		}
	}
		
	public enum Action {
		NONE,
	    ADD,
	    DELETE
	}
}
